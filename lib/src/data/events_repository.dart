import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart' hide Order;
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'models.dart';
import 'repositories.dart';
import 'live_snapshots.dart';

/// Events: users add them unconfirmed, the team (admins and support
/// accounts) checks, corrects and confirms them. Everybody sees all events
/// that aren't hidden.
abstract class EventRepository {
  /// Events that aren't hidden, soonest first. The team passes
  /// [includeHidden].
  Stream<List<Event>> watchEvents({bool includeHidden = false});
  Stream<Event?> watchEvent(String id);

  /// The event's picture as a base64 JPEG, or null.
  Future<String?> loadImage(String id);

  /// Adds an event and returns its id: confirmed when the team adds it
  /// ([byStaff]), otherwise waiting for the team to check it.
  Future<String> createEvent(
    EventInfo info, {
    required String createdBy,
    required bool byStaff,
    String genre = '',
    String? imageBase64,
  });

  /// The team saves changes. [imageBase64] replaces the picture,
  /// [removeImage] drops it.
  Future<void> updateEvent(
    String id,
    EventInfo info, {
    String genre = '',
    String? imageBase64,
    bool removeImage = false,
  });

  /// The team confirms, hides or shows an event again.
  Future<void> setStatus(String id, EventStatus status);
}

/// What the security rules accept as an event's status.
String _statusName(EventStatus s) => s.name;

class FirestoreEventRepository implements EventRepository {
  FirestoreEventRepository(this._db);
  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> get _events =>
      _db.collection('events');
  DocumentReference<Map<String, dynamic>> _image(String id) =>
      _db.collection('eventImages').doc(id);

  Event _event(DocumentSnapshot<Map<String, dynamic>> d) =>
      Event.fromMap(d.id, firestoreData(d));

  @override
  Stream<List<Event>> watchEvents({bool includeHidden = false}) {
    // One filter only, sorted on the device: no composite index needed.
    // The list must match the rules' list of visible statuses.
    final Query<Map<String, dynamic>> q = includeHidden
        ? _events
        : _events.where('status', whereIn: visibleEventStatuses);
    return q.liveSnapshots().map(
      (s) =>
          [for (final d in s.docs) _event(d)]
            ..sort((a, b) => a.info.date.compareTo(b.info.date)),
    );
  }

  @override
  Stream<Event?> watchEvent(String id) =>
      _events.doc(id).liveSnapshots().map((d) => d.exists ? _event(d) : null);

  @override
  Future<String?> loadImage(String id) async =>
      (await _image(id).get()).data()?['data'] as String?;

  @override
  Future<String> createEvent(
    EventInfo info, {
    required String createdBy,
    required bool byStaff,
    String genre = '',
    String? imageBase64,
  }) async {
    final ref = _events.doc();
    final batch = _db.batch()
      ..set(ref, {
        ...info.toMap(),
        'genre': genre,
        'status': _statusName(
          byStaff ? EventStatus.confirmed : EventStatus.pending,
        ),
        'createdBy': createdBy,
        'hasImage': imageBase64 != null,
        'imageVersion': 1,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    if (imageBase64 != null) {
      batch.set(_image(ref.id), {
        'data': imageBase64,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    }
    await batch.commit();
    return ref.id;
  }

  @override
  Future<void> updateEvent(
    String id,
    EventInfo info, {
    String genre = '',
    String? imageBase64,
    bool removeImage = false,
  }) async {
    final batch = _db.batch()
      ..update(_events.doc(id), {
        ...info.toMap(),
        'genre': genre,
        if (imageBase64 != null) 'hasImage': true,
        if (removeImage && imageBase64 == null) 'hasImage': false,
        if (imageBase64 != null || removeImage)
          'imageVersion': FieldValue.increment(1),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    if (imageBase64 != null) {
      batch.set(_image(id), {
        'data': imageBase64,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } else if (removeImage) {
      batch.delete(_image(id));
    }
    await batch.commit();
  }

  @override
  Future<void> setStatus(String id, EventStatus status) =>
      _events.doc(id).update({
        'status': _statusName(status),
        'updatedAt': FieldValue.serverTimestamp(),
      });
}

/// Statuses everybody may read. "active" is how v1.3.0 stored events.
const visibleEventStatuses = ['pending', 'confirmed', 'active'];

/// Events held in memory, for tests.
class InMemoryEventRepository implements EventRepository {
  InMemoryEventRepository({List<Event> events = const []})
    : _events = [...events];

  final List<Event> _events;
  final _images = <String, String>{};
  final _changes = StreamController<void>.broadcast();
  var _nextId = 1;

  Stream<T> _watch<T>(T Function() read) async* {
    yield read();
    yield* _changes.stream.map((_) => read());
  }

  @override
  Stream<List<Event>> watchEvents({bool includeHidden = false}) => _watch(
    () =>
        _events.where((e) => includeHidden || !e.hidden).toList()
          ..sort((a, b) => a.info.date.compareTo(b.info.date)),
  );

  @override
  Stream<Event?> watchEvent(String id) =>
      _watch(() => _events.where((e) => e.id == id).firstOrNull);

  @override
  Future<String?> loadImage(String id) async => _images[id];

  void _put(Event e) {
    _events
      ..removeWhere((x) => x.id == e.id)
      ..add(e);
    _changes.add(null);
  }

  Event _get(String id) => _events.firstWhere((e) => e.id == id);

  @override
  Future<String> createEvent(
    EventInfo info, {
    required String createdBy,
    required bool byStaff,
    String genre = '',
    String? imageBase64,
  }) async {
    final id = 'event-${_nextId++}';
    if (imageBase64 != null) _images[id] = imageBase64;
    _put(
      Event(
        id: id,
        info: info,
        status: byStaff ? EventStatus.confirmed : EventStatus.pending,
        genre: genre,
        createdBy: createdBy,
        hasImage: imageBase64 != null,
        imageVersion: 1,
        createdAt: DateTime.now(),
      ),
    );
    return id;
  }

  @override
  Future<void> updateEvent(
    String id,
    EventInfo info, {
    String genre = '',
    String? imageBase64,
    bool removeImage = false,
  }) async {
    final old = _get(id);
    if (imageBase64 != null) {
      _images[id] = imageBase64;
    } else if (removeImage) {
      _images.remove(id);
    }
    _put(
      old.copyWith(
        info: info,
        genre: genre,
        hasImage: _images.containsKey(id),
        imageVersion: old.imageVersion + 1,
      ),
    );
  }

  @override
  Future<void> setStatus(String id, EventStatus status) async =>
      _put(_get(id).copyWith(status: status));
}

final eventRepositoryProvider = Provider<EventRepository>(
  (ref) => FirestoreEventRepository(ref.watch(firestoreProvider)),
);

/// Visible events, soonest first, including past ones (pages filter).
final eventsProvider = StreamProvider<List<Event>>(
  (ref) => ref.watch(eventRepositoryProvider).watchEvents(),
);

/// Visible events that haven't happened yet: what the home page and the
/// sell form offer.
final upcomingEventsProvider = Provider<AsyncValue<List<Event>>>(
  (ref) => ref
      .watch(eventsProvider)
      .whenData(
        (all) => [
          for (final e in all)
            if (e.isUpcoming) e,
        ],
      ),
);

/// For the team: events users added that wait for a check.
final pendingEventsProvider = Provider<List<Event>>(
  (ref) => [
    for (final e in ref.watch(eventsProvider).value ?? const <Event>[])
      if (e.pending) e,
  ],
);

/// All events including hidden ones, for the team.
final allEventsProvider = StreamProvider<List<Event>>(
  (ref) => ref.watch(eventRepositoryProvider).watchEvents(includeHidden: true),
);

final eventProvider = StreamProvider.family<Event?, String>(
  (ref, id) => ref.watch(eventRepositoryProvider).watchEvent(id),
);

/// The decoded picture of an event. Keyed by version, so a new picture
/// loads fresh and an unchanged one comes from memory.
final eventImageProvider = FutureProvider.family<Uint8List?, (String, int)>((
  ref,
  key,
) async {
  final data = await ref.watch(eventRepositoryProvider).loadImage(key.$1);
  ref.keepAlive();
  return data == null ? null : base64Decode(data);
});

/// Active listings for one event, cheapest first.
final eventListingsProvider = StreamProvider.family<List<Listing>, String>(
  (ref, eventId) =>
      ref.watch(marketRepositoryProvider).watchEventListings(eventId),
);

/// Per event: how many tickets are on sale and from which price, from the
/// active listings. Events without tickets have no entry.
@immutable
class EventOffer {
  const EventOffer({
    required this.tickets,
    required this.minPriceMinor,
    required this.currency,
    this.sold = 0,
  });

  /// Tickets on sale.
  final int tickets;

  /// Tickets already sold from listings still on sale: with [tickets] a
  /// measure of how popular the event is.
  final int sold;
  final int minPriceMinor;
  final String currency;
}

final eventOffersProvider = Provider<Map<String, EventOffer>>((ref) {
  final listings = ref.watch(activeListingsProvider).value ?? const [];
  final offers = <String, EventOffer>{};
  for (final l in listings) {
    if (l.eventId.isEmpty || l.available <= 0) continue;
    final o = offers[l.eventId];
    offers[l.eventId] = EventOffer(
      tickets: (o?.tickets ?? 0) + l.available,
      sold: (o?.sold ?? 0) + l.quantitySold,
      minPriceMinor: o == null || l.priceMinor < o.minPriceMinor
          ? l.priceMinor
          : o.minPriceMinor,
      currency: o == null || l.priceMinor < o.minPriceMinor
          ? l.currency
          : o.currency,
    );
  }
  return offers;
});
