import 'package:flat/l10n/app_localizations.dart';
import 'package:flat/src/data/models.dart';
import 'package:flat/src/market/order_labels.dart';
import 'package:flat/src/ui/status_timeline.dart';
import 'package:flat/src/ui/site_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'fixtures.dart';
import 'helpers.dart';

/// Signs in as user '1' with the demo data and opens an account entry.
Future<void> _openAccountEntry(WidgetTester tester, String entry) async {
  final auth = await pumpApp(tester, marketRepository: buildSampleMarket('1'));
  await auth.signIn(email: 'amra@test.ba', password: 'x', keepSignedIn: true);
  await tester.pumpAndSettle();
  await tester.tap(byLabel('Postavke'));
  await tester.pumpAndSettle();
  await tapVisible(tester, find.text(entry));
}

void main() {
  testWidgets('account counts follow orders and listings', (tester) async {
    final auth = await pumpApp(
      tester,
      marketRepository: buildSampleMarket('1'),
    );
    await auth.signIn(email: 'amra@test.ba', password: 'x', keepSignedIn: true);
    await tester.pumpAndSettle();
    await tester.tap(byLabel('Postavke'));
    await tester.pumpAndSettle();
    // Listed 4+4+2, sold 1+2+4+1 (pending payment excluded),
    // bought 2+1+2 (refunded excluded).
    expect(find.text('10'), findsOneWidget);
    expect(find.text('8'), findsOneWidget);
    expect(find.text('5'), findsOneWidget);
  });

  testWidgets('purchase shows progress and invoice with fees', (tester) async {
    await _openAccountEntry(tester, 'Kupovine i računi');
    expect(find.text('FK Sarajevo – FK Željezničar'), findsOneWidget);
    expect(find.text('EXIT Festival'), findsOneWidget);

    await tester.tap(find.text('Završene'));
    await tester.pumpAndSettle();
    expect(find.text('EXIT Festival'), findsNothing);
    await tester.tap(find.text('Hamlet'));
    await tester.pumpAndSettle();

    expect(find.text('Detalji narudžbe'), findsOneWidget);
    expect(find.text('Uživaj u događaju!'), findsOneWidget);
    await tapVisible(tester, find.text('Račun'));
    // 2 × 25,00 = 50,00; fee 5,00; total 55,00.
    expect(find.textContaining('50,00'), findsWidgets);
    expect(find.textContaining('55,00'), findsWidgets);
    expect(find.text('Visa •••• 4242'), findsOneWidget);
    expect(find.text('SSW-2PLM6R'), findsWidgets);
  });

  testWidgets('sale shows seller earnings and a dispute', (tester) async {
    await _openAccountEntry(tester, 'Prodaje');
    await tester.tap(find.text('Zdravko Čolić'));
    await tester.pumpAndSettle();
    expect(find.text('Detalji prodaje'), findsOneWidget);
    await tapVisible(tester, find.text('Tvoja zarada'));
    // 4 × 60,00 = 240,00 − 10 % = 216,00.
    expect(find.textContaining('216,00'), findsWidgets);

    await tester.tap(find.byKey(backButtonKey).last);
    await tester.pumpAndSettle();
    await tapVisible(tester, find.text('Hamlet'));
    expect(
      find.text('Kupac je prijavio problem. Isplata čeka rješenje.'),
      findsOneWidget,
    );
    expect(find.text('U rješavanju'), findsWidgets);
  });

  testWidgets('payouts sum upcoming and paid money', (tester) async {
    await _openAccountEntry(tester, 'Isplate');
    await tester.pumpAndSettle();
    // Upcoming: 103,50 + 216,00; paid: 81,00.
    expect(find.textContaining('319,50'), findsOneWidget);
    expect(find.textContaining('81,00'), findsWidgets);
    expect(find.text('IBAN •••• 8494'), findsOneWidget);

    await tapVisible(tester, find.text('Neuspjelo'));
    expect(find.text('Detalji isplate'), findsOneWidget);
    expect(find.text('IBAN account closed'), findsOneWidget);
  });

  testWidgets('payout method validates the IBAN', (tester) async {
    await _openAccountEntry(tester, 'Način isplate');
    final iban = find.byType(EditableText).last;
    await tester.enterText(iban, 'BA39 1290 0794 0102 8495');
    await tester.tap(find.text('Sačuvaj'));
    await tester.pumpAndSettle();
    expect(find.text('Neispravan IBAN'), findsOneWidget);

    await tester.enterText(iban, 'de89370400440532013000');
    await tester.pumpAndSettle();
    expect(find.text('DE89 3704 0044 0532 0130 00'), findsOneWidget);
    await tester.tap(find.text('Sačuvaj'));
    await tester.pumpAndSettle();
    final method = await tester.runAsync(
      () => market.watchPayoutMethod('1').first,
    );
    expect(method?.iban, 'DE89370400440532013000');
  });

  testWidgets('timeline marks done, current and failed steps', (tester) async {
    late List<TimelineStep> paid, refunded, completed;
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Builder(
          builder: (context) {
            Order order(OrderStatus s, List<OrderStatus> reached) =>
                Order.fromMap('o', {
                  'event': {'name': 'X'},
                  'status': s.name,
                  'history': [
                    for (final r in reached)
                      {'status': r.name, 'at': DateTime(2030)},
                  ],
                });
            paid = orderTimeline(
              context,
              order(OrderStatus.paid, [
                OrderStatus.pendingPayment,
                OrderStatus.paid,
              ]),
            );
            refunded = orderTimeline(
              context,
              order(OrderStatus.refunded, [
                OrderStatus.pendingPayment,
                OrderStatus.paid,
                OrderStatus.refunded,
              ]),
            );
            completed = orderTimeline(
              context,
              order(OrderStatus.completed, orderHappyPath),
            );
            return const SizedBox();
          },
        ),
      ),
    );
    await tester.pump();
    expect(
      [for (final s in paid) s.state],
      [
        TimelineState.done,
        TimelineState.current,
        TimelineState.upcoming,
        TimelineState.upcoming,
      ],
    );
    expect(
      [for (final s in refunded) s.state],
      [TimelineState.done, TimelineState.done, TimelineState.failed],
    );
    expect(completed.every((s) => s.state == TimelineState.done), isTrue);
  });
}
