import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../settings/settings_controller.dart';

/// The signed-in user, independent of Firebase types.
class AppUser {
  const AppUser({required this.uid, this.email, this.displayName});
  final String uid;
  final String? email;
  final String? displayName;
}

/// Error categories shown to the user, independent of Firebase error codes.
enum AuthError {
  invalidCredentials,
  emailInUse,
  weakPassword,
  userDisabled,
  tooManyRequests,
  network,
  methodDisabled,

  /// The user closed the Google popup; nothing to show.
  cancelled,
  unknown,
}

class AuthException implements Exception {
  const AuthException(this.error);
  final AuthError error;
}

abstract class AuthRepository {
  AppUser? get currentUser;
  Stream<AppUser?> authStateChanges();
  Future<void> signIn({
    required String email,
    required String password,
    required bool keepSignedIn,
  });
  Future<void> signInWithGoogle({required bool keepSignedIn});
  Future<void> signUp({
    required String name,
    required String email,
    required String password,
  });
  Future<void> sendPasswordReset({
    required String email,
    required String languageCode,
  });
  Future<void> signOut();
}

const _keepSignedInKey = 'keepSignedIn';

class FirebaseAuthRepository implements AuthRepository {
  FirebaseAuthRepository(this._auth, this._prefs);
  final FirebaseAuth _auth;
  final SharedPreferences _prefs;

  /// Ends a session the user did not want to keep. On web this is handled by
  /// in-memory persistence; native apps call this once at startup.
  static Future<void> dropUnwantedSession(
    FirebaseAuth auth,
    SharedPreferences prefs,
  ) async {
    if (!kIsWeb && prefs.getBool(_keepSignedInKey) == false) {
      await auth.signOut();
    }
  }

  static AppUser? _toAppUser(User? user) => user == null
      ? null
      : AppUser(
          uid: user.uid,
          email: user.email,
          displayName: user.displayName,
        );

  @override
  AppUser? get currentUser => _toAppUser(_auth.currentUser);

  @override
  Stream<AppUser?> authStateChanges() =>
      _auth.authStateChanges().map(_toAppUser);

  Future<void> _applyKeepSignedIn(bool keep) async {
    await _prefs.setBool(_keepSignedInKey, keep);
    if (kIsWeb) {
      await _auth.setPersistence(
        // NONE keeps the session in memory only, so it ends on reload or when
        // the app is reopened. SESSION would survive reloads, and iOS Safari
        // even restores it after Safari was closed.
        keep ? Persistence.LOCAL : Persistence.NONE,
      );
    }
  }

  Future<void> _guard(Future<void> Function() action) async {
    try {
      await action();
    } on FirebaseAuthException catch (e) {
      throw AuthException(_mapCode(e.code));
    }
  }

  @override
  Future<void> signIn({
    required String email,
    required String password,
    required bool keepSignedIn,
  }) => _guard(() async {
    await _applyKeepSignedIn(keepSignedIn);
    await _auth.signInWithEmailAndPassword(email: email, password: password);
  });

  @override
  Future<void> signInWithGoogle({required bool keepSignedIn}) =>
      _guard(() async {
        await _applyKeepSignedIn(keepSignedIn);
        final provider = GoogleAuthProvider();
        if (kIsWeb) {
          await _auth.signInWithPopup(provider);
        } else {
          await _auth.signInWithProvider(provider);
        }
      });

  @override
  Future<void> signUp({
    required String name,
    required String email,
    required String password,
  }) => _guard(() async {
    await _applyKeepSignedIn(true);
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    await credential.user?.updateDisplayName(name);
    await credential.user?.reload();
  });

  @override
  Future<void> sendPasswordReset({
    required String email,
    required String languageCode,
  }) => _guard(() async {
    await _auth.setLanguageCode(languageCode);
    await _auth.sendPasswordResetEmail(email: email);
  });

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
      case 'email-already-in-use':
      case 'account-exists-with-different-credential':
        return AuthError.emailInUse;
      case 'weak-password':
        return AuthError.weakPassword;
      case 'user-disabled':
        return AuthError.userDisabled;
      case 'too-many-requests':
        return AuthError.tooManyRequests;
      case 'network-request-failed':
        return AuthError.network;
      case 'operation-not-allowed':
        return AuthError.methodDisabled;
      case 'popup-closed-by-user':
      case 'cancelled-popup-request':
      case 'web-context-canceled':
        return AuthError.cancelled;
      default:
        return AuthError.unknown;
    }
  }
}

final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => FirebaseAuthRepository(
    FirebaseAuth.instance,
    ref.watch(sharedPreferencesProvider),
  ),
);

final authStateProvider = StreamProvider<AppUser?>(
  (ref) => ref.watch(authRepositoryProvider).authStateChanges(),
);

/// Whether the user chose to browse events without an account.
class GuestMode extends Notifier<bool> {
  @override
  bool build() => false;

  void enter() => state = true;
  void exit() => state = false;
}

final guestModeProvider = NotifierProvider<GuestMode, bool>(GuestMode.new);
