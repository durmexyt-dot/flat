import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The signed-in user, independent of Firebase types.
class AppUser {
  const AppUser({required this.uid, this.email});
  final String uid;
  final String? email;
}

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

abstract class AuthRepository {
  AppUser? get currentUser;
  Stream<AppUser?> authStateChanges();
  Future<void> signIn({required String email, required String password});
  Future<void> signOut();
}

class FirebaseAuthRepository implements AuthRepository {
  FirebaseAuthRepository(this._auth);
  final FirebaseAuth _auth;

  static AppUser? _toAppUser(User? user) =>
      user == null ? null : AppUser(uid: user.uid, email: user.email);

  @override
  AppUser? get currentUser => _toAppUser(_auth.currentUser);

  @override
  Stream<AppUser?> authStateChanges() =>
      _auth.authStateChanges().map(_toAppUser);

  @override
  Future<void> signIn({required String email, required String password}) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch (e) {
      throw AuthException(_mapCode(e.code));
    }
  }

  @override
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
  (ref) => FirebaseAuthRepository(FirebaseAuth.instance),
);

final authStateProvider = StreamProvider<AppUser?>(
  (ref) => ref.watch(authRepositoryProvider).authStateChanges(),
);
