import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart' hide Order;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/events_repository.dart';
import '../data/repositories.dart';

/// Everything Stubswap stores about a user, for the right of access (GDPR
/// art. 15, ZZLP): profile, payout method, listings, orders, payouts,
/// support requests, invoices, reports, events added.
abstract class DataExportRepository {
  Future<Map<String, dynamic>> collect(String uid);
}

/// Firestore values as JSON: times as ISO text, pictures left out.
Object? jsonValue(Object? v, [String key = '']) => switch (v) {
  Timestamp t => t.toDate().toUtc().toIso8601String(),
  DateTime d => d.toUtc().toIso8601String(),
  // Inline pictures (profile photo, support screenshots) are large base64.
  String s when (key == 'photo' || key == 'data') && s.length > 200 =>
    '[picture]',
  List l when key == 'images' => ['${l.length} picture(s)'],
  Map m => {
    for (final e in m.entries) '${e.key}': jsonValue(e.value, '${e.key}'),
  },
  List l => [for (final x in l) jsonValue(x)],
  _ => v,
};

class FirestoreDataExportRepository implements DataExportRepository {
  FirestoreDataExportRepository(this._db);
  final FirebaseFirestore _db;

  Future<Map<String, dynamic>?> _doc(String path) async {
    try {
      final d = await _db.doc(path).get();
      return d.exists ? jsonValue(d.data()) as Map<String, dynamic> : null;
    } on FirebaseException {
      return null;
    }
  }

  Future<List<Map<String, dynamic>>> _query(
    Query<Map<String, dynamic>> q,
  ) async {
    try {
      return [
        for (final d in (await q.get()).docs)
          {'id': d.id, ...jsonValue(d.data()) as Map<String, dynamic>},
      ];
    } on FirebaseException {
      return const [];
    }
  }

  @override
  Future<Map<String, dynamic>> collect(String uid) async {
    final orders = _db.collection('orders');
    final tickets = await _query(
      _db.collection('supportTickets').where('uid', isEqualTo: uid),
    );
    for (final t in tickets) {
      t['messages'] = await _query(
        _db
            .collection('supportTickets')
            .doc(t['id'] as String)
            .collection('messages'),
      );
    }
    return {
      'profile': await _doc('users/$uid'),
      'publicProfile': await _doc('publicProfiles/$uid'),
      'payoutMethod': await _doc('users/$uid/private/payoutMethod'),
      'listings': await _query(
        _db.collection('listings').where('sellerId', isEqualTo: uid),
      ),
      'purchases': await _query(orders.where('buyerId', isEqualTo: uid)),
      'sales': await _query(orders.where('sellerId', isEqualTo: uid)),
      'payouts': await _query(
        _db.collection('payouts').where('sellerId', isEqualTo: uid),
      ),
      'supportRequests': tickets,
      'invoices': await _query(
        _db.collection('invoices').where('recipientUid', isEqualTo: uid),
      ),
      'reports': await _query(
        _db.collection('reports').where('reporterId', isEqualTo: uid),
      ),
      // Only events the user can still read (not hidden by the team).
      'eventsAdded': await _query(
        _db
            .collection('events')
            .where('createdBy', isEqualTo: uid)
            .where('status', whereIn: visibleEventStatuses),
      ),
      'sellerStats': await _doc('sellerStats/$uid'),
      'block': await _doc('bans/$uid'),
    };
  }
}

/// The file the user downloads: account, data and an explanation.
String exportJson({
  required Map<String, dynamic> data,
  required Map<String, dynamic> account,
  required DateTime now,
}) => const JsonEncoder.withIndent('  ').convert({
  'about':
      'Stubswap – all data stored about this account (right of access, '
      'GDPR art. 15). Pictures are left out.',
  'exportedAt': now.toUtc().toIso8601String(),
  'account': account,
  ...data,
});

final dataExportRepositoryProvider = Provider<DataExportRepository>(
  (ref) => FirestoreDataExportRepository(ref.watch(firestoreProvider)),
);
