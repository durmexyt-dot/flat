import 'package:flat/src/splash/splash_page.dart';
import 'package:flat/src/ui/hero_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';

import 'helpers.dart';

/// Sizes of all laid-out brand logo icons. The icon is 56% of the logo:
/// 53.8 on the splash, 22.4 on sign-in screens and 17.9 in the home app bar.
/// A size in between can only come from the copy shown during a Hero flight.
Iterable<double> _markSizes(WidgetTester tester) => find
    .byIcon(FLucideIcons.ticket, skipOffstage: false)
    .evaluate()
    .map((e) => (e.renderObject as RenderBox?)?.size.width)
    .whereType<double>();

bool _inFlight(WidgetTester tester, double from, double to) =>
    _markSizes(tester).any((w) => w > from + 0.3 && w < to - 0.3);

Future<void> _pumpHalfTransition(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(heroTransitionDuration ~/ 2);
}

void main() {
  testWidgets('brand flies from splash to login', (tester) async {
    await pumpApp(tester, settle: false);
    await tester.pump(splashMinDuration);
    await _pumpHalfTransition(tester);
    expect(
      _inFlight(tester, 22.4, 53.8),
      isTrue,
      reason: 'sizes: ${_markSizes(tester)}',
    );
    // The tagline cross-fades from the splash text to the welcome text.
    expect(find.text('Kupuj i prodaji karte za događaje'), findsOneWidget);
    expect(find.text('Dobrodošli na Stubswap'), findsWidgets);
    await tester.pumpAndSettle();
    expect(find.text('Kupuj i prodaji karte za događaje'), findsNothing);
  });

  testWidgets('brand flies into the app bar on sign in and back on sign out', (
    tester,
  ) async {
    final auth = await pumpApp(tester);

    await auth.signIn(email: 'a@b.ba', password: 'x', keepSignedIn: true);
    await _pumpHalfTransition(tester);
    expect(
      _inFlight(tester, 17.9, 22.4),
      isTrue,
      reason: 'sizes: ${_markSizes(tester)}',
    );
    await tester.pumpAndSettle();
    expect(find.text('Zdravo, Amra'), findsOneWidget);

    await auth.signOut();
    await _pumpHalfTransition(tester);
    expect(
      _inFlight(tester, 17.9, 22.4),
      isTrue,
      reason: 'sizes: ${_markSizes(tester)}',
    );
    await tester.pumpAndSettle();
    expect(find.text('Dobrodošli na Stubswap'), findsOneWidget);
  });
}
