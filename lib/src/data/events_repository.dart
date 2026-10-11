import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart' hide Order;
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'models.dart';
import 'repositories.dart';

/// Events are created by admins; everybody can see the visible ones.
abstract class EventRepository {
  /// Visible events, soonest first. Admins pass [includeHidden].
  Stream<List<Event>> watchEvents({bool includeHidden = false});
  Stream<Event?> watchEvent(String id);

  /// The event's picture as a base64 JPEG, or null.
  Future<String?> loadImage(String id);

  /// Creates an event with an optional picture and returns its id.
  Future<String> createEvent(EventInfo info, {String? imageBase64});

  /// Saves changes. [imageBase64] replaces the picture, [removeImage]
  /// drops it.
  Future<void> updateEvent(
    String id,
    EventInfo info, {
    String? imageBase64,
    bool removeImage = false,
  });
  Future<void> setHidden(String id, bool hidden);
}

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
    final Query<Map<String, dynamic>> q = includeHidden
        ? _events
        : _events.where('status', isEqualTo: 'active');
    return q.snapshots().map(
      (s) =>
          [for (final d in s.docs) _event(d)]
            ..sort((a, b) => a.info.date.compareTo(b.info.date)),
    );
  }

  @override
  Stream<Event?> watchEvent(String id) =>
      _events.doc(id).snapshots().map((d) => d.exists ? _event(d) : null);

  @override
  Future<String?> loadImage(String id) async =>
      (await _image(id).get()).data()?['data'] as String?;

  @override
  Future<String> createEvent(EventInfo info, {String? imageBase64}) async {
    final ref = _events.doc();
    final batch = _db.batch()
      ..set(ref, {
        ...info.toMap(),
        'status': 'active',
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
    String? imageBase64,
    bool removeImage = false,
  }) async {
    final batch = _db.batch()
      ..update(_events.doc(id), {
        ...info.toMap(),
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
  Future<void> setHidden(String id, bool hidden) => _events.doc(id).update({
    'status': hidden ? 'hidden' : 'active',
    'updatedAt': FieldValue.serverTimestamp(),
  });
}

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

  @override
  Future<String> createEvent(EventInfo info, {String? imageBase64}) async {
    final id = 'event-${_nextId++}';
    if (imageBase64 != null) _images[id] = imageBase64;
    _put(
      Event(
        id: id,
        info: info,
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
    String? imageBase64,
    bool removeImage = false,
  }) async {
    final old = _events.firstWhere((e) => e.id == id);
    if (imageBase64 != null) {
      _images[id] = imageBase64;
    } else if (removeImage) {
      _images.remove(id);
    }
    _put(
      Event(
        id: id,
        info: info,
        hasImage: _images.containsKey(id),
        imageVersion: old.imageVersion + 1,
        hidden: old.hidden,
        createdAt: old.createdAt,
      ),
    );
  }

  @override
  Future<void> setHidden(String id, bool hidden) async {
    final old = _events.firstWhere((e) => e.id == id);
    _put(
      Event(
        id: id,
        info: old.info,
        hasImage: old.hasImage,
        imageVersion: old.imageVersion,
        hidden: hidden,
        createdAt: old.createdAt,
      ),
    );
  }
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

/// All events including hidden ones, for admins.
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
  });
  final int tickets;
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
