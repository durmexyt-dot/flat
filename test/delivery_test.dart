import 'dart:typed_data';

import 'package:flat/src/data/memory_repositories.dart';
import 'package:flat/src/data/models.dart';
import 'package:flat/src/data/tickets_repository.dart';
import 'package:flat/src/market/ticket_files_widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/widgets.dart';

import 'helpers.dart';

final _event = {
  'name': 'Sarajevo Jazz Festival',
  'venue': 'Dom mladih',
  'city': 'Sarajevo',
  'date': DateTime(2030, 11, 2, 20),
  'category': 'festivals',
};

Listing _listing({String seller = '1', int quantity = 2, int sold = 0}) =>
    Listing.fromMap('jazz', {
      'sellerId': seller,
      'event': _event,
      'ticketType': 'eTicket',
      'quantity': quantity,
      'quantitySold': sold,
      'priceMinor': 3500,
      'currency': 'BAM',
      'status': 'active',
    });

Order _order({
  required String buyer,
  required String seller,
  String status = 'paid',
  int quantity = 1,
  int delivered = 0,
}) => Order.fromMap('order-7', {
  'number': 'SSW-ABC123',
  'listingId': 'jazz',
  'buyerId': buyer,
  'sellerId': seller,
  'event': _event,
  'quantity': quantity,
  'unitPriceMinor': 3500,
  'currency': 'BAM',
  'ticketType': 'eTicket',
  'status': status,
  'ticketsDelivered': delivered,
  'history': [
    {'status': status, 'at': DateTime(2026, 10, 1)},
  ],
  'createdAt': DateTime(2026, 10, 1),
});

Future<void> _signIn(
  WidgetTester tester,
  Future<FakeAuthRepository> app,
) async {
  final auth = await app;
  await auth.signIn(email: 'amra@test.ba', password: 'x', keepSignedIn: true);
  await tester.pumpAndSettle();
}

Future<void> _openAccountEntry(WidgetTester tester, String entry) async {
  await tester.tap(byLabel('Postavke'));
  await tester.pumpAndSettle();
  await tapVisible(tester, find.text(entry));
}

Future<void> goTo(WidgetTester tester, String location) async {
  GoRouter.of(tester.element(find.byType(Navigator).first)).push(location);
  await tester.pumpAndSettle();
}

void main() {
  final realPicker = pickTicketFile;
  final realOpen = openTicketUrl;
  tearDown(() {
    pickTicketFile = realPicker;
    openTicketUrl = realOpen;
  });

  testWidgets('seller uploads tickets for a listing', (tester) async {
    await _signIn(
      tester,
      pumpApp(
        tester,
        marketRepository: InMemoryMarketRepository(listings: [_listing()]),
      ),
    );
    await _openAccountEntry(tester, 'Moje ponude');
    // The listing has no files yet.
    expect(find.text('Karte nisu uploadovane'), findsOneWidget);
    await tester.tap(byLabel('Uploaduj karte'));
    await tester.pumpAndSettle();
    expect(find.text('Karte za ponudu'), findsOneWidget);
    expect(find.text('0 od 2 karata uploadovano'), findsOneWidget);

    // Not a ticket file.
    pickTicketFile = () async =>
        (name: 'notes.txt', bytes: Uint8List(10), contentType: 'text/plain');
    await tapVisible(tester, find.text('Dodaj karte'));
    expect(
      find.text(
        'Ova vrsta fajla nije podržana. Koristi PDF, PNG, JPG ili WebP.',
      ),
      findsOneWidget,
    );
    expect(ticketFiles.listingFiles['jazz'], isNull);

    // One PDF with both tickets.
    pickTicketFile = () async => (
      name: 'karte.pdf',
      bytes: Uint8List(2048),
      contentType: 'application/pdf',
    );
    await tapVisible(tester, find.text('Dodaj karte'));
    expect(find.text('Koliko karata je u fajlu?'), findsOneWidget);
    await tester.tap(byLabel('+').first);
    await tester.pumpAndSettle();
    expect(find.text('2 karte'), findsOneWidget);
    await tester.tap(find.widgetWithText(FButton, 'Uploaduj'));
    await tester.pumpAndSettle();

    final file = ticketFiles.listingFiles['jazz']!.single;
    expect(file.tickets, 2);
    expect(file.contentType, 'application/pdf');
    expect(find.text('karte.pdf'), findsOneWidget);
    expect(find.text('Čeka kupca'), findsOneWidget);
    expect(find.text('2 od 2 karata uploadovano'), findsOneWidget);
    // All uploaded: no more adding.
    expect(find.text('Dodaj karte'), findsNothing);

    // A file not handed out yet can go again.
    await tester.tap(byLabel('Obriši').first);
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FButton, 'Obriši').last);
    await tester.pumpAndSettle();
    expect(ticketFiles.listingFiles['jazz'], isEmpty);
  });

  testWidgets('only the seller can upload', (tester) async {
    await _signIn(
      tester,
      pumpApp(
        tester,
        marketRepository: InMemoryMarketRepository(
          listings: [_listing(seller: 'someone')],
        ),
      ),
    );
    await goTo(tester, '/listing/jazz/tickets');
    expect(find.text('Nemaš pristup'), findsOneWidget);
    expect(find.text('Dodaj karte'), findsNothing);
  });

  testWidgets('buyer downloads the delivered tickets', (tester) async {
    final files = InMemoryTicketFileRepository();
    await files.upload(
      listing: _listing(seller: 'seller'),
      bytes: Uint8List(4096),
      name: 'ulaznica.pdf',
      contentType: 'application/pdf',
    );
    files.deliver('jazz', 'order-7', 1);
    final opened = <String>[];
    openTicketUrl = (url) async {
      opened.add(url);
      return true;
    };

    await _signIn(
      tester,
      pumpApp(
        tester,
        marketRepository: InMemoryMarketRepository(
          listings: [_listing(seller: 'seller', sold: 1)],
          orders: [
            _order(
              buyer: '1',
              seller: 'seller',
              status: 'ticketsSent',
              delivered: 1,
            ),
          ],
        ),
        ticketFileRepository: files,
      ),
    );
    await _openAccountEntry(tester, 'Kupovine i računi');
    await tester.tap(find.text('Sarajevo Jazz Festival'));
    await tester.pumpAndSettle();
    expect(find.text('Tvoje karte'), findsOneWidget);
    expect(find.text('ulaznica.pdf'), findsOneWidget);
    expect(find.textContaining('Prodavac još nije poslao'), findsNothing);

    await tapVisible(tester, find.text('Preuzmi'));
    expect(opened, ['https://example.test/deliveries/order-7/file-1']);
  });

  testWidgets('buyer waits for tickets with a deadline', (tester) async {
    await _signIn(
      tester,
      pumpApp(
        tester,
        marketRepository: InMemoryMarketRepository(
          listings: [_listing(seller: 'seller', sold: 1)],
          orders: [_order(buyer: '1', seller: 'seller')],
        ),
      ),
    );
    await _openAccountEntry(tester, 'Kupovine i računi');
    await tester.tap(find.text('Sarajevo Jazz Festival'));
    await tester.pumpAndSettle();
    expect(
      find.textContaining('Prodavac još nije poslao karte. Rok:'),
      findsOneWidget,
    );
  });

  testWidgets('seller is warned about sold tickets without files', (
    tester,
  ) async {
    await _signIn(
      tester,
      pumpApp(
        tester,
        marketRepository: InMemoryMarketRepository(
          listings: [_listing(sold: 1)],
          orders: [_order(buyer: 'buyer', seller: '1')],
        ),
      ),
    );
    await tester.tap(byLabel('Postavke'));
    await tester.pumpAndSettle();
    expect(
      find.text('Imaš 1 prodanu kartu koja još nije uploadovana'),
      findsOneWidget,
    );

    await tapVisible(tester, find.text('Prodaje'));
    expect(
      find.text('Imaš 1 prodanu kartu koja još nije uploadovana'),
      findsOneWidget,
    );
    await tapVisible(tester, find.text('Sarajevo Jazz Festival'));
    expect(find.text('Karte još nisu uploadovane'), findsOneWidget);
    // E-tickets aren't marked as sent by hand.
    expect(find.text('Označi karte kao poslane'), findsNothing);

    // The alert leads to the upload page.
    await tapVisible(tester, find.text('Uploaduj karte'));
    expect(find.text('Karte za ponudu'), findsOneWidget);
  });
}
