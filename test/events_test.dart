import 'package:flat/src/admin/admin_repository.dart';
import 'package:flat/src/data/events_repository.dart';
import 'package:flat/src/data/memory_repositories.dart';
import 'package:flat/src/data/models.dart';
import 'package:flat/src/home/home_page.dart';
import 'package:flat/src/market/listing_ticket.dart';
import 'package:flat/src/ui/segmented.dart';
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

    // Events show up in several sections (popular, nearby, all …).
    expect(find.text('FK Sarajevo – FK Željezničar'), findsWidgets);
    expect(find.text('Dubioza kolektiv'), findsWidgets);
    // Past events are not offered.
    expect(find.text('Hamlet'), findsNothing);
    // Derby: 6 − 2 tickets from 35,00 (38,50 with the 10 % service fee);
    // Dubioza: 1 of the own listing.
    expect(find.textContaining('od 38,50'), findsWidgets);
    expect(find.textContaining('· 4 karte'), findsWidgets);
    expect(find.textContaining('· 1 karta'), findsWidgets);
  });

  testWidgets('tapping an event shows its offers', (tester) async {
    await _signedIn(tester);

    await tester.tap(find.text('FK Sarajevo – FK Željezničar').first);
    await tester.pumpAndSettle();
    expect(find.text('Imaš karte za ovaj događaj?'), findsOneWidget);
    // Offers show what tells them apart: price, seats, how many.
    expect(find.byType(OfferTicket), findsWidgets);
    await tapVisible(tester, find.byType(OfferTicket).first);
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

    await tapVisible(tester, find.text('Bijelo Dugme Tribute').first);
    await tapVisible(tester, find.widgetWithText(FButton, 'Prodaj karte').last);
    // Preselected.
    expect(find.text('Bijelo Dugme Tribute'), findsOneWidget);
    expect(find.text('Promijeni'), findsOneWidget);

    await tester.ensureVisible(find.byIcon(FLucideIcons.receiptText));
    await tester.enterText(
      find.descendant(
        of: find.ancestor(
          of: find.byIcon(FLucideIcons.receiptText),
          matching: find.byType(FTextFormField),
        ),
        matching: find.byType(EditableText),
      ),
      '35',
    );
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
    // Nothing waits for a check: confirmed upcoming events come first.
    expect(find.text('Hamlet'), findsNothing);
    await tester.ensureVisible(find.text('Prošli'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Prošli'));
    await tester.pumpAndSettle();
    expect(find.text('Hamlet'), findsOneWidget);
    await tester.ensureVisible(find.text('Potvrđeni'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Potvrđeni'));
    await tester.pumpAndSettle();

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

  testWidgets('offers are cheapest first and filter by how many', (
    tester,
  ) async {
    Listing offer(String id, int price, int quantity) => Listing.fromMap(id, {
      'sellerId': 'other',
      'eventId': 'ev-x',
      'event': {
        'name': 'Test koncert',
        'venue': 'Zetra',
        'city': 'Sarajevo',
        'date': DateTime(2030, 7, 14, 20),
        'category': 'concerts',
      },
      'quantity': quantity,
      'priceMinor': price,
      'currency': 'BAM',
      'status': 'active',
    });
    final auth = await pumpApp(
      tester,
      marketRepository: InMemoryMarketRepository(
        listings: [
          offer('a', 6000, 2),
          offer('b', 4000, 1),
          offer('c', 5000, 5),
        ],
      ),
      eventRepository: InMemoryEventRepository(
        events: [Event(id: 'ev-x', info: offer('a', 1, 1).event)],
      ),
    );
    await auth.signIn(email: 'amra@test.ba', password: 'x', keepSignedIn: true);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Test koncert').first);
    await tester.pumpAndSettle();
    expect(find.text('3 ponude'), findsOneWidget);

    List<String> shown() => tester
        .widgetList<OfferTicket>(find.byType(OfferTicket, skipOffstage: false))
        .map((t) => t.listing.id)
        .toList();
    // Cheapest first.
    expect(shown(), ['b', 'c', 'a']);

    // Only offers with at least 2 tickets left.
    Finder amount(String label) => find.descendant(
      of: find.byType(Segmented<int>),
      matching: find.text(label),
    );
    await tapVisible(tester, amount('2'));
    expect(shown(), ['c', 'a']);
    // None has 4 or more besides "c".
    await tapVisible(tester, amount('4+'));
    expect(shown(), ['c']);
  });
}
