import 'package:flat/src/admin/admin_repository.dart';
import 'package:flat/src/app.dart';
import 'package:flat/src/data/models.dart';
import 'package:flat/src/router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';

import 'helpers.dart';

const _lejla = UserLookup(
  uid: '7',
  name: 'Lejla Kovač',
  email: 'lejla@test.ba',
  username: 'lejla',
);

Future<FakeAuthRepository> _pumpAdmin(WidgetTester tester) async {
  final auth = await pumpApp(
    tester,
    adminRepository: InMemoryAdminRepository(
      roles: {'1': StaffRole.admin},
      users: [_lejla],
    ),
  );
  await auth.signIn(email: 'amra@test.ba', password: 'x', keepSignedIn: true);
  await tester.pumpAndSettle();
  return auth;
}

Future<void> _openSettings(WidgetTester tester) async {
  await tester.tap(byLabel('Postavke'));
  await tester.pumpAndSettle();
}

ProviderContainer _container(WidgetTester tester) =>
    ProviderScope.containerOf(tester.element(find.byType(FlatApp)));

void main() {
  testWidgets('admin opens the hub from settings and changes the fee', (
    tester,
  ) async {
    await _pumpAdmin(tester);
    await _openSettings(tester);

    await tester.scrollUntilVisible(
      find.text('Administracija'),
      200,
      scrollable: mainScrollable,
    );
    expect(find.text('Upiti podrške'), findsOneWidget);
    await tapVisible(tester, find.text('Administracija'));

    expect(find.text('Događaji'), findsOneWidget);
    expect(find.text('Tim i podrška'), findsOneWidget);
    expect(find.text('Kupac 10 % · Prodavac 10 %'), findsOneWidget);

    await tapVisible(tester, find.text('Servisna naknada'));
    expect(find.text('Trenutno: Kupac 10 % · Prodavac 10 %'), findsOneWidget);

    FButton save() =>
        tester.widget<FButton>(find.widgetWithText(FButton, 'Sačuvaj naknadu'));
    expect(save().onPress, isNull);

    // Buyer 12 % by typing, seller 8 % with the minus button.
    await tester.enterText(
      find.descendant(
        of: find.byKey(const ValueKey('buyer-fee')),
        matching: find.byType(EditableText),
      ),
      '12',
    );
    await tester.pumpAndSettle();
    for (var i = 0; i < 2; i++) {
      await tester.tap(byLabel('Smanji Naknada prodavca').first);
      await tester.pumpAndSettle();
    }
    // 50 + 12 % = 56; 50 - 8 % = 46.
    expect(find.textContaining('56,00'), findsOneWidget);
    expect(find.textContaining('46,00'), findsOneWidget);

    // Out of range blocks saving.
    await tester.enterText(
      find.descendant(
        of: find.byKey(const ValueKey('buyer-fee')),
        matching: find.byType(EditableText),
      ),
      '45',
    );
    await tester.pumpAndSettle();
    expect(find.text('Unesi cijeli broj od 0 do 30'), findsOneWidget);
    expect(save().onPress, isNull);
    await tester.enterText(
      find.descendant(
        of: find.byKey(const ValueKey('buyer-fee')),
        matching: find.byType(EditableText),
      ),
      '12',
    );
    await tester.pumpAndSettle();

    await tapVisible(tester, find.text('Sačuvaj naknadu'));
    expect(find.text('Promijeniti naknadu?'), findsOneWidget);
    await tester.tap(find.widgetWithText(FButton, 'Sačuvaj'));
    await tester.pumpAndSettle();

    expect(admin.fees, const FeeConfig(buyerPercent: 12, sellerPercent: 8));
    // New listings take the fees from here.
    final fees = _container(tester).read(feeConfigProvider).value!;
    expect(fees.buyerFee(5000), 600);
    expect(fees.sellerFee(5000), 400);
    expect(find.text('Trenutno: Kupac 12 % · Prodavac 8 %'), findsOneWidget);
    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();
  });

  testWidgets('admin adds and removes a support account', (tester) async {
    await _pumpAdmin(tester);
    _container(tester).read(routerProvider).push('/admin/team');
    await tester.pumpAndSettle();

    expect(find.text('Admin'), findsOneWidget);
    expect(find.textContaining('Firebase konzoli'), findsOneWidget);

    final field = find.descendant(
      of: find.byKey(const ValueKey('find-user')),
      matching: find.byType(EditableText),
    );
    await tester.enterText(field, 'nobody@test.ba');
    await tapVisible(tester, find.widgetWithText(FButton, 'Traži'));
    expect(find.text('Korisnik nije pronađen'), findsOneWidget);

    await tester.enterText(field, 'lejla@test.ba');
    await tapVisible(tester, find.widgetWithText(FButton, 'Traži'));
    expect(find.text('Lejla Kovač'), findsOneWidget);
    expect(find.text('@lejla'), findsOneWidget);

    await tapVisible(tester, find.widgetWithText(FButton, 'Dodaj kao podršku'));
    expect(
      _container(tester).read(teamProvider).value!.map((m) => m.uid),
      contains('7'),
    );
    expect(find.text('Podrška'), findsWidgets);

    // Searching again shows they're already in the team.
    await tester.enterText(field, 'lejla');
    await tapVisible(tester, find.widgetWithText(FButton, 'Traži'));
    expect(find.text('Već je u timu kao Podrška'), findsOneWidget);
    expect(find.text('Dodaj kao podršku'), findsNothing);

    await tapVisible(tester, byLabel('Ukloni iz podrške').first);
    expect(find.text('Ukloniti iz podrške?'), findsOneWidget);
    await tester.tap(find.widgetWithText(FButton, 'Ukloni'));
    await tester.pumpAndSettle();
    expect(
      _container(tester).read(teamProvider).value!.map((m) => m.uid),
      isNot(contains('7')),
    );
    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();
  });

  testWidgets('normal users have no admin entry and no access', (tester) async {
    final auth = await pumpApp(tester);
    await auth.signIn(email: 'amra@test.ba', password: 'x', keepSignedIn: true);
    await tester.pumpAndSettle();
    await _openSettings(tester);
    await tester.scrollUntilVisible(
      find.text('Centar za pomoć'),
      200,
      scrollable: mainScrollable,
    );
    expect(find.text('Administracija'), findsNothing);
    expect(find.text('Upiti podrške'), findsNothing);

    _container(tester).read(routerProvider).push('/admin');
    await tester.pumpAndSettle();
    expect(find.text('Nemaš pristup'), findsOneWidget);
    expect(find.text('Događaji'), findsNothing);
  });
}
