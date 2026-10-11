import 'package:flat/src/data/models.dart';
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
    await tester.enterText(find.byType(EditableText).last, 'Kratko');
    await tester.tap(find.text('Pošalji'));
    await tester.pumpAndSettle();
    expect(find.text('Napiši barem 10 znakova'), findsOneWidget);

    await tester.enterText(
      find.byType(EditableText).last,
      'The refund has not arrived on my card yet.',
    );
    await tester.tap(find.text('Pošalji'));
    await tester.pumpAndSettle();

    final ticket = support.tickets.single;
    expect(ticket.reference, 'SSW-9ZC4TB');
    expect(ticket.topic, SupportTopic.order);
    expect(ticket.name, 'Amra Test');
    expect(ticket.unreadForStaff, isTrue);
    // The conversation opens right away, with the first message.
    expect(find.text('Upit poslan'), findsOneWidget);
    expect(find.text(ticket.number), findsWidgets);
    expect(
      find.text('The refund has not arrived on my card yet.'),
      findsOneWidget,
    );
    expect(find.text('Otvoren'), findsOneWidget);
    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();
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
    expect(find.text('Moji upiti'), findsNothing);
    expect(find.text('Prijava ili registracija'), findsWidgets);
  });
}
