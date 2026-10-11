import 'package:firebase_core/firebase_core.dart';

/// Firestore errors that a retry can't fix.
const _final = {
  'permission-denied',
  'unauthenticated',
  'not-found',
  'invalid-argument',
};

/// Retries failed providers a few times for network hiccups, but not errors
/// that won't go away (e.g. missing access), so the UI shows them at once.
Duration? retryPolicy(int retryCount, Object error) {
  if (error is FirebaseException && _final.contains(error.code)) return null;
  if (retryCount >= 3) return null;
  return Duration(milliseconds: 400 * (1 << retryCount));
}
