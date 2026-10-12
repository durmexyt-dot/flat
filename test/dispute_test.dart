import 'package:flat/src/admin/admin_repository.dart';
import 'package:flat/src/data/events_repository.dart';
import 'package:flat/src/data/memory_repositories.dart';
import 'package:flat/src/data/models.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';

import 'helpers.dart';

final _event = {
  'name': 'Sarajevo Jazz Festival',
  'venue': 'Dom mladih',
  'city': 'Sarajevo',
  'date': DateTime(2030, 11, 2, 20),
  'category': 'festivals',
};

Order _order({
  String buyer = '1',
  String seller = 'seller',
  String status = 'ticketsSent',
  Map<String, Object?>? dispute,
}) => Order.fromMap('order-7', {
  'number': 'SSW-ABC123',
  'listingId': 'jazz',
  'buyerId': buyer,
  'sellerId': seller,
  'event': _event,
  'quantity': 1,
  'unitPriceMinor': 3500,
  'currency': 'BAM',
  'ticketType': 'mobile',
  'status': status,
  'dispute': ?dispute,
  'history': [
    {'status': status, 'at': DateTime(2026, 10, 1)},
  ],
  'createdAt': DateTime(2026, 10, 1),
});

Future<void> _start(
  WidgetTester tester, {
  required List<Order> orders,
  StaffRole? role,
  InMemoryEventRepository? events,
}) async {
  final auth = await pumpApp(
    tester,
    marketRepository: InMemoryMarketRepository(orders: orders),
    adminRepository: InMemoryAdminRepository(roles: {'1': ?role}),
    eventRepository: events,
  );
  await auth.signIn(email: 'amra@test.ba', password: 'x', keepSignedIn: true);
  await tester.pumpAndSettle();
}

Future<void> _go(WidgetTester tester, String location) async {
  GoRouter.of(tester.element(find.byType(Navigator).first)).push(location);
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('buyer reports a problem with an order', (tester) async {
    await _start(tester, orders: [_order()]);
    await _go(tester, '/order/order-7');
    expect(find.text('Detalji narudžbe'), findsOneWidget);

    await tapVisible(tester, find.text('Prijavi problem'));
    expect(find.text('Prijavi problem s narudžbom'), findsOneWidget);
    await tester.tap(find.text('Pogrešne karte'));
    await tester.pumpAndSettle();

    // Too short to help the team.
    await tester.enterText(find.byType(EditableText).last, 'Loše');
    await tester.tap(find.text('Pošalji prijavu'));
    await tester.pumpAndSettle();
    expect(find.text('Napiši barem 10 znakova.'), findsOneWidget);
    expect(serverActions.calls, isEmpty);

    await tester.enterText(
      find.byType(EditableText).last,
      'Na kartama je drugi sektor nego u ponudi.',
    );
    await tester.tap(find.text('Pošalji prijavu'));
    await tester.pumpAndSettle();
    expect(serverActions.calls, ['openDispute order-7 wrongTickets']);
    expect(find.text('Prijava poslana. Javit ćemo ti se.'), findsOneWidget);
    expect(find.text('Prijavi problem s narudžbom'), findsNothing);
  });

  testWidgets('buyer sees the open report and its request', (tester) async {
    await _start(
      tester,
      orders: [
        _order(
          status: 'disputed',
          dispute: {
            'reason': 'invalid',
            'text': 'Karta je odbijena na ulazu.',
            'previousStatus': 'ticketsSent',
            'supportTicketId': 'ticket-9',
            'openedAt': DateTime(2026, 10, 2),
          },
        ),
      ],
    );
    await _go(tester, '/order/order-7');
    expect(
      find.text('Problem prijavljen – čeka odluku podrške'),
      findsOneWidget,
    );
    await tapVisible(tester, find.text('Karta je odbijena na ulazu.'));
    expect(find.text('Karta ne važi'), findsOneWidget);
    expect(find.text('Čeka odluku'), findsOneWidget);
    expect(find.text('Otvori zahtjev za podršku'), findsOneWidget);
    // One report at a time.
    expect(find.text('Prijavi problem'), findsNothing);
  });

  testWidgets('the team decides on a reported problem', (tester) async {
    await _start(
      tester,
      role: StaffRole.support,
      orders: [
        _order(
          buyer: 'buyer',
          status: 'disputed',
          dispute: {
            'reason': 'notReceived',
            'text': 'Karte nikad nisu stigle.',
            'previousStatus': 'paid',
          },
        ),
      ],
    );
    await _go(tester, '/order/order-7');
    expect(find.text('Odluka tima'), findsOneWidget);
    expect(find.text('Prijavi problem'), findsNothing);

    await tapVisible(tester, find.text('Odbij prijavu'));
    expect(
      find.text('Narudžba se nastavlja kao prije prijave.'),
      findsOneWidget,
    );
    await tester.enterText(
      find.byType(EditableText).last,
      'Prodavac je poslao dokaz o predaji.',
    );
    await tester.tap(find.widgetWithText(FButton, 'Odbij prijavu').last);
    await tester.pumpAndSettle();
    expect(serverActions.calls, ['resolveDispute order-7 reject']);
    expect(find.text('Odluka sačuvana'), findsOneWidget);
  });

  testWidgets('the team cancels an event', (tester) async {
    await _start(
      tester,
      role: StaffRole.admin,
      orders: const [],
      events: InMemoryEventRepository(
        events: [Event(id: 'jazz-event', info: EventInfo.fromMap(_event))],
      ),
    );
    await _go(tester, '/admin/events/jazz-event');
    await tapVisible(tester, find.text('Otkaži događaj'));
    expect(
      find.textContaining('Svi kupci automatski dobijaju povrat novca'),
      findsOneWidget,
    );
    // A reason is required.
    await tester.tap(find.widgetWithText(FButton, 'Otkaži događaj').last);
    await tester.pumpAndSettle();
    expect(find.text('Obavezno polje'), findsOneWidget);

    await tester.enterText(
      find.byType(EditableText).last,
      'Izvođač je otkazao nastup.',
    );
    await tester.tap(find.widgetWithText(FButton, 'Otkaži događaj').last);
    await tester.pumpAndSettle();
    expect(serverActions.calls, ['cancelEvent jazz-event']);
    expect(
      find.text('Događaj otkazan, 0 kupaca dobija povrat novca'),
      findsOneWidget,
    );
  });

  testWidgets('a cancelled event cannot be edited', (tester) async {
    await _start(
      tester,
      role: StaffRole.admin,
      orders: const [],
      events: InMemoryEventRepository(
        events: [
          Event.fromMap('jazz-event', {
            ..._event,
            'status': 'cancelled',
            'cancelReason': 'Kiša',
          }),
        ],
      ),
    );
    await _go(tester, '/admin/events/jazz-event');
    expect(
      find.text('Ovaj događaj je otkazan i više se ne može mijenjati.'),
      findsOneWidget,
    );
    expect(find.text('Razlog: Kiša'), findsOneWidget);
    expect(find.text('Sačuvaj'), findsNothing);
    expect(find.text('Otkaži događaj'), findsNothing);
  });
}
