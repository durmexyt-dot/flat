import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';

import 'fixtures.dart';
import 'helpers.dart';

void main() {
  testWidgets('help request from an order carries its number', (tester) async {
    final auth = await pumpApp(
      tester,
      marketRepository: buildSampleMarket('1'),
    );
    await auth.signIn(email: 'amra@test.ba', password: 'x', keepSignedIn: true);
    await tester.pumpAndSettle();
    await tester.tap(byLabel('Postavke'));
    await tester.pumpAndSettle();
    await tapVisible(tester, find.text('Kupovine i računi'));
    await tester.tap(find.text('EXIT Festival'));
    await tester.pumpAndSettle();
    await tapVisible(tester, find.text('Pomoć oko ove narudžbe'));

    expect(find.text('SSW-9ZC4TB'), findsOneWidget);
    await tester.enterText(find.byType(EditableText).last, 'Too short');
    await tester.tap(find.text('Pošalji'));
    await tester.pumpAndSettle();
    expect(find.text('Napiši barem 20 znakova'), findsOneWidget);

    await tester.enterText(
      find.byType(EditableText).last,
      'The refund has not arrived on my card yet.',
    );
    await tester.tap(find.text('Pošalji'));
    await tester.pumpAndSettle();
    expect(find.text('Zahtjev je poslan'), findsOneWidget);
    expect(find.textContaining('SUP-100000'), findsOneWidget);
    expect(market.supportRequests.single['reference'], 'SSW-9ZC4TB');
    expect(market.supportRequests.single['topic'], 'order');
  });

  testWidgets('guests can read the help center', (tester) async {
    await pumpApp(tester);
    await tester.tap(find.text('Pretraži događaje kao gost'));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(FLucideIcons.settings));
    await tester.pumpAndSettle();
    await tapVisible(tester, find.text('Centar za pomoć'));
    await tester.tap(find.text('Koje su naknade?'));
    await tester.pumpAndSettle();
    expect(find.textContaining('naknadu za uslugu od 10%'), findsOneWidget);
    expect(find.text('Kontaktiraj podršku'), findsNothing);
  });
}
