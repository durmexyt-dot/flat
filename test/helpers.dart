import 'dart:async';

import 'package:flat/src/app.dart';
import 'package:flat/src/auth/auth_repository.dart';
import 'package:flat/src/settings/settings_controller.dart';
import 'package:flat/src/splash/splash_page.dart';
import 'package:flat/src/ui/hero_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FakeAuthRepository implements AuthRepository {
  final _controller = StreamController<AppUser?>.broadcast();
  AppUser? _user;

  void _set(AppUser? user) {
    _user = user;
    _controller.add(user);
  }

  @override
  AppUser? get currentUser => _user;

  @override
  Stream<AppUser?> authStateChanges() async* {
    // Like Firebase: emit the current user first, then changes.
    yield _user;
    yield* _controller.stream;
  }

  @override
  Future<void> signIn({
    required String email,
    required String password,
    required bool keepSignedIn,
  }) async => _set(AppUser(uid: '1', email: email, displayName: 'Amra Test'));

  @override
  Future<void> signInWithGoogle({required bool keepSignedIn}) async =>
      _set(const AppUser(uid: '2', email: 'g@gmail.com'));

  @override
  Future<void> signUp({
    required String name,
    required String email,
    required String password,
  }) async => _set(AppUser(uid: '3', email: email, displayName: name));

  @override
  Future<void> sendPasswordReset({
    required String email,
    required String languageCode,
  }) async {}

  @override
  Future<void> signOut() async => _set(null);
}

/// Starts the full app on a phone-sized screen and waits past the splash
/// until the first real screen has settled.
Future<FakeAuthRepository> pumpApp(
  WidgetTester tester, {
  bool settle = true,
}) async {
  tester.view.physicalSize = const Size(390, 844) * 3;
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);

  SharedPreferences.setMockInitialValues({});
  final prefs = await SharedPreferences.getInstance();
  final auth = FakeAuthRepository();

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        authRepositoryProvider.overrideWithValue(auth),
      ],
      child: const FlatApp(),
    ),
  );
  if (settle) {
    await tester.pump(splashMinDuration);
    await tester.pump();
    await tester.pump(heroTransitionDuration);
    await tester.pumpAndSettle();
  }
  return auth;
}
