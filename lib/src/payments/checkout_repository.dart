import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart' hide Order;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/models.dart';
import '../data/repositories.dart';
import 'payment_gateway.dart';

/// Thrown when the listing has fewer tickets left than ordered.
class SoldOutException implements Exception {}

/// Creates orders and records their payment.
///
/// In test mode the app does this itself, guarded by the Firestore rules.
/// With real Stripe the server takes over [completePayment] (webhook) and
/// [markTicketsSent] stays a seller action.
abstract class CheckoutRepository {
  /// Creates an order awaiting payment.
  Future<Order> createOrder({
    required Listing listing,
    required int quantity,
    required String buyerId,
  });

  /// Marks the order paid (and takes the tickets off the listing and starts
  /// the seller's payout) or cancelled. Throws [SoldOutException].
  Future<void> completePayment(Order order, PaymentOutcome outcome);

  Future<void> markTicketsSent(Order order);
}

String newOrderNumber() {
  const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
  final r = Random.secure();
  return 'SSW-${[for (var i = 0; i < 6; i++) chars[r.nextInt(chars.length)]].join()}';
}

/// When the seller is paid: a few days after the event.
DateTime expectedPayoutDate(DateTime eventDate) =>
    eventDate.add(const Duration(days: 5));

class FirestoreCheckoutRepository implements CheckoutRepository {
  FirestoreCheckoutRepository(this._db);
  final FirebaseFirestore _db;

  DocumentReference<Map<String, dynamic>> _order(String id) =>
      _db.collection('orders').doc(id);
  DocumentReference<Map<String, dynamic>> _listing(String id) =>
      _db.collection('listings').doc(id);

  Map<String, Object> _step(OrderStatus s) => {
    'status': s.name,
    'at': Timestamp.now(),
  };

  @override
  Future<Order> createOrder({
    required Listing listing,
    required int quantity,
    required String buyerId,
  }) async {
    final ref = _db.collection('orders').doc();
    final data = <String, dynamic>{
      'number': newOrderNumber(),
      'listingId': listing.id,
      'buyerId': buyerId,
      'sellerId': listing.sellerId,
      'event': listing.event.toMap(),
      'quantity': quantity,
      'unitPriceMinor': listing.priceMinor,
      'currency': listing.currency,
      'ticketType': listing.ticketType.name,
      'section': listing.section,
      'row': listing.row,
      'seats': listing.seats,
      'status': OrderStatus.pendingPayment.name,
      'history': [_step(OrderStatus.pendingPayment)],
      'testMode': true,
      'createdAt': Timestamp.now(),
    };
    await ref.set(data);
    return Order.fromMap(ref.id, {
      ...data,
      'createdAt': DateTime.now(),
      'history': [
        {'status': OrderStatus.pendingPayment.name, 'at': DateTime.now()},
      ],
    });
  }

  @override
  Future<void> completePayment(Order order, PaymentOutcome outcome) async {
    switch (outcome) {
      case PaymentCancelled():
        return;
      case PaymentFailed(:final reason):
        await _order(order.id).update({
          'status': OrderStatus.cancelled.name,
          'failureReason': reason.name,
          'history': FieldValue.arrayUnion([_step(OrderStatus.cancelled)]),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      case PaymentSucceeded(:final paymentId, :final methodLabel):
        // One transaction, so the rules can check that tickets, order and
        // payout change together.
        await _db.runTransaction((tx) async {
          final listingSnap = await tx.get(_listing(order.listingId));
          final listing = listingSnap.data();
          final sold = (listing?['quantitySold'] as num?)?.toInt() ?? 0;
          final total = (listing?['quantity'] as num?)?.toInt() ?? 0;
          if (listing == null || sold + order.quantity > total) {
            throw SoldOutException();
          }
          final nowSold = sold + order.quantity;
          tx
            ..update(_order(order.id), {
              'status': OrderStatus.paid.name,
              'paymentId': paymentId,
              'paymentMethod': methodLabel,
              'history': FieldValue.arrayUnion([_step(OrderStatus.paid)]),
              'updatedAt': FieldValue.serverTimestamp(),
            })
            ..update(_listing(order.listingId), {
              'quantitySold': nowSold,
              'status': nowSold == total
                  ? ListingStatus.soldOut.name
                  : listing['status'],
              'lastOrderId': order.id,
              'updatedAt': FieldValue.serverTimestamp(),
            })
            ..set(_db.collection('payouts').doc(order.id), {
              'sellerId': order.sellerId,
              'orderId': order.id,
              'orderNumbers': [order.number],
              'amountMinor': order.sellerEarningsMinor,
              'currency': order.currency,
              'status': PayoutStatus.pending.name,
              'expectedAt': Timestamp.fromDate(
                expectedPayoutDate(order.event.date),
              ),
              'history': [
                {'status': PayoutStatus.pending.name, 'at': Timestamp.now()},
              ],
              'testMode': true,
              'createdAt': Timestamp.now(),
            });
        });
    }
  }

  @override
  Future<void> markTicketsSent(Order order) => _order(order.id).update({
    'status': OrderStatus.ticketsSent.name,
    'history': FieldValue.arrayUnion([_step(OrderStatus.ticketsSent)]),
    'updatedAt': FieldValue.serverTimestamp(),
  });
}

final checkoutRepositoryProvider = Provider<CheckoutRepository>((ref) {
  // In-memory markets (tests) handle checkout themselves.
  final MarketRepository market = ref.watch(marketRepositoryProvider);
  if (market case final CheckoutRepository checkout) return checkout;
  return FirestoreCheckoutRepository(ref.watch(firestoreProvider));
});
