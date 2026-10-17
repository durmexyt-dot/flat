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
    // Off until these exist; the switches are shown but locked.
    this.priceAlerts = false,
    this.eventReminders = false,
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

/// Where an event stands. Users add events unconfirmed; admins and support
/// accounts check, correct and confirm them. Tickets can be sold and bought
/// for unconfirmed events too.
enum EventStatus {
  /// Added by a user, not yet checked by the team.
  pending,

  /// Checked by the team (or added by it).
  confirmed,

  /// Taken down by the team: not shown and no new listings.
  hidden,

  /// Called off: every buyer was refunded, nothing is sold anymore.
  cancelled,
}

/// An event. Sellers list tickets for it.
@immutable
class Event {
  const Event({
    required this.id,
    required this.info,
    this.status = EventStatus.confirmed,
    this.genre = '',
    this.performer = '',
    this.createdBy = '',
    this.postponedFrom,
    this.cancelReason = '',
    this.hasImage = false,
    this.imageVersion = 0,
    this.maxMarkupPercent,
    this.createdAt,
  });

  final String id;
  final EventInfo info;
  final EventStatus status;

  /// A finer category within [EventInfo.category], e.g. "football" or
  /// "rock" (see events/genres.dart). Empty if none.
  final String genre;

  /// The artist, team or tour (e.g. "Metallica"): dates of the same
  /// performer in other places belong together. Empty: the name counts.
  final String performer;

  /// Dates with the same key are one show in different places: the
  /// performer if given, else the name (case, spaces and diacritics don't
  /// matter).
  String get groupKey =>
      searchKey(performer.trim().isNotEmpty ? performer : info.name);

  /// Who added the event.
  final String createdBy;

  /// The original date when the event was moved; tickets stay valid.
  final DateTime? postponedFrom;

  /// Why the event was called off.
  final String cancelReason;

  /// The picture lives in eventImages/{id}, so event lists stay small.
  final bool hasImage;

  /// Changes with every new picture, so caches know to reload it.
  final int imageVersion;

  /// This event's own resale limit (admins); null: the general rule.
  final int? maxMarkupPercent;
  final DateTime? createdAt;

  bool get hidden => status == EventStatus.hidden;
  bool get cancelled => status == EventStatus.cancelled;
  bool get postponed => postponedFrom != null;
  bool get confirmed => status == EventStatus.confirmed;
  bool get pending => status == EventStatus.pending;
  bool get isUpcoming => info.date.isAfter(DateTime.now());

  factory Event.fromMap(String id, Map<String, dynamic> m) => Event(
    id: id,
    info: EventInfo.fromMap(m),
    // "active" is how events from v1.3.0 were stored: made by admins.
    status: m['status'] == 'active'
        ? EventStatus.confirmed
        : enumByName(EventStatus.values, m['status'], EventStatus.pending),
    genre: m['genre'] as String? ?? '',
    performer: m['performer'] as String? ?? '',
    postponedFrom: _date(m['postponedFrom']),
    cancelReason: m['cancelReason'] as String? ?? '',
    createdBy: m['createdBy'] as String? ?? '',
    hasImage: m['hasImage'] == true,
    imageVersion: (m['imageVersion'] as num?)?.toInt() ?? 0,
    maxMarkupPercent: (m['maxMarkupPercent'] as num?)?.toInt(),
    createdAt: _date(m['createdAt']),
  );

  Event copyWith({
    EventInfo? info,
    EventStatus? status,
    String? genre,
    String? performer,
    bool? hasImage,
    int? imageVersion,
    int? Function()? maxMarkupPercent,
  }) => Event(
    id: id,
    info: info ?? this.info,
    status: status ?? this.status,
    genre: genre ?? this.genre,
    performer: performer ?? this.performer,
    createdBy: createdBy,
    postponedFrom: postponedFrom,
    cancelReason: cancelReason,
    hasImage: hasImage ?? this.hasImage,
    imageVersion: imageVersion ?? this.imageVersion,
    maxMarkupPercent: maxMarkupPercent == null
        ? this.maxMarkupPercent
        : maxMarkupPercent(),
    createdAt: createdAt,
  );
}

/// Compares names loosely: case, spaces, punctuation and diacritics don't
/// matter ("Tribina Sjever" = "tribina-sjever", "Koševo" = "Kosevo").
String searchKey(String text) {
  const map = {'č': 'c', 'ć': 'c', 'š': 's', 'ž': 'z', 'đ': 'dj', 'ü': 'u'};
  final folded = text.trim().toLowerCase().split('').map((c) => map[c] ?? c);
  return folded.join().replaceAll(RegExp(r'[^a-z0-9]+'), ' ').trim();
}

// ---------------------------------------------------------------------------
// Seat maps
// ---------------------------------------------------------------------------

/// The seat map id of a venue: the same hall shares one map across events.
String seatMapId(String venue, String city) =>
    '${searchKey(venue)} ${searchKey(city)}'.trim().replaceAll(' ', '-');

/// A rectangle on a seat map, in fractions (0–1) of the map's width and
/// height, so it fits any size the map is drawn at.
@immutable
class MapRect {
  const MapRect(this.x, this.y, this.w, this.h);

  final double x;
  final double y;
  final double w;
  final double h;

  /// Clamped into the map and at least [min] in size.
  factory MapRect.normalized(
    double x,
    double y,
    double w,
    double h, {
    double min = 0.02,
  }) {
    double c(double v) => v.clamp(0.0, 1.0);
    final left = c(w < 0 ? x + w : x), top = c(h < 0 ? y + h : y);
    final width = (c(left + w.abs()) - left).clamp(min, 1.0 - left);
    final height = (c(top + h.abs()) - top).clamp(min, 1.0 - top);
    return MapRect(left, top, width, height);
  }

  bool contains(double px, double py) =>
      px >= x && px <= x + w && py >= y && py <= y + h;

  factory MapRect.fromMap(Map<String, dynamic> m) {
    double v(String k) => (m[k] as num?)?.toDouble() ?? 0;
    return MapRect(v('x'), v('y'), v('w'), v('h'));
  }

  Map<String, dynamic> toMap() => {'x': x, 'y': y, 'w': w, 'h': h};

  @override
  bool operator ==(Object other) =>
      other is MapRect &&
      other.x == x &&
      other.y == y &&
      other.w == w &&
      other.h == h;

  @override
  int get hashCode => Object.hash(x, y, w, h);
}

/// One section of a hall (a stand, a block, the floor) on its seat map.
/// Listings belong to it when their section has the same name.
@immutable
class SeatSection {
  const SeatSection({required this.name, required this.rect});

  final String name;
  final MapRect rect;

  bool matches(String section) =>
      section.trim().isNotEmpty && searchKey(section) == searchKey(name);

  factory SeatSection.fromMap(Map<String, dynamic> m) =>
      SeatSection(name: m['name'] as String? ?? '', rect: MapRect.fromMap(m));

  Map<String, dynamic> toMap() => {'name': name, ...rect.toMap()};

  SeatSection copyWith({String? name, MapRect? rect}) =>
      SeatSection(name: name ?? this.name, rect: rect ?? this.rect);
}

/// A venue's seat map: optional floor plan picture with the sections drawn
/// on it as tappable areas. Without a picture the sections are drawn on
/// their own.
@immutable
class SeatMap {
  const SeatMap({
    required this.id,
    required this.venue,
    required this.city,
    this.aspectRatio = defaultAspectRatio,
    this.sections = const [],
    this.stage,
    this.hasImage = false,
    this.imageVersion = 0,
  });

  /// Width / height of a map without a picture.
  static const defaultAspectRatio = 4 / 3;

  /// The most sections a map holds (the rules check it too).
  static const maxSections = 120;

  final String id;
  final String venue;
  final String city;

  /// Width / height: the picture's, or [defaultAspectRatio].
  final double aspectRatio;
  final List<SeatSection> sections;

  /// Where the stage or pitch is, if marked.
  final MapRect? stage;

  /// The picture lives in seatMapImages/{id}.
  final bool hasImage;
  final int imageVersion;

  /// The section a listing's [section] text belongs to, if any.
  SeatSection? sectionOf(String section) =>
      sections.where((s) => s.matches(section)).firstOrNull;

  factory SeatMap.fromMap(String id, Map<String, dynamic> m) => SeatMap(
    id: id,
    venue: m['venue'] as String? ?? '',
    city: m['city'] as String? ?? '',
    aspectRatio: (m['aspectRatio'] as num?)?.toDouble() ?? defaultAspectRatio,
    sections: [
      for (final s in (m['sections'] as List?) ?? const [])
        SeatSection.fromMap((s as Map).cast<String, dynamic>()),
    ],
    stage: m['stage'] is Map
        ? MapRect.fromMap((m['stage'] as Map).cast<String, dynamic>())
        : null,
    hasImage: m['hasImage'] == true,
    imageVersion: (m['imageVersion'] as num?)?.toInt() ?? 0,
  );

  /// Without hasImage and imageVersion: the repository sets those.
  Map<String, dynamic> toMap() => {
    'venue': venue,
    'city': city,
    'aspectRatio': aspectRatio,
    'sections': [for (final s in sections) s.toMap()],
    'stage': stage?.toMap(),
  };

  SeatMap copyWith({
    double? aspectRatio,
    List<SeatSection>? sections,
    MapRect? Function()? stage,
    bool? hasImage,
    int? imageVersion,
  }) => SeatMap(
    id: id,
    venue: venue,
    city: city,
    aspectRatio: aspectRatio ?? this.aspectRatio,
    sections: sections ?? this.sections,
    stage: stage == null ? this.stage : stage(),
    hasImage: hasImage ?? this.hasImage,
    imageVersion: imageVersion ?? this.imageVersion,
  );
}

// ---------------------------------------------------------------------------
// Resale rules and seller limits
// ---------------------------------------------------------------------------

/// How far above the face value tickets may be resold (admins set it, for
/// all events or per event), and whether sellers must give the face value.
@immutable
class ResaleConfig {
  const ResaleConfig({this.maxMarkupPercent, this.requireFaceValue = false});

  /// Highest markup an admin can set.
  static const maxMarkup = 1000;

  /// Null: no price limit.
  final int? maxMarkupPercent;
  final bool requireFaceValue;

  factory ResaleConfig.fromMap(Map<String, dynamic>? m) => ResaleConfig(
    maxMarkupPercent: (m?['maxMarkupPercent'] as num?)?.toInt(),
    requireFaceValue: m?['requireFaceValue'] == true,
  );

  Map<String, dynamic> toMap() => {
    'maxMarkupPercent': maxMarkupPercent,
    'requireFaceValue': requireFaceValue,
  };

  /// The limit for [event]: its own, else this general one.
  int? limitFor(Event? event) => event?.maxMarkupPercent ?? maxMarkupPercent;

  /// Whether listings for [event] need the face value.
  bool needsFaceValue(Event? event) =>
      requireFaceValue || limitFor(event) != null;

  @override
  bool operator ==(Object other) =>
      other is ResaleConfig &&
      other.maxMarkupPercent == maxMarkupPercent &&
      other.requireFaceValue == requireFaceValue;

  @override
  int get hashCode => Object.hash(maxMarkupPercent, requireFaceValue);
}

/// The highest price per ticket for [faceValueMinor] with [markupPercent]
/// (as the security rules check it: price × 100 ≤ face value × (100 + %)).
int maxResalePrice(int faceValueMinor, int markupPercent) =>
    faceValueMinor * (100 + markupPercent) ~/ 100;

/// Limits for new sellers until they have completed sales (the team sets
/// them).
@immutable
class SellerLimits {
  const SellerLimits({
    this.newSellerMaxListings = 5,
    this.newSellerMaxTickets = 6,
    this.trustedAfterSales = 3,
  });

  final int newSellerMaxListings;
  final int newSellerMaxTickets;
  final int trustedAfterSales;

  factory SellerLimits.fromMap(Map<String, dynamic>? m) {
    int v(String k, int d) => (m?[k] as num?)?.toInt() ?? d;
    const d = SellerLimits();
    return SellerLimits(
      newSellerMaxListings: v('newSellerMaxListings', d.newSellerMaxListings),
      newSellerMaxTickets: v('newSellerMaxTickets', d.newSellerMaxTickets),
      trustedAfterSales: v('trustedAfterSales', d.trustedAfterSales),
    );
  }

  Map<String, dynamic> toMap() => {
    'newSellerMaxListings': newSellerMaxListings,
    'newSellerMaxTickets': newSellerMaxTickets,
    'trustedAfterSales': trustedAfterSales,
  };

  @override
  bool operator ==(Object other) =>
      other is SellerLimits &&
      other.newSellerMaxListings == newSellerMaxListings &&
      other.newSellerMaxTickets == newSellerMaxTickets &&
      other.trustedAfterSales == trustedAfterSales;

  @override
  int get hashCode =>
      Object.hash(newSellerMaxListings, newSellerMaxTickets, trustedAfterSales);
}

/// A seller's counts, kept by the Cloud Function.
@immutable
class SellerStats {
  const SellerStats({
    this.activeListings = 0,
    this.completedSales = 0,
    this.trusted = false,
  });

  final int activeListings;
  final int completedSales;

  /// The team lifted the limits.
  final bool trusted;

  bool isNew(SellerLimits limits) =>
      !trusted && completedSales < limits.trustedAfterSales;

  factory SellerStats.fromMap(Map<String, dynamic>? m) => SellerStats(
    activeListings: (m?['activeListings'] as num?)?.toInt() ?? 0,
    completedSales: (m?['completedSales'] as num?)?.toInt() ?? 0,
    trusted: m?['trusted'] == true,
  );
}

/// A blocked account (the team).
@immutable
class UserBan {
  const UserBan({this.reason = '', this.at});
  final String reason;
  final DateTime? at;

  factory UserBan.fromMap(Map<String, dynamic> m) =>
      UserBan(reason: m['reason'] as String? ?? '', at: _date(m['at']));
}

// ---------------------------------------------------------------------------
// Reports and the team's log
// ---------------------------------------------------------------------------

enum ReportType { listing, duplicateTicket }

enum ReportReason { fake, price, wrongEvent, spam, other }

enum ReportStatus { open, resolved, dismissed }

@immutable
class Report {
  const Report({
    required this.id,
    required this.type,
    required this.listingId,
    this.reason = ReportReason.other,
    this.text = '',
    this.reporterId = '',
    this.status = ReportStatus.open,
    this.sellerId = '',
    this.otherListingId = '',
    this.otherSellerId = '',
    this.eventName = '',
    this.note = '',
    this.createdAt,
  });

  final String id;
  final ReportType type;
  final String listingId;
  final ReportReason reason;
  final String text;
  final String reporterId;
  final ReportStatus status;

  /// For copied ticket files: the seller of the copy and the first upload.
  final String sellerId;
  final String otherListingId;
  final String otherSellerId;
  final String eventName;

  /// The team's note when handling it.
  final String note;
  final DateTime? createdAt;

  factory Report.fromMap(String id, Map<String, dynamic> m) => Report(
    id: id,
    type: enumByName(ReportType.values, m['type'], ReportType.listing),
    listingId: m['listingId'] as String? ?? '',
    reason: enumByName(ReportReason.values, m['reason'], ReportReason.other),
    text: m['text'] as String? ?? '',
    reporterId: m['reporterId'] as String? ?? '',
    status: enumByName(ReportStatus.values, m['status'], ReportStatus.open),
    sellerId: m['sellerId'] as String? ?? '',
    otherListingId: m['otherListingId'] as String? ?? '',
    otherSellerId: m['otherSellerId'] as String? ?? '',
    eventName: m['eventName'] as String? ?? '',
    note: m['note'] as String? ?? '',
    createdAt: _date(m['createdAt']),
  );
}

/// One step the team took (written by the Cloud Function).
@immutable
class ModerationEntry {
  const ModerationEntry({
    required this.id,
    required this.action,
    this.targetUid = '',
    this.staffUid = '',
    this.reason = '',
    this.listingId = '',
    this.orderId = '',
    this.at,
  });

  final String id;

  /// ban, unban, removeListing, refund, trust, untrust.
  final String action;
  final String targetUid;
  final String staffUid;
  final String reason;
  final String listingId;
  final String orderId;
  final DateTime? at;

  factory ModerationEntry.fromMap(String id, Map<String, dynamic> m) =>
      ModerationEntry(
        id: id,
        action: m['action'] as String? ?? '',
        targetUid: m['targetUid'] as String? ?? '',
        staffUid: m['staffUid'] as String? ?? '',
        reason: m['reason'] as String? ?? '',
        listingId: m['listingId'] as String? ?? '',
        orderId: m['orderId'] as String? ?? '',
        at: _date(m['at']),
      );
}

// ---------------------------------------------------------------------------
// The platform's invoices for its service fee
// ---------------------------------------------------------------------------

/// The platform's company details printed on invoices (admins).
@immutable
class CompanyInfo {
  const CompanyInfo({
    this.name = 'Stubswap',
    this.address = '',
    this.taxId = '',
    this.vatNumber = '',
    this.vatPercent = 17,
    this.email = '',
    this.invoicePrefix = 'SSW',
  });

  final String name;
  final String address;

  /// Identification number (JIB / tax number).
  final String taxId;

  /// VAT number (PDV broj); empty if not registered for VAT.
  final String vatNumber;

  /// VAT included in the service fee (17 % PDV in Bosnia and Herzegovina).
  final int vatPercent;
  final String email;

  /// Before the year and number on invoices, e.g. SSW-2026-00001.
  final String invoicePrefix;

  factory CompanyInfo.fromMap(Map<String, dynamic>? m) {
    const d = CompanyInfo();
    String s(String k, String def) => (m?[k] as String?) ?? def;
    return CompanyInfo(
      name: s('name', d.name),
      address: s('address', d.address),
      taxId: s('taxId', d.taxId),
      vatNumber: s('vatNumber', d.vatNumber),
      vatPercent: (m?['vatPercent'] as num?)?.toInt() ?? d.vatPercent,
      email: s('email', d.email),
      invoicePrefix: s('invoicePrefix', d.invoicePrefix),
    );
  }

  Map<String, dynamic> toMap() => {
    'name': name,
    'address': address,
    'taxId': taxId,
    'vatNumber': vatNumber,
    'vatPercent': vatPercent,
    'email': email,
    'invoicePrefix': invoicePrefix,
  };

  @override
  bool operator ==(Object other) =>
      other is CompanyInfo &&
      other.name == name &&
      other.address == address &&
      other.taxId == taxId &&
      other.vatNumber == vatNumber &&
      other.vatPercent == vatPercent &&
      other.email == email &&
      other.invoicePrefix == invoicePrefix;

  @override
  int get hashCode => Object.hash(
    name,
    address,
    taxId,
    vatNumber,
    vatPercent,
    email,
    invoicePrefix,
  );
}

enum InvoiceType { invoice, creditNote }

/// An invoice (or credit note) of the platform's service fee to a buyer or
/// seller, issued by the Cloud Function.
@immutable
class PlatformInvoice {
  const PlatformInvoice({
    required this.id,
    required this.number,
    required this.type,
    required this.orderId,
    required this.orderNumber,
    required this.recipientUid,
    required this.recipientRole,
    required this.netMinor,
    required this.vatMinor,
    required this.grossMinor,
    required this.vatPercent,
    required this.currency,
    required this.company,
    this.recipientName = '',
    this.recipientEmail = '',
    this.feePercent = 0,
    this.baseMinor = 0,
    this.eventName = '',
    this.creditFor = '',
    this.issuedAt,
  });

  final String id;
  final String number;
  final InvoiceType type;
  final String orderId;
  final String orderNumber;
  final String recipientUid;

  /// "buyer" (service fee) or "seller" (seller fee).
  final String recipientRole;
  final String recipientName;
  final String recipientEmail;

  /// The fee in percent of [baseMinor] (the tickets' price).
  final int feePercent;
  final int baseMinor;
  final String eventName;
  final int netMinor;
  final int vatMinor;
  final int grossMinor;
  final int vatPercent;
  final String currency;

  /// The platform as it was when the invoice was issued.
  final CompanyInfo company;

  /// The invoice a credit note cancels.
  final String creditFor;
  final DateTime? issuedAt;

  bool get isCreditNote => type == InvoiceType.creditNote;
  bool get forBuyer => recipientRole == 'buyer';

  factory PlatformInvoice.fromMap(String id, Map<String, dynamic> m) {
    int n(String k) => (m[k] as num?)?.toInt() ?? 0;
    return PlatformInvoice(
      id: id,
      number: m['number'] as String? ?? '',
      type: enumByName(InvoiceType.values, m['type'], InvoiceType.invoice),
      orderId: m['orderId'] as String? ?? '',
      orderNumber: m['orderNumber'] as String? ?? '',
      recipientUid: m['recipientUid'] as String? ?? '',
      recipientRole: m['recipientRole'] as String? ?? 'buyer',
      recipientName: m['recipientName'] as String? ?? '',
      recipientEmail: m['recipientEmail'] as String? ?? '',
      feePercent: n('feePercent'),
      baseMinor: n('baseMinor'),
      eventName: m['eventName'] as String? ?? '',
      netMinor: n('netMinor'),
      vatMinor: n('vatMinor'),
      grossMinor: n('grossMinor'),
      vatPercent: n('vatPercent'),
      currency: m['currency'] as String? ?? 'BAM',
      company: CompanyInfo.fromMap((m['company'] as Map?)?.cast()),
      creditFor: m['creditFor'] as String? ?? '',
      issuedAt: _date(m['issuedAt']),
    );
  }
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

  /// Taken down by the team (breaks the rules, blocked seller).
  removed,
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
    this.quantityReserved = 0,
    required this.priceMinor,
    required this.currency,
    required this.status,
    this.eventId = '',
    this.fees = const FeeConfig(),
    this.faceValueMinor,
    this.section = '',
    this.row = '',
    this.seats = '',
    this.note = '',
    this.together = false,
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

  /// The original price printed on one ticket, if the seller gave it.
  final int? faceValueMinor;
  final TicketType ticketType;
  final int quantity;
  final int quantitySold;

  /// Tickets held for buyers who are paying right now.
  final int quantityReserved;

  /// Price per ticket in minor units (cents), as the buyer sees it before
  /// the service fee.
  final int priceMinor;
  final String currency;
  final ListingStatus status;
  final String section;
  final String row;
  final String seats;
  final String note;

  /// The seller says the seats are next to each other, so buyers of two
  /// or more sit together. False also for listings from before.
  final bool together;
  final DateTime? createdAt;

  int get available => quantity - quantitySold - quantityReserved;

  /// What the seller receives per ticket after the seller fee.
  int get payoutPerTicketMinor => priceMinor - fees.sellerFee(priceMinor);

  factory Listing.fromMap(String id, Map<String, dynamic> m) => Listing(
    id: id,
    sellerId: m['sellerId'] as String? ?? '',
    eventId: m['eventId'] as String? ?? '',
    faceValueMinor: (m['faceValueMinor'] as num?)?.toInt(),
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
    quantityReserved: (m['quantityReserved'] as num?)?.toInt() ?? 0,
    priceMinor: (m['priceMinor'] as num?)?.toInt() ?? 0,
    currency: m['currency'] as String? ?? 'BAM',
    status: enumByName(ListingStatus.values, m['status'], ListingStatus.active),
    section: m['section'] as String? ?? '',
    row: m['row'] as String? ?? '',
    seats: m['seats'] as String? ?? '',
    note: m['note'] as String? ?? '',
    together: m['together'] == true,
    createdAt: _date(m['createdAt']),
  );

  Map<String, dynamic> toMap() => {
    'sellerId': sellerId,
    if (eventId.isNotEmpty) 'eventId': eventId,
    'event': event.toMap(),
    'buyerFeePercent': fees.buyerPercent,
    'sellerFeePercent': fees.sellerPercent,
    'faceValueMinor': ?faceValueMinor,
    'ticketType': ticketType.name,
    'quantity': quantity,
    'quantitySold': quantitySold,
    'quantityReserved': quantityReserved,
    'priceMinor': priceMinor,
    'currency': currency,
    'status': status.name,
    'section': section,
    'row': row,
    'seats': seats,
    'note': note,
    if (together) 'together': true,
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
    this.cancelledBy = '',
    this.testMode = false,
    this.reserved = false,
    this.ticketsDelivered = 0,
    this.deliveredAt,
    this.dispute,
    this.handover,
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
  final String cancelledBy;

  /// Who ended the order: 'seller', 'expired' (not paid in time),
  /// 'deadline' (tickets not delivered in time), 'event' (event called off)
  /// or 'support' (reported problem).
  bool get cancelledBySeller => cancelledBy == 'seller';

  /// The tickets were held while paying (see [reservedUntil]).
  final bool reserved;

  /// How many tickets the buyer has received as files.
  final int ticketsDelivered;
  final DateTime? deliveredAt;

  /// A problem the buyer reported, or null.
  final OrderDispute? dispute;

  /// How the seller handed over mobile or paper tickets, or null.
  final TicketHandover? handover;

  /// Paid with the payment simulator, not real money.
  final bool testMode;
  final List<StatusChange<OrderStatus>> history;
  final DateTime? createdAt;

  int get subtotalMinor => unitPriceMinor * quantity;

  /// Until when a buyer can pay while the tickets are held for them.
  DateTime? get reservedUntil =>
      reserved ? createdAt?.add(reservationDuration) : null;

  /// E-tickets still to be uploaded by the seller for this order.
  int get ticketsMissing =>
      ticketType == TicketType.eTicket &&
          (status == OrderStatus.paid || status == OrderStatus.disputed)
      ? (quantity - ticketsDelivered).clamp(0, quantity)
      : 0;

  /// By when the seller must have uploaded the tickets.
  DateTime get deliveryDeadline => event.date.subtract(deliveryDeadlineBefore);
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
    cancelledBy: m['cancelledBy'] as String? ?? '',
    reserved: m['reserved'] == true,
    ticketsDelivered: (m['ticketsDelivered'] as num?)?.toInt() ?? 0,
    deliveredAt: _date(m['deliveredAt']),
    dispute: m['dispute'] is Map
        ? OrderDispute.fromMap((m['dispute'] as Map).cast<String, dynamic>())
        : null,
    handover: m['handover'] is Map
        ? TicketHandover.fromMap((m['handover'] as Map).cast<String, dynamic>())
        : null,
    testMode: m['testMode'] == true,
    history: _history(m['history'], OrderStatus.values),
    createdAt: _date(m['createdAt']),
  );
}

/// The buyer has this long to pay while the tickets are held (Cloud
/// Function and rules use the same 15 minutes).
const reservationDuration = Duration(minutes: 15);

/// E-tickets must be uploaded this long before the event, or the buyer is
/// refunded automatically.
const deliveryDeadlineBefore = Duration(hours: 24);

/// Orders complete (and payouts are released) this long after the event.
const completeAfterEvent = Duration(days: 3);

/// Buyers can report a problem until this long after the event.
const disputeWindowAfterEvent = Duration(days: 7);

/// How mobile or paper tickets reach the buyer.
enum HandoverMethod {
  /// Mobile tickets moved in the organizer's app to the buyer's account.
  appTransfer,

  /// Paper tickets by post or courier, with a tracking number if any.
  post,
  courier,

  /// Paper tickets handed over in person.
  inPerson,
}

/// The methods a ticket type is handed over with (e-tickets are files).
List<HandoverMethod> handoverMethods(TicketType type) => switch (type) {
  TicketType.mobile => const [HandoverMethod.appTransfer],
  TicketType.paper => const [
    HandoverMethod.post,
    HandoverMethod.courier,
    HandoverMethod.inPerson,
  ],
  TicketType.eTicket => const [],
};

/// What the seller says about handing over mobile or paper tickets, and
/// when the buyer confirmed getting them: the record if anything goes wrong.
@immutable
class TicketHandover {
  const TicketHandover({
    required this.method,
    this.recipient = '',
    this.trackingNumber = '',
    this.note = '',
    this.sentAt,
    this.confirmedAt,
  });

  final HandoverMethod method;

  /// Mobile: the name or email the tickets were transferred to.
  final String recipient;

  /// Post or courier: the shipment's tracking number.
  final String trackingNumber;
  final String note;
  final DateTime? sentAt;

  /// When the buyer confirmed getting the tickets.
  final DateTime? confirmedAt;

  bool get confirmed => confirmedAt != null;

  factory TicketHandover.fromMap(Map<String, dynamic> m) => TicketHandover(
    method: enumByName(
      HandoverMethod.values,
      m['method'],
      HandoverMethod.inPerson,
    ),
    recipient: m['recipient'] as String? ?? '',
    trackingNumber: m['trackingNumber'] as String? ?? '',
    note: m['note'] as String? ?? '',
    sentAt: _date(m['sentAt']),
    confirmedAt: _date(m['confirmedAt']),
  );

  /// The fields the seller writes (times are the server's).
  Map<String, dynamic> toMap() => {
    'method': method.name,
    'recipient': recipient,
    'trackingNumber': trackingNumber,
    'note': note,
  };
}

enum DisputeReason { notReceived, invalid, wrongTickets, eventChanged, other }

/// A problem the buyer reported with an order.
@immutable
class OrderDispute {
  const OrderDispute({
    required this.reason,
    required this.text,
    this.previousStatus,
    this.decision = '',
    this.note = '',
    this.supportTicketId = '',
    this.openedAt,
    this.resolvedAt,
  });

  final DisputeReason reason;
  final String text;
  final OrderStatus? previousStatus;

  /// 'refund' or 'reject' once the team decided; empty while open.
  final String decision;
  final String note;
  final String supportTicketId;
  final DateTime? openedAt;
  final DateTime? resolvedAt;

  bool get open => decision.isEmpty;

  factory OrderDispute.fromMap(Map<String, dynamic> m) => OrderDispute(
    reason: enumByName(DisputeReason.values, m['reason'], DisputeReason.other),
    text: m['text'] as String? ?? '',
    previousStatus: m['previousStatus'] == null
        ? null
        : enumByName(OrderStatus.values, m['previousStatus'], OrderStatus.paid),
    decision: m['decision'] as String? ?? '',
    note: m['note'] as String? ?? '',
    supportTicketId: m['supportTicketId'] as String? ?? '',
    openedAt: _date(m['openedAt']),
    resolvedAt: _date(m['resolvedAt']),
  );
}

/// A ticket file: uploaded by the seller for a listing, or delivered to an
/// order (the buyer's copy).
@immutable
class TicketFile {
  const TicketFile({
    required this.id,
    required this.name,
    required this.contentType,
    required this.size,
    required this.storagePath,
    this.tickets = 1,
    this.orderId,
    this.at,
  });

  final String id;
  final String name;
  final String contentType;
  final int size;
  final String storagePath;

  /// How many tickets the file holds (one PDF can hold several).
  final int tickets;

  /// For an uploaded file: the order it went to, null while waiting.
  final String? orderId;

  /// Uploaded or delivered.
  final DateTime? at;

  bool get isPdf => contentType == 'application/pdf';
  bool get assigned => orderId != null;

  factory TicketFile.fromMap(String id, Map<String, dynamic> m) => TicketFile(
    id: id,
    name: m['name'] as String? ?? id,
    contentType: m['contentType'] as String? ?? '',
    size: (m['size'] as num?)?.toInt() ?? 0,
    storagePath: m['storagePath'] as String? ?? '',
    tickets: (m['tickets'] as num?)?.toInt() ?? 1,
    orderId: m['orderId'] as String?,
    at: _date(m['uploadedAt'] ?? m['deliveredAt']),
  );
}

/// File types a seller can upload as tickets.
const ticketFileTypes = {
  'pdf': 'application/pdf',
  'png': 'image/png',
  'jpg': 'image/jpeg',
  'jpeg': 'image/jpeg',
  'webp': 'image/webp',
};

/// Largest ticket file (Storage rules allow just under 10 MB).
const maxTicketFileBytes = 10 * 1024 * 1024 - 1;

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
    this.orderId = '',
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

  /// For a reported problem: the order it is about.
  final String orderId;
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
        orderId: m['orderId'] as String? ?? '',
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
