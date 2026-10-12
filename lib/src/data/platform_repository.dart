import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart' hide Order;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'live_snapshots.dart';
import 'models.dart';
import 'repositories.dart';

/// The platform's rules and records: resale rules and seller limits,
/// company details, blocks, reports, the team's log and the platform's
/// invoices. Blocks, counts, the log and invoices are written by the Cloud
/// Functions; the app reads them.
abstract class PlatformRepository {
  Stream<ResaleConfig> watchResale();
  Future<void> setResale(ResaleConfig config, {required String byUid});

  Stream<SellerLimits> watchLimits();
  Future<void> setLimits(SellerLimits limits, {required String byUid});

  Stream<CompanyInfo> watchCompany();
  Future<void> setCompany(CompanyInfo company, {required String byUid});

  Stream<SellerStats> watchSellerStats(String uid);
  Stream<UserBan?> watchBan(String uid);

  /// A user reports a listing (once).
  Future<void> reportListing({
    required String listingId,
    required String uid,
    required ReportReason reason,
    required String text,
  });

  /// Whether [uid] already reported [listingId].
  Future<bool> hasReported(String listingId, String uid);

  /// Open reports, or the handled ones (newest first).
  Stream<List<Report>> watchReports({required bool open});
  Future<void> handleReport(
    String id, {
    required ReportStatus status,
    required String note,
    required String byUid,
  });

  /// The team's steps concerning one user, newest first.
  Stream<List<ModerationEntry>> watchLog(String targetUid);

  /// All listings of a seller, for the team.
  Stream<List<Listing>> watchListingsOf(String uid);

  /// A user's orders as buyer and seller, for the team.
  Stream<List<Order>> watchOrdersOf(String uid);

  Stream<List<PlatformInvoice>> watchMyInvoices(String uid);
  Stream<List<PlatformInvoice>> watchOrderInvoices(String orderId, String uid);

  /// Admins: all invoices issued in [from, to).
  Stream<List<PlatformInvoice>> watchInvoices(DateTime from, DateTime to);
  Stream<PlatformInvoice?> watchInvoice(String id);
}

int _newestFirst(DateTime? a, DateTime? b) =>
    (b ?? DateTime(0)).compareTo(a ?? DateTime(0));

class FirestorePlatformRepository implements PlatformRepository {
  FirestorePlatformRepository(this._db);
  final FirebaseFirestore _db;

  DocumentReference<Map<String, dynamic>> _config(String id) =>
      _db.collection('config').doc(id);

  Map<String, dynamic>? _data(DocumentSnapshot<Map<String, dynamic>> d) =>
      d.exists ? firestoreData(d) : null;

  Future<void> _setConfig(String id, Map<String, dynamic> m, String byUid) =>
      _config(id).set({
        ...m,
        'updatedBy': byUid,
        'updatedAt': FieldValue.serverTimestamp(),
      });

  @override
  Stream<ResaleConfig> watchResale() =>
      _config('resale')
          .liveSnapshots()
          .map((d) => ResaleConfig.fromMap(_data(d)));

  @override
  Future<void> setResale(ResaleConfig config, {required String byUid}) =>
      _setConfig('resale', config.toMap(), byUid);

  @override
  Stream<SellerLimits> watchLimits() =>
      _config('limits')
          .liveSnapshots()
          .map((d) => SellerLimits.fromMap(_data(d)));

  @override
  Future<void> setLimits(SellerLimits limits, {required String byUid}) =>
      _setConfig('limits', limits.toMap(), byUid);

  @override
  Stream<CompanyInfo> watchCompany() =>
      _config('company')
          .liveSnapshots()
          .map((d) => CompanyInfo.fromMap(_data(d)));

  @override
  Future<void> setCompany(CompanyInfo company, {required String byUid}) =>
      _setConfig('company', company.toMap(), byUid);

  @override
  Stream<SellerStats> watchSellerStats(String uid) => _db
      .collection('sellerStats')
      .doc(uid)
      .liveSnapshots()
      .map((d) => SellerStats.fromMap(_data(d)));

  @override
  Stream<UserBan?> watchBan(String uid) => _db
      .collection('bans')
      .doc(uid)
      .liveSnapshots()
      .map((d) => d.exists ? UserBan.fromMap(firestoreData(d)) : null);

  DocumentReference<Map<String, dynamic>> _report(
    String listingId,
    String uid,
  ) => _db.collection('reports').doc('${listingId}_$uid');

  @override
  Future<void> reportListing({
    required String listingId,
    required String uid,
    required ReportReason reason,
    required String text,
  }) => _report(listingId, uid).set({
    'type': ReportType.listing.name,
    'listingId': listingId,
    'reason': reason.name,
    'text': text,
    'reporterId': uid,
    'status': ReportStatus.open.name,
    'createdAt': FieldValue.serverTimestamp(),
  });

  @override
  Future<bool> hasReported(String listingId, String uid) async {
    try {
      return (await _report(listingId, uid).get()).exists;
    } on FirebaseException {
      // Not readable: no such report.
      return false;
    }
  }

  List<Report> _reports(QuerySnapshot<Map<String, dynamic>> q) =>
      [for (final d in q.docs) Report.fromMap(d.id, firestoreData(d))]
        ..sort((a, b) => _newestFirst(a.createdAt, b.createdAt));

  @override
  Stream<List<Report>> watchReports({required bool open}) {
    final reports = _db.collection('reports');
    final query = open
        ? reports.where('status', isEqualTo: ReportStatus.open.name)
        : reports
              .where(
                'status',
                whereIn: [
                  ReportStatus.resolved.name,
                  ReportStatus.dismissed.name,
                ],
              )
              .limit(100);
    return query.liveSnapshots().map(_reports);
  }

  @override
  Future<void> handleReport(
    String id, {
    required ReportStatus status,
    required String note,
    required String byUid,
  }) => _db.collection('reports').doc(id).update({
    'status': status.name,
    'note': note,
    'handledBy': byUid,
    'handledAt': FieldValue.serverTimestamp(),
  });

  @override
  Stream<List<ModerationEntry>> watchLog(String targetUid) => _db
      .collection('moderationLog')
      .where('targetUid', isEqualTo: targetUid)
      .liveSnapshots()
      .map(
        (q) => [
          for (final d in q.docs)
            ModerationEntry.fromMap(d.id, firestoreData(d)),
        ]..sort((a, b) => _newestFirst(a.at, b.at)),
      );

  @override
  Stream<List<Listing>> watchListingsOf(String uid) => _db
      .collection('listings')
      .where('sellerId', isEqualTo: uid)
      .liveSnapshots()
      .map(
        (q) =>
            [for (final d in q.docs) Listing.fromMap(d.id, firestoreData(d))]
              ..sort((a, b) => _newestFirst(a.createdAt, b.createdAt)),
      );

  @override
  Stream<List<Order>> watchOrdersOf(String uid) {
    final orders = _db.collection('orders');
    final asBuyer = orders.where('buyerId', isEqualTo: uid).liveSnapshots();
    final asSeller = orders.where('sellerId', isEqualTo: uid).liveSnapshots();
    late StreamController<List<Order>> out;
    var buyer = <Order>[];
    var seller = <Order>[];
    var seen = 0;
    void emit() {
      if (seen < 2) return;
      out.add(
        [...buyer, ...seller]
          ..sort((a, b) => _newestFirst(a.createdAt, b.createdAt)),
      );
    }

    List<Order> parse(QuerySnapshot<Map<String, dynamic>> q) => [
      for (final d in q.docs) Order.fromMap(d.id, firestoreData(d)),
    ];
    final subs = <StreamSubscription<Object?>>[];
    out = StreamController<List<Order>>(
      onListen: () {
        var gotBuyer = false;
        var gotSeller = false;
        subs
          ..add(
            asBuyer.listen((q) {
              buyer = parse(q);
              if (!gotBuyer) seen++;
              gotBuyer = true;
              emit();
            }, onError: out.addError),
          )
          ..add(
            asSeller.listen((q) {
              seller = parse(q);
              if (!gotSeller) seen++;
              gotSeller = true;
              emit();
            }, onError: out.addError),
          );
      },
      onCancel: () async {
        for (final s in subs) {
          await s.cancel();
        }
      },
    );
    return out.stream;
  }

  List<PlatformInvoice> _invoices(QuerySnapshot<Map<String, dynamic>> q) =>
      [for (final d in q.docs) PlatformInvoice.fromMap(d.id, firestoreData(d))]
        ..sort((a, b) => _newestFirst(a.issuedAt, b.issuedAt));

  @override
  Stream<List<PlatformInvoice>> watchMyInvoices(String uid) => _db
      .collection('invoices')
      .where('recipientUid', isEqualTo: uid)
      .liveSnapshots()
      .map(_invoices);

  @override
  Stream<List<PlatformInvoice>> watchOrderInvoices(
    String orderId,
    String uid,
  ) => _db
      .collection('invoices')
      .where('orderId', isEqualTo: orderId)
      .where('recipientUid', isEqualTo: uid)
      .liveSnapshots()
      .map(_invoices);

  @override
  Stream<List<PlatformInvoice>> watchInvoices(DateTime from, DateTime to) => _db
      .collection('invoices')
      .where('issuedAt', isGreaterThanOrEqualTo: Timestamp.fromDate(from))
      .where('issuedAt', isLessThan: Timestamp.fromDate(to))
      .liveSnapshots()
      .map(_invoices);

  @override
  Stream<PlatformInvoice?> watchInvoice(String id) => _db
      .collection('invoices')
      .doc(id)
      .liveSnapshots()
      .map(
        (d) =>
            d.exists ? PlatformInvoice.fromMap(d.id, firestoreData(d)) : null,
      );
}

/// Everything in memory, for tests.
class InMemoryPlatformRepository implements PlatformRepository {
  InMemoryPlatformRepository({
    this.resale = const ResaleConfig(),
    this.limits = const SellerLimits(),
    this.company = const CompanyInfo(),
  });

  ResaleConfig resale;
  SellerLimits limits;
  CompanyInfo company;
  final stats = <String, SellerStats>{};
  final bans = <String, UserBan>{};
  final reports = <String, Report>{};
  final log = <ModerationEntry>[];
  final listings = <Listing>[];
  final orders = <Order>[];
  final invoices = <PlatformInvoice>[];
  final _changes = StreamController<void>.broadcast();

  void changed() => _changes.add(null);

  Stream<T> _watch<T>(T Function() read) async* {
    yield read();
    yield* _changes.stream.map((_) => read());
  }

  @override
  Stream<ResaleConfig> watchResale() => _watch(() => resale);

  @override
  Future<void> setResale(ResaleConfig config, {required String byUid}) async {
    resale = config;
    changed();
  }

  @override
  Stream<SellerLimits> watchLimits() => _watch(() => limits);

  @override
  Future<void> setLimits(SellerLimits limits, {required String byUid}) async {
    this.limits = limits;
    changed();
  }

  @override
  Stream<CompanyInfo> watchCompany() => _watch(() => company);

  @override
  Future<void> setCompany(CompanyInfo company, {required String byUid}) async {
    this.company = company;
    changed();
  }

  @override
  Stream<SellerStats> watchSellerStats(String uid) =>
      _watch(() => stats[uid] ?? const SellerStats());

  @override
  Stream<UserBan?> watchBan(String uid) => _watch(() => bans[uid]);

  @override
  Future<void> reportListing({
    required String listingId,
    required String uid,
    required ReportReason reason,
    required String text,
  }) async {
    reports['${listingId}_$uid'] = Report(
      id: '${listingId}_$uid',
      type: ReportType.listing,
      listingId: listingId,
      reason: reason,
      text: text,
      reporterId: uid,
      createdAt: DateTime.now(),
    );
    changed();
  }

  @override
  Future<bool> hasReported(String listingId, String uid) async =>
      reports.containsKey('${listingId}_$uid');

  @override
  Stream<List<Report>> watchReports({required bool open}) => _watch(
    () => [
      for (final r in reports.values)
        if ((r.status == ReportStatus.open) == open) r,
    ],
  );

  @override
  Future<void> handleReport(
    String id, {
    required ReportStatus status,
    required String note,
    required String byUid,
  }) async {
    final r = reports[id];
    if (r == null) return;
    reports[id] = Report(
      id: r.id,
      type: r.type,
      listingId: r.listingId,
      reason: r.reason,
      text: r.text,
      reporterId: r.reporterId,
      status: status,
      sellerId: r.sellerId,
      otherListingId: r.otherListingId,
      otherSellerId: r.otherSellerId,
      eventName: r.eventName,
      note: note,
      createdAt: r.createdAt,
    );
    changed();
  }

  @override
  Stream<List<ModerationEntry>> watchLog(String targetUid) => _watch(
    () => [
      for (final e in log)
        if (e.targetUid == targetUid) e,
    ],
  );

  @override
  Stream<List<Listing>> watchListingsOf(String uid) => _watch(
    () => [
      for (final l in listings)
        if (l.sellerId == uid) l,
    ],
  );

  @override
  Stream<List<Order>> watchOrdersOf(String uid) => _watch(
    () => [
      for (final o in orders)
        if (o.buyerId == uid || o.sellerId == uid) o,
    ],
  );

  @override
  Stream<List<PlatformInvoice>> watchMyInvoices(String uid) => _watch(
    () => [
      for (final i in invoices)
        if (i.recipientUid == uid) i,
    ],
  );

  @override
  Stream<List<PlatformInvoice>> watchOrderInvoices(
    String orderId,
    String uid,
  ) => _watch(
    () => [
      for (final i in invoices)
        if (i.orderId == orderId && i.recipientUid == uid) i,
    ],
  );

  @override
  Stream<List<PlatformInvoice>> watchInvoices(DateTime from, DateTime to) =>
      _watch(
        () => [
          for (final i in invoices)
            if (i.issuedAt != null &&
                !i.issuedAt!.isBefore(from) &&
                i.issuedAt!.isBefore(to))
              i,
        ],
      );

  @override
  Stream<PlatformInvoice?> watchInvoice(String id) =>
      _watch(() => invoices.where((i) => i.id == id).firstOrNull);
}

final platformRepositoryProvider = Provider<PlatformRepository>(
  (ref) => FirestorePlatformRepository(ref.watch(firestoreProvider)),
);

final resaleConfigProvider = StreamProvider<ResaleConfig>(
  (ref) => ref.watch(platformRepositoryProvider).watchResale(),
);

final sellerLimitsProvider = StreamProvider<SellerLimits>(
  (ref) => ref.watch(platformRepositoryProvider).watchLimits(),
);

final companyInfoProvider = StreamProvider<CompanyInfo>(
  (ref) => ref.watch(platformRepositoryProvider).watchCompany(),
);

final sellerStatsProvider = StreamProvider.family<SellerStats, String>(
  (ref, uid) => ref.watch(platformRepositoryProvider).watchSellerStats(uid),
);

final banProvider = StreamProvider.family<UserBan?, String>(
  (ref, uid) => ref.watch(platformRepositoryProvider).watchBan(uid),
);

/// The signed-in user's block, if any.
final myBanProvider = Provider<UserBan?>((ref) {
  final uid = ref.watch(currentUidProvider);
  return uid == null ? null : ref.watch(banProvider(uid)).value;
});

final openReportsProvider = StreamProvider.autoDispose<List<Report>>(
  (ref) => ref.watch(platformRepositoryProvider).watchReports(open: true),
);

final handledReportsProvider = StreamProvider.autoDispose<List<Report>>(
  (ref) => ref.watch(platformRepositoryProvider).watchReports(open: false),
);

final moderationLogProvider = StreamProvider.autoDispose
    .family<List<ModerationEntry>, String>(
      (ref, uid) => ref.watch(platformRepositoryProvider).watchLog(uid),
    );

final listingsOfProvider = StreamProvider.autoDispose
    .family<List<Listing>, String>(
      (ref, uid) => ref.watch(platformRepositoryProvider).watchListingsOf(uid),
    );

final ordersOfProvider = StreamProvider.autoDispose.family<List<Order>, String>(
  (ref, uid) => ref.watch(platformRepositoryProvider).watchOrdersOf(uid),
);

final myInvoicesProvider = StreamProvider.autoDispose<List<PlatformInvoice>>((
  ref,
) {
  final uid = ref.watch(currentUidProvider);
  if (uid == null) return Stream.value(const []);
  return ref.watch(platformRepositoryProvider).watchMyInvoices(uid);
});

final orderInvoicesProvider = StreamProvider.autoDispose
    .family<List<PlatformInvoice>, String>((ref, orderId) {
      final uid = ref.watch(currentUidProvider);
      if (uid == null) return Stream.value(const []);
      return ref
          .watch(platformRepositoryProvider)
          .watchOrderInvoices(orderId, uid);
    });

final invoiceProvider = StreamProvider.autoDispose
    .family<PlatformInvoice?, String>(
      (ref, id) => ref.watch(platformRepositoryProvider).watchInvoice(id),
    );

/// Admins: the invoices of one month (first day of [month]).
final monthInvoicesProvider = StreamProvider.autoDispose
    .family<List<PlatformInvoice>, DateTime>((ref, month) {
      final from = DateTime(month.year, month.month);
      final to = DateTime(month.year, month.month + 1);
      return ref.watch(platformRepositoryProvider).watchInvoices(from, to);
    });
