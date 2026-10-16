import 'package:flat/src/ui/tokens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';

import 'fixtures.dart';
import 'helpers.dart';

/// Tap targets of at least 44 px (Apple HIG, WCAG 2.5.5) and a label on
/// everything tappable. Links inside running text are exempt (WCAG 2.5.8):
/// they are as tall as the line.
Future<void> _expectAccessible(WidgetTester tester, String page) async {
  final tap = await iOSTapTargetGuideline.evaluate(tester);
  final small = tap.passed
      ? const <String>[]
      : tap.reason!
            .split('\n')
            .where((l) => l.startsWith('SemanticsNode'))
            .where((l) => !l.contains('PlaceholderSpanIndexSemanticsTag'))
            .toList();
  expect(small, isEmpty, reason: '$page: tap targets');
  await expectLater(
    tester,
    meetsGuideline(labeledTapTargetGuideline),
    reason: '$page: labels',
  );
}

Future<void> _go(WidgetTester tester, String location) async {
  GoRouter.of(tester.element(find.byType(Navigator).first)).go(location);
  await tester.pumpAndSettle();
}

double _contrast(Color a, Color b) {
  final la = a.computeLuminance(), lb = b.computeLuminance();
  return (la > lb ? la + 0.05 : lb + 0.05) / (la > lb ? lb + 0.05 : la + 0.05);
}

void main() {
  for (final dark in [false, true]) {
    testWidgets('pages on phones are accessible (dark: $dark)', (tester) async {
      final semantics = tester.ensureSemantics();
      if (dark) {
        tester.platformDispatcher.platformBrightnessTestValue = Brightness.dark;
      }
      addTearDown(tester.platformDispatcher.clearPlatformBrightnessTestValue);
      final auth = await pumpApp(
        tester,
        marketRepository: buildSampleMarket('1'),
        eventRepository: buildSampleEvents(),
      );
      await tester.pumpAndSettle();
      await _expectAccessible(tester, 'home (guest)');
      await _go(tester, '/login');
      await _expectAccessible(tester, 'login');

      await auth.signIn(
        email: 'amra@test.ba',
        password: 'x',
        keepSignedIn: true,
      );
      await tester.pumpAndSettle();
      await _go(tester, '/');
      await _expectAccessible(tester, 'home');
      final listing = (await tester.runAsync(
        () => market.watchActiveListings().first,
      ))!.first;
      for (final page in [
        '/event/${listing.eventId}',
        '/listing/${listing.id}',
        '/account/purchases',
        '/account/sales',
        '/account/listings',
        '/settings',
        '/sell',
        '/support',
        '/settings/privacy',
        '/settings/appearance',
        '/account/payouts',
      ]) {
        await _go(tester, page);
        await _expectAccessible(tester, page);
      }
      semantics.dispose();
    });
  }

  // Screenshot-based contrast checks misjudge thin text, so the palette is
  // checked by its numbers instead.
  test('text and status colors have enough contrast', () {
    for (final c in [FColors.neutralLight, FColors.neutralDark]) {
      for (final surface in [c.background, c.card]) {
        expect(_contrast(c.foreground, surface), greaterThanOrEqualTo(4.5));
        expect(
          _contrast(c.mutedForeground, surface),
          greaterThanOrEqualTo(4.5),
          reason: 'muted text, ${c.brightness}',
        );
        for (final status in [FixedColors.positive, FixedColors.waiting]) {
          expect(
            _contrast(status, surface),
            greaterThanOrEqualTo(3),
            reason: '$status on ${c.brightness}',
          );
        }
      }
    }
    expect(
      _contrast(FixedColors.onWaiting, FixedColors.waiting),
      greaterThanOrEqualTo(4.5),
    );
  });

  testWidgets('reduced motion turns durations off', (tester) async {
    tester.platformDispatcher.accessibilityFeaturesTestValue =
        FakeAccessibilityFeatures(disableAnimations: true);
    addTearDown(tester.platformDispatcher.clearAccessibilityFeaturesTestValue);
    await pumpApp(tester);
    await tester.pumpAndSettle();
    expect(Motion.reduced, isTrue);
    expect(Motion.normal, Duration.zero);

    tester.platformDispatcher.clearAccessibilityFeaturesTestValue();
    await tester.pumpAndSettle();
    expect(Motion.reduced, isFalse);
    expect(Motion.normal, greaterThan(Duration.zero));
  });
}
