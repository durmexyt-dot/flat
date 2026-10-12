import 'package:flat/src/admin/admin_repository.dart';
import 'package:flat/src/data/events_repository.dart';
import 'package:flat/src/data/memory_repositories.dart';
import 'package:flat/src/data/models.dart';
import 'package:flat/src/data/platform_repository.dart';
import 'package:flat/src/home/home_page.dart';
import 'package:flat/src/invoices/invoice_pages.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';

import 'helpers.dart';

final _event = Event(
  id: 'e-dubioza',
  info: EventInfo(
    name: 'Dubioza kolektiv',
    venue: 'Zetra',
    city: 'Sarajevo',
    date: DateTime(2030, 7, 14, 20),
    category: EventCategory.concerts,
  ),
);

const _payout = PayoutMethod(
  accountHolder: 'Amra Test',
  iban: 'BA391290079401028494',
);

Future<void> _enter(WidgetTester tester, IconData icon, String text) async {
  await tester.ensureVisible(find.byIcon(icon));
  final field = find.descendant(
    of: find.ancestor(
      of: find.byIcon(icon),
      matching: find.byType(FTextFormField),
    ),
    matching: find.byType(EditableText),
  );
  await tester.enterText(field, text);
  await tester.pumpAndSettle();
}

/// Lets toasts time out (they cover buttons, and leave no timers).
Future<void> _finishToasts(WidgetTester tester) async {
  await tester.pump(const Duration(seconds: 5));
  await tester.pumpAndSettle();
}

Future<void> _go(WidgetTester tester, String path) async {
  GoRouter.of(tester.element(find.byType(HomePage).first)).push(path);
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('resale rules: the highest price is shown and enforced', (
    tester,
  ) async {
    final auth = await pumpApp(
      tester,
      eventRepository: InMemoryEventRepository(events: [_event]),
      marketRepository: InMemoryMarketRepository(payoutMethod: _payout),
      platformRepository: InMemoryPlatformRepository(
        resale: const ResaleConfig(maxMarkupPercent: 20),
      ),
    );
    await auth.signIn(email: 'a@b.ba', password: 'x', keepSignedIn: true);
    auth.verifyEmail();
    await tester.pumpAndSettle();
    await _go(tester, '/sell?event=${_event.id}');

    await _enter(tester, FLucideIcons.receiptText, '30');
    expect(find.textContaining('36,00'), findsWidgets);
    await _enter(tester, FLucideIcons.tag, '40');
    await tapVisible(tester, find.text('Objavi ponudu'));
    expect(find.textContaining('Najviša dozvoljena cijena'), findsOneWidget);
    expect(await market.watchMyListings('1').first, isEmpty);

    await _enter(tester, FLucideIcons.tag, '36');
    await tapVisible(tester, find.text('Objavi ponudu'));
    expect(find.text('Detalji ponude'), findsOneWidget);
    expect((await market.watchMyListings('1').first).single.priceMinor, 3600);
  });

  testWidgets('new sellers see their limits; at the limit they cannot list', (
    tester,
  ) async {
    final platform = InMemoryPlatformRepository(
      limits: const SellerLimits(
        newSellerMaxListings: 2,
        newSellerMaxTickets: 3,
      ),
    )..stats['1'] = const SellerStats(activeListings: 2);
    final auth = await pumpApp(
      tester,
      eventRepository: InMemoryEventRepository(events: [_event]),
      marketRepository: InMemoryMarketRepository(payoutMethod: _payout),
      platformRepository: platform,
    );
    await auth.signIn(email: 'a@b.ba', password: 'x', keepSignedIn: true);
    auth.verifyEmail();
    await tester.pumpAndSettle();
    await _go(tester, '/sell?event=${_event.id}');
    expect(find.text('Dostignut limit za nove prodavce'), findsOneWidget);
    expect(find.textContaining('do 2 aktivnih ponuda'), findsOneWidget);
  });

  testWidgets('blocked users are told and cannot list', (tester) async {
    final platform = InMemoryPlatformRepository()
      ..bans['1'] = const UserBan(reason: 'Fake');
    final auth = await pumpApp(
      tester,
      eventRepository: InMemoryEventRepository(events: [_event]),
      marketRepository: InMemoryMarketRepository(payoutMethod: _payout),
      platformRepository: platform,
    );
    await auth.signIn(email: 'a@b.ba', password: 'x', keepSignedIn: true);
    auth.verifyEmail();
    await tester.pumpAndSettle();
    await _go(tester, '/sell?event=${_event.id}');
    expect(find.text('Tvoj račun je blokiran'), findsOneWidget);
  });

  testWidgets('the team blocks a user from the moderation page', (
    tester,
  ) async {
    final auth = await pumpApp(
      tester,
      adminRepository: InMemoryAdminRepository(
        roles: {'1': StaffRole.support},
        users: const [
          UserLookup(
            uid: 'u9',
            name: 'Varalica',
            email: 'fake@test.ba',
            username: 'fake',
          ),
        ],
      ),
    );
    await auth.signIn(email: 'a@b.ba', password: 'x', keepSignedIn: true);
    await tester.pumpAndSettle();
    await _go(tester, '/admin/moderation');
    expect(find.text('Nema otvorenih prijava'), findsOneWidget);
    await tester.tap(find.text('Korisnici'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(EditableText).first, 'fake@test.ba');
    await tester.tap(find.text('Traži'));
    await tester.pumpAndSettle();
    expect(find.text('Korisnik'), findsWidgets);
    await tapVisible(tester, find.text('Blokiraj'));
    await tester.tap(find.text('Blokiraj').last);
    await tester.pumpAndSettle();
    expect(serverActions.calls, contains('setUserBan u9 true'));
  });

  testWidgets('buyers report a listing once', (tester) async {
    final auth = await pumpApp(
      tester,
      eventRepository: InMemoryEventRepository(events: [_event]),
      marketRepository: InMemoryMarketRepository(
        listings: [
          Listing.fromMap('L1', {
            'sellerId': 'other',
            'eventId': _event.id,
            'event': _event.info.toMap(),
            'quantity': 2,
            'quantitySold': 0,
            'priceMinor': 4500,
            'currency': 'BAM',
            'status': 'active',
          }),
        ],
      ),
    );
    await auth.signIn(email: 'a@b.ba', password: 'x', keepSignedIn: true);
    await tester.pumpAndSettle();
    await _go(tester, '/listing/L1');
    await tapVisible(tester, find.text('Prijavi ponudu'));
    await tester.tap(find.text('Previsoka cijena'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Pošalji prijavu'));
    await tester.pumpAndSettle();
    expect(platform.reports['L1_1']?.reason, ReportReason.price);
    await _finishToasts(tester);
    await tapVisible(tester, find.text('Prijavi ponudu'));
    expect(find.text('Već si prijavio ovu ponudu.'), findsOneWidget);
    await _finishToasts(tester);
  });

  testWidgets('users see their invoices; admins export a month as CSV', (
    tester,
  ) async {
    final now = DateTime.now();
    final invoice = PlatformInvoice(
      id: 'o1-buyer',
      number: 'SSW-${now.year}-00001',
      type: InvoiceType.invoice,
      orderId: 'o1',
      orderNumber: 'SSW-AAAAAA',
      recipientUid: '1',
      recipientRole: 'buyer',
      recipientName: 'Amra Test',
      recipientEmail: 'a@b.ba',
      feePercent: 10,
      baseMinor: 10000,
      eventName: 'Dubioza kolektiv',
      netMinor: 855,
      vatMinor: 145,
      grossMinor: 1000,
      vatPercent: 17,
      currency: 'BAM',
      company: const CompanyInfo(name: 'Stubswap d.o.o.'),
      issuedAt: now,
    );
    final auth = await pumpApp(
      tester,
      platformRepository: InMemoryPlatformRepository()..invoices.add(invoice),
    );
    await auth.signIn(email: 'a@b.ba', password: 'x', keepSignedIn: true);
    await tester.pumpAndSettle();
    await _go(tester, '/account/invoices');
    expect(find.text('Račun ${invoice.number}'), findsOneWidget);
    await tester.tap(find.text('Račun ${invoice.number}'));
    await tester.pumpAndSettle();
    expect(find.text('Stubswap d.o.o.'), findsOneWidget);
    expect(find.text('Servisna naknada za kupovinu karata'), findsOneWidget);
    expect(find.text('PDV 17 %'), findsOneWidget);

    final csv = invoicesCsv([invoice]);
    expect(csv, startsWith('﻿number;type;date'));
    expect(csv, contains('${invoice.number};invoice;'));
    expect(csv, contains(';8,55;1,45;10,00;17;BAM;'));
  });

  testWidgets('admins set the resale rule; the app language goes to the '
      'profile for emails', (tester) async {
    final auth = await pumpApp(
      tester,
      adminRepository: InMemoryAdminRepository(roles: {'1': StaffRole.admin}),
    );
    await auth.signIn(email: 'a@b.ba', password: 'x', keepSignedIn: true);
    await tester.pumpAndSettle();
    expect(profiles.languages['1'], 'bs');
    await _go(tester, '/admin/resale');
    await tester.tap(find.text('Ograniči cijenu'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(EditableText).first, '15');
    await tester.pumpAndSettle();
    expect(find.textContaining('57,50'), findsOneWidget);
    await tapVisible(tester, find.text('Sačuvaj'));
    expect(platform.resale.maxMarkupPercent, 15);
    expect(platform.resale.needsFaceValue(null), isTrue);
    await _finishToasts(tester);
  });
}
