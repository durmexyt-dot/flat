import 'package:flat/src/auth/auth_widgets.dart';
import 'package:flat/src/data/events_repository.dart';
import 'package:flat/src/data/memory_repositories.dart';
import 'package:flat/src/data/models.dart';
import 'package:flat/src/market/listing_ticket.dart';
import 'package:flat/src/payments/checkout_page.dart';
import 'package:flat/src/payments/payment_gateway.dart';
import 'package:flat/src/payments/test_payment_gateway.dart';
import 'package:flat/src/ui/site_scaffold.dart';
import 'package:flutter/widgets.dart' show EditableText;
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';

import 'helpers.dart';

Listing _jazz({int quantity = 4}) => Listing.fromMap('jazz', {
  'sellerId': 'seller',
  'eventId': 'jazz-event',
  'event': {
    'name': 'Sarajevo Jazz Festival',
    'venue': 'Dom mladih',
    'city': 'Sarajevo',
    'date': DateTime(2030, 11, 2, 20),
    'category': 'festivals',
  },
  'quantity': quantity,
  'priceMinor': 3500,
  'currency': 'BAM',
  'status': 'active',
});

/// Signs in as buyer '1', opens the listing and goes to checkout with
/// two tickets.
Future<void> _toCheckout(WidgetTester tester, {int quantity = 4}) async {
  final auth = await pumpApp(
    tester,
    marketRepository: InMemoryMarketRepository(
      listings: [_jazz(quantity: quantity)],
    ),
    eventRepository: InMemoryEventRepository(
      events: [Event(id: 'jazz-event', info: _jazz().event)],
    ),
  );
  await auth.signIn(email: 'amra@test.ba', password: 'x', keepSignedIn: true);
  await tester.pumpAndSettle();
  // Home shows the event; its page lists the offer.
  await tester.tap(find.text('Sarajevo Jazz Festival').first);
  await tester.pumpAndSettle();
  await tapVisible(tester, find.byType(OfferTicket).first);
  // Phones: the buy bar at the bottom; the number is chosen at checkout.
  await tester.tap(find.text('Kupi karte').last);
  await tester.pumpAndSettle();
  expect(find.text('Plaćanje'), findsOneWidget);
  await tapVisible(tester, find.byIcon(FLucideIcons.plus).last);
  expect(find.text('Testni način · bez pravog novca'), findsOneWidget);
}

/// The pay button keeps spinning while the simulator is open, so this
/// advances time instead of waiting for everything to settle.
Future<void> _settleSheet(WidgetTester tester) async {
  for (var i = 0; i < 6; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

Future<void> _openSimulatorAndPay(
  WidgetTester tester, {
  bool succeed = true,
  String? reason,
  String payLabel = 'Plati 77,00',
}) async {
  // 2 × 35,00 + 10 % = 77,00
  final pay = find.descendant(
    of: find.byType(SubmitButton),
    matching: find.textContaining(payLabel),
  );
  await tester.ensureVisible(pay.first);
  await tester.pumpAndSettle();
  await tester.tap(pay.first);
  await _settleSheet(tester);
  expect(find.text('stripe'), findsOneWidget);
  expect(find.text('4242 4242 4242 4242'), findsOneWidget);
  if (!succeed) {
    await tester.tap(find.text('Plaćanje uspješno'));
    await _settleSheet(tester);
    if (reason != null) {
      await tester.tap(find.text(reason));
      await _settleSheet(tester);
    }
  }
  await tester.tap(
    find
        .descendant(
          of: find.byType(PaymentSimulatorSheet),
          matching: find.byType(FButton),
        )
        .last,
  );
  await tester.pump();
  expect(find.text('Obrada plaćanja…'), findsOneWidget);
  await tester.pump(const Duration(milliseconds: 1500));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('successful test payment pays the order and books tickets', (
    tester,
  ) async {
    await _toCheckout(tester);
    await _openSimulatorAndPay(tester);

    expect(find.text('Detalji narudžbe'), findsOneWidget);
    expect(find.text('Plaćeno'), findsWidgets);
    final orders = await tester.runAsync(
      () => market.watchPurchases('1').first,
    );
    final order = orders!.single;
    expect(order.status, OrderStatus.paid);
    expect(order.paymentMethod, 'Visa •••• 4242');
    expect(order.paymentId, startsWith('pi_test_'));

    final listing = await tester.runAsync(
      () => market.watchListing('jazz').first,
    );
    expect(listing!.quantitySold, 2);
    expect(listing.status, ListingStatus.active);

    final payouts = await tester.runAsync(
      () => market.watchPayouts('seller').first,
    );
    // 70,00 − 10 % = 63,00 for the seller.
    expect(payouts!.single.amountMinor, 6300);
    expect(payouts.single.status, PayoutStatus.pending);
  });

  testWidgets('declined test payment cancels the order and allows retry', (
    tester,
  ) async {
    await _toCheckout(tester);
    await _openSimulatorAndPay(
      tester,
      succeed: false,
      reason: 'Nedovoljno sredstava',
    );

    expect(find.text('Plaćanje nije uspjelo'), findsOneWidget);
    expect(find.textContaining('Nedovoljno sredstava'), findsOneWidget);
    final orders = await tester.runAsync(
      () => market.watchPurchases('1').first,
    );
    expect(orders!.single.status, OrderStatus.cancelled);
    expect(orders.single.failureReason, 'insufficientFunds');
    final listing = await tester.runAsync(
      () => market.watchListing('jazz').first,
    );
    expect(listing!.quantitySold, 0);

    // Retry starts a new order and succeeds.
    await _openSimulatorAndPay(tester, payLabel: 'Pokušaj ponovo');
    final after = await tester.runAsync(() => market.watchPurchases('1').first);
    expect(
      after!.map((o) => o.status),
      containsAll([OrderStatus.cancelled, OrderStatus.paid]),
    );
  });

  testWidgets('tickets are held for 15 minutes, then the hold ends', (
    tester,
  ) async {
    addTearDown(() => checkoutNow = DateTime.now);
    await _toCheckout(tester);
    expect(find.textContaining('15 minuta rezervisane'), findsOneWidget);

    // Starting the payment holds the tickets; closing the form keeps them.
    final pay = find.descendant(
      of: find.byType(SubmitButton),
      matching: find.textContaining('Plati 77,00'),
    );
    await tester.ensureVisible(pay.first);
    await tester.pumpAndSettle();
    await tester.tap(pay.first);
    await _settleSheet(tester);
    await tester.tap(
      find.descendant(
        of: find.byType(PaymentSimulatorSheet),
        matching: find.byIcon(FLucideIcons.x),
      ),
    );
    await tester.pumpAndSettle();
    expect(
      find.textContaining('Karte su rezervisane za tebe još 1'),
      findsOneWidget,
    );
    final listing = await tester.runAsync(
      () => market.watchListing('jazz').first,
    );
    expect(listing!.quantityReserved, 2);

    // A quarter of an hour later the time is up.
    checkoutNow = () => DateTime.now().add(const Duration(minutes: 16));
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();
    expect(find.text('Rezervacija je istekla'), findsOneWidget);
    expect(find.text('Nazad na ponudu'), findsOneWidget);
  });

  testWidgets('buying the last tickets sells the listing out', (tester) async {
    await _toCheckout(tester, quantity: 2);
    await _openSimulatorAndPay(tester);
    final listing = await tester.runAsync(
      () => market.watchListing('jazz').first,
    );
    expect(listing!.status, ListingStatus.soldOut);
  });

  testWidgets('seller marks mobile tickets sent on a paid sale', (
    tester,
  ) async {
    // E-tickets go out as uploaded files; mobile tickets are confirmed.
    final market = InMemoryMarketRepository(
      listings: [
        Listing.fromMap('jazz', {
          ..._jazz().toMap(),
          'sellerId': '1',
          'ticketType': 'mobile',
        }),
      ],
    );
    final listing = (await market.watchListing('jazz').first)!;
    final order = await market.createOrder(
      listing: listing,
      quantity: 1,
      buyerId: 'buyer',
    );
    await market.completePayment(
      order,
      const PaymentSucceeded(paymentId: 'pi_1', methodLabel: 'Visa'),
    );
    final auth = await pumpApp(tester, marketRepository: market);
    await auth.signIn(email: 'a@b.ba', password: 'x', keepSignedIn: true);
    await tester.pumpAndSettle();
    await tester.tap(byLabel('Postavke'));
    await tester.pumpAndSettle();
    await tapVisible(tester, find.text('Prodane karte'));
    await tester.tap(find.text('Sarajevo Jazz Festival'));
    await tester.pumpAndSettle();
    expect(find.text('Pošalji karte kupcu što prije.'), findsOneWidget);

    // With the handover details: transferred to the buyer's account.
    await tapVisible(tester, find.text('Unesi predaju karata'));
    await tester.enterText(
      find.descendant(
        of: find.ancestor(
          of: find.text('Prenijeto na'),
          matching: find.byType(FTextFormField),
        ),
        matching: find.byType(EditableText),
      ),
      'kupac@test.ba',
    );
    await tester.tap(find.text('Karte predane'));
    await tester.pumpAndSettle();
    final sales = await tester.runAsync(() => market.watchSales('1').first);
    expect(sales!.single.status, OrderStatus.ticketsSent);
    await tester.pumpAndSettle();
    expect(
      find.text('Isplata slijedi nakon događaja.', skipOffstage: false),
      findsOneWidget,
    );

    // The sales list shows the new status too.
    await tester.tap(find.byKey(backButtonKey).last);
    await tester.pumpAndSettle();
    expect(find.text('Karte poslane'), findsOneWidget);
    expect(find.text('Plaćeno'), findsNothing);
  });

  testWidgets('seller cancels a sale: refund, tickets back, no payout', (
    tester,
  ) async {
    final market = InMemoryMarketRepository(
      listings: [
        Listing.fromMap('jazz', {
          ..._jazz().toMap(),
          'sellerId': '1',
          'quantity': 2,
        }),
      ],
    );
    final listing = (await market.watchListing('jazz').first)!;
    final order = await market.createOrder(
      listing: listing,
      quantity: 2,
      buyerId: 'buyer',
    );
    await market.completePayment(
      order,
      const PaymentSucceeded(paymentId: 'pi_1', methodLabel: 'Visa'),
    );
    expect(
      (await market.watchListing('jazz').first)!.status,
      ListingStatus.soldOut,
    );

    final auth = await pumpApp(tester, marketRepository: market);
    await auth.signIn(email: 'a@b.ba', password: 'x', keepSignedIn: true);
    await tester.pumpAndSettle();
    await tester.tap(byLabel('Postavke'));
    await tester.pumpAndSettle();
    await tapVisible(tester, find.text('Prodane karte'));
    await tester.tap(find.text('Sarajevo Jazz Festival'));
    await tester.pumpAndSettle();

    await tapVisible(tester, find.text('Otkaži prodaju'));
    expect(find.text('Otkazati prodaju?'), findsOneWidget);
    await tester.tap(find.widgetWithText(FButton, 'Otkaži prodaju').last);
    await tester.pumpAndSettle();

    final sales = await tester.runAsync(() => market.watchSales('1').first);
    expect(sales!.single.status, OrderStatus.refunded);
    final back = await tester.runAsync(() => market.watchListing('jazz').first);
    expect(back!.quantitySold, 0);
    expect(back.status, ListingStatus.active);
    final payouts = await tester.runAsync(() => market.watchPayouts('1').first);
    expect(payouts, isEmpty);
    expect(
      find.text(
        'Otkazao/la si prodaju. Kupcu je vraćen novac, a karte su ponovo u prodaji.',
        skipOffstage: false,
      ),
      findsOneWidget,
    );
    expect(find.text('Otkaži prodaju'), findsNothing);
  });

  testWidgets('buyers get no cancel button', (tester) async {
    final market = InMemoryMarketRepository(listings: [_jazz()]);
    final listing = (await market.watchListing('jazz').first)!;
    final order = await market.createOrder(
      listing: listing,
      quantity: 1,
      buyerId: '1',
    );
    await market.completePayment(
      order,
      const PaymentSucceeded(paymentId: 'pi_1', methodLabel: 'Visa'),
    );
    final auth = await pumpApp(tester, marketRepository: market);
    await auth.signIn(email: 'a@b.ba', password: 'x', keepSignedIn: true);
    await tester.pumpAndSettle();
    await tester.tap(byLabel('Postavke'));
    await tester.pumpAndSettle();
    await tapVisible(tester, find.text('Moje karte').first);
    await tester.tap(find.text('Sarajevo Jazz Festival'));
    await tester.pumpAndSettle();
    expect(find.text('Detalji narudžbe'), findsOneWidget);
    expect(find.text('Otkaži prodaju'), findsNothing);
  });

  testWidgets('the seller sees a sale live, the moment the buyer pays', (
    tester,
  ) async {
    final market = InMemoryMarketRepository(
      listings: [
        Listing.fromMap('jazz', {..._jazz().toMap(), 'sellerId': '1'}),
      ],
    );
    final auth = await pumpApp(tester, marketRepository: market);
    await auth.signIn(email: 'a@b.ba', password: 'x', keepSignedIn: true);
    await tester.pumpAndSettle();
    expect(find.textContaining('Prodane karte'), findsNothing);

    // Somewhere else, a buyer pays.
    final listing = (await market.watchListing('jazz').first)!;
    await tester.runAsync(() async {
      final order = await market.createOrder(
        listing: listing,
        quantity: 2,
        buyerId: 'buyer',
      );
      await market.completePayment(
        order,
        const PaymentSucceeded(paymentId: 'pi_1', methodLabel: 'Visa'),
      );
    });
    await tester.pumpAndSettle();
    expect(find.text('Prodane karte: Sarajevo Jazz Festival'), findsOneWidget);

    // The toast leads to the sale.
    await tester.tap(find.text('Pogledaj'));
    await tester.pumpAndSettle();
    expect(find.text('Detalji prodaje'), findsOneWidget);
  });
}
