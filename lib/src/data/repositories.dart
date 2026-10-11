import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart' hide Order;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../auth/auth_repository.dart';
import 'models.dart';

/// Thrown when a username is already taken.
class UsernameTakenException implements Exception {}

abstract class ProfileRepository {
  Stream<UserProfile?> watchProfile(String uid);

  /// Creates the profile document on first sign-in.
  Future<void> ensureProfile(AppUser user);
  Future<void> updateDisplayName(String uid, String name);

  /// Reserves [username] for [uid] and releases the previous one.
  Future<void> setUsername(String uid, String username);
  Future<void> setPhoto(String uid, String? base64Jpeg);
  Future<void> setVisibility(String uid, ProfileVisibility visibility);
  Future<void> setNotifications(String uid, NotificationPrefs prefs);

  /// Removes all of the user's own documents (before the account goes).
  Future<void> deleteUserData(String uid);
}

abstract class MarketRepository {
  Stream<List<Listing>> watchActiveListings();
  Stream<List<Listing>> watchMyListings(String uid);
  Stream<Listing?> watchListing(String id);
  Future<String> createListing(Listing listing);
  Future<void> updateListingPrice(String id, int priceMinor);
  Future<void> withdrawListing(String id);

  Stream<List<Order>> watchPurchases(String uid);
  Stream<List<Order>> watchSales(String uid);
  Stream<Order?> watchOrder(String id);

  Stream<List<Payout>> watchPayouts(String uid);
  Stream<Payout?> watchPayout(String id);

  Future<ProfileStats> loadStats(String uid);

  Stream<PayoutMethod?> watchPayoutMethod(String uid);
  Future<void> setPayoutMethod(String uid, PayoutMethod method);

  Future<String> createSupportRequest({
    required String uid,
    required String email,
    required SupportTopic topic,
    required String reference,
    required String message,
  });
}

// ---------------------------------------------------------------------------
// Firestore
// ---------------------------------------------------------------------------

/// Converts Firestore Timestamps to DateTime, recursively.
Object? _plain(Object? value) => switch (value) {
  Timestamp t => t.toDate(),
  Map m => {for (final e in m.entries) e.key as String: _plain(e.value)},
  List l => [for (final e in l) _plain(e)],
  _ => value,
};

Map<String, dynamic> _data(DocumentSnapshot<Map<String, dynamic>> doc) =>
    _plain(doc.data()) as Map<String, dynamic>;

int _byNewest(DateTime? a, DateTime? b) =>
    (b ?? DateTime(0)).compareTo(a ?? DateTime(0));

class FirestoreProfileRepository implements ProfileRepository {
  FirestoreProfileRepository(this._db);
  final FirebaseFirestore _db;

  DocumentReference<Map<String, dynamic>> _user(String uid) =>
      _db.collection('users').doc(uid);
  DocumentReference<Map<String, dynamic>> _public(String uid) =>
      _db.collection('publicProfiles').doc(uid);

  @override
  Stream<UserProfile?> watchProfile(String uid) =>
      _user(uid)
          .snapshots()
          .map((d) => d.exists ? UserProfile.fromMap(uid, _data(d)) : null);

  @override
  Future<void> ensureProfile(AppUser user) async {
    final ref = _user(user.uid);
    final snap = await ref.get();
    if (snap.exists) return;
    final batch = _db.batch()
      ..set(ref, {
        'displayName': user.displayName,
        'email': user.email,
        'visibility': ProfileVisibility.public.name,
        'notifications': const NotificationPrefs().toMap(),
        'createdAt': FieldValue.serverTimestamp(),
      })
      ..set(_public(user.uid), {
        'displayName': user.displayName,
        'visibility': ProfileVisibility.public.name,
      });
    await batch.commit();
  }

  /// Writes fields to the private profile and, where they are public, to the
  /// public profile.
  Future<void> _update(
    String uid,
    Map<String, dynamic> fields, {
    Map<String, dynamic> public = const {},
  }) {
    final batch = _db.batch()..set(_user(uid), fields, SetOptions(merge: true));
    if (public.isNotEmpty) {
      batch.set(_public(uid), public, SetOptions(merge: true));
    }
    return batch.commit();
  }

  @override
  Future<void> updateDisplayName(String uid, String name) =>
      _update(uid, {'displayName': name}, public: {'displayName': name});

  @override
  Future<void> setUsername(String uid, String username) async {
    final name = username.toLowerCase();
    await _db.runTransaction((tx) async {
      final user = await tx.get(_user(uid));
      final taken = await tx.get(_db.collection('usernames').doc(name));
      if (taken.exists && taken.data()?['uid'] != uid) {
        throw UsernameTakenException();
      }
      final previous = user.data()?['username'] as String?;
      if (previous != null && previous != name) {
        tx.delete(_db.collection('usernames').doc(previous));
      }
      tx
        ..set(_db.collection('usernames').doc(name), {'uid': uid})
        ..set(_user(uid), {'username': name}, SetOptions(merge: true))
        ..set(_public(uid), {'username': name}, SetOptions(merge: true));
    });
  }

  @override
  Future<void> setPhoto(String uid, String? base64Jpeg) =>
      _update(uid, {'photo': base64Jpeg}, public: {'photo': base64Jpeg});

  @override
  Future<void> setVisibility(String uid, ProfileVisibility visibility) =>
      _update(
        uid,
        {'visibility': visibility.name},
        public: {'visibility': visibility.name},
      );

  @override
  Future<void> setNotifications(String uid, NotificationPrefs prefs) =>
      _update(uid, {'notifications': prefs.toMap()});

  @override
  Future<void> deleteUserData(String uid) async {
    final user = await _user(uid).get();
    final username = user.data()?['username'] as String?;
    final batch = _db.batch()
      ..delete(_user(uid))
      ..delete(_public(uid))
      ..delete(_user(uid).collection('private').doc('payoutMethod'));
    if (username != null) {
      batch.delete(_db.collection('usernames').doc(username));
    }
    await batch.commit();
  }
}

class FirestoreMarketRepository implements MarketRepository {
  FirestoreMarketRepository(this._db);
  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> get _listings =>
      _db.collection('listings');
  CollectionReference<Map<String, dynamic>> get _orders =>
      _db.collection('orders');
  CollectionReference<Map<String, dynamic>> get _payouts =>
      _db.collection('payouts');

  // Queries filter on one field only and sort on the device, so Firestore
  // needs no composite indexes.

  List<Listing> _listingList(QuerySnapshot<Map<String, dynamic>> q) => [
    for (final d in q.docs) Listing.fromMap(d.id, _data(d)),
  ];

  List<Order> _orderList(QuerySnapshot<Map<String, dynamic>> q) =>
      [for (final d in q.docs) Order.fromMap(d.id, _data(d))]
        ..sort((a, b) => _byNewest(a.createdAt, b.createdAt));

  @override
  Stream<List<Listing>> watchActiveListings() => _listings
      .where('status', isEqualTo: ListingStatus.active.name)
      .limit(100)
      .snapshots()
      .map(
        (q) =>
            _listingList(q)
                .where((l) => l.event.date.isAfter(DateTime.now()))
                .toList()
              ..sort((a, b) => a.event.date.compareTo(b.event.date)),
      );

  @override
  Stream<List<Listing>> watchMyListings(String uid) => _listings
      .where('sellerId', isEqualTo: uid)
      .snapshots()
      .map(
        (q) =>
            _listingList(q)
              ..sort((a, b) => _byNewest(a.createdAt, b.createdAt)),
      );

  @override
  Stream<Listing?> watchListing(String id) => _listings
      .doc(id)
      .snapshots()
      .map((d) => d.exists ? Listing.fromMap(d.id, _data(d)) : null);

  @override
  Future<String> createListing(Listing listing) async {
    final ref = await _listings.add({
      ...listing.toMap(),
      'status': ListingStatus.active.name,
      'quantitySold': 0,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
    return ref.id;
  }

  @override
  Future<void> updateListingPrice(String id, int priceMinor) =>
      _listings.doc(id).update({
        'priceMinor': priceMinor,
        'updatedAt': FieldValue.serverTimestamp(),
      });

  @override
  Future<void> withdrawListing(String id) => _listings.doc(id).update({
    'status': ListingStatus.withdrawn.name,
    'updatedAt': FieldValue.serverTimestamp(),
  });

  @override
  Stream<List<Order>> watchPurchases(String uid) =>
      _orders.where('buyerId', isEqualTo: uid).snapshots().map(_orderList);

  @override
  Stream<List<Order>> watchSales(String uid) =>
      _orders.where('sellerId', isEqualTo: uid).snapshots().map(_orderList);

  @override
  Stream<Order?> watchOrder(String id) => _orders
      .doc(id)
      .snapshots()
      .map((d) => d.exists ? Order.fromMap(d.id, _data(d)) : null);

  @override
  Stream<List<Payout>> watchPayouts(String uid) => _payouts
      .where('sellerId', isEqualTo: uid)
      .snapshots()
      .map(
        (q) =>
            [for (final d in q.docs) Payout.fromMap(d.id, _data(d))]
              ..sort((a, b) => _byNewest(a.createdAt, b.createdAt)),
      );

  @override
  Stream<Payout?> watchPayout(String id) => _payouts
      .doc(id)
      .snapshots()
      .map((d) => d.exists ? Payout.fromMap(d.id, _data(d)) : null);

  @override
  Future<ProfileStats> loadStats(String uid) async {
    final results = await Future.wait([
      _listings.where('sellerId', isEqualTo: uid).get(),
      _orders.where('sellerId', isEqualTo: uid).get(),
      _orders.where('buyerId', isEqualTo: uid).get(),
    ]);
    int tickets(QuerySnapshot<Map<String, dynamic>> q) => q.docs
        .map((d) => Order.fromMap(d.id, _data(d)))
        .where((o) => _countsAsSold(o.status))
        .fold<int>(0, (total, o) => total + o.quantity);
    return ProfileStats(
      listed: _listingList(results[0])
          .where((l) => l.status != ListingStatus.withdrawn)
          .fold<int>(0, (total, l) => total + l.quantity),
      sold: tickets(results[1]),
      bought: tickets(results[2]),
    );
  }

  @override
  Stream<PayoutMethod?> watchPayoutMethod(String uid) => _db
      .collection('users')
      .doc(uid)
      .collection('private')
      .doc('payoutMethod')
      .snapshots()
      .map((d) => d.exists ? PayoutMethod.fromMap(_data(d)) : null);

  @override
  Future<void> setPayoutMethod(String uid, PayoutMethod method) => _db
      .collection('users')
      .doc(uid)
      .collection('private')
      .doc('payoutMethod')
      .set({...method.toMap(), 'updatedAt': FieldValue.serverTimestamp()});

  @override
  Future<String> createSupportRequest({
    required String uid,
    required String email,
    required SupportTopic topic,
    required String reference,
    required String message,
  }) async {
    final number = 'SUP-${_randomCode(6)}';
    await _db.collection('supportRequests').add({
      'number': number,
      'uid': uid,
      'email': email,
      'topic': topic.name,
      'reference': reference,
      'message': message,
      'status': 'open',
      'createdAt': FieldValue.serverTimestamp(),
    });
    return number;
  }
}

/// Orders that count as a completed sale or purchase.
bool _countsAsSold(OrderStatus s) => const {
  OrderStatus.paid,
  OrderStatus.ticketsSent,
  OrderStatus.completed,
  OrderStatus.disputed,
}.contains(s);

String _randomCode(int length) {
  const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
  final r = Random.secure();
  return [for (var i = 0; i < length; i++) chars[r.nextInt(chars.length)]]
      .join();
}

// ---------------------------------------------------------------------------
// Providers
// ---------------------------------------------------------------------------

final firestoreProvider = Provider<FirebaseFirestore>(
  (ref) => FirebaseFirestore.instance,
);

final profileRepositoryProvider = Provider<ProfileRepository>(
  (ref) => FirestoreProfileRepository(ref.watch(firestoreProvider)),
);

final marketRepositoryProvider = Provider<MarketRepository>(
  (ref) => FirestoreMarketRepository(ref.watch(firestoreProvider)),
);

/// The signed-in user's uid, or null.
final currentUidProvider = Provider<String?>(
  (ref) => ref.watch(authStateProvider).value?.uid,
);

final profileProvider = StreamProvider<UserProfile?>((ref) {
  final uid = ref.watch(currentUidProvider);
  if (uid == null) return Stream.value(null);
  return ref.watch(profileRepositoryProvider).watchProfile(uid);
});

final statsProvider = FutureProvider<ProfileStats?>((ref) {
  final uid = ref.watch(currentUidProvider);
  if (uid == null) return null;
  return ref.watch(marketRepositoryProvider).loadStats(uid);
});

Stream<T> _forUser<T>(Ref ref, T empty, Stream<T> Function(String uid) f) {
  final uid = ref.watch(currentUidProvider);
  return uid == null ? Stream.value(empty) : f(uid);
}

final activeListingsProvider = StreamProvider<List<Listing>>(
  (ref) => ref.watch(marketRepositoryProvider).watchActiveListings(),
);

final myListingsProvider = StreamProvider<List<Listing>>(
  (ref) => _forUser(
    ref,
    const <Listing>[],
    ref.watch(marketRepositoryProvider).watchMyListings,
  ),
);

final purchasesProvider = StreamProvider<List<Order>>(
  (ref) => _forUser(
    ref,
    const <Order>[],
    ref.watch(marketRepositoryProvider).watchPurchases,
  ),
);

final salesProvider = StreamProvider<List<Order>>(
  (ref) => _forUser(
    ref,
    const <Order>[],
    ref.watch(marketRepositoryProvider).watchSales,
  ),
);

final payoutsProvider = StreamProvider<List<Payout>>(
  (ref) => _forUser(
    ref,
    const <Payout>[],
    ref.watch(marketRepositoryProvider).watchPayouts,
  ),
);

final payoutMethodProvider = StreamProvider<PayoutMethod?>(
  (ref) => _forUser(
    ref,
    null,
    ref.watch(marketRepositoryProvider).watchPayoutMethod,
  ),
);

final listingProvider = StreamProvider.family<Listing?, String>(
  (ref, id) => ref.watch(marketRepositoryProvider).watchListing(id),
);

final orderProvider = StreamProvider.family<Order?, String>(
  (ref, id) => ref.watch(marketRepositoryProvider).watchOrder(id),
);

final payoutProvider = StreamProvider.family<Payout?, String>(
  (ref, id) => ref.watch(marketRepositoryProvider).watchPayout(id),
);

/// Creates the profile document when a user signs in. Watched by the app.
final profileBootstrapProvider = Provider<void>((ref) {
  ref.listen(authStateProvider, (_, next) {
    final user = next.value;
    if (user == null) return;
    ref
        .read(profileRepositoryProvider)
        .ensureProfile(user)
        // Without Firestore the app still works from the auth data.
        .catchError((Object _) {});
  }, fireImmediately: true);
});
