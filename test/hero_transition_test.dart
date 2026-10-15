import 'package:flat/src/splash/splash_page.dart';
import 'package:flat/src/ui/hero_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';

import 'helpers.dart';

/// Sizes of all laid-out brand logo icons. The icon is 56% of the logo:
/// 53.8 on the splash, 22.4 on sign-in screens and 17.9 in the home app bar.
/// (The tab bar uses a different ticket icon, so it isn't counted.)
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
  testWidgets('brand flies from splash to the events', (tester) async {
    await pumpApp(tester, settle: false);
    await tester.pump(splashMinDuration);
    await _pumpHalfTransition(tester);
    // From the splash (53.8) into the home bar (17.9).
    expect(
      _inFlight(tester, 17.9, 53.8),
      isTrue,
      reason: 'sizes: ${_markSizes(tester)}',
    );
    await tester.pumpAndSettle();
    expect(find.text('Kupuj i prodaji karte za događaje'), findsNothing);
    expect(
      find.text('Prijavite se da biste kupovali i prodavali karte'),
      findsOneWidget,
    );
  });

  testWidgets('brand flies into the app bar on sign in', (tester) async {
    await pumpApp(tester);
    await openLogin(tester);
    expect(find.text('Dobrodošli na Stubswap'), findsOneWidget);

    await tester.enterText(find.byType(EditableText).at(0), 'a@b.ba');
    await tester.enterText(find.byType(EditableText).at(1), 'secret1');
    await tester.tap(find.widgetWithText(FButton, 'Prijavi se'));
    await _pumpHalfTransition(tester);
    // From sign-in (22.4) into the home bar (17.9).
    expect(
      _inFlight(tester, 17.9, 22.4),
      isTrue,
      reason: 'sizes: ${_markSizes(tester)}',
    );
    await tester.pumpAndSettle();
    expect(find.text('Zdravo, A'), findsNothing);
    expect(find.text('Dobrodošli na Stubswap'), findsNothing);
  });
}
