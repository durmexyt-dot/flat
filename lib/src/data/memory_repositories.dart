import 'dart:async';

import '../auth/auth_repository.dart';
import '../payments/checkout_repository.dart';
import '../payments/payment_gateway.dart';
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

  /// Per user: the version of the terms they accepted, for tests.
  final acceptedTerms = <String, String>{};

  @override
  Future<void> acceptTerms(String uid, String version) async =>
      acceptedTerms[uid] = version;

  /// Per user: the app language saved for emails, for tests.
  final languages = <String, String>{};

  @override
  Future<void> setLanguage(String uid, String code) async =>
      languages[uid] = code;
}

/// Marketplace data held in memory, for tests.
/// Handles checkout too, like the server will.
class InMemoryMarketRepository implements MarketRepository, CheckoutRepository {
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
  Stream<List<Listing>> watchEventListings(String eventId) => _map(
    _listings,
    (all) =>
        all
            .where(
              (l) =>
                  l.eventId == eventId &&
                  l.status == ListingStatus.active &&
                  l.available > 0,
            )
            .toList()
          ..sort((a, b) => a.priceMinor.compareTo(b.priceMinor)),
  );

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

  // Checkout -----------------------------------------------------------------

  Map<String, Object?> _orderMap(Order o) => {
    'number': o.number,
    'listingId': o.listingId,
    'buyerId': o.buyerId,
    'sellerId': o.sellerId,
    'event': o.event.toMap(),
    'buyerFeePercent': o.fees.buyerPercent,
    'sellerFeePercent': o.fees.sellerPercent,
    'quantity': o.quantity,
    'unitPriceMinor': o.unitPriceMinor,
    'currency': o.currency,
    'status': o.status.name,
    'ticketType': o.ticketType.name,
    'section': o.section,
    'row': o.row,
    'seats': o.seats,
    'paymentMethod': o.paymentMethod,
    'paymentId': o.paymentId,
    'failureReason': o.failureReason,
    'testMode': o.testMode,
    'reserved': o.reserved,
    'cancelledBy': o.cancelledBy,
    'ticketsDelivered': o.ticketsDelivered,
    if (o.handover case final h?)
      'handover': {
        ...h.toMap(),
        'sentAt': h.sentAt,
        'confirmedAt': h.confirmedAt,
      },
    'history': [
      for (final h in o.history) {'status': h.status.name, 'at': h.at},
    ],
    'createdAt': o.createdAt,
  };

  void _replaceOrder(Order o, Map<String, Object?> changes, OrderStatus step) {
    final map = _orderMap(o);
    final updated = Order.fromMap(o.id, {
      ...map,
      ...changes,
      'history': [
        ...map['history']! as List,
        {'status': step.name, 'at': DateTime.now()},
      ],
    });
    _orders.value = [for (final x in _orders.value) x.id == o.id ? updated : x];
  }

  Order _current(Order o) => _orders.value.firstWhere((x) => x.id == o.id);

  @override
  Future<Order> createOrder({
    required Listing listing,
    required int quantity,
    required String buyerId,
  }) async {
    if (listing.sellerId == buyerId) throw OwnListingException();
    final order = Order.fromMap('order-${_nextId++}', {
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
      'testMode': true,
      'reserved': true,
      'history': [
        {'status': OrderStatus.pendingPayment.name, 'at': DateTime.now()},
      ],
      'createdAt': DateTime.now(),
    });
    _orders.value = [order, ..._orders.value];
    _updateListing(listing.id, {
      'quantityReserved':
          _listings.value
              .firstWhere((l) => l.id == listing.id)
              .quantityReserved +
          quantity,
    });
    return order;
  }

  @override
  Future<void> completePayment(Order order, PaymentOutcome outcome) async {
    final current = _current(order);
    switch (outcome) {
      case PaymentCancelled():
        return;
      case PaymentFailed(:final reason):
        _replaceOrder(current, {
          'status': OrderStatus.cancelled.name,
          'failureReason': reason.name,
        }, OrderStatus.cancelled);
        _release(order);
      case PaymentSucceeded(:final paymentId, :final methodLabel):
        if (reservationExpired(current)) throw ReservationExpiredException();
        _release(order);
        final listing = _listings.value.firstWhere(
          (l) => l.id == order.listingId,
        );
        final sold = listing.quantitySold + order.quantity;
        if (sold > listing.quantity) throw SoldOutException();
        _replaceOrder(current, {
          'status': OrderStatus.paid.name,
          'paymentId': paymentId,
          'paymentMethod': methodLabel,
        }, OrderStatus.paid);
        _updateListing(listing.id, {
          'quantitySold': sold,
          if (sold == listing.quantity) 'status': ListingStatus.soldOut.name,
        });
        _payouts.value = [
          Payout.fromMap(order.id, {
            'sellerId': order.sellerId,
            'orderNumbers': [order.number],
            'amountMinor': order.sellerEarningsMinor,
            'currency': order.currency,
            'status': PayoutStatus.pending.name,
            'expectedAt': expectedPayoutDate(order.event.date),
            'history': [
              {'status': PayoutStatus.pending.name, 'at': DateTime.now()},
            ],
            'createdAt': DateTime.now(),
          }),
          ..._payouts.value,
        ];
    }
  }

  /// The tickets held for [order] are free again.
  void _release(Order order) {
    if (!order.reserved) return;
    final listing = _listings.value.firstWhere((l) => l.id == order.listingId);
    _updateListing(listing.id, {
      'quantityReserved': (listing.quantityReserved - order.quantity).clamp(
        0,
        listing.quantity,
      ),
    });
  }

  @override
  Future<void> markTicketsSent(Order order, TicketHandover handover) async =>
      _replaceOrder(_current(order), {
        'status': OrderStatus.ticketsSent.name,
        'handover': {...handover.toMap(), 'sentAt': DateTime.now()},
      }, OrderStatus.ticketsSent);

  @override
  Future<void> confirmReceipt(Order order) async {
    final current = _current(order);
    final map = _orderMap(current);
    final updated = Order.fromMap(current.id, {
      ...map,
      'handover': {
        ...?(map['handover'] as Map<String, dynamic>?),
        'confirmedAt': DateTime.now(),
      },
    });
    _orders.value = [
      for (final x in _orders.value) x.id == current.id ? updated : x,
    ];
  }

  @override
  Future<void> cancelSale(Order order) async {
    final current = _current(order);
    if (!canSellerCancel(current.status)) {
      throw StateError('Sale can no longer be cancelled');
    }
    _replaceOrder(current, {
      'status': OrderStatus.refunded.name,
      'cancelledBy': 'seller',
    }, OrderStatus.refunded);
    final listing = _listings.value.firstWhere((l) => l.id == order.listingId);
    _updateListing(listing.id, {
      'quantitySold': listing.quantitySold - order.quantity,
      if (listing.status == ListingStatus.soldOut)
        'status': ListingStatus.active.name,
    });
    _payouts.value = [
      for (final p in _payouts.value)
        if (p.id != order.id) p,
    ];
  }
}
