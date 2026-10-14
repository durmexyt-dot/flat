import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart' show Timestamp;
import 'package:flat/src/account/data_export.dart';
import 'package:flat/src/data/memory_repositories.dart';
import 'package:flat/src/data/models.dart';
import 'package:flat/src/home/home_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';

import 'helpers.dart';

Order _order(String buyer, String seller, {String status = 'paid'}) =>
    Order.fromMap('o1', {
      'number': 'SSW-MOB001',
      'listingId': 'L1',
      'buyerId': buyer,
      'sellerId': seller,
      'event': {
        'name': 'Dubioza kolektiv',
        'venue': 'Zetra',
        'city': 'Sarajevo',
        'date': DateTime(2030, 7, 14, 20),
        'category': 'concerts',
      },
      'quantity': 2,
      'unitPriceMinor': 4500,
      'currency': 'BAM',
      'ticketType': 'mobile',
      'status': status,
      'testMode': true,
      'history': [
        {'status': 'paid', 'at': DateTime(2030)},
      ],
      'createdAt': DateTime(2029),
    });

Future<void> _go(WidgetTester tester, String path) async {
  GoRouter.of(tester.element(find.byType(HomePage).first)).push(path);
  await tester.pumpAndSettle();
}

Future<void> _finishToasts(WidgetTester tester) async {
  await tester.pump(const Duration(seconds: 5));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('the seller enters the handover of mobile tickets; the buyer '
      'confirms receipt', (tester) async {
    final market = InMemoryMarketRepository(orders: [_order('other', '1')]);
    final auth = await pumpApp(tester, marketRepository: market);
    await auth.signIn(email: 'a@b.ba', password: 'x', keepSignedIn: true);
    await tester.pumpAndSettle();
    await _go(tester, '/order/o1');

    await tapVisible(tester, find.text('Unesi predaju karata'));
    expect(find.text('Kako si predao karte?'), findsOneWidget);
    // Without the recipient: refused.
    await tester.tap(find.text('Karte predane'));
    await tester.pumpAndSettle();
    expect(find.text('Upiši kome si prenio karte'), findsOneWidget);
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
    await tester.pumpAndSettle();
    await tester.tap(find.text('Karte predane'));
    await tester.pumpAndSettle();
    final sent = (await market.watchSales('1').first).single;
    expect(sent.status, OrderStatus.ticketsSent);
    expect(sent.handover?.method, HandoverMethod.appTransfer);
    expect(sent.handover?.recipient, 'kupac@test.ba');
    expect(find.text('Predaja karata'), findsOneWidget);
    expect(find.text('Kupac još nije potvrdio prijem.'), findsOneWidget);
    await _finishToasts(tester);
  });

  testWidgets('the buyer sees the handover and confirms receipt', (
    tester,
  ) async {
    final market = InMemoryMarketRepository(orders: [_order('1', 'other')]);
    await market.markTicketsSent(
      _order('1', 'other'),
      const TicketHandover(
        method: HandoverMethod.appTransfer,
        recipient: 'amra@test.ba',
        note: 'Eventim',
      ),
    );
    final auth = await pumpApp(tester, marketRepository: market);
    await auth.signIn(email: 'a@b.ba', password: 'x', keepSignedIn: true);
    await tester.pumpAndSettle();
    await _go(tester, '/order/o1');
    expect(find.text('amra@test.ba'), findsOneWidget);
    expect(find.text('Eventim'), findsOneWidget);
    await tapVisible(tester, find.text('Potvrdi prijem'));
    final order = (await market.watchPurchases('1').first).single;
    expect(order.handover?.confirmed, isTrue);
    await tester.scrollUntilVisible(
      find.textContaining('Kupac je potvrdio prijem'),
      -200,
      scrollable: mainScrollable,
    );
    expect(find.textContaining('Kupac je potvrdio prijem'), findsOneWidget);
    await _finishToasts(tester);
  });

  test('the data export is readable JSON without pictures', () {
    final data =
        jsonValue({
              'profile': {
                'displayName': 'Amra',
                'photo': 'A' * 500,
                'createdAt': Timestamp.fromDate(DateTime.utc(2026, 10, 1)),
              },
              'supportRequests': [
                {
                  'messages': [
                    {
                      'text': 'Pomoć',
                      'images': ['x' * 300, 'y' * 300],
                    },
                  ],
                },
              ],
            })!
            as Map<String, dynamic>;
    final json = exportJson(
      data: data,
      account: {'uid': '1', 'email': 'a@b.ba'},
      now: DateTime.utc(2026, 10, 14),
    );
    final back = jsonDecode(json) as Map<String, dynamic>;
    expect(back['account']['email'], 'a@b.ba');
    expect(back['exportedAt'], '2026-10-14T00:00:00.000Z');
    expect(back['profile']['photo'], '[picture]');
    expect(back['profile']['createdAt'], '2026-10-01T00:00:00.000Z');
    expect(back['supportRequests'][0]['messages'][0]['images'], [
      '2 picture(s)',
    ]);
  });
}
