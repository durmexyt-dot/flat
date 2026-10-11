import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';

/// Errors that go away by themselves: a listener started at the very moment
/// the user signs in or out can run with the previous sign-in and be
/// refused once; the network can drop for a moment.
const _transient = {'permission-denied', 'unauthenticated', 'unavailable'};

/// Listens to [open] and starts it again a few times (after 0.4, 1 and 2 s)
/// when it fails with a transient error, before passing the error on.
Stream<T> retryTransient<T>(Stream<T> Function() open) {
  const delays = [
    Duration(milliseconds: 400),
    Duration(seconds: 1),
    Duration(seconds: 2),
  ];
  late final StreamController<T> controller;
  StreamSubscription<T>? sub;
  Timer? retry;
  var attempt = 0;

  void start() {
    sub = open().listen(
      (value) {
        // Working again: a later hiccup gets fresh retries.
        attempt = 0;
        controller.add(value);
      },
      onError: (Object error, StackTrace stack) {
        if (error is FirebaseException &&
            _transient.contains(error.code) &&
            attempt < delays.length) {
          sub?.cancel();
          retry = Timer(delays[attempt++], start);
        } else {
          controller.addError(error, stack);
        }
      },
      onDone: controller.close,
    );
  }

  controller = StreamController<T>(
    onListen: start,
    onCancel: () {
      retry?.cancel();
      return sub?.cancel();
    },
  );
  return controller.stream;
}

extension LiveQuery<T> on Query<T> {
  /// [snapshots] that ride out transient errors (see [retryTransient]).
  Stream<QuerySnapshot<T>> liveSnapshots() => retryTransient(snapshots);
}

extension LiveDocument<T> on DocumentReference<T> {
  /// [snapshots] that ride out transient errors (see [retryTransient]).
  Stream<DocumentSnapshot<T>> liveSnapshots() => retryTransient(snapshots);
}
