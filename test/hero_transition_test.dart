import 'dart:async';

import 'package:flat/src/app.dart';
import 'package:flat/src/auth/auth_repository.dart';
import 'package:flat/src/settings/locale_controller.dart';
import 'package:flat/src/ui/hero_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FakeAuthRepository implements AuthRepository {
  final _controller = StreamController<AppUser?>.broadcast();
  AppUser? _user;

  @override
  AppUser? get currentUser => _user;

  @override
  Stream<AppUser?> authStateChanges() async* {
    // Like Firebase: emit the current user first, then changes.
    yield _user;
    yield* _controller.stream;
  }

  @override
  Future<void> signIn({required String email, required String password}) async {
    _user = AppUser(uid: '1', email: email);
    _controller.add(_user);
  }

  @override
  Future<void> signOut() async {
    _user = null;
    _controller.add(null);
  }
}

/// Sizes of all laid-out logo icons. The icon is 60% of the logo, so it is
/// 33.6 on the login page and 21.6 in the app bar; any size in between can only
/// come from the copy Flutter shows during a Hero flight.
Iterable<double> _logoSizes(WidgetTester tester) => find
    .byIcon(Icons.home_rounded, skipOffstage: false)
    .evaluate()
    .map((e) => (e.renderObject as RenderBox?)?.size.width)
    .whereType<double>();

bool _logoInFlight(WidgetTester tester) =>
    _logoSizes(tester).any((w) => w > 22 && w < 33);

void main() {
  testWidgets('logo flies between login and dashboard', (tester) async {
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
    await tester.pumpAndSettle();
    expect(find.text('Prijava'), findsOneWidget);
    expect(_logoInFlight(tester), isFalse);

    // Sign in: the logo flies from the login page into the app bar.
    await auth.signIn(email: 'a@b.ba', password: 'x');
    await tester.pump();
    await tester.pump(heroTransitionDuration ~/ 2);
    expect(
      _logoInFlight(tester),
      isTrue,
      reason: 'sizes: ${_logoSizes(tester)}',
    );
    await tester.pumpAndSettle();
    expect(find.text('Dobrodošli, a@b.ba'), findsOneWidget);
    expect(_logoInFlight(tester), isFalse);

    // Sign out: the logo flies back.
    await auth.signOut();
    await tester.pump();
    await tester.pump(heroTransitionDuration ~/ 2);
    expect(
      _logoInFlight(tester),
      isTrue,
      reason: 'sizes: ${_logoSizes(tester)}',
    );
    await tester.pumpAndSettle();
    expect(find.text('Prijava'), findsOneWidget);
  });
}
