import 'package:flutter/foundation.dart';

/// Marketplace fees in percent of the ticket price.
abstract final class Fees {
  /// Paid by the buyer on top of the ticket price.
  static const buyerPercent = 10;

  /// Kept from the seller's ticket price.
  static const sellerPercent = 10;

  static int buyerFee(int subtotalMinor) =>
      (subtotalMinor * buyerPercent / 100).round();
  static int sellerFee(int subtotalMinor) =>
      (subtotalMinor * sellerPercent / 100).round();
}

T enumByName<T extends Enum>(List<T> values, Object? name, T fallback) =>
    values.where((v) => v.name == name).firstOrNull ?? fallback;

DateTime? _date(Object? value) => switch (value) {
  DateTime d => d,
  int ms => DateTime.fromMillisecondsSinceEpoch(ms),
  _ => null,
};

// ---------------------------------------------------------------------------
// Profile
// ---------------------------------------------------------------------------

enum ProfileVisibility { public, private }

@immutable
class NotificationPrefs {
  const NotificationPrefs({
    this.orderUpdates = true,
    this.saleUpdates = true,
    this.payoutUpdates = true,
    this.priceAlerts = true,
    this.eventReminders = true,
    this.newsletter = false,
    this.email = true,
    this.push = false,
  });

  /// Buyer: payment confirmed, tickets delivered, refunds.
  final bool orderUpdates;

  /// Seller: listing sold, tickets need to be sent.
  final bool saleUpdates;

  /// Seller: payout scheduled, sent or failed.
  final bool payoutUpdates;

  /// Price drops for events the user follows.
  final bool priceAlerts;

  /// Reminder before events the user has tickets for.
  final bool eventReminders;
  final bool newsletter;

  /// Channels.
  final bool email;
  final bool push;

  factory NotificationPrefs.fromMap(Map<String, dynamic>? m) {
    const d = NotificationPrefs();
    if (m == null) return d;
    bool v(String k, bool fallback) => m[k] is bool ? m[k] as bool : fallback;
    return NotificationPrefs(
      orderUpdates: v('orderUpdates', d.orderUpdates),
      saleUpdates: v('saleUpdates', d.saleUpdates),
      payoutUpdates: v('payoutUpdates', d.payoutUpdates),
      priceAlerts: v('priceAlerts', d.priceAlerts),
      eventReminders: v('eventReminders', d.eventReminders),
      newsletter: v('newsletter', d.newsletter),
      email: v('email', d.email),
      push: v('push', d.push),
    );
  }

  Map<String, dynamic> toMap() => {
    'orderUpdates': orderUpdates,
    'saleUpdates': saleUpdates,
    'payoutUpdates': payoutUpdates,
    'priceAlerts': priceAlerts,
    'eventReminders': eventReminders,
    'newsletter': newsletter,
    'email': email,
    'push': push,
  };

  NotificationPrefs copyWithKey(String key, bool value) =>
      NotificationPrefs.fromMap({...toMap(), key: value});
}

@immutable
class UserProfile {
  const UserProfile({
    required this.uid,
    this.displayName,
    this.username,
    this.email,
    this.photoBase64,
    this.visibility = ProfileVisibility.public,
    this.notifications = const NotificationPrefs(),
    this.createdAt,
  });

  final String uid;
  final String? displayName;
  final String? username;
  final String? email;

  /// Small JPEG (max 256 px), stored inline so no Storage bucket is needed.
  final String? photoBase64;
  final ProfileVisibility visibility;
  final NotificationPrefs notifications;
  final DateTime? createdAt;

  factory UserProfile.fromMap(String uid, Map<String, dynamic> m) =>
      UserProfile(
        uid: uid,
        displayName: m['displayName'] as String?,
        username: m['username'] as String?,
        email: m['email'] as String?,
        photoBase64: m['photo'] as String?,
        visibility: enumByName(
          ProfileVisibility.values,
          m['visibility'],
          ProfileVisibility.public,
        ),
        notifications: NotificationPrefs.fromMap(
          (m['notifications'] as Map?)?.cast<String, dynamic>(),
        ),
        createdAt: _date(m['createdAt']),
      );
}

@immutable
class ProfileStats {
  const ProfileStats({
    required this.listed,
    required this.sold,
    required this.bought,
  });

  /// Tickets put up for sale (all listings, any status but withdrawn).
  final int listed;

  /// Tickets sold to buyers.
  final int sold;

  /// Tickets bought.
  final int bought;
}

// ---------------------------------------------------------------------------
// Events and listings
// ---------------------------------------------------------------------------

enum EventCategory { concerts, sports, theater, festivals, other }

@immutable
class EventInfo {
  const EventInfo({
    required this.name,
    required this.venue,
    required this.city,
    required this.date,
    required this.category,
  });

  final String name;
  final String venue;
  final String city;
  final DateTime date;
  final EventCategory category;

  factory EventInfo.fromMap(Map<String, dynamic> m) => EventInfo(
    name: m['name'] as String? ?? '',
    venue: m['venue'] as String? ?? '',
    city: m['city'] as String? ?? '',
    date: _date(m['date']) ?? DateTime(2000),
    category: enumByName(
      EventCategory.values,
      m['category'],
      EventCategory.other,
    ),
  );

  Map<String, dynamic> toMap() => {
    'name': name,
    'venue': venue,
    'city': city,
    'date': date,
    'category': category.name,
  };
}

enum TicketType { eTicket, mobile, paper }

enum ListingStatus {
  /// Visible to buyers.
  active,

  /// A buyer is paying for the last tickets.
  reserved,

  /// All tickets sold.
  soldOut,

  /// The event date passed with tickets left.
  expired,

  /// Taken down by the seller.
  withdrawn,
}

@immutable
class Listing {
  const Listing({
    required this.id,
    required this.sellerId,
    required this.event,
    required this.ticketType,
    required this.quantity,
    required this.quantitySold,
    required this.priceMinor,
    required this.currency,
    required this.status,
    this.section = '',
    this.row = '',
    this.seats = '',
    this.note = '',
    this.createdAt,
  });

  final String id;
  final String sellerId;
  final EventInfo event;
  final TicketType ticketType;
  final int quantity;
  final int quantitySold;

  /// Price per ticket in minor units (cents), as the buyer sees it before
  /// the service fee.
  final int priceMinor;
  final String currency;
  final ListingStatus status;
  final String section;
  final String row;
  final String seats;
  final String note;
  final DateTime? createdAt;

  int get available => quantity - quantitySold;

  /// What the seller receives per ticket after the seller fee.
  int get payoutPerTicketMinor => priceMinor - Fees.sellerFee(priceMinor);

  factory Listing.fromMap(String id, Map<String, dynamic> m) => Listing(
    id: id,
    sellerId: m['sellerId'] as String? ?? '',
    event: EventInfo.fromMap((m['event'] as Map).cast<String, dynamic>()),
    ticketType: enumByName(
      TicketType.values,
      m['ticketType'],
      TicketType.eTicket,
    ),
    quantity: (m['quantity'] as num?)?.toInt() ?? 0,
    quantitySold: (m['quantitySold'] as num?)?.toInt() ?? 0,
    priceMinor: (m['priceMinor'] as num?)?.toInt() ?? 0,
    currency: m['currency'] as String? ?? 'BAM',
    status: enumByName(ListingStatus.values, m['status'], ListingStatus.active),
    section: m['section'] as String? ?? '',
    row: m['row'] as String? ?? '',
    seats: m['seats'] as String? ?? '',
    note: m['note'] as String? ?? '',
    createdAt: _date(m['createdAt']),
  );

  Map<String, dynamic> toMap() => {
    'sellerId': sellerId,
    'event': event.toMap(),
    'ticketType': ticketType.name,
    'quantity': quantity,
    'quantitySold': quantitySold,
    'priceMinor': priceMinor,
    'currency': currency,
    'status': status.name,
    'section': section,
    'row': row,
    'seats': seats,
    'note': note,
  };
}

// ---------------------------------------------------------------------------
// Orders (one purchase of tickets from one listing)
// ---------------------------------------------------------------------------

/// The order life cycle, as on ticket resale marketplaces: the buyer pays,
/// the money is held, the seller delivers the tickets, and the order
/// completes after the event. Only the server changes the status.
enum OrderStatus {
  pendingPayment,
  paid,
  ticketsSent,
  completed,
  cancelled,
  refunded,
  disputed,
}

/// The regular path; other statuses branch off it.
const orderHappyPath = [
  OrderStatus.pendingPayment,
  OrderStatus.paid,
  OrderStatus.ticketsSent,
  OrderStatus.completed,
];

@immutable
class StatusChange<S extends Enum> {
  const StatusChange(this.status, this.at);
  final S status;
  final DateTime at;
}

List<StatusChange<S>> _history<S extends Enum>(Object? raw, List<S> values) {
  if (raw is! List) return const [];
  return [
    for (final e in raw.whereType<Map>())
      if (_date(e['at']) case final at?)
        StatusChange(enumByName(values, e['status'], values.first), at),
  ];
}

@immutable
class Order {
  const Order({
    required this.id,
    required this.number,
    required this.listingId,
    required this.buyerId,
    required this.sellerId,
    required this.event,
    required this.quantity,
    required this.unitPriceMinor,
    required this.currency,
    required this.status,
    this.ticketType = TicketType.eTicket,
    this.section = '',
    this.row = '',
    this.seats = '',
    this.paymentMethod = '',
    this.paymentId = '',
    this.failureReason = '',
    this.testMode = false,
    this.history = const [],
    this.createdAt,
  });

  final String id;

  /// Human-readable reference for support, e.g. "SSW-4F7K2Q".
  final String number;
  final String listingId;
  final String buyerId;
  final String sellerId;
  final EventInfo event;
  final int quantity;
  final int unitPriceMinor;
  final String currency;
  final OrderStatus status;
  final TicketType ticketType;
  final String section;
  final String row;
  final String seats;

  /// E.g. "Visa •••• 4242".
  final String paymentMethod;

  /// The payment provider's reference, e.g. a Stripe PaymentIntent id.
  final String paymentId;

  /// Why the payment failed, a [PaymentFailure] name.
  final String failureReason;

  /// Paid with the payment simulator, not real money.
  final bool testMode;
  final List<StatusChange<OrderStatus>> history;
  final DateTime? createdAt;

  int get subtotalMinor => unitPriceMinor * quantity;
  int get buyerFeeMinor => Fees.buyerFee(subtotalMinor);
  int get totalMinor => subtotalMinor + buyerFeeMinor;
  int get sellerFeeMinor => Fees.sellerFee(subtotalMinor);
  int get sellerEarningsMinor => subtotalMinor - sellerFeeMinor;

  DateTime? reachedAt(OrderStatus s) =>
      history.where((h) => h.status == s).firstOrNull?.at;

  factory Order.fromMap(String id, Map<String, dynamic> m) => Order(
    id: id,
    number: m['number'] as String? ?? id,
    listingId: m['listingId'] as String? ?? '',
    buyerId: m['buyerId'] as String? ?? '',
    sellerId: m['sellerId'] as String? ?? '',
    event: EventInfo.fromMap((m['event'] as Map).cast<String, dynamic>()),
    quantity: (m['quantity'] as num?)?.toInt() ?? 1,
    unitPriceMinor: (m['unitPriceMinor'] as num?)?.toInt() ?? 0,
    currency: m['currency'] as String? ?? 'BAM',
    status: enumByName(
      OrderStatus.values,
      m['status'],
      OrderStatus.pendingPayment,
    ),
    ticketType: enumByName(
      TicketType.values,
      m['ticketType'],
      TicketType.eTicket,
    ),
    section: m['section'] as String? ?? '',
    row: m['row'] as String? ?? '',
    seats: m['seats'] as String? ?? '',
    paymentMethod: m['paymentMethod'] as String? ?? '',
    paymentId: m['paymentId'] as String? ?? '',
    failureReason: m['failureReason'] as String? ?? '',
    testMode: m['testMode'] == true,
    history: _history(m['history'], OrderStatus.values),
    createdAt: _date(m['createdAt']),
  );
}

// ---------------------------------------------------------------------------
// Payouts (money sent to a seller for completed orders)
// ---------------------------------------------------------------------------

enum PayoutStatus {
  /// Waiting for the event to take place.
  pending,

  /// Released, waiting for the next payout run.
  scheduled,

  /// Bank transfer started.
  processing,
  paid,
  failed,
}

const payoutHappyPath = [
  PayoutStatus.pending,
  PayoutStatus.scheduled,
  PayoutStatus.processing,
  PayoutStatus.paid,
];

@immutable
class Payout {
  const Payout({
    required this.id,
    required this.sellerId,
    required this.orderNumbers,
    required this.amountMinor,
    required this.currency,
    required this.status,
    this.method = '',
    this.failureReason = '',
    this.expectedAt,
    this.history = const [],
    this.createdAt,
  });

  final String id;
  final String sellerId;
  final List<String> orderNumbers;
  final int amountMinor;
  final String currency;
  final PayoutStatus status;

  /// E.g. "IBAN •••• 1234".
  final String method;
  final String failureReason;
  final DateTime? expectedAt;
  final List<StatusChange<PayoutStatus>> history;
  final DateTime? createdAt;

  DateTime? reachedAt(PayoutStatus s) =>
      history.where((h) => h.status == s).firstOrNull?.at;

  factory Payout.fromMap(String id, Map<String, dynamic> m) => Payout(
    id: id,
    sellerId: m['sellerId'] as String? ?? '',
    orderNumbers: [...?(m['orderNumbers'] as List?)?.whereType<String>()],
    amountMinor: (m['amountMinor'] as num?)?.toInt() ?? 0,
    currency: m['currency'] as String? ?? 'BAM',
    status: enumByName(PayoutStatus.values, m['status'], PayoutStatus.pending),
    method: m['method'] as String? ?? '',
    failureReason: m['failureReason'] as String? ?? '',
    expectedAt: _date(m['expectedAt']),
    history: _history(m['history'], PayoutStatus.values),
    createdAt: _date(m['createdAt']),
  );
}

@immutable
class PayoutMethod {
  const PayoutMethod({required this.accountHolder, required this.iban});

  final String accountHolder;
  final String iban;

  String get masked =>
      'IBAN •••• ${iban.length >= 4 ? iban.substring(iban.length - 4) : iban}';

  factory PayoutMethod.fromMap(Map<String, dynamic> m) => PayoutMethod(
    accountHolder: m['accountHolder'] as String? ?? '',
    iban: m['iban'] as String? ?? '',
  );

  Map<String, dynamic> toMap() => {
    'accountHolder': accountHolder,
    'iban': iban,
  };
}

/// Validates an IBAN with the ISO 13616 mod-97 checksum.
bool isValidIban(String input) {
  final iban = input.replaceAll(' ', '').toUpperCase();
  if (!RegExp(r'^[A-Z]{2}\d{2}[A-Z0-9]{10,30}$').hasMatch(iban)) return false;
  final rearranged = iban.substring(4) + iban.substring(0, 4);
  var remainder = 0;
  for (final unit in rearranged.codeUnits) {
    final digits = unit >= 65 ? '${unit - 55}' : String.fromCharCode(unit);
    for (final d in digits.codeUnits) {
      remainder = (remainder * 10 + d - 48) % 97;
    }
  }
  return remainder == 1;
}

// ---------------------------------------------------------------------------
// Support
// ---------------------------------------------------------------------------

enum SupportTopic { order, sale, payout, account, other }
