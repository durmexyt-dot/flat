import 'dart:async';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart' hide Order;
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'live_snapshots.dart';
import 'models.dart';
import 'repositories.dart';

/// Ticket files. Sellers upload them for a listing (now or after the sale);
/// a Cloud Function hands them to paid orders, where the buyer downloads
/// them.
abstract class TicketFileRepository {
  /// The seller's uploaded files of a listing.
  Stream<List<TicketFile>> watchListingFiles(String listingId);

  /// The files an order received.
  Stream<List<TicketFile>> watchOrderFiles(String orderId);

  /// Uploads a file for [listing] holding [tickets] tickets.
  Future<void> upload({
    required Listing listing,
    required Uint8List bytes,
    required String name,
    required String contentType,
    int tickets = 1,
  });

  /// Removes a file that was not handed to a buyer yet.
  Future<void> delete(String listingId, TicketFile file);

  /// A link to download the file (only for those allowed to read it).
  Future<String> downloadUrl(TicketFile file);
}

class FirebaseTicketFileRepository implements TicketFileRepository {
  FirebaseTicketFileRepository(this._db, this._storage);
  final FirebaseFirestore _db;
  final FirebaseStorage _storage;

  CollectionReference<Map<String, dynamic>> _listingFiles(String id) =>
      _db.collection('listings').doc(id).collection('files');

  List<TicketFile> _files(QuerySnapshot<Map<String, dynamic>> q) =>
      [for (final d in q.docs) TicketFile.fromMap(d.id, firestoreData(d))]
        ..sort((a, b) => (a.at ?? DateTime(0)).compareTo(b.at ?? DateTime(0)));

  @override
  Stream<List<TicketFile>> watchListingFiles(String listingId) =>
      _listingFiles(listingId).liveSnapshots().map(_files);

  @override
  Stream<List<TicketFile>> watchOrderFiles(String orderId) => _db
      .collection('orders')
      .doc(orderId)
      .collection('files')
      .liveSnapshots()
      .map(_files);

  @override
  Future<void> upload({
    required Listing listing,
    required Uint8List bytes,
    required String name,
    required String contentType,
    int tickets = 1,
  }) async {
    final doc = _listingFiles(listing.id).doc();
    final path = 'tickets/${listing.sellerId}/${listing.id}/${doc.id}';
    // The file first: the document makes the Cloud Function deliver it.
    await _storage
        .ref(path)
        .putData(bytes, SettableMetadata(contentType: contentType));
    await doc.set({
      'name': name.length > 120 ? name.substring(name.length - 120) : name,
      'contentType': contentType,
      'size': bytes.length,
      'storagePath': path,
      'tickets': tickets,
      'orderId': null,
      'uploadedAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<void> delete(String listingId, TicketFile file) async {
    await _listingFiles(listingId).doc(file.id).delete();
    await _storage.ref(file.storagePath).delete().catchError((Object _) {});
  }

  @override
  Future<String> downloadUrl(TicketFile file) =>
      _storage.ref(file.storagePath).getDownloadURL();
}

/// Ticket files held in memory, for tests. [deliver] plays the Cloud
/// Function.
class InMemoryTicketFileRepository implements TicketFileRepository {
  final listingFiles = <String, List<TicketFile>>{};
  final orderFiles = <String, List<TicketFile>>{};
  final _changes = StreamController<void>.broadcast();
  var _next = 1;

  Stream<T> _watch<T>(T Function() read) async* {
    yield read();
    yield* _changes.stream.map((_) => read());
  }

  @override
  Stream<List<TicketFile>> watchListingFiles(String listingId) =>
      _watch(() => [...?listingFiles[listingId]]);

  @override
  Stream<List<TicketFile>> watchOrderFiles(String orderId) =>
      _watch(() => [...?orderFiles[orderId]]);

  @override
  Future<void> upload({
    required Listing listing,
    required Uint8List bytes,
    required String name,
    required String contentType,
    int tickets = 1,
  }) async {
    final id = 'file-${_next++}';
    listingFiles
        .putIfAbsent(listing.id, () => [])
        .add(
          TicketFile(
            id: id,
            name: name,
            contentType: contentType,
            size: bytes.length,
            storagePath: 'tickets/${listing.sellerId}/${listing.id}/$id',
            tickets: tickets,
            at: DateTime.now(),
          ),
        );
    _changes.add(null);
  }

  /// Gives [order] its tickets from the listing's waiting files.
  void deliver(String listingId, String orderId, int quantity) {
    final files = listingFiles[listingId] ?? [];
    var need = quantity;
    for (var i = 0; i < files.length && need > 0; i++) {
      final f = files[i];
      if (f.assigned || f.tickets > need) continue;
      files[i] = TicketFile(
        id: f.id,
        name: f.name,
        contentType: f.contentType,
        size: f.size,
        storagePath: f.storagePath,
        tickets: f.tickets,
        orderId: orderId,
        at: f.at,
      );
      orderFiles
          .putIfAbsent(orderId, () => [])
          .add(
            TicketFile(
              id: f.id,
              name: f.name,
              contentType: f.contentType,
              size: f.size,
              storagePath: 'deliveries/$orderId/${f.id}',
              tickets: f.tickets,
              at: DateTime.now(),
            ),
          );
      need -= f.tickets;
    }
    _changes.add(null);
  }

  @override
  Future<void> delete(String listingId, TicketFile file) async {
    listingFiles[listingId]?.removeWhere((f) => f.id == file.id);
    _changes.add(null);
  }

  @override
  Future<String> downloadUrl(TicketFile file) async =>
      'https://example.test/${file.storagePath}';
}

final firebaseStorageProvider = Provider<FirebaseStorage>(
  (ref) => FirebaseStorage.instance,
);

final ticketFileRepositoryProvider = Provider<TicketFileRepository>(
  (ref) => FirebaseTicketFileRepository(
    ref.watch(firestoreProvider),
    ref.watch(firebaseStorageProvider),
  ),
);

final listingFilesProvider = StreamProvider.family<List<TicketFile>, String>(
  (ref, id) => ref.watch(ticketFileRepositoryProvider).watchListingFiles(id),
);

final orderFilesProvider = StreamProvider.family<List<TicketFile>, String>(
  (ref, id) => ref.watch(ticketFileRepositoryProvider).watchOrderFiles(id),
);

/// The seller's sales still waiting for e-ticket uploads: the warning on
/// their pages until every buyer has the tickets.
final salesAwaitingTicketsProvider = Provider<List<Order>>(
  (ref) => [
    for (final o in ref.watch(salesProvider).value ?? const <Order>[])
      if (o.ticketsMissing > 0) o,
  ],
);
