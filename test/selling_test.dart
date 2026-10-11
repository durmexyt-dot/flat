import 'package:flat/src/data/memory_repositories.dart';
import 'package:flat/src/data/models.dart';
import 'package:flat/src/ui/hero_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';

import 'helpers.dart';

Listing listingOf(
  String id, {
  String seller = 'other',
  String name = 'Dubioza kolektiv',
  EventCategory category = EventCategory.concerts,
  ListingStatus status = ListingStatus.active,
}) => Listing.fromMap(id, {
  'sellerId': seller,
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
  testWidgets('home lists active listings, filters by search and category', (
    tester,
  ) async {
    final auth = await pumpApp(
      tester,
      marketRepository: InMemoryMarketRepository(
        listings: [
          listingOf('a'),
          listingOf(
            'b',
            name: 'FK Sarajevo – FK Željezničar',
            category: EventCategory.sports,
          ),
          listingOf(
            'c',
            name: 'Withdrawn show',
            status: ListingStatus.withdrawn,
          ),
        ],
      ),
    );
    await auth.signIn(email: 'a@b.ba', password: 'x', keepSignedIn: true);
    await tester.pumpAndSettle();

    expect(find.text('Dubioza kolektiv'), findsOneWidget);
    expect(find.text('FK Sarajevo – FK Željezničar'), findsOneWidget);
    expect(find.text('Withdrawn show'), findsNothing);
    expect(find.text('3 od 4 dostupno'), findsNWidgets(2));

    await tester.tap(find.text('Sport'));
    await tester.pumpAndSettle();
    expect(find.text('Dubioza kolektiv'), findsNothing);
    await tester.tap(find.text('Sport'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(EditableText), 'dubioza');
    await tester.pumpAndSettle();
    expect(find.text('Dubioza kolektiv'), findsOneWidget);
    expect(find.text('FK Sarajevo – FK Željezničar'), findsNothing);

    await tester.enterText(find.byType(EditableText), 'opera');
    await tester.pumpAndSettle();
    expect(find.text('Nema rezultata za „opera”'), findsOneWidget);
  });

  testWidgets('listing ticket flies into the detail page', (tester) async {
    final auth = await pumpApp(
      tester,
      marketRepository: InMemoryMarketRepository(listings: [listingOf('a')]),
    );
    await auth.signIn(email: 'a@b.ba', password: 'x', keepSignedIn: true);
    await tester.pumpAndSettle();

    // The newest copy: the home card, then the flying one, then the detail.
    double titleTop() => tester
        .getTopLeft(find.text('Dubioza kolektiv', skipOffstage: false).last)
        .dy;
    final before = titleTop();
    await tester.tap(find.text('Dubioza kolektiv'));
    await tester.pump();
    await tester.pump(heroTransitionDuration ~/ 2);
    final during = titleTop();
    await tester.pumpAndSettle();
    final after = titleTop();
    expect(
      during,
      inExclusiveRange(after, before),
      reason: 'before $before during $during after $after',
    );

    // A buyer sees the total with the 10 % service fee.
    expect(find.text('Detalji ponude'), findsOneWidget);
    await tapVisible(tester, find.byIcon(FLucideIcons.plus).last);
    // 2 × 45,00 = 90,00 + 9,00 fee = 99,00
    expect(find.textContaining('99,00'), findsOneWidget);
  });

  testWidgets('seller publishes a listing, changes price and withdraws', (
    tester,
  ) async {
    final auth = await pumpApp(tester);
    await auth.signIn(email: 'a@b.ba', password: 'x', keepSignedIn: true);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Prodaj karte'));
    await tester.pumpAndSettle();
    // Without a payout method the form is locked.
    expect(find.text('Prvo dodaj način isplate'), findsOneWidget);
    expect(find.text('Naziv događaja'), findsNothing);
    await tester.tap(find.text('Dodaj način isplate'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(EditableText).first, 'Amra Test');
    await tester.enterText(
      find.byType(EditableText).last,
      'BA391290079401028494',
    );
    await tester.tap(find.text('Sačuvaj'));
    await tester.pumpAndSettle();
    expect(find.text('Naziv događaja'), findsOneWidget);
    // Let the "saved" snack bar go; it covers the bottom of the form.
    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();

    // Missing fields are reported.
    await tapVisible(tester, find.text('Objavi ponudu'));
    await tester.drag(find.byType(Scrollable).first, const Offset(0, 3000));
    await tester.pumpAndSettle();
    expect(find.text('Obavezno polje'), findsWidgets);
    expect(market.watchMyListings('1').first, completion(isEmpty));

    final fields = find.byType(EditableText);
    await tester.enterText(fields.at(0), 'Sarajevo Film Festival');
    await tester.enterText(fields.at(1), 'Narodno pozorište');
    await tester.enterText(fields.at(2), 'Sarajevo');
    // Date: pick the preselected day and time.
    await tapVisible(tester, find.byIcon(FLucideIcons.calendar));
    await tester.tap(find.text('Uredu').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Uredu').last);
    await tester.pumpAndSettle();
    await tapVisible(tester, find.byIcon(FLucideIcons.plus));

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

  testWidgets('guests cannot open the sell form', (tester) async {
    await pumpApp(tester);
    await tester.tap(find.text('Pretraži događaje kao gost'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Prodaj karte'));
    await tester.pumpAndSettle();
    expect(find.text('Objavi ponudu'), findsNothing);
    expect(
      find.text('Prijavite se da biste kupovali i prodavali karte'),
      findsWidgets,
    );
  });
}
