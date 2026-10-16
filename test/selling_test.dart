import 'package:flat/src/market/listing_ticket.dart';
import 'package:flat/src/data/events_repository.dart';
import 'package:flat/src/data/memory_repositories.dart';
import 'package:flat/src/data/models.dart';
import 'package:flat/src/ui/tokens.dart';
import 'package:flat/src/ui/ticket.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';

import 'helpers.dart';

Event eventOf(
  String id, {
  String name = 'Dubioza kolektiv',
  EventCategory category = EventCategory.concerts,
  DateTime? date,
  bool hidden = false,
}) => Event(
  id: id,
  info: EventInfo(
    name: name,
    venue: 'Zetra',
    city: 'Sarajevo',
    date: date ?? DateTime(2030, 7, 14, 20),
    category: category,
  ),
  status: hidden ? EventStatus.hidden : EventStatus.confirmed,
);

Listing listingOf(
  String id, {
  String eventId = 'e-dubioza',
  String seller = 'other',
  String name = 'Dubioza kolektiv',
  EventCategory category = EventCategory.concerts,
  ListingStatus status = ListingStatus.active,
}) => Listing.fromMap(id, {
  'sellerId': seller,
  'eventId': eventId,
  'event': {
    'name': name,
    'venue': 'Zetra',
    'city': 'Sarajevo',
    'date': DateTime(2030, 7, 14, 20),
    'category': category.name,
  },
  'quantity': 4,
  'quantitySold': 1,
  'priceMinor': 4500,
  'currency': 'BAM',
  'status': status.name,
  'createdAt': DateTime(2029),
});

void main() {
  testWidgets('home lists upcoming events, filters by search and category', (
    tester,
  ) async {
    final auth = await pumpApp(
      tester,
      eventRepository: InMemoryEventRepository(
        events: [
          eventOf('e-dubioza'),
          eventOf(
            'e-derby',
            name: 'FK Sarajevo – FK Željezničar',
            category: EventCategory.sports,
          ),
          eventOf('e-old', name: 'Past show', date: DateTime(2020)),
          eventOf('e-hidden', name: 'Hidden show', hidden: true),
        ],
      ),
      marketRepository: InMemoryMarketRepository(
        listings: [
          listingOf('a'),
          listingOf('c', status: ListingStatus.withdrawn, eventId: 'e-derby'),
        ],
      ),
    );
    await auth.signIn(email: 'a@b.ba', password: 'x', keepSignedIn: true);
    await tester.pumpAndSettle();

    // Events show up in several sections (popular, nearby, all …).
    expect(find.text('Dubioza kolektiv'), findsWidgets);
    expect(find.text('FK Sarajevo – FK Željezničar'), findsWidgets);
    expect(find.text('Past show'), findsNothing);
    expect(find.text('Hidden show'), findsNothing);
    expect(find.textContaining('· 3 karte'), findsWidgets);
    // Final prices: 45,00 + 10 % service fee.
    expect(find.textContaining('od 49,50'), findsWidgets);
    expect(find.text('Još nema ponuda'), findsWidgets);

    Finder type(String name) =>
        find.descendant(of: find.byType(FTabs), matching: find.text(name));
    await tester.tap(type('Sport'));
    await tester.pumpAndSettle();
    expect(find.text('Dubioza kolektiv'), findsNothing);
    expect(find.text('Svi događaji: Sport'), findsOneWidget);
    await tester.tap(type('Svi tipovi'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(EditableText), 'dubioza');
    await tester.pumpAndSettle();
    expect(find.text('Dubioza kolektiv'), findsOneWidget);
    expect(find.text('FK Sarajevo – FK Željezničar'), findsNothing);

    await tester.enterText(find.byType(EditableText), 'opera');
    await tester.pumpAndSettle();
    expect(find.text('Nema rezultata za „opera”'), findsOneWidget);
  });

  testWidgets('event page lists offers; the ticket flies into the detail', (
    tester,
  ) async {
    final auth = await pumpApp(
      tester,
      eventRepository: InMemoryEventRepository(events: [eventOf('e-dubioza')]),
      marketRepository: InMemoryMarketRepository(listings: [listingOf('a')]),
    );
    await auth.signIn(email: 'a@b.ba', password: 'x', keepSignedIn: true);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Dubioza kolektiv').first);
    await tester.pumpAndSettle();
    expect(find.text('Imaš karte za ovaj događaj?'), findsOneWidget);
    await openTickets(tester);
    expect(find.text('1 ponuda'), findsOneWidget);

    // The offer on the tickets page, then the flying one, then the
    // detail's.
    final offer = find.byType(OfferTicket);
    final ticket = find.byType(TicketCard, skipOffstage: false);
    double ticketTop() => tester.getTopLeft(ticket.last).dy;
    await tester.ensureVisible(offer.first);
    await tester.pumpAndSettle();
    final before = ticketTop();
    await tester.tap(offer.first);
    await tester.pump();
    await tester.pump(Motion.page ~/ 2);
    final during = ticketTop();
    await tester.pumpAndSettle();
    final after = ticketTop();
    expect(
      during,
      inExclusiveRange(
        after < before ? after : before,
        after < before ? before : after,
      ),
      reason: 'before $before during $during after $after',
    );

    // A buyer sees the price per ticket with the 10 % service fee, in the
    // buy bar; the number of tickets is chosen at checkout.
    expect(find.text('Detalji ponude'), findsOneWidget);
    expect(find.text('Sve ponude za ovaj događaj'), findsOneWidget);
    expect(
      find.text('po karti · uključena naknada za uslugu 10%'),
      findsOneWidget,
    );
    expect(find.textContaining('49,50'), findsWidgets);
  });

  testWidgets('seller publishes a listing, changes price and withdraws', (
    tester,
  ) async {
    final auth = await pumpApp(
      tester,
      eventRepository: InMemoryEventRepository(
        events: [
          eventOf('e-sff', name: 'Sarajevo Film Festival'),
          eventOf('e-dubioza'),
        ],
      ),
    );
    await auth.signIn(email: 'a@b.ba', password: 'x', keepSignedIn: true);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Prodaj'));
    await tester.pumpAndSettle();
    // Without a payout method the form is locked.
    expect(find.text('Prvo dodaj način isplate'), findsOneWidget);
    expect(find.text('Odaberi događaj'), findsNothing);
    await tester.tap(find.text('Dodaj način isplate'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(EditableText).first, 'Amra Test');
    await tester.enterText(
      find.byType(EditableText).last,
      'BA391290079401028494',
    );
    await tester.tap(find.text('Sačuvaj'));
    await tester.pumpAndSettle();
    expect(find.text('Odaberi događaj'), findsOneWidget);
    // Let the "saved" snack bar go; it covers the bottom of the form.
    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();

    // Missing fields are reported.
    await tapVisible(tester, find.text('Objavi ponudu'));
    await tester.drag(find.byType(Scrollable).first, const Offset(0, 3000));
    await tester.pumpAndSettle();
    expect(find.text('Odaberite događaj'), findsOneWidget);
    expect(market.watchMyListings('1').first, completion(isEmpty));

    // The event comes from a searchable list.
    await tapVisible(tester, find.text('Odaberi događaj'));
    await tester.enterText(find.byType(EditableText).last, 'film');
    await tester.pumpAndSettle();
    expect(find.text('Dubioza kolektiv'), findsNothing);
    await tester.tap(find.text('Sarajevo Film Festival'));
    await tester.pumpAndSettle();
    expect(find.text('Odaberite događaj'), findsNothing);
    expect(find.text('Sarajevo Film Festival'), findsOneWidget);
    await tapVisible(tester, find.byIcon(FLucideIcons.plus));

    await tester.ensureVisible(find.byIcon(FLucideIcons.receiptText));
    await tester.enterText(
      find.descendant(
        of: find.ancestor(
          of: find.byIcon(FLucideIcons.receiptText),
          matching: find.byType(FTextFormField),
        ),
        matching: find.byType(EditableText),
      ),
      '40',
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
      '50',
    );
    await tester.pumpAndSettle();
    // Seller fee 10 %: 45,00 per ticket, 2 tickets = 90,00.
    expect(find.textContaining('90,00'), findsOneWidget);

    // Without a confirmed email address nothing is published.
    await tapVisible(tester, find.text('Objavi ponudu'));
    expect(find.text('Detalji ponude'), findsNothing);
    expect(market.watchMyListings('1').first, completion(isEmpty));
    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();

    // Once confirmed, it goes through.
    auth.verifyEmail();
    await tester.pumpAndSettle();
    await tapVisible(tester, find.text('Objavi ponudu'));
    expect(find.text('Detalji ponude'), findsOneWidget);
    expect(find.text('Tvoja ponuda'), findsOneWidget);
    expect(find.text('Aktivna'), findsOneWidget);
    // Created for the chosen event, with the current fees.
    final created = (await market.watchMyListings('1').first).single;
    expect(created.eventId, 'e-sff');
    expect(created.event.name, 'Sarajevo Film Festival');
    // Let the "published" toast go; it covers the buttons below.
    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();

    await tapVisible(tester, find.text('Promijeni cijenu'));
    await tester.enterText(find.byType(EditableText).last, '60');
    await tester.tap(find.text('Sačuvaj'));
    await tester.pumpAndSettle();
    expect(find.textContaining('60,00'), findsWidgets);
    // Let the "saved" snack bar disappear; it covers the buttons below.
    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();

    await tapVisible(tester, find.text('Povuci ponudu'));
    await tester.tap(find.widgetWithText(FButton, 'Povuci ponudu').last);
    await tester.pumpAndSettle();
    expect(find.text('Povučena'), findsOneWidget);
    expect(find.text('Promijeni cijenu'), findsNothing);
  });

  testWidgets('guests sign in before selling and come back to the form', (
    tester,
  ) async {
    await pumpApp(tester);
    await tester.tap(find.text('Prodaj'));
    await tester.pumpAndSettle();
    expect(find.text('Objavi ponudu'), findsNothing);
    expect(
      find.text('Prijavi se ili napravi račun da nastaviš.'),
      findsOneWidget,
    );

    await tester.enterText(find.byType(EditableText).at(0), 'amra@test.ba');
    await tester.enterText(find.byType(EditableText).at(1), 'secret1');
    await tester.tap(find.widgetWithText(FButton, 'Prijavi se'));
    await tester.pumpAndSettle();
    // Back where the user wanted to go: selling (here: a payout method
    // is needed first).
    expect(find.text('Prodaj karte'), findsWidgets);
    expect(find.text('Dobrodošli na Stubswap'), findsNothing);
  });
}
