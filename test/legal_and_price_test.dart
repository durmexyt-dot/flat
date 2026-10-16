import 'package:flat/src/auth/login_page.dart';
import 'package:flat/src/data/events_repository.dart';
import 'package:flat/src/data/memory_repositories.dart';
import 'package:flat/src/data/models.dart';
import 'package:flat/src/home/home_page.dart';
import 'package:flat/src/info/info_page.dart';
import 'package:flat/src/info/legal_texts.dart';
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
  status: EventStatus.confirmed,
);

/// 45,00 per ticket from another seller, face value 30,00, 10 % fees.
Listing _listing({String seller = 'other'}) => Listing.fromMap('a', {
  'sellerId': seller,
  'eventId': _event.id,
  'event': _event.info.toMap(),
  'quantity': 4,
  'quantitySold': 1,
  'priceMinor': 4500,
  'faceValueMinor': 3000,
  'currency': 'BAM',
  'status': ListingStatus.active.name,
  'createdAt': DateTime(2029),
});

Finder _fieldWithIcon(IconData icon) => find.descendant(
  of: find.ancestor(
    of: find.byIcon(icon),
    matching: find.byType(FTextFormField),
  ),
  matching: find.byType(EditableText),
);

Future<void> _enter(WidgetTester tester, IconData icon, String text) async {
  await tester.ensureVisible(find.byIcon(icon));
  await tester.enterText(_fieldWithIcon(icon), text);
  await tester.pumpAndSettle();
}

/// Taps the box of the (only) checkbox, not the links in its label.
Future<void> _tapCheckbox(WidgetTester tester) async {
  final box = find.byType(FCheckbox);
  await tester.ensureVisible(box);
  await tester.pumpAndSettle();
  await tester.tapAt(tester.getTopLeft(box) + const Offset(8, 8));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('legal pages show their texts with the placeholders', (
    tester,
  ) async {
    await pumpApp(tester);
    await openLogin(tester);
    final router = GoRouter.of(tester.element(find.byType(LoginPage)));
    for (final (topic, title) in [
      ('imprint', 'Impresum'),
      ('terms', 'Uslovi korištenja'),
      ('privacy', 'Politika privatnosti'),
      ('cookies', 'Kolačići'),
    ]) {
      expect(infoTopics, contains(topic));
      router.push('/info/$topic');
      await tester.pumpAndSettle();
      expect(find.text(title), findsWidgets, reason: topic);
      // The operator fills these in later: they stay visible until then.
      expect(find.textContaining('[DATUM]'), findsWidgets, reason: topic);
      expect(find.textContaining(termsVersion), findsOneWidget);
      if (topic != 'cookies') {
        expect(
          find.textContaining('[BETREIBER / FIRMA]'),
          findsWidgets,
          reason: topic,
        );
      }
      router.pop();
      await tester.pumpAndSettle();
    }

    // Every language has the texts.
    expect(legalDoc('terms', const Locale('de')), isNotNull);
    expect(legalDoc('terms', const Locale('en')), isNotNull);
    expect(legalDoc('nope', const Locale('bs')), isNull);
  });

  testWidgets('the login page links the terms (Google creates accounts)', (
    tester,
  ) async {
    await pumpApp(tester);
    await openLogin(tester);
    expect(
      find.textContaining('Nastavkom prihvataš', findRichText: true),
      findsOneWidget,
    );
    await tapVisible(tester, find.text('uslove korištenja'));
    expect(find.textContaining('[BETREIBER / FIRMA]'), findsWidgets);
  });

  testWidgets('sign up needs the terms and records their acceptance', (
    tester,
  ) async {
    final auth = await pumpApp(tester);
    await openLogin(tester);
    await tester.tap(find.text('Registruj se'));
    await tester.pumpAndSettle();

    final fields = find.byType(EditableText);
    await tester.enterText(fields.at(0), 'Emir Hodžić');
    await tester.enterText(fields.at(1), 'emir@test.ba');
    await tester.enterText(fields.at(2), 'secret123');
    await tester.enterText(fields.at(3), 'secret123');
    await tapVisible(tester, find.widgetWithText(FButton, 'Kreiraj račun'));
    expect(
      find.text(
        'Za registraciju prihvati uslove korištenja i politiku privatnosti.',
      ),
      findsOneWidget,
    );
    expect(auth.currentUser, isNull);

    await _tapCheckbox(tester);
    await tapVisible(tester, find.widgetWithText(FButton, 'Kreiraj račun'));
    expect(auth.currentUser?.uid, '3');
    expect(find.text('Zdravo, Emir'), findsOneWidget);
    expect(profiles.acceptedTerms, {'3': termsVersion});
  });

  testWidgets('buyers see final prices including the service fee', (
    tester,
  ) async {
    final auth = await pumpApp(
      tester,
      eventRepository: InMemoryEventRepository(events: [_event]),
      marketRepository: InMemoryMarketRepository(listings: [_listing()]),
    );
    await auth.signIn(email: 'a@b.ba', password: 'x', keepSignedIn: true);
    await tester.pumpAndSettle();

    // 45,00 + 10 % = 49,50, on the event cards too.
    expect(find.textContaining('od 49,50'), findsWidgets);
    expect(find.textContaining('od 45,00'), findsNothing);

    await tester.tap(find.text('Dubioza kolektiv').first);
    await tester.pumpAndSettle();
    await openTickets(tester);
    final price = find.textContaining('49,50');
    await tester.scrollUntilVisible(price, 200, scrollable: mainScrollable);
    expect(price, findsOneWidget);
    expect(
      find.text('po karti · uključena naknada za uslugu 10%'),
      findsOneWidget,
    );

    // The detail shows the face value.
    await tapVisible(tester, price);
    expect(find.text('Detalji ponude'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Originalna cijena'),
      200,
      scrollable: mainScrollable,
    );
    expect(find.textContaining('30,00'), findsOneWidget);
  });

  testWidgets('sellers see their own price, without the buyer fee', (
    tester,
  ) async {
    final auth = await pumpApp(
      tester,
      eventRepository: InMemoryEventRepository(events: [_event]),
      marketRepository: InMemoryMarketRepository(
        listings: [_listing(seller: '1')],
      ),
    );
    await auth.signIn(email: 'a@b.ba', password: 'x', keepSignedIn: true);
    await tester.pumpAndSettle();
    GoRouter.of(tester.element(find.byType(HomePage)))
        .push('/listing/a', extra: _listing(seller: '1'));
    await tester.pumpAndSettle();
    expect(find.text('Tvoja ponuda'), findsOneWidget);
    expect(find.textContaining('49,50'), findsNothing);
    expect(find.text('uključena naknada za uslugu 10%'), findsNothing);
  });

  testWidgets('the sell form shows the profit over the face value', (
    tester,
  ) async {
    final auth = await pumpApp(
      tester,
      eventRepository: InMemoryEventRepository(events: [_event]),
      marketRepository: InMemoryMarketRepository(
        payoutMethod: const PayoutMethod(
          accountHolder: 'Amra Test',
          iban: 'BA391290079401028494',
        ),
      ),
    );
    await auth.signIn(email: 'a@b.ba', password: 'x', keepSignedIn: true);
    auth.verifyEmail();
    await tester.pumpAndSettle();
    GoRouter.of(tester.element(find.byType(HomePage)))
        .push('/sell?event=${_event.id}');
    await tester.pumpAndSettle();

    // The face value is required.
    await tapVisible(tester, find.text('Objavi ponudu'));
    await tester.drag(find.byType(Scrollable).first, const Offset(0, 3000));
    await tester.pumpAndSettle();
    expect(find.text('Unesi originalnu cijenu karte'), findsOneWidget);

    await tapVisible(tester, find.byIcon(FLucideIcons.plus));
    await _enter(tester, FLucideIcons.receiptText, '30');
    await _enter(tester, FLucideIcons.tag, '45');
    // 45,00 − 10 % = 40,50 per ticket, 10,50 more than the face value;
    // for 2 tickets 81,00 and 21,00.
    expect(find.textContaining('40,50'), findsOneWidget);
    expect(find.textContaining('10,50'), findsOneWidget);
    expect(find.textContaining('81,00'), findsOneWidget);
    expect(find.textContaining('21,00'), findsOneWidget);
    expect(find.text('Zarada po karti'), findsOneWidget);
    expect(find.text('Originalna cijena'), findsOneWidget);

    // Below the face value: a hint.
    await _enter(tester, FLucideIcons.receiptText, '50');
    expect(find.textContaining('9,50'), findsWidgets);
    expect(
      find.text('Nakon naknade dobijaš manje od originalne cijene karte.'),
      findsOneWidget,
    );
    await _enter(tester, FLucideIcons.receiptText, '30');

    await tapVisible(tester, find.text('Objavi ponudu'));
    expect(find.text('Detalji ponude'), findsOneWidget);
    final created = (await market.watchMyListings('1').first).single;
    expect(created.faceValueMinor, 3000);
    expect(created.priceMinor, 4500);
    expect(created.quantity, 2);
  });
}
