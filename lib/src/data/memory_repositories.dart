import 'dart:async';

import '../auth/auth_repository.dart';
import 'models.dart';
import 'repositories.dart';

/// Keeps a value and emits it to listeners, starting with the current one.
class _Store<T> {
  _Store(this._value);
  T _value;
  final _changes = StreamController<T>.broadcast();

  T get value => _value;
  set value(T v) {
    _value = v;
    _changes.add(v);
  }

  Stream<T> watch() async* {
    yield _value;
    yield* _changes.stream;
  }
}

/// Profiles held in memory, for tests.
class InMemoryProfileRepository implements ProfileRepository {
  final _profiles = <String, _Store<UserProfile?>>{};
  final _usernames = <String, String>{};

  _Store<UserProfile?> _store(String uid) =>
      _profiles.putIfAbsent(uid, () => _Store(null));

  void _edit(String uid, UserProfile Function(UserProfile p) f) {
    final store = _store(uid);
    store.value = f(store.value ?? UserProfile(uid: uid));
  }

  @override
  Stream<UserProfile?> watchProfile(String uid) => _store(uid).watch();

  @override
  Future<void> ensureProfile(AppUser user) async {
    if (_store(user.uid).value != null) return;
    _store(user.uid).value = UserProfile(
      uid: user.uid,
      displayName: user.displayName,
      email: user.email,
      createdAt: DateTime.now(),
    );
  }

  UserProfile _copy(
    UserProfile p, {
    String? displayName,
    String? username,
    String? photo,
    bool clearPhoto = false,
    ProfileVisibility? visibility,
    NotificationPrefs? notifications,
  }) => UserProfile(
    uid: p.uid,
    displayName: displayName ?? p.displayName,
    username: username ?? p.username,
    email: p.email,
    photoBase64: clearPhoto ? null : (photo ?? p.photoBase64),
    visibility: visibility ?? p.visibility,
    notifications: notifications ?? p.notifications,
    createdAt: p.createdAt,
  );

  @override
  Future<void> updateDisplayName(String uid, String name) async =>
      _edit(uid, (p) => _copy(p, displayName: name));

  @override
  Future<void> setUsername(String uid, String username) async {
    final name = username.toLowerCase();
    final owner = _usernames[name];
    if (owner != null && owner != uid) throw UsernameTakenException();
    _usernames.removeWhere((_, v) => v == uid);
    _usernames[name] = uid;
    _edit(uid, (p) => _copy(p, username: name));
  }

  @override
  Future<void> setPhoto(String uid, String? base64Jpeg) async => _edit(
    uid,
    (p) => _copy(p, photo: base64Jpeg, clearPhoto: base64Jpeg == null),
  );

  @override
  Future<void> setVisibility(String uid, ProfileVisibility visibility) async =>
      _edit(uid, (p) => _copy(p, visibility: visibility));

  @override
  Future<void> setNotifications(String uid, NotificationPrefs prefs) async =>
      _edit(uid, (p) => _copy(p, notifications: prefs));

  @override
  Future<void> deleteUserData(String uid) async {
    _store(uid).value = null;
    _usernames.removeWhere((_, v) => v == uid);
  }

  /// Reserves a username for another user, to test conflicts.
  void reserveUsername(String name, String uid) => _usernames[name] = uid;
}

/// Marketplace data held in memory: used by tests and by the demo mode.
class InMemoryMarketRepository implements MarketRepository {
  InMemoryMarketRepository({
    List<Listing> listings = const [],
    List<Order> orders = const [],
    List<Payout> payouts = const [],
    PayoutMethod? payoutMethod,
  }) : _listings = _Store([...listings]),
       _orders = _Store([...orders]),
       _payouts = _Store([...payouts]),
       _payoutMethod = _Store(payoutMethod);

  final _Store<List<Listing>> _listings;
  final _Store<List<Order>> _orders;
  final _Store<List<Payout>> _payouts;
  final _Store<PayoutMethod?> _payoutMethod;
  final supportRequests = <Map<String, Object>>[];
  var _nextId = 1;

  Stream<R> _map<T, R>(_Store<T> s, R Function(T v) f) => s.watch().map(f);

  @override
  Stream<List<Listing>> watchActiveListings() => _map(
    _listings,
    (all) =>
        all.where((l) => l.status == ListingStatus.active).toList()
          ..sort((a, b) => a.event.date.compareTo(b.event.date)),
  );

  @override
  Stream<List<Listing>> watchMyListings(String uid) =>
      _map(_listings, (all) => all.where((l) => l.sellerId == uid).toList());

  @override
  Stream<Listing?> watchListing(String id) =>
      _map(_listings, (all) => all.where((l) => l.id == id).firstOrNull);

  @override
  Future<String> createListing(Listing listing) async {
    final id = 'listing-${_nextId++}';
    _listings.value = [
      Listing.fromMap(id, {
        ...listing.toMap(),
        'status': ListingStatus.active.name,
        'quantitySold': 0,
        'createdAt': DateTime.now(),
      }),
      ..._listings.value,
    ];
    return id;
  }

  void _updateListing(String id, Map<String, Object> changes) {
    _listings.value = [
      for (final l in _listings.value)
        l.id == id
            ? Listing.fromMap(id, {
                ...l.toMap(),
                'createdAt': ?l.createdAt,
                ...changes,
              })
            : l,
    ];
  }

  @override
  Future<void> updateListingPrice(String id, int priceMinor) async =>
      _updateListing(id, {'priceMinor': priceMinor});

  @override
  Future<void> withdrawListing(String id) async =>
      _updateListing(id, {'status': ListingStatus.withdrawn.name});

  @override
  Stream<List<Order>> watchPurchases(String uid) =>
      _map(_orders, (all) => all.where((o) => o.buyerId == uid).toList());

  @override
  Stream<List<Order>> watchSales(String uid) =>
      _map(_orders, (all) => all.where((o) => o.sellerId == uid).toList());

  @override
  Stream<Order?> watchOrder(String id) =>
      _map(_orders, (all) => all.where((o) => o.id == id).firstOrNull);

  @override
  Stream<List<Payout>> watchPayouts(String uid) =>
      _map(_payouts, (all) => all.where((p) => p.sellerId == uid).toList());

  @override
  Stream<Payout?> watchPayout(String id) =>
      _map(_payouts, (all) => all.where((p) => p.id == id).firstOrNull);

  @override
  Future<ProfileStats> loadStats(String uid) async {
    bool sold(Order o) => const {
      OrderStatus.paid,
      OrderStatus.ticketsSent,
      OrderStatus.completed,
      OrderStatus.disputed,
    }.contains(o.status);
    int tickets(Iterable<Order> orders) =>
        orders.where(sold).fold(0, (total, o) => total + o.quantity);
    return ProfileStats(
      listed: _listings.value
          .where(
            (l) => l.sellerId == uid && l.status != ListingStatus.withdrawn,
          )
          .fold(0, (total, l) => total + l.quantity),
      sold: tickets(_orders.value.where((o) => o.sellerId == uid)),
      bought: tickets(_orders.value.where((o) => o.buyerId == uid)),
    );
  }

  @override
  Stream<PayoutMethod?> watchPayoutMethod(String uid) => _payoutMethod.watch();

  @override
  Future<void> setPayoutMethod(String uid, PayoutMethod method) async =>
      _payoutMethod.value = method;

  @override
  Future<String> createSupportRequest({
    required String uid,
    required String email,
    required SupportTopic topic,
    required String reference,
    required String message,
  }) async {
    final number = 'SUP-${100000 + supportRequests.length}';
    supportRequests.add({
      'number': number,
      'topic': topic.name,
      'reference': reference,
      'message': message,
    });
    return number;
  }
}
