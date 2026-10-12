import 'dart:async';

import 'package:flat/src/admin/admin_repository.dart';
import 'package:flat/src/app.dart';
import 'package:flat/src/auth/auth_repository.dart';
import 'package:flat/src/data/memory_repositories.dart';
import 'package:flat/src/data/events_repository.dart';
import 'package:flat/src/data/repositories.dart';
import 'package:flat/src/data/server_actions.dart';
import 'package:flat/src/data/tickets_repository.dart';
import 'package:flat/src/settings/settings_controller.dart';
import 'package:flat/src/splash/splash_page.dart';
import 'package:flat/src/support/support_repository.dart';
import 'package:flat/src/ui/hero_page.dart';
import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FakeAuthRepository implements AuthRepository {
  final _controller = StreamController<AppUser?>.broadcast();
  AppUser? _user;

  /// Simulated server response time for sign-in.
  Duration delay = Duration.zero;

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
  }) async {
    // Only wait when asked to: tests that await signIn directly would
    // otherwise block on a timer that only advances when pumped.
    if (delay > Duration.zero) await Future<void>.delayed(delay);
    _set(AppUser(uid: '1', email: email, displayName: 'Amra Test'));
  }

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
  Future<void> updateDisplayName(String name) async {
    final u = _user;
    if (u != null) {
      _set(AppUser(uid: u.uid, email: u.email, displayName: name));
    }
  }

  bool verificationSent = false;
  String password = 'secret1';
  bool deleted = false;

  /// Marks the email as verified, as if the link was opened.
  void verifyEmail() {
    final u = _user!;
    _set(
      AppUser(
        uid: u.uid,
        email: u.email,
        displayName: u.displayName,
        emailVerified: true,
      ),
    );
  }

  @override
  Future<void> sendEmailVerification(String languageCode) async =>
      verificationSent = true;

  @override
  Future<void> reloadUser() async {}

  @override
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    if (currentPassword != password) {
      throw const AuthException(AuthError.invalidCredentials);
    }
    password = newPassword;
  }

  @override
  Future<void> deleteAccount({String? password}) async {
    if (password != this.password) {
      throw const AuthException(AuthError.invalidCredentials);
    }
    deleted = true;
    _set(null);
  }

  @override
  Future<void> signOut() async => _set(null);
}

/// Starts the full app on a phone-sized screen and waits past the splash
/// until the first real screen has settled.
/// The repositories of the last [pumpApp], for assertions.
late InMemoryProfileRepository profiles;
late InMemoryMarketRepository market;
late InMemoryEventRepository events;
late InMemorySupportRepository support;
late InMemoryAdminRepository admin;
late InMemoryTicketFileRepository ticketFiles;
late FakeServerActions serverActions;

Future<FakeAuthRepository> pumpApp(
  WidgetTester tester, {
  bool settle = true,
  InMemoryMarketRepository? marketRepository,
  InMemoryEventRepository? eventRepository,
  InMemorySupportRepository? supportRepository,
  InMemoryAdminRepository? adminRepository,
  InMemoryTicketFileRepository? ticketFileRepository,
}) async {
  profiles = InMemoryProfileRepository();
  market = marketRepository ?? InMemoryMarketRepository();
  events = eventRepository ?? InMemoryEventRepository();
  support = supportRepository ?? InMemorySupportRepository();
  admin = adminRepository ?? InMemoryAdminRepository();
  ticketFiles = ticketFileRepository ?? InMemoryTicketFileRepository();
  serverActions = FakeServerActions();
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
        profileRepositoryProvider.overrideWithValue(profiles),
        marketRepositoryProvider.overrideWithValue(market),
        eventRepositoryProvider.overrideWithValue(events),
        supportRepositoryProvider.overrideWithValue(support),
        adminRepositoryProvider.overrideWithValue(admin),
        ticketFileRepositoryProvider.overrideWithValue(ticketFiles),
        serverActionsProvider.overrideWithValue(serverActions),
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

/// The vertical list of the screen on top (not e.g. a row of chips).
Finder get mainScrollable => find
    .byWidgetPredicate(
      (w) => w is Scrollable && w.axisDirection == AxisDirection.down,
    )
    .last;

/// Scrolls the first scrollable until [finder] is built and visible, then
/// taps it.
Future<void> tapVisible(WidgetTester tester, Finder finder) async {
  if (finder.evaluate().isEmpty) {
    await tester.scrollUntilVisible(finder, 200, scrollable: mainScrollable);
  }
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

/// A Forui control by its semantics label (Forui tooltips only build on
/// hover, so `find.byTooltip` doesn't see them).
Finder byLabel(String label) => find.byWidgetPredicate(
  (w) => switch (w) {
    FButton(:final semanticsLabel) => semanticsLabel == label,
    FTappable(:final semanticsLabel) => semanticsLabel == label,
    FHeaderAction(:final semanticsLabel) => semanticsLabel == label,
    _ => false,
  },
);
