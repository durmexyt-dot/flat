import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers.dart';

void main() {
  testWidgets('splash leads to the Bosnian login screen', (tester) async {
    await pumpApp(tester);
    expect(find.text('Dobrodošli na Stubswap'), findsOneWidget);
    expect(find.text('Ostani prijavljen'), findsOneWidget);
    expect(find.text('Nastavi s Google računom'), findsOneWidget);
    expect(find.text('Pretraži događaje kao gost'), findsOneWidget);
  });

  testWidgets('empty login shows validation errors', (tester) async {
    await pumpApp(tester);
    await tester.tap(find.widgetWithText(FilledButton, 'Prijavi se'));
    await tester.pumpAndSettle();
    expect(find.text('Unesite e-mail adresu'), findsOneWidget);
    expect(find.text('Unesite lozinku'), findsOneWidget);
  });

  testWidgets('sign in leads to home with greeting', (tester) async {
    await pumpApp(tester);
    await tester.enterText(find.byType(TextFormField).at(0), 'amra@test.ba');
    await tester.enterText(find.byType(TextFormField).at(1), 'secret1');
    await tester.tap(find.widgetWithText(FilledButton, 'Prijavi se'));
    await tester.pumpAndSettle();
    expect(find.text('Zdravo, Amra'), findsOneWidget);
  });

  testWidgets('guest can browse events and get back to sign in', (
    tester,
  ) async {
    await pumpApp(tester);
    await tester.tap(find.text('Pretraži događaje kao gost'));
    await tester.pumpAndSettle();
    expect(find.text('Pregledate kao gost'), findsOneWidget);

    await tester.tap(find.widgetWithText(TextButton, 'Prijavi se'));
    await tester.pumpAndSettle();
    expect(find.text('Dobrodošli na Stubswap'), findsOneWidget);
  });

  testWidgets('sign up creates the account and opens home', (tester) async {
    await pumpApp(tester);
    await tester.tap(find.text('Registruj se'));
    await tester.pumpAndSettle();
    expect(find.text('Kreirajte svoj račun'), findsOneWidget);

    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), 'Emir Hodžić');
    await tester.enterText(fields.at(1), 'emir@test.ba');
    await tester.enterText(fields.at(2), 'secret1');
    await tester.enterText(fields.at(3), 'secret1');
    await tester.tap(find.widgetWithText(FilledButton, 'Kreiraj račun'));
    await tester.pumpAndSettle();
    expect(find.text('Zdravo, Emir'), findsOneWidget);
  });

  testWidgets('settings switch language, theme and currency, and sign out', (
    tester,
  ) async {
    final auth = await pumpApp(tester);
    await auth.signIn(email: 'a@b.ba', password: 'x', keepSignedIn: true);
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.settings_outlined));
    await tester.pumpAndSettle();
    expect(find.text('Postavke'), findsOneWidget);

    await tester.tap(find.text('Bosanski'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Deutsch').last);
    await tester.pumpAndSettle();
    expect(find.text('Einstellungen'), findsOneWidget);

    await tester.tap(find.text('Dunkel'));
    await tester.pumpAndSettle();
    final context = tester.element(find.text('Einstellungen'));
    expect(Theme.of(context).brightness, Brightness.dark);

    await tester.tap(find.text('BAM (KM)'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('EUR (€)').last);
    await tester.pumpAndSettle();
    expect(find.text('EUR (€)'), findsOneWidget);

    await tester.tap(find.text('Abmelden'));
    await tester.pumpAndSettle();
    expect(find.text('Willkommen bei Stubswap'), findsOneWidget);
  });
}
