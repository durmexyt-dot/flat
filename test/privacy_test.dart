import 'package:flat/src/data/models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers.dart';

Future<FakeAuthRepository> _signedInAt(WidgetTester tester, String tile) async {
  final auth = await pumpApp(tester);
  await auth.signIn(email: 'amra@test.ba', password: 'x', keepSignedIn: true);
  await tester.pumpAndSettle();
  await tester.tap(find.byTooltip('Postavke'));
  await tester.pumpAndSettle();
  await tapVisible(tester, find.text(tile));
  return auth;
}

void main() {
  testWidgets('profile can be made private', (tester) async {
    await _signedInAt(tester, 'Privatnost i sigurnost');
    await tester.tap(find.text('Privatni profil'));
    await tester.pumpAndSettle();
    final profile = await tester.runAsync(
      () => profiles.watchProfile('1').first,
    );
    expect(profile?.visibility, ProfileVisibility.private);
  });

  testWidgets('email verification can be requested and shows when done', (
    tester,
  ) async {
    final auth = await _signedInAt(tester, 'Privatnost i sigurnost');
    expect(find.text('Nije potvrđeno'), findsOneWidget);
    await tester.tap(find.text('Pošalji link za potvrdu'));
    await tester.pumpAndSettle();
    expect(auth.verificationSent, isTrue);
    expect(find.text('Link je poslan na amra@test.ba'), findsOneWidget);

    auth.verifyEmail();
    await tester.pumpAndSettle();
    expect(find.text('Potvrđeno'), findsOneWidget);
  });

  testWidgets('password change checks the current password', (tester) async {
    final auth = await _signedInAt(tester, 'Privatnost i sigurnost');
    await tapVisible(tester, find.text('Promijeni lozinku'));
    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), 'wrong');
    await tester.enterText(fields.at(1), 'newpass1');
    await tester.enterText(fields.at(2), 'newpass1');
    await tester.tap(find.widgetWithText(FilledButton, 'Sačuvaj'));
    await tester.pumpAndSettle();
    expect(find.text('Pogrešan e-mail ili lozinka'), findsOneWidget);

    await tester.enterText(fields.at(0), 'secret1');
    await tester.tap(find.widgetWithText(FilledButton, 'Sačuvaj'));
    await tester.pumpAndSettle();
    expect(auth.password, 'newpass1');
    expect(find.text('Lozinka je promijenjena'), findsOneWidget);
  });

  testWidgets('deleting the account removes the profile and signs out', (
    tester,
  ) async {
    final auth = await _signedInAt(tester, 'Privatnost i sigurnost');
    await tapVisible(tester, find.text('Obriši račun'));
    await tester.enterText(find.byType(TextFormField).last, 'secret1');
    await tester.tap(find.widgetWithText(FilledButton, 'Obriši račun'));
    await tester.pumpAndSettle();
    expect(auth.deleted, isTrue);
    expect(find.text('Dobrodošli na Stubswap'), findsOneWidget);
    final profile = await tester.runAsync(
      () => profiles.watchProfile('1').first,
    );
    expect(profile, isNull);
  });

  testWidgets('notification switches are saved to the profile', (tester) async {
    await _signedInAt(tester, 'Obavještenja');
    expect(find.text('Status narudžbe'), findsOneWidget);
    await tapVisible(tester, find.text('Novosti i ponude'));
    final profile = await tester.runAsync(
      () => profiles.watchProfile('1').first,
    );
    expect(profile?.notifications.newsletter, isTrue);
    // Push is not available in tests (no browser).
    await tester.scrollUntilVisible(
      find.text('Push na ovom uređaju'),
      -200,
      scrollable: mainScrollable,
    );
    expect(
      find.text(
        'Ovaj preglednik ne podržava obavještenja. Na iPhoneu dodaj Stubswap na početni ekran.',
      ),
      findsOneWidget,
    );
  });
}
