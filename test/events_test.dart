import 'package:flat/src/admin/admin_repository.dart';
import 'package:flat/src/data/models.dart';
import 'package:flat/src/home/home_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';

import 'fixtures.dart';
import 'helpers.dart';

Future<FakeAuthRepository> _signedIn(
  WidgetTester tester, {
  InMemoryAdminRepository? admin,
}) async {
  final auth = await pumpApp(
    tester,
    marketRepository: buildSampleMarket('1'),
    eventRepository: buildSampleEvents(),
    adminRepository: admin,
  );
  await auth.signIn(email: 'amra@test.ba', password: 'x', keepSignedIn: true);
  await tester.pumpAndSettle();
  return auth;
}

Future<void> _go(WidgetTester tester, String location) async {
  GoRouter.of(tester.element(find.byType(HomePage))).push(location);
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('home shows upcoming events with their offers', (tester) async {
    await _signedIn(tester);

    expect(find.text('FK Sarajevo – FK Željezničar'), findsOneWidget);
    expect(find.text('Dubioza kolektiv'), findsOneWidget);
    // Past events are not offered.
    expect(find.text('Hamlet'), findsNothing);
    // Derby: 6 − 2 tickets from 35,00; Dubioza: 1 of the own listing.
    expect(find.textContaining('od 35,00'), findsOneWidget);
    expect(find.textContaining('· 4 karte'), findsOneWidget);
    expect(find.textContaining('· 1 karta'), findsOneWidget);
  });

  testWidgets('tapping an event shows its offers', (tester) async {
    await _signedIn(tester);

    await tester.tap(find.text('FK Sarajevo – FK Željezničar'));
    await tester.pumpAndSettle();
    expect(find.text('Prodaj karte za ovaj događaj'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('4 od 6 dostupno'),
      200,
      scrollable: mainScrollable,
    );
    expect(find.text('4 od 6 dostupno'), findsOneWidget);

    await tapVisible(tester, find.text('4 od 6 dostupno'));
    expect(find.text('Detalji ponude'), findsOneWidget);
    expect(find.text('Sve ponude za ovaj događaj'), findsOneWidget);
  });

  testWidgets('selling from an event page uses that event and current fees', (
    tester,
  ) async {
    final auth = await _signedIn(
      tester,
      admin: InMemoryAdminRepository(
        fees: const FeeConfig(buyerPercent: 7, sellerPercent: 5),
      ),
    );
    auth.verifyEmail();
    await tester.pumpAndSettle();

    await tapVisible(tester, find.text('Bijelo Dugme Tribute'));
    await tapVisible(tester, find.text('Prodaj karte za ovaj događaj'));
    // Preselected.
    expect(find.text('Bijelo Dugme Tribute'), findsOneWidget);
    expect(find.text('Promijeni'), findsOneWidget);

    await tester.ensureVisible(find.byIcon(FLucideIcons.tag));
    await tester.enterText(
      find.descendant(
        of: find.ancestor(
          of: find.byIcon(FLucideIcons.tag),
          matching: find.byType(FTextFormField),
        ),
        matching: find.byType(EditableText),
      ),
      '40',
    );
    await tester.pumpAndSettle();
    await tapVisible(tester, find.text('Objavi ponudu'));
    expect(find.text('Detalji ponude'), findsOneWidget);

    final created = (await market.watchMyListings('1').first).firstWhere(
      (l) => l.event.name == 'Bijelo Dugme Tribute',
    );
    expect(created.eventId, 'ev-tribute');
    expect(created.fees, const FeeConfig(buyerPercent: 7, sellerPercent: 5));
    expect(created.priceMinor, 4000);
  });

  testWidgets('admin creates an event', (tester) async {
    await _signedIn(
      tester,
      admin: InMemoryAdminRepository(roles: {'1': StaffRole.admin}),
    );
    await _go(tester, '/admin/events');
    expect(find.text('Hamlet'), findsOneWidget);
    expect(find.text('Prošao'), findsWidgets);

    await tester.tap(byLabel('Novi događaj').first);
    await tester.pumpAndSettle();

    // Nothing is saved without the details.
    await tapVisible(tester, find.text('Sačuvaj'));
    expect(find.text('Obavezno polje'), findsWidgets);

    final fields = find.byType(EditableText);
    await tester.enterText(fields.at(0), 'Mostar Blues Festival');
    await tester.enterText(fields.at(1), 'Stari most');
    await tester.enterText(fields.at(2), 'Mostar');
    await tapVisible(tester, find.byIcon(FLucideIcons.calendar));
    await tester.tap(find.text('Uredu').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Uredu').last);
    await tester.pumpAndSettle();
    await tapVisible(tester, find.text('Festivali'));
    await tapVisible(tester, find.text('Sačuvaj'));

    expect(find.text('Novi događaj'), findsNothing);
    expect(find.text('Mostar Blues Festival'), findsOneWidget);
    final all = await events.watchEvents().first;
    final created = all.singleWhere(
      (e) => e.info.name == 'Mostar Blues Festival',
    );
    expect(created.info.city, 'Mostar');
    expect(created.info.category, EventCategory.festivals);
    expect(created.isUpcoming, isTrue);
  });

  testWidgets('non-admins have no access to event management', (tester) async {
    await _signedIn(tester);
    await _go(tester, '/admin/events');
    expect(find.text('Nemate pristup'), findsOneWidget);
    expect(find.text('Hamlet'), findsNothing);
  });
}
