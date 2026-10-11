import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../settings/settings_controller.dart';

/// The signed-in user, independent of Firebase types.
class AppUser {
  const AppUser({
    required this.uid,
    this.email,
    this.displayName,
    this.emailVerified = false,
    this.providers = const ['password'],
  });
  final String uid;
  final String? email;
  final String? displayName;
  final bool emailVerified;

  /// Sign-in methods, e.g. 'password', 'google.com'.
  final List<String> providers;

  bool get hasPassword => providers.contains('password');
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
  Future<void> updateDisplayName(String name);
  Future<void> sendEmailVerification(String languageCode);

  /// Reloads the user, e.g. after the email link was opened elsewhere.
  Future<void> reloadUser();

  /// Throws [AuthException] with [AuthError.invalidCredentials] when
  /// [currentPassword] is wrong.
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  });

  /// Confirms the user's identity again and deletes the account. Password
  /// users pass their password; others confirm with their provider.
  Future<void> deleteAccount({String? password});
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
          emailVerified: user.emailVerified,
          providers: [for (final p in user.providerData) p.providerId],
        );

  @override
  AppUser? get currentUser => _toAppUser(_auth.currentUser);

  @override
  Stream<AppUser?> authStateChanges() =>
      // Unlike authStateChanges, userChanges also fires on profile updates.
      _auth.userChanges().map(_toAppUser);

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
  Future<void> updateDisplayName(String name) async {
    await _auth.currentUser?.updateDisplayName(name);
    await _auth.currentUser?.reload();
  }

  @override
  Future<void> sendEmailVerification(String languageCode) => _guard(() async {
    await _auth.setLanguageCode(languageCode);
    await _auth.currentUser?.sendEmailVerification();
  });

  @override
  Future<void> reloadUser() async {
    await _auth.currentUser?.reload();
    // The security rules read "email verified" from the ID token, which keeps
    // the old value for up to an hour: get a fresh one.
    await _auth.currentUser?.getIdToken(true);
  }

  Future<void> _reauthenticate({String? password}) async {
    final user = _auth.currentUser!;
    if (password != null) {
      await user.reauthenticateWithCredential(
        EmailAuthProvider.credential(email: user.email!, password: password),
      );
    } else if (kIsWeb) {
      await user.reauthenticateWithPopup(GoogleAuthProvider());
    } else {
      await user.reauthenticateWithProvider(GoogleAuthProvider());
    }
  }

  @override
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) => _guard(() async {
    await _reauthenticate(password: currentPassword);
    await _auth.currentUser!.updatePassword(newPassword);
  });

  @override
  Future<void> deleteAccount({String? password}) => _guard(() async {
    await _reauthenticate(password: password);
    await _auth.currentUser!.delete();
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
      // The project's password policy (Authentication → Settings).
      case 'password-does-not-meet-requirements':
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
