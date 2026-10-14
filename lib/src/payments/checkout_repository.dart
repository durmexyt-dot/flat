import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart' hide Order;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/models.dart';
import '../data/repositories.dart';
import 'payment_gateway.dart';

/// Thrown when the listing has fewer tickets left than ordered.
class SoldOutException implements Exception {}

/// Thrown when someone tries to buy their own listing.
class OwnListingException implements Exception {}

/// Thrown when the 15 minutes to pay are over: the tickets were released.
class ReservationExpiredException implements Exception {}

/// Whether the time to pay for [order] is over.
bool reservationExpired(Order order, [DateTime? now]) {
  final until = order.reservedUntil;
  return until != null && (now ?? DateTime.now()).isAfter(until);
}

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

  /// The seller hands over mobile or paper tickets as [handover] says.
  Future<void> markTicketsSent(Order order, TicketHandover handover);

  /// The buyer confirms having the mobile or paper tickets.
  Future<void> confirmReceipt(Order order);

  /// The seller cancels a sale before it is completed: the buyer gets the
  /// money back, the tickets go back on sale and the payout is dropped.
  /// Buyers can't cancel; they contact support.
  Future<void> cancelSale(Order order);
}

/// Statuses in which the seller can still cancel the sale.
bool canSellerCancel(OrderStatus s) =>
    s == OrderStatus.paid || s == OrderStatus.ticketsSent;

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
    if (listing.sellerId == buyerId) throw OwnListingException();
    final ref = _db.collection('orders').doc();
    final data = <String, dynamic>{
      'number': newOrderNumber(),
      'listingId': listing.id,
      'buyerId': buyerId,
      'sellerId': listing.sellerId,
      'event': listing.event.toMap(),
      'buyerFeePercent': listing.fees.buyerPercent,
      'sellerFeePercent': listing.fees.sellerPercent,
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
      // Held for the buyer for 15 minutes, counted from the server's time.
      'reserved': true,
      'createdAt': FieldValue.serverTimestamp(),
    };
    // The order and the hold on its tickets in one write: the rules check
    // that they go together.
    await (_db.batch()
          ..set(ref, data)
          ..update(_listing(listing.id), {
            'quantityReserved': FieldValue.increment(quantity),
            'lastOrderId': ref.id,
            'updatedAt': FieldValue.serverTimestamp(),
          }))
        .commit();
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
        // The order ends and its held tickets are free again, together.
        await _db.runTransaction((tx) async {
          final listingSnap = await tx.get(_listing(order.listingId));
          final held =
              (listingSnap.data()?['quantityReserved'] as num?)?.toInt() ?? 0;
          tx.update(_order(order.id), {
            'status': OrderStatus.cancelled.name,
            'failureReason': reason.name,
            'history': FieldValue.arrayUnion([_step(OrderStatus.cancelled)]),
            'updatedAt': FieldValue.serverTimestamp(),
          });
          if (order.reserved) {
            tx.update(_listing(order.listingId), {
              'quantityReserved': held >= order.quantity
                  ? held - order.quantity
                  : 0,
              'lastOrderId': order.id,
              'updatedAt': FieldValue.serverTimestamp(),
            });
          }
        });
      case PaymentSucceeded(:final paymentId, :final methodLabel):
        if (reservationExpired(order)) throw ReservationExpiredException();
        // One transaction, so the rules can check that tickets, order and
        // payout change together.
        await _db.runTransaction((tx) async {
          final listingSnap = await tx.get(_listing(order.listingId));
          final listing = listingSnap.data();
          final sold = (listing?['quantitySold'] as num?)?.toInt() ?? 0;
          final total = (listing?['quantity'] as num?)?.toInt() ?? 0;
          final held = (listing?['quantityReserved'] as num?)?.toInt() ?? 0;
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
              // The tickets were held for this order; now they are sold.
              'quantityReserved': !order.reserved
                  ? held
                  : held >= order.quantity
                  ? held - order.quantity
                  : 0,
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
  Future<void> markTicketsSent(Order order, TicketHandover handover) =>
      _order(order.id).update({
        'status': OrderStatus.ticketsSent.name,
        'handover': {
          ...handover.toMap(),
          'sentAt': FieldValue.serverTimestamp(),
        },
        'history': FieldValue.arrayUnion([_step(OrderStatus.ticketsSent)]),
        'updatedAt': FieldValue.serverTimestamp(),
      });

  @override
  Future<void> confirmReceipt(Order order) => _order(order.id).update({
    'handover.confirmedAt': FieldValue.serverTimestamp(),
    'updatedAt': FieldValue.serverTimestamp(),
  });

  @override
  Future<void> cancelSale(Order order) async {
    // One transaction, so the rules can check that order, tickets and payout
    // change together.
    await _db.runTransaction((tx) async {
      final orderSnap = await tx.get(_order(order.id));
      final listingSnap = await tx.get(_listing(order.listingId));
      final current = enumByName(
        OrderStatus.values,
        orderSnap.data()?['status'] as String?,
        OrderStatus.pendingPayment,
      );
      final listing = listingSnap.data();
      if (!canSellerCancel(current) || listing == null) {
        throw StateError('Sale can no longer be cancelled');
      }
      final sold = (listing['quantitySold'] as num?)?.toInt() ?? 0;
      tx
        ..update(_order(order.id), {
          'status': OrderStatus.refunded.name,
          'cancelledBy': 'seller',
          'history': FieldValue.arrayUnion([_step(OrderStatus.refunded)]),
          'updatedAt': FieldValue.serverTimestamp(),
        })
        // The tickets are for sale again; a sold-out listing reopens.
        ..update(_listing(order.listingId), {
          'quantitySold': sold - order.quantity,
          'status': listing['status'] == ListingStatus.soldOut.name
              ? ListingStatus.active.name
              : listing['status'],
          'lastOrderId': order.id,
          'updatedAt': FieldValue.serverTimestamp(),
        })
        ..delete(_db.collection('payouts').doc(order.id));
    });
  }
}

final checkoutRepositoryProvider = Provider<CheckoutRepository>((ref) {
  // In-memory markets (tests) handle checkout themselves.
  final MarketRepository market = ref.watch(marketRepositoryProvider);
  if (market case final CheckoutRepository checkout) return checkout;
  return FirestoreCheckoutRepository(ref.watch(firestoreProvider));
});
