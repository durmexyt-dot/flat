import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart' hide Order;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../admin/admin_repository.dart';
import '../config/app_info.dart';
import '../data/models.dart';
import '../data/repositories.dart';

/// Support requests run inside the app: a ticket with a conversation
/// between the user and the support team (admins and support accounts).
abstract class SupportRepository {
  /// The user's own requests, newest activity first.
  Stream<List<SupportTicket>> watchMyTickets(String uid);

  /// For the team: all requests, newest activity first.
  Stream<List<SupportTicket>> watchAllTickets();

  Stream<SupportTicket?> watchTicket(String id);
  Stream<List<SupportMessage>> watchMessages(String ticketId);

  /// Opens a request with its first message and returns the ticket id.
  Future<String> createTicket({
    required String uid,
    required String email,
    required String name,
    required SupportTopic topic,
    required String reference,
    required String text,
    List<String> images = const [],
  });

  /// Adds a message. A team answer marks the ticket answered and unread for
  /// the user; a user message reopens it for the team.
  Future<void> sendMessage({
    required SupportTicket ticket,
    required String authorId,
    required String authorName,
    required bool fromStaff,
    required String text,
    List<String> images = const [],
  });

  /// The user or the team opened the ticket.
  Future<void> markRead(String ticketId, {required bool byStaff});

  Future<void> closeTicket(String ticketId, {required bool byStaff});
}

/// The first words of a message, as the ticket's subject in lists.
String supportSubject(String text) {
  final oneLine = text.trim().replaceAll(RegExp(r'\s+'), ' ');
  return oneLine.length <= 80 ? oneLine : '${oneLine.substring(0, 79)}…';
}

int _byActivity(SupportTicket a, SupportTicket b) =>
    (b.lastMessageAt ?? b.createdAt ?? DateTime(0)).compareTo(
      a.lastMessageAt ?? a.createdAt ?? DateTime(0),
    );

class FirestoreSupportRepository implements SupportRepository {
  FirestoreSupportRepository(this._db);
  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> get _tickets =>
      _db.collection('supportTickets');
  CollectionReference<Map<String, dynamic>> _messages(String id) =>
      _tickets.doc(id).collection('messages');

  List<SupportTicket> _list(QuerySnapshot<Map<String, dynamic>> q) =>
      [for (final d in q.docs) SupportTicket.fromMap(d.id, firestoreData(d))]
        ..sort(_byActivity);

  @override
  Stream<List<SupportTicket>> watchMyTickets(String uid) =>
      _tickets.where('uid', isEqualTo: uid).snapshots().map(_list);

  @override
  Stream<List<SupportTicket>> watchAllTickets() => _tickets
      .orderBy('lastMessageAt', descending: true)
      .limit(300)
      .snapshots()
      .map(_list);

  @override
  Stream<SupportTicket?> watchTicket(String id) => _tickets
      .doc(id)
      .snapshots()
      .map(
        (d) => d.exists ? SupportTicket.fromMap(d.id, firestoreData(d)) : null,
      );

  @override
  Stream<List<SupportMessage>> watchMessages(String ticketId) =>
      _messages(ticketId)
          .orderBy('createdAt')
          .snapshots()
          .map(
            (q) => [
              for (final d in q.docs)
                SupportMessage.fromMap(d.id, firestoreData(d)),
            ],
          );

  @override
  Future<String> createTicket({
    required String uid,
    required String email,
    required String name,
    required SupportTopic topic,
    required String reference,
    required String text,
    List<String> images = const [],
  }) async {
    final ref = _tickets.doc();
    final batch = _db.batch()
      ..set(ref, {
        'number': 'SUP-${randomCode(6)}',
        'uid': uid,
        'email': email,
        'name': name,
        'topic': topic.name,
        'reference': reference,
        'subject': supportSubject(text),
        'status': SupportStatus.open.name,
        'unreadForUser': false,
        'unreadForStaff': true,
        // Which app version the user had: helps to reproduce a problem.
        'appVersion': AppInfo.label,
        'createdAt': FieldValue.serverTimestamp(),
        'lastMessageAt': FieldValue.serverTimestamp(),
      })
      ..set(ref.collection('messages').doc(), {
        'authorId': uid,
        'authorRole': 'user',
        'authorName': name,
        'text': text,
        'images': images,
        'createdAt': FieldValue.serverTimestamp(),
      });
    await batch.commit();
    return ref.id;
  }

  @override
  Future<void> sendMessage({
    required SupportTicket ticket,
    required String authorId,
    required String authorName,
    required bool fromStaff,
    required String text,
    List<String> images = const [],
  }) async {
    final batch = _db.batch()
      ..set(_messages(ticket.id).doc(), {
        'authorId': authorId,
        'authorRole': fromStaff ? 'staff' : 'user',
        'authorName': authorName,
        'text': text,
        'images': images,
        'createdAt': FieldValue.serverTimestamp(),
      })
      ..update(_tickets.doc(ticket.id), {
        'status':
            (fromStaff ? SupportStatus.answered : SupportStatus.open).name,
        'unreadForUser': fromStaff,
        'unreadForStaff': !fromStaff,
        'lastMessageAt': FieldValue.serverTimestamp(),
      });
    await batch.commit();
  }

  @override
  Future<void> markRead(String ticketId, {required bool byStaff}) => _tickets
      .doc(ticketId)
      .update({byStaff ? 'unreadForStaff' : 'unreadForUser': false});

  @override
  Future<void> closeTicket(String ticketId, {required bool byStaff}) =>
      _tickets.doc(ticketId).update({
        'status': SupportStatus.closed.name,
        'closedBy': byStaff ? 'staff' : 'user',
        'unreadForStaff': false,
        // The user learns that the team closed it.
        'unreadForUser': byStaff,
      });
}

/// Support held in memory, for tests.
class InMemorySupportRepository implements SupportRepository {
  final tickets = <SupportTicket>[];
  final messages = <String, List<SupportMessage>>{};
  final _changes = StreamController<void>.broadcast();
  var _nextId = 1;

  Stream<T> _watch<T>(T Function() read) async* {
    yield read();
    yield* _changes.stream.map((_) => read());
  }

  void _put(SupportTicket t) {
    final i = tickets.indexWhere((x) => x.id == t.id);
    if (i < 0) {
      tickets.add(t);
    } else {
      tickets[i] = t;
    }
    _changes.add(null);
  }

  SupportTicket _copy(
    SupportTicket t, {
    SupportStatus? status,
    bool? unreadForUser,
    bool? unreadForStaff,
    String? closedBy,
    DateTime? lastMessageAt,
  }) => SupportTicket(
    id: t.id,
    number: t.number,
    uid: t.uid,
    email: t.email,
    name: t.name,
    topic: t.topic,
    status: status ?? t.status,
    reference: t.reference,
    subject: t.subject,
    unreadForUser: unreadForUser ?? t.unreadForUser,
    unreadForStaff: unreadForStaff ?? t.unreadForStaff,
    closedBy: closedBy ?? t.closedBy,
    appVersion: t.appVersion,
    createdAt: t.createdAt,
    lastMessageAt: lastMessageAt ?? t.lastMessageAt,
  );

  SupportTicket _get(String id) => tickets.firstWhere((t) => t.id == id);

  @override
  Stream<List<SupportTicket>> watchMyTickets(String uid) => _watch(
    () => tickets.where((t) => t.uid == uid).toList()..sort(_byActivity),
  );

  @override
  Stream<List<SupportTicket>> watchAllTickets() =>
      _watch(() => [...tickets]..sort(_byActivity));

  @override
  Stream<SupportTicket?> watchTicket(String id) =>
      _watch(() => tickets.where((t) => t.id == id).firstOrNull);

  @override
  Stream<List<SupportMessage>> watchMessages(String ticketId) =>
      _watch(() => [...?messages[ticketId]]);

  void _addMessage(
    String ticketId,
    String authorId,
    String authorName,
    bool fromStaff,
    String text,
    List<String> images,
  ) {
    final list = messages.putIfAbsent(ticketId, () => []);
    list.add(
      SupportMessage(
        id: 'm${list.length + 1}',
        authorId: authorId,
        fromStaff: fromStaff,
        authorName: authorName,
        text: text,
        images: images,
        createdAt: DateTime.now(),
      ),
    );
  }

  @override
  Future<String> createTicket({
    required String uid,
    required String email,
    required String name,
    required SupportTopic topic,
    required String reference,
    required String text,
    List<String> images = const [],
  }) async {
    final id = 'ticket-${_nextId++}';
    _addMessage(id, uid, name, false, text, images);
    _put(
      SupportTicket(
        id: id,
        number: 'SUP-${100000 + _nextId}',
        uid: uid,
        email: email,
        name: name,
        topic: topic,
        status: SupportStatus.open,
        reference: reference,
        subject: supportSubject(text),
        unreadForStaff: true,
        createdAt: DateTime.now(),
        lastMessageAt: DateTime.now(),
      ),
    );
    return id;
  }

  @override
  Future<void> sendMessage({
    required SupportTicket ticket,
    required String authorId,
    required String authorName,
    required bool fromStaff,
    required String text,
    List<String> images = const [],
  }) async {
    _addMessage(ticket.id, authorId, authorName, fromStaff, text, images);
    _put(
      _copy(
        _get(ticket.id),
        status: fromStaff ? SupportStatus.answered : SupportStatus.open,
        unreadForUser: fromStaff,
        unreadForStaff: !fromStaff,
        lastMessageAt: DateTime.now(),
      ),
    );
  }

  @override
  Future<void> markRead(String ticketId, {required bool byStaff}) async => _put(
    byStaff
        ? _copy(_get(ticketId), unreadForStaff: false)
        : _copy(_get(ticketId), unreadForUser: false),
  );

  @override
  Future<void> closeTicket(String ticketId, {required bool byStaff}) async =>
      _put(
        _copy(
          _get(ticketId),
          status: SupportStatus.closed,
          closedBy: byStaff ? 'staff' : 'user',
          unreadForStaff: false,
          unreadForUser: byStaff,
        ),
      );
}

final supportRepositoryProvider = Provider<SupportRepository>(
  (ref) => FirestoreSupportRepository(ref.watch(firestoreProvider)),
);

/// The signed-in user's own requests.
final myTicketsProvider = StreamProvider<List<SupportTicket>>((ref) {
  final uid = ref.watch(currentUidProvider);
  if (uid == null) return Stream.value(const []);
  return ref.watch(supportRepositoryProvider).watchMyTickets(uid);
});

/// Requests with a support answer the user hasn't read: the badge on the
/// profile picture and in the help center.
final unreadSupportAnswersProvider = Provider<int>(
  (ref) =>
      ref
          .watch(myTicketsProvider)
          .value
          ?.where((t) => t.unreadForUser)
          .length ??
      0,
);

/// For the team: all requests. Empty for everybody else.
final staffTicketsProvider = StreamProvider<List<SupportTicket>>((ref) {
  if (!ref.watch(isStaffProvider)) return Stream.value(const []);
  return ref.watch(supportRepositoryProvider).watchAllTickets();
});

/// For the team: requests waiting for someone to read them.
final unreadForStaffProvider = Provider<int>(
  (ref) =>
      ref
          .watch(staffTicketsProvider)
          .value
          ?.where((t) => t.unreadForStaff)
          .length ??
      0,
);

/// What the badge on the profile picture counts: unread answers, plus new
/// requests for the team.
final accountBadgeProvider = Provider<int>(
  (ref) =>
      ref.watch(unreadSupportAnswersProvider) +
      ref.watch(unreadForStaffProvider),
);

final supportTicketProvider = StreamProvider.family<SupportTicket?, String>(
  (ref, id) => ref.watch(supportRepositoryProvider).watchTicket(id),
);

final supportMessagesProvider =
    StreamProvider.family<List<SupportMessage>, String>(
      (ref, id) => ref.watch(supportRepositoryProvider).watchMessages(id),
    );
