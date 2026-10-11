import 'package:flutter/foundation.dart';

/// Marketplace fees in percent of the ticket price.
///
/// An admin sets them (config/fees); every listing keeps the percentages in
/// force when it was created, and its orders copy them, so a later change
/// only applies to new listings.
@immutable
class FeeConfig {
  const FeeConfig({
    this.buyerPercent = defaultPercent,
    this.sellerPercent = defaultPercent,
  });

  /// Before fees were configurable, and for documents without them.
  static const defaultPercent = 10;

  /// Highest fee an admin can set.
  static const maxPercent = 30;

  /// Paid by the buyer on top of the ticket price (service fee).
  final int buyerPercent;

  /// Kept from the seller's ticket price.
  final int sellerPercent;

  int buyerFee(int subtotalMinor) => percentOf(subtotalMinor, buyerPercent);
  int sellerFee(int subtotalMinor) => percentOf(subtotalMinor, sellerPercent);

  factory FeeConfig.fromMap(Map<String, dynamic>? m) => FeeConfig(
    buyerPercent: _percent(m?['buyerPercent']),
    sellerPercent: _percent(m?['sellerPercent']),
  );

  Map<String, dynamic> toMap() => {
    'buyerPercent': buyerPercent,
    'sellerPercent': sellerPercent,
  };

  @override
  bool operator ==(Object other) =>
      other is FeeConfig &&
      other.buyerPercent == buyerPercent &&
      other.sellerPercent == sellerPercent;

  @override
  int get hashCode => Object.hash(buyerPercent, sellerPercent);
}

int percentOf(int amountMinor, int percent) =>
    (amountMinor * percent / 100).round();

int _percent(Object? v) => v is num
    ? v.toInt().clamp(0, FeeConfig.maxPercent)
    : FeeConfig.defaultPercent;

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

/// An event created by an admin. Sellers list tickets for it.
@immutable
class Event {
  const Event({
    required this.id,
    required this.info,
    this.hasImage = false,
    this.imageVersion = 0,
    this.hidden = false,
    this.createdAt,
  });

  final String id;
  final EventInfo info;

  /// The picture lives in eventImages/{id}, so event lists stay small.
  final bool hasImage;

  /// Changes with every new picture, so caches know to reload it.
  final int imageVersion;

  /// Hidden by an admin: not shown and no new listings.
  final bool hidden;
  final DateTime? createdAt;

  bool get isUpcoming => info.date.isAfter(DateTime.now());

  factory Event.fromMap(String id, Map<String, dynamic> m) => Event(
    id: id,
    info: EventInfo.fromMap(m),
    hasImage: m['hasImage'] == true,
    imageVersion: (m['imageVersion'] as num?)?.toInt() ?? 0,
    hidden: m['status'] == 'hidden',
    createdAt: _date(m['createdAt']),
  );
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
    this.eventId = '',
    this.fees = const FeeConfig(),
    this.section = '',
    this.row = '',
    this.seats = '',
    this.note = '',
    this.createdAt,
  });

  final String id;
  final String sellerId;

  /// The admin-created event; empty for listings from before events.
  final String eventId;

  /// A copy of the event as it was when the listing was created.
  final EventInfo event;

  /// The fees in force when the listing was created.
  final FeeConfig fees;
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
  int get payoutPerTicketMinor => priceMinor - fees.sellerFee(priceMinor);

  factory Listing.fromMap(String id, Map<String, dynamic> m) => Listing(
    id: id,
    sellerId: m['sellerId'] as String? ?? '',
    eventId: m['eventId'] as String? ?? '',
    fees: FeeConfig(
      buyerPercent: _percent(m['buyerFeePercent']),
      sellerPercent: _percent(m['sellerFeePercent']),
    ),
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
    if (eventId.isNotEmpty) 'eventId': eventId,
    'event': event.toMap(),
    'buyerFeePercent': fees.buyerPercent,
    'sellerFeePercent': fees.sellerPercent,
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
    this.fees = const FeeConfig(),
    this.ticketType = TicketType.eTicket,
    this.section = '',
    this.row = '',
    this.seats = '',
    this.paymentMethod = '',
    this.paymentId = '',
    this.failureReason = '',
    this.cancelledBySeller = false,
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

  /// The listing's fees, fixed with the order.
  final FeeConfig fees;
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

  /// The seller cancelled the sale and the buyer was refunded.
  final bool cancelledBySeller;

  /// Paid with the payment simulator, not real money.
  final bool testMode;
  final List<StatusChange<OrderStatus>> history;
  final DateTime? createdAt;

  int get subtotalMinor => unitPriceMinor * quantity;
  int get buyerFeeMinor => fees.buyerFee(subtotalMinor);
  int get totalMinor => subtotalMinor + buyerFeeMinor;
  int get sellerFeeMinor => fees.sellerFee(subtotalMinor);
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
    fees: FeeConfig(
      buyerPercent: _percent(m['buyerFeePercent']),
      sellerPercent: _percent(m['sellerFeePercent']),
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
    cancelledBySeller: m['cancelledBy'] == 'seller',
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

/// Letters and digits only, upper case: drops spaces of any kind (pasted
/// IBANs often carry non-breaking ones), dashes, dots and invisible marks.
String normalizeIban(String input) =>
    input.toUpperCase().replaceAll(RegExp(r'[^A-Z0-9]'), '');

/// IBAN lengths per country (ISO 13616 registry; SEPA and neighbours).
const ibanLengths = {
  'AD': 24,
  'AL': 28,
  'AT': 20,
  'BA': 20,
  'BE': 16,
  'BG': 22,
  'CH': 21,
  'CY': 28,
  'CZ': 24,
  'DE': 22,
  'DK': 18,
  'EE': 20,
  'ES': 24,
  'FI': 18,
  'FR': 27,
  'GB': 22,
  'GI': 23,
  'GR': 27,
  'HR': 21,
  'HU': 28,
  'IE': 22,
  'IS': 26,
  'IT': 27,
  'LI': 21,
  'LT': 20,
  'LU': 20,
  'LV': 21,
  'MC': 27,
  'MD': 24,
  'ME': 22,
  'MK': 19,
  'MT': 31,
  'NL': 18,
  'NO': 15,
  'PL': 28,
  'PT': 25,
  'RO': 24,
  'RS': 22,
  'SE': 24,
  'SI': 19,
  'SK': 24,
  'SM': 27,
  'TR': 26,
  'UA': 29,
  'VA': 22,
  'XK': 20,
};

/// Longest IBAN in the registry.
const ibanMaxLength = 34;

/// Why an IBAN is not valid.
sealed class IbanProblem {
  const IbanProblem();
}

/// Doesn't start with a country code and two check digits.
class IbanBadFormat extends IbanProblem {
  const IbanBadFormat();
}

/// Too short or too long for its country.
class IbanWrongLength extends IbanProblem {
  const IbanWrongLength(this.country, this.expected, this.actual);
  final String country;
  final int expected;
  final int actual;
}

/// The check digits don't match: usually a typo.
class IbanBadChecksum extends IbanProblem {
  const IbanBadChecksum();
}

/// Null for a valid IBAN, otherwise what is wrong with it.
IbanProblem? checkIban(String input) {
  final iban = normalizeIban(input);
  if (!RegExp(r'^[A-Z]{2}\d{2}[A-Z0-9]+$').hasMatch(iban)) {
    return const IbanBadFormat();
  }
  final country = iban.substring(0, 2);
  final expected = ibanLengths[country];
  if (expected != null && iban.length != expected) {
    return IbanWrongLength(country, expected, iban.length);
  }
  if (iban.length < 15 || iban.length > ibanMaxLength) {
    return const IbanBadFormat();
  }
  // ISO 13616 mod-97 checksum.
  final rearranged = iban.substring(4) + iban.substring(0, 4);
  var remainder = 0;
  for (final unit in rearranged.codeUnits) {
    final digits = unit >= 65 ? '${unit - 55}' : String.fromCharCode(unit);
    for (final d in digits.codeUnits) {
      remainder = (remainder * 10 + d - 48) % 97;
    }
  }
  return remainder == 1 ? null : const IbanBadChecksum();
}

/// Validates an IBAN: format, length for its country and checksum.
bool isValidIban(String input) => checkIban(input) == null;

// ---------------------------------------------------------------------------
// Support
// ---------------------------------------------------------------------------

enum SupportTopic { order, sale, payout, account, other }

enum SupportStatus {
  /// Waiting for support.
  open,

  /// Support replied, waiting for the user.
  answered,

  /// Done: the user was satisfied or support closed it. Read-only.
  closed,
}

/// A support request: a conversation between a user and the support team,
/// held in the app (no email).
@immutable
class SupportTicket {
  const SupportTicket({
    required this.id,
    required this.number,
    required this.uid,
    required this.topic,
    required this.status,
    this.email = '',
    this.name = '',
    this.reference = '',
    this.subject = '',
    this.unreadForUser = false,
    this.unreadForStaff = false,
    this.closedBy = '',
    this.appVersion = '',
    this.createdAt,
    this.lastMessageAt,
  });

  final String id;

  /// E.g. "SUP-4F7K2Q".
  final String number;
  final String uid;
  final String email;
  final String name;
  final SupportTopic topic;
  final SupportStatus status;

  /// An order or payout number the request is about.
  final String reference;

  /// The start of the first message, for lists.
  final String subject;

  /// Support replied and the user hasn't opened it yet.
  final bool unreadForUser;

  /// The user wrote and nobody from support has opened it yet.
  final bool unreadForStaff;

  /// 'user' or 'staff'.
  final String closedBy;
  final String appVersion;
  final DateTime? createdAt;
  final DateTime? lastMessageAt;

  bool get isClosed => status == SupportStatus.closed;

  factory SupportTicket.fromMap(String id, Map<String, dynamic> m) =>
      SupportTicket(
        id: id,
        number: m['number'] as String? ?? id,
        uid: m['uid'] as String? ?? '',
        email: m['email'] as String? ?? '',
        name: m['name'] as String? ?? '',
        topic: enumByName(SupportTopic.values, m['topic'], SupportTopic.other),
        status: enumByName(
          SupportStatus.values,
          m['status'],
          SupportStatus.open,
        ),
        reference: m['reference'] as String? ?? '',
        subject: m['subject'] as String? ?? '',
        unreadForUser: m['unreadForUser'] == true,
        unreadForStaff: m['unreadForStaff'] == true,
        closedBy: m['closedBy'] as String? ?? '',
        appVersion: m['appVersion'] as String? ?? '',
        createdAt: _date(m['createdAt']),
        lastMessageAt: _date(m['lastMessageAt']),
      );
}

@immutable
class SupportMessage {
  const SupportMessage({
    required this.id,
    required this.authorId,
    required this.fromStaff,
    required this.text,
    this.authorName = '',
    this.images = const [],
    this.createdAt,
  });

  final String id;
  final String authorId;

  /// Written by support (admin or support account), not the user.
  final bool fromStaff;
  final String authorName;
  final String text;

  /// JPEGs in base64, at most [maxSupportImages].
  final List<String> images;
  final DateTime? createdAt;

  factory SupportMessage.fromMap(String id, Map<String, dynamic> m) =>
      SupportMessage(
        id: id,
        authorId: m['authorId'] as String? ?? '',
        fromStaff: m['authorRole'] == 'staff',
        authorName: m['authorName'] as String? ?? '',
        text: m['text'] as String? ?? '',
        images: [...?(m['images'] as List?)?.whereType<String>()],
        createdAt: _date(m['createdAt']),
      );
}

/// Pictures per support message.
const maxSupportImages = 3;

// ---------------------------------------------------------------------------
// Roles
// ---------------------------------------------------------------------------

/// Team accounts. Admins are assigned in the Firebase console only; admins
/// assign support accounts in the app.
enum StaffRole { admin, support }

@immutable
class StaffMember {
  const StaffMember({
    required this.uid,
    required this.role,
    this.name = '',
    this.email = '',
    this.grantedAt,
  });

  final String uid;
  final StaffRole role;
  final String name;
  final String email;
  final DateTime? grantedAt;

  factory StaffMember.fromMap(String uid, Map<String, dynamic> m) =>
      StaffMember(
        uid: uid,
        role: enumByName(StaffRole.values, m['role'], StaffRole.support),
        name: m['name'] as String? ?? '',
        email: m['email'] as String? ?? '',
        grantedAt: _date(m['grantedAt']),
      );
}

/// A user found by an admin, to make them a support account.
@immutable
class UserLookup {
  const UserLookup({
    required this.uid,
    this.name = '',
    this.email = '',
    this.username = '',
  });

  final String uid;
  final String name;
  final String email;
  final String username;
}
