import 'dart:convert';

import 'package:flat/src/account/photo_picker.dart';
import 'package:flat/src/data/models.dart';
import 'package:flat/src/data/memory_repositories.dart';
import 'package:flat/src/ui/hero_page.dart';
import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;

import 'helpers.dart';

Listing _listing(String seller, int quantity, ListingStatus status) =>
    Listing.fromMap('l-$seller-$quantity-${status.name}', {
      'sellerId': seller,
      'event': {
        'name': 'Koncert',
        'venue': 'Zetra',
        'city': 'Sarajevo',
        'date': DateTime(2030),
        'category': 'concerts',
      },
      'quantity': quantity,
      'priceMinor': 5000,
      'status': status.name,
    });

Order _order(String buyer, String seller, int quantity, OrderStatus status) =>
    Order.fromMap('o-$buyer-$quantity', {
      'buyerId': buyer,
      'sellerId': seller,
      'event': {'name': 'Koncert', 'date': DateTime(2030)},
      'quantity': quantity,
      'unitPriceMinor': 5000,
      'status': status.name,
    });

Future<void> _openAccount(WidgetTester tester) async {
  await tester.tap(find.byTooltip('Postavke'));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('account shows profile and animated ticket counts', (
    tester,
  ) async {
    final auth = await pumpApp(
      tester,
      marketRepository: InMemoryMarketRepository(
        listings: [
          _listing('1', 3, ListingStatus.active),
          _listing('1', 2, ListingStatus.withdrawn),
        ],
        orders: [
          _order('x', '1', 2, OrderStatus.paid),
          _order('1', 'y', 4, OrderStatus.completed),
          _order('1', 'z', 1, OrderStatus.cancelled),
        ],
      ),
    );
    await auth.signIn(email: 'amra@test.ba', password: 'x', keepSignedIn: true);
    await tester.pumpAndSettle();
    await _openAccount(tester);

    expect(find.text('Amra Test'), findsOneWidget);
    expect(find.text('Javni profil'), findsOneWidget);
    // Listed 3 (withdrawn excluded), sold 2, bought 4 (cancelled excluded).
    expect(find.text('3'), findsOneWidget);
    expect(find.text('2'), findsOneWidget);
    expect(find.text('4'), findsOneWidget);
  });

  testWidgets('avatar flies from the home app bar to the account page', (
    tester,
  ) async {
    final auth = await pumpApp(tester);
    await auth.signIn(email: 'amra@test.ba', password: 'x', keepSignedIn: true);
    await tester.pumpAndSettle();

    Iterable<double> sizes() => find
        .text('AT', skipOffstage: false)
        .evaluate()
        .map((e) => (e.renderObject as RenderBox?)?.size.height)
        .whereType<double>();
    final before = sizes().toList();

    await tester.tap(find.byTooltip('Postavke'));
    await tester.pump();
    await tester.pump(heroTransitionDuration ~/ 2);
    final during = sizes().toList();
    await tester.pumpAndSettle();
    final after = sizes().toList();

    // Initials scale with the avatar: 34 px in the app bar, 96 px on the
    // account page, somewhere in between while flying.
    final low = before.reduce((a, b) => a < b ? a : b);
    final high = after.reduce((a, b) => a > b ? a : b);
    expect(
      during.any((h) => h > low + 1 && h < high - 1),
      isTrue,
      reason: 'before $before during $during after $after',
    );
  });

  testWidgets('edit profile saves name and rejects a taken username', (
    tester,
  ) async {
    final auth = await pumpApp(tester);
    await auth.signIn(email: 'amra@test.ba', password: 'x', keepSignedIn: true);
    await tester.pumpAndSettle();
    profiles.reserveUsername('taken', 'someone-else');
    await _openAccount(tester);
    await tester.tap(find.text('Uredi profil'));
    await tester.pumpAndSettle();

    final fields = find.byType(EditableText);
    await tester.enterText(fields.at(0), 'Amra Begić');
    await tester.enterText(fields.at(1), 'taken');
    await tester.tap(find.widgetWithText(FButton, 'Sačuvaj'));
    await tester.pumpAndSettle();
    expect(find.text('Korisničko ime je zauzeto'), findsOneWidget);

    await tester.enterText(fields.at(1), 'Not valid!');
    await tester.tap(find.widgetWithText(FButton, 'Sačuvaj'));
    await tester.pumpAndSettle();
    expect(find.text('Neispravno korisničko ime'), findsOneWidget);

    await tester.enterText(fields.at(1), 'amra.b');
    await tester.tap(find.widgetWithText(FButton, 'Sačuvaj'));
    await tester.pumpAndSettle();
    expect(find.text('Amra Begić'), findsOneWidget);
    expect(find.text('@amra.b'), findsOneWidget);
  });

  test('profile photos are cropped square and scaled to 256 px', () {
    final wide = img.Image(width: 800, height: 400);
    final encoded = encodeProfilePhoto(img.encodePng(wide));
    final decoded = img.decodeJpg(base64Decode(encoded))!;
    expect(decoded.width, 256);
    expect(decoded.height, 256);
  });
}
