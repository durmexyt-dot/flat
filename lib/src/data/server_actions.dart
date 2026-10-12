import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'models.dart';

/// Thrown when the server refuses an action, with its message.
class ServerActionException implements Exception {
  const ServerActionException(this.code, this.message);
  final String code;
  final String message;

  @override
  String toString() => 'ServerActionException($code: $message)';
}

/// Actions that run on the server (Cloud Functions), because they change
/// many documents or other people's data: reporting a problem, the team's
/// decisions, cancelling or moving an event.
abstract class ServerActions {
  /// The buyer reports a problem; returns the support request's id.
  Future<String> openDispute({
    required String orderId,
    required DisputeReason reason,
    required String text,
  });

  /// The team decides on a reported problem: refund or continue.
  Future<void> resolveDispute({
    required String orderId,
    required bool refund,
    String note = '',
  });

  /// The team calls an event off; returns how many buyers were refunded.
  Future<int> cancelEvent({required String eventId, required String reason});

  /// The team moves an event to [newDate].
  Future<void> postponeEvent({
    required String eventId,
    required DateTime newDate,
  });

  /// The team blocks or unblocks a user; returns how many listings were
  /// taken off sale.
  Future<int> setUserBan({
    required String uid,
    required bool banned,
    String reason = '',
  });

  /// The team takes a listing off sale.
  Future<void> removeListing({required String listingId, String reason = ''});

  /// The team refunds a paid order.
  Future<void> refundOrder({required String orderId, String reason = ''});

  /// The team lifts (or sets again) the limits of a new seller.
  Future<void> setSellerTrusted({required String uid, required bool trusted});
}

class CloudServerActions implements ServerActions {
  CloudServerActions(this._functions);
  final FirebaseFunctions _functions;

  Future<Map<String, dynamic>> _call(
    String name,
    Map<String, dynamic> data,
  ) async {
    try {
      final result = await _functions.httpsCallable(name).call<Object?>(data);
      final value = result.data;
      return value is Map ? value.cast<String, dynamic>() : const {};
    } on FirebaseFunctionsException catch (e) {
      throw ServerActionException(e.code, e.message ?? e.code);
    }
  }

  @override
  Future<String> openDispute({
    required String orderId,
    required DisputeReason reason,
    required String text,
  }) async =>
      (await _call('openDispute', {
            'orderId': orderId,
            'reason': reason.name,
            'text': text,
          }))['supportTicketId']
          as String? ??
      '';

  @override
  Future<void> resolveDispute({
    required String orderId,
    required bool refund,
    String note = '',
  }) => _call('resolveDispute', {
    'orderId': orderId,
    'decision': refund ? 'refund' : 'reject',
    'note': note,
  });

  @override
  Future<int> cancelEvent({
    required String eventId,
    required String reason,
  }) async =>
      ((await _call('cancelEvent', {
                'eventId': eventId,
                'reason': reason,
              }))['refunded']
              as num?)
          ?.toInt() ??
      0;

  @override
  Future<void> postponeEvent({
    required String eventId,
    required DateTime newDate,
  }) => _call('postponeEvent', {
    'eventId': eventId,
    'newDate': newDate.toUtc().toIso8601String(),
  });

  @override
  Future<int> setUserBan({
    required String uid,
    required bool banned,
    String reason = '',
  }) async =>
      ((await _call('setUserBan', {
                'uid': uid,
                'banned': banned,
                'reason': reason,
              }))['listingsRemoved']
              as num?)
          ?.toInt() ??
      0;

  @override
  Future<void> removeListing({required String listingId, String reason = ''}) =>
      _call('removeListing', {'listingId': listingId, 'reason': reason});

  @override
  Future<void> refundOrder({required String orderId, String reason = ''}) =>
      _call('refundOrder', {'orderId': orderId, 'reason': reason});

  @override
  Future<void> setSellerTrusted({required String uid, required bool trusted}) =>
      _call('setSellerTrusted', {'uid': uid, 'trusted': trusted});
}

/// Records the calls, for tests.
class FakeServerActions implements ServerActions {
  final calls = <String>[];

  @override
  Future<String> openDispute({
    required String orderId,
    required DisputeReason reason,
    required String text,
  }) async {
    calls.add('openDispute $orderId ${reason.name}');
    return 'ticket-1';
  }

  @override
  Future<void> resolveDispute({
    required String orderId,
    required bool refund,
    String note = '',
  }) async =>
      calls.add('resolveDispute $orderId ${refund ? 'refund' : 'reject'}');

  @override
  Future<int> cancelEvent({
    required String eventId,
    required String reason,
  }) async {
    calls.add('cancelEvent $eventId');
    return 0;
  }

  @override
  Future<void> postponeEvent({
    required String eventId,
    required DateTime newDate,
  }) async => calls.add('postponeEvent $eventId');

  @override
  Future<int> setUserBan({
    required String uid,
    required bool banned,
    String reason = '',
  }) async {
    calls.add('setUserBan $uid $banned');
    return 0;
  }

  @override
  Future<void> removeListing({
    required String listingId,
    String reason = '',
  }) async => calls.add('removeListing $listingId');

  @override
  Future<void> refundOrder({
    required String orderId,
    String reason = '',
  }) async => calls.add('refundOrder $orderId');

  @override
  Future<void> setSellerTrusted({
    required String uid,
    required bool trusted,
  }) async => calls.add('setSellerTrusted $uid $trusted');
}

/// The functions run in Europe, next to the database.
final serverActionsProvider = Provider<ServerActions>(
  (ref) =>
      CloudServerActions(FirebaseFunctions.instanceFor(region: 'europe-west1')),
);
