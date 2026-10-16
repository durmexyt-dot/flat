import 'package:flat/src/admin/admin_repository.dart';
import 'package:flat/src/data/events_repository.dart';
import 'package:flat/src/data/memory_repositories.dart';
import 'package:flat/src/data/models.dart';
import 'package:flat/src/data/seat_map_repository.dart';
import 'package:flat/src/events/event_tickets_page.dart';
import 'package:flat/src/home/home_page.dart';
import 'package:flat/src/location/cities.dart';
import 'package:flat/src/location/location_controller.dart';
import 'package:flat/src/market/listing_ticket.dart';
import 'package:flat/src/ui/segmented.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';

import 'helpers.dart';

final _date = DateTime(2030, 6, 20, 20);

Event _show(String id, String venue, String city, {int day = 0}) => Event(
  id: id,
  performer: 'Metallica',
  info: EventInfo(
    name: 'Metallica – M72 $city',
    venue: venue,
    city: city,
    date: _date.add(Duration(days: day)),
    category: EventCategory.concerts,
  ),
);

Listing _offer(
  String id,
  Event e, {
  int price = 10000,
  int quantity = 2,
  String section = '',
  bool together = false,
  TicketType type = TicketType.eTicket,
}) => Listing(
  id: id,
  sellerId: 'seller',
  eventId: e.id,
  event: e.info,
  ticketType: type,
  quantity: quantity,
  quantitySold: 0,
  priceMinor: price,
  currency: 'BAM',
  status: ListingStatus.active,
  section: section,
  together: together,
);

final _sarajevo = _show('m-sa', 'Zetra', 'Sarajevo');
final _zagreb = _show('m-zg', 'Arena', 'Zagreb', day: 2);
final _ilidza = _show('m-il', 'Hala', 'Ilidža', day: 4);

const _zetraMap = SeatMap(
  id: 'zetra-sarajevo',
  venue: 'Zetra',
  city: 'Sarajevo',
  sections: [
    SeatSection(name: 'Parter', rect: MapRect(0.1, 0.4, 0.8, 0.3)),
    SeatSection(name: 'Tribina Sjever', rect: MapRect(0.1, 0.05, 0.8, 0.2)),
  ],
  stage: MapRect(0.3, 0.8, 0.4, 0.15),
);

Future<FakeAuthRepository> _pump(
  WidgetTester tester, {
  List<Event>? events,
  List<Listing> listings = const [],
  List<SeatMap> maps = const [],
  InMemoryAdminRepository? admin,
}) async {
  final auth = await pumpApp(
    tester,
    eventRepository: InMemoryEventRepository(
      events: events ?? [_sarajevo, _zagreb],
    ),
    marketRepository: InMemoryMarketRepository(listings: listings),
    seatMapRepository: InMemorySeatMapRepository(maps: maps),
    adminRepository: admin,
  );
  await auth.signIn(email: 'a@b.ba', password: 'x', keepSignedIn: true);
  await tester.pumpAndSettle();
  return auth;
}

ProviderContainer _container(WidgetTester tester) =>
    ProviderScope.containerOf(tester.element(find.byType(HomePage)));

Future<void> _go(WidgetTester tester, String location) async {
  GoRouter.of(tester.element(find.byType(HomePage))).push(location);
  await tester.pumpAndSettle();
}

List<String> _shownOffers(WidgetTester tester) => tester
    .widgetList<OfferTicket>(find.byType(OfferTicket))
    .map((t) => t.listing.id)
    .toList();

void main() {
  test('dates group by performer, else by name', () {
    expect(_sarajevo.groupKey, _zagreb.groupKey);
    final other = Event(id: 'x', info: _sarajevo.info);
    expect(other.groupKey, isNot(_sarajevo.groupKey));
    expect(searchKey('Tribina  Sjever!'), searchKey('tribina-sjever'));
    expect(seatMapId('Koševo', 'Sarajevo'), 'kosevo-sarajevo');
    expect(isNearCity('Ilidža', 'Sarajevo'), isTrue);
    expect(isNearCity('Tuzla', 'Sarajevo'), isFalse);
    final r = MapRect.normalized(0.5, 0.5, -0.2, 0.9);
    expect([r.x, r.y, r.w, r.h], [0.3, 0.5, 0.2, 0.5]);
  });

  testWidgets('no dates near the chosen city: the others are offered', (
    tester,
  ) async {
    await _pump(
      tester,
      listings: [_offer('a', _sarajevo), _offer('b', _zagreb)],
    );
    _container(tester).read(chosenCityProvider.notifier).setCity('Tuzla');
    await _go(tester, '/event/${_sarajevo.id}');

    expect(find.text('Nema događaja u tvojoj blizini'), findsOneWidget);
    expect(find.text('2 događaja na drugim mjestima'), findsOneWidget);
    expect(find.text('Prikaži karte'), findsNWidgets(2));
  });

  testWidgets('dates near the city come first; sold out ones say so', (
    tester,
  ) async {
    await _pump(
      tester,
      events: [_sarajevo, _zagreb, _ilidza],
      listings: [_offer('a', _sarajevo), _offer('b', _zagreb)],
    );
    _container(tester).read(chosenCityProvider.notifier).setCity('Sarajevo');
    await _go(tester, '/event/${_zagreb.id}');

    // Sarajevo and nearby Ilidža; Zagreb elsewhere.
    expect(find.text('2 događaja u tvojoj blizini'), findsOneWidget);
    expect(find.text('1 događaj na drugom mjestu'), findsOneWidget);
    // Ilidža has no tickets.
    expect(find.text('Nema karata'), findsOneWidget);
    expect(find.text('Prikaži karte'), findsNWidgets(2));

    await tapVisible(tester, find.text('Prikaži karte').first);
    expect(find.byType(EventTicketsPage), findsOneWidget);
    expect(_shownOffers(tester), ['a']);
  });

  testWidgets('without a seat map the tickets page says one is coming', (
    tester,
  ) async {
    await _pump(tester, listings: [_offer('a', _sarajevo)]);
    await _go(tester, '/event/${_sarajevo.id}/tickets');
    expect(find.text('Plan sjedenja uskoro'), findsOneWidget);
    expect(_shownOffers(tester), ['a']);
  });

  testWidgets('tapping a section on the seat map shows its offers', (
    tester,
  ) async {
    await _pump(
      tester,
      maps: [_zetraMap],
      listings: [
        _offer('p1', _sarajevo, section: 'parter', price: 9000),
        _offer('t1', _sarajevo, section: 'Tribina Sjever', price: 7000),
        _offer('x1', _sarajevo, section: 'VIP', price: 8000),
      ],
    );
    final semantics = tester.ensureSemantics();
    await _go(tester, '/event/${_sarajevo.id}/tickets');
    expect(find.text('Plan sjedenja uskoro'), findsNothing);
    expect(_shownOffers(tester), ['t1', 'x1', 'p1']);

    await tester.tap(find.bySemanticsLabel(RegExp('^Parter: 1 ponuda')));
    await tester.pumpAndSettle();
    expect(_shownOffers(tester), ['p1']);
    expect(find.text('Sektor: Parter'), findsOneWidget);

    // Tapping it again shows all again.
    await tester.tap(find.bySemanticsLabel(RegExp('^Parter: 1 ponuda')));
    await tester.pumpAndSettle();
    expect(_shownOffers(tester).length, 3);
    semantics.dispose();
  });

  testWidgets('seats together, price and ticket type filter the offers', (
    tester,
  ) async {
    await _pump(
      tester,
      listings: [
        _offer('a', _sarajevo, price: 5000, quantity: 3, together: true),
        _offer('b', _sarajevo, price: 6000, quantity: 4),
        _offer('c', _sarajevo, price: 7000, quantity: 1),
        _offer('d', _sarajevo, price: 8000, type: TicketType.paper),
      ],
    );
    await _go(tester, '/event/${_sarajevo.id}/tickets');
    expect(_shownOffers(tester), ['a', 'b', 'c', 'd']);
    // The switch only appears from two tickets on.
    expect(find.text('Sjedišta jedno do drugog'), findsNothing);

    await tapVisible(
      tester,
      find.descendant(
        of: find.byType(Segmented<int>),
        matching: find.text('2'),
      ),
    );
    expect(_shownOffers(tester), ['a', 'b', 'd']);
    await tapVisible(tester, find.text('Sjedišta jedno do drugog'));
    expect(_shownOffers(tester), ['a']);
    expect(find.text('Jedno do drugog'), findsOneWidget);

    await tapVisible(tester, find.text('Poništi filtere'));
    expect(_shownOffers(tester).length, 4);
    await tapVisible(tester, find.widgetWithText(FButton, 'Papirna'));
    expect(_shownOffers(tester), ['d']);
  });

  test('the price range keeps offers between its bounds', () {
    final l = _offer('a', _sarajevo, price: 5000);
    // 5000 + 10 % service fee.
    expect(l.buyerPriceMinor, 5500);
    expect(const OfferFilter(minPrice: 5000, maxPrice: 6000).accepts(l), true);
    expect(const OfferFilter(maxPrice: 5000).accepts(l), false);
    expect(const OfferFilter(minPrice: 6000).accepts(l), false);
  });

  testWidgets('the team draws a section on a seat map and saves it', (
    tester,
  ) async {
    await _pump(
      tester,
      admin: InMemoryAdminRepository(roles: {'1': StaffRole.support}),
    );
    await _go(
      tester,
      Uri(
        path: '/admin/seatmaps/zetra-sarajevo',
        queryParameters: {'venue': 'Zetra', 'city': 'Sarajevo'},
      ).toString(),
    );
    expect(find.text('Zetra · Sarajevo'), findsOneWidget);

    final map = find.byType(AspectRatio).first;
    final box = tester.getRect(map);
    await tester.dragFrom(
      box.topLeft + Offset(box.width * 0.1, box.height * 0.1),
      Offset(box.width * 0.5, box.height * 0.3),
    );
    await tester.pumpAndSettle();
    // The new section is selected for naming.
    final name = find.widgetWithText(FTextField, 'Naziv sektora');
    expect(name, findsOneWidget);
    await tester.enterText(
      find.descendant(of: name, matching: find.byType(EditableText)),
      'Parter',
    );
    FocusManager.instance.primaryFocus?.unfocus();
    await tester.pumpAndSettle();
    await tapVisible(tester, find.widgetWithText(FButton, 'Sačuvaj'));

    final saved = await seatMaps.watchSeatMap('zetra-sarajevo').first;
    expect(saved!.sections.single.name, 'Parter');
    expect(saved.sections.single.rect.w, closeTo(0.5, 0.05));
  });
}
