import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart' hide Order;
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'live_snapshots.dart';
import 'models.dart';
import 'repositories.dart';

/// Seat maps of venues. Everybody reads them; the team (admins and support
/// accounts) draws and changes them.
abstract class SeatMapRepository {
  /// All maps, by venue name.
  Stream<List<SeatMap>> watchSeatMaps();

  /// The map with [id] (see [seatMapId]), or null if there is none yet.
  Stream<SeatMap?> watchSeatMap(String id);

  /// The map's picture as a base64 JPEG, or null.
  Future<String?> loadImage(String id);

  /// Saves [map]. [imageBase64] replaces the picture, [removeImage] drops
  /// it.
  Future<void> saveSeatMap(
    SeatMap map, {
    String? imageBase64,
    bool removeImage = false,
  });

  Future<void> deleteSeatMap(String id);
}

class FirestoreSeatMapRepository implements SeatMapRepository {
  FirestoreSeatMapRepository(this._db);
  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> get _maps =>
      _db.collection('seatMaps');
  DocumentReference<Map<String, dynamic>> _image(String id) =>
      _db.collection('seatMapImages').doc(id);

  @override
  Stream<List<SeatMap>> watchSeatMaps() => _maps.liveSnapshots().map(
    (s) =>
        [for (final d in s.docs) SeatMap.fromMap(d.id, firestoreData(d))]
          ..sort((a, b) => a.venue.compareTo(b.venue)),
  );

  @override
  Stream<SeatMap?> watchSeatMap(String id) => _maps
      .doc(id)
      .liveSnapshots()
      .map((d) => d.exists ? SeatMap.fromMap(d.id, firestoreData(d)) : null);

  @override
  Future<String?> loadImage(String id) async =>
      (await _image(id).get()).data()?['data'] as String?;

  @override
  Future<void> saveSeatMap(
    SeatMap map, {
    String? imageBase64,
    bool removeImage = false,
  }) async {
    final hasImage = imageBase64 != null || (map.hasImage && !removeImage);
    final batch = _db.batch()
      ..set(_maps.doc(map.id), {
        ...map.toMap(),
        'hasImage': hasImage,
        'imageVersion': map.imageVersion + 1,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    if (imageBase64 != null) {
      batch.set(_image(map.id), {
        'data': imageBase64,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } else if (removeImage && map.hasImage) {
      batch.delete(_image(map.id));
    }
    await batch.commit();
  }

  @override
  Future<void> deleteSeatMap(String id) async {
    final batch = _db.batch()
      ..delete(_maps.doc(id))
      ..delete(_image(id));
    await batch.commit();
  }
}

/// Seat maps held in memory, for tests.
class InMemorySeatMapRepository implements SeatMapRepository {
  InMemorySeatMapRepository({List<SeatMap> maps = const []})
    : _maps = {for (final m in maps) m.id: m};

  final Map<String, SeatMap> _maps;
  final _images = <String, String>{};
  final _changes = StreamController<void>.broadcast();

  Stream<T> _watch<T>(T Function() read) async* {
    yield read();
    yield* _changes.stream.map((_) => read());
  }

  @override
  Stream<List<SeatMap>> watchSeatMaps() => _watch(
    () => _maps.values.toList()..sort((a, b) => a.venue.compareTo(b.venue)),
  );

  @override
  Stream<SeatMap?> watchSeatMap(String id) => _watch(() => _maps[id]);

  @override
  Future<String?> loadImage(String id) async => _images[id];

  @override
  Future<void> saveSeatMap(
    SeatMap map, {
    String? imageBase64,
    bool removeImage = false,
  }) async {
    if (imageBase64 != null) {
      _images[map.id] = imageBase64;
    } else if (removeImage) {
      _images.remove(map.id);
    }
    _maps[map.id] = map.copyWith(
      hasImage: _images.containsKey(map.id),
      imageVersion: map.imageVersion + 1,
    );
    _changes.add(null);
  }

  @override
  Future<void> deleteSeatMap(String id) async {
    _maps.remove(id);
    _images.remove(id);
    _changes.add(null);
  }
}

final seatMapRepositoryProvider = Provider<SeatMapRepository>(
  (ref) => FirestoreSeatMapRepository(ref.watch(firestoreProvider)),
);

final seatMapsProvider = StreamProvider<List<SeatMap>>(
  (ref) => ref.watch(seatMapRepositoryProvider).watchSeatMaps(),
);

/// The seat map of a venue, by [seatMapId].
final seatMapProvider = StreamProvider.family<SeatMap?, String>(
  (ref, id) => ref.watch(seatMapRepositoryProvider).watchSeatMap(id),
);

/// The decoded picture of a seat map, keyed by version.
final seatMapImageProvider = FutureProvider.family<Uint8List?, (String, int)>((
  ref,
  key,
) async {
  final data = await ref.watch(seatMapRepositoryProvider).loadImage(key.$1);
  ref.keepAlive();
  return data == null ? null : base64Decode(data);
});
