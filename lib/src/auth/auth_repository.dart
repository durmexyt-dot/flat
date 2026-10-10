import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final firebaseAuthProvider = Provider<FirebaseAuth>(
  (ref) => FirebaseAuth.instance,
);

final authStateProvider = StreamProvider<User?>(
  (ref) => ref.watch(firebaseAuthProvider).authStateChanges(),
);

/// Error categories shown to the user, independent of Firebase error codes.
enum AuthError {
  invalidCredentials,
  userDisabled,
  tooManyRequests,
  network,
  unknown,
}

class AuthException implements Exception {
  const AuthException(this.error);
  final AuthError error;
}

class AuthRepository {
  AuthRepository(this._auth);
  final FirebaseAuth _auth;

  Future<void> signIn({required String email, required String password}) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch (e) {
      throw AuthException(_mapCode(e.code));
    }
  }

  Future<void> signOut() => _auth.signOut();

  static AuthError _mapCode(String code) {
    switch (code) {
      case 'invalid-credential':
      case 'invalid-email':
      case 'user-not-found':
      case 'wrong-password':
      case 'INVALID_LOGIN_CREDENTIALS':
        return AuthError.invalidCredentials;
      case 'user-disabled':
        return AuthError.userDisabled;
      case 'too-many-requests':
        return AuthError.tooManyRequests;
      case 'network-request-failed':
        return AuthError.network;
      default:
        return AuthError.unknown;
    }
  }
}

final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => AuthRepository(ref.watch(firebaseAuthProvider)),
);
