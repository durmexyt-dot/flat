import 'package:flat/src/auth/auth_widgets.dart';
import 'package:flat/src/data/memory_repositories.dart';
import 'package:flat/src/data/models.dart';
import 'package:flat/src/payments/payment_gateway.dart';
import 'package:flat/src/payments/test_payment_gateway.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers.dart';

Listing _jazz({int quantity = 4}) => Listing.fromMap('jazz', {
  'sellerId': 'seller',
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
  );
  await auth.signIn(email: 'amra@test.ba', password: 'x', keepSignedIn: true);
  await tester.pumpAndSettle();
  await tester.tap(find.text('Sarajevo Jazz Festival'));
  await tester.pumpAndSettle();
  await tapVisible(tester, find.byIcon(Icons.add).last);
  await tapVisible(tester, find.text('Kupi karte').last);
  expect(find.text('Plaćanje'), findsOneWidget);
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
    find.descendant(
      of: find.byType(PaymentSimulatorSheet),
      matching: find.byType(FilledButton),
    ),
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

  testWidgets('buying the last tickets sells the listing out', (tester) async {
    await _toCheckout(tester, quantity: 2);
    await _openSimulatorAndPay(tester);
    final listing = await tester.runAsync(
      () => market.watchListing('jazz').first,
    );
    expect(listing!.status, ListingStatus.soldOut);
  });

  testWidgets('seller marks tickets sent on a paid sale', (tester) async {
    final market = InMemoryMarketRepository(
      listings: [
        Listing.fromMap('jazz', {..._jazz().toMap(), 'sellerId': '1'}),
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
    await tester.tap(find.byTooltip('Postavke'));
    await tester.pumpAndSettle();
    await tapVisible(tester, find.text('Prodaje'));
    await tester.tap(find.text('Sarajevo Jazz Festival'));
    await tester.pumpAndSettle();
    expect(find.text('Pošalji karte kupcu što prije.'), findsOneWidget);

    await tapVisible(tester, find.text('Označi karte kao poslane'));
    final sales = await tester.runAsync(() => market.watchSales('1').first);
    expect(sales!.single.status, OrderStatus.ticketsSent);
    await tester.pumpAndSettle();
    expect(
      find.text('Isplata slijedi nakon događaja.', skipOffstage: false),
      findsOneWidget,
    );

    // The sales list shows the new status too.
    await tester.tap(find.byType(BackButton).last);
    await tester.pumpAndSettle();
    expect(find.text('Karte poslane'), findsOneWidget);
    expect(find.text('Plaćeno'), findsNothing);
  });
}
