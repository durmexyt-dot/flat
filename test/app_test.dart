import 'package:flat/src/settings/settings_controller.dart';
import 'package:flat/src/ui/app_style.dart';
import 'package:flat/src/ui/site_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'helpers.dart';

void main() {
  test('German until a language is picked', () async {
    SharedPreferences.setMockInitialValues({});
    final container = ProviderContainer(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(
          await SharedPreferences.getInstance(),
        ),
      ],
    );
    addTearDown(container.dispose);
    expect(container.read(settingsProvider).locale, const Locale('de'));
  });

  testWidgets('splash leads to the events, without a sign-in wall', (
    tester,
  ) async {
    await pumpApp(tester);
    expect(find.text('Dobrodošli na Stubswap'), findsNothing);
    expect(
      find.text('Prijavite se da biste kupovali i prodavali karte'),
      findsOneWidget,
    );
    // Phones: the tab bar.
    expect(find.text('Događaji'), findsWidgets);
    expect(find.text('Moje karte'), findsOneWidget);
    expect(find.text('Prodaj'), findsOneWidget);
    expect(find.text('Profil'), findsOneWidget);
  });

  testWidgets('the Bosnian login screen', (tester) async {
    await pumpApp(tester);
    await openLogin(tester);
    expect(find.text('Dobrodošli na Stubswap'), findsOneWidget);
    expect(find.text('Ostani prijavljen'), findsOneWidget);
    expect(find.text('Nastavi s Google računom'), findsOneWidget);
    expect(find.text('Nastavi bez prijave'), findsOneWidget);
  });

  testWidgets('empty login shows validation errors', (tester) async {
    await pumpApp(tester);
    await openLogin(tester);
    await tester.tap(find.widgetWithText(FButton, 'Prijavi se'));
    await tester.pumpAndSettle();
    expect(find.text('Unesite e-mail adresu'), findsOneWidget);
    expect(find.text('Unesite lozinku'), findsOneWidget);
  });

  testWidgets('sign in leads to home with greeting', (tester) async {
    await pumpApp(tester);
    await openLogin(tester);
    await tester.enterText(find.byType(EditableText).at(0), 'amra@test.ba');
    await tester.enterText(find.byType(EditableText).at(1), 'secret1');
    await tester.tap(find.widgetWithText(FButton, 'Prijavi se'));
    await tester.pumpAndSettle();
    expect(find.text('Zdravo, Amra'), findsOneWidget);
  });

  testWidgets('sign-in button turns into a spinner until the response', (
    tester,
  ) async {
    final auth = await pumpApp(tester);
    await openLogin(tester);
    auth.delay = const Duration(seconds: 2);
    await tester.enterText(find.byType(EditableText).at(0), 'amra@test.ba');
    await tester.enterText(find.byType(EditableText).at(1), 'secret1');
    await tester.tap(find.widgetWithText(FButton, 'Prijavi se'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    // The label turns into a spinner while waiting.
    expect(find.byType(FCircularProgress), findsOneWidget);
    expect(find.widgetWithText(FButton, 'Prijavi se'), findsNothing);

    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();
    expect(find.text('Zdravo, Amra'), findsOneWidget);
  });

  testWidgets('sign-in goes back to the page that needed it', (tester) async {
    await pumpApp(tester);
    // E.g. a guest opened "Moje karte".
    await tester.tap(find.text('Moje karte'));
    await tester.pumpAndSettle();
    expect(
      find.text('Prijavi se ili napravi račun da nastaviš.'),
      findsOneWidget,
    );
    await tester.enterText(find.byType(EditableText).at(0), 'amra@test.ba');
    await tester.enterText(find.byType(EditableText).at(1), 'secret1');
    await tester.tap(find.widgetWithText(FButton, 'Prijavi se'));
    await tester.pumpAndSettle();
    expect(find.text('Još nemaš kupovina'), findsOneWidget);
  });

  testWidgets('guests leave sign-in and keep browsing', (tester) async {
    await pumpApp(tester);
    await openLogin(tester);
    await tester.tap(find.text('Nastavi bez prijave'));
    await tester.pumpAndSettle();
    expect(
      find.text('Prijavite se da biste kupovali i prodavali karte'),
      findsOneWidget,
    );
  });

  testWidgets('sign up creates the account and opens home', (tester) async {
    await pumpApp(tester);
    await openLogin(tester);
    await tester.tap(find.text('Registruj se'));
    await tester.pumpAndSettle();
    expect(find.text('Kreirajte svoj račun'), findsOneWidget);

    final fields = find.byType(EditableText);
    await tester.enterText(fields.at(0), 'Emir Hodžić');
    await tester.enterText(fields.at(1), 'emir@test.ba');
    await tester.enterText(fields.at(2), 'secret123');
    await tester.enterText(fields.at(3), 'secret123');
    // The terms must be accepted (see legal_and_price_test.dart).
    final terms = find.byType(FCheckbox);
    await tester.ensureVisible(terms);
    await tester.pumpAndSettle();
    await tester.tapAt(tester.getTopLeft(terms) + const Offset(8, 8));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FButton, 'Kreiraj račun'));
    await tester.pumpAndSettle();
    expect(find.text('Zdravo, Emir'), findsOneWidget);
  });

  testWidgets('settings switch language, theme and currency, and sign out', (
    tester,
  ) async {
    final auth = await pumpApp(tester);
    await auth.signIn(email: 'a@b.ba', password: 'x', keepSignedIn: true);
    await tester.pumpAndSettle();

    await tester.tap(byLabel('Postavke'));
    await tester.pumpAndSettle();
    // The account page is named like its tab.
    expect(find.text('Profil'), findsWidgets);

    await tapVisible(tester, find.text('Bosanski'));
    await tester.tap(find.text('Deutsch').last);
    await tester.pumpAndSettle();
    expect(find.text('Darstellung'), findsWidgets);

    await tapVisible(tester, find.text('Darstellung').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Dunkel'));
    await tester.pumpAndSettle();
    final context = tester.element(find.text('Designfarbe'));
    expect(Theme.of(context).brightness, Brightness.dark);
    await tester.ensureVisible(byLabel('Grün'));
    await tester.tap(byLabel('Grün'));
    await tester.pumpAndSettle();
    expect(
      Theme.of(tester.element(find.text('Designfarbe'))).colorScheme.primary,
      colorSchemeFor(BrandColor.green, Brightness.dark).primary,
    );
    await tester.ensureVisible(find.text('Kantig'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Kantig'));
    await tester.pumpAndSettle();
    expect(
      AppStyle.of(tester.element(find.text('Designfarbe'))).cardRadius,
      UiStyle.crisp.cardRadius,
    );
    await tester.tap(find.byKey(backButtonKey));
    await tester.pumpAndSettle();

    await tapVisible(tester, find.text('BAM (KM)'));
    await tester.tap(find.text('EUR (€)').last);
    await tester.pumpAndSettle();
    expect(find.text('EUR (€)'), findsOneWidget);

    await tapVisible(tester, find.text('Abmelden'));
    await tester.pumpAndSettle();
    // Signed out: back to the events, as a guest.
    expect(
      find.text('Melde dich an, um Tickets zu kaufen und zu verkaufen'),
      findsOneWidget,
    );
  });
}
