import 'package:flat/src/admin/admin_repository.dart';
import 'package:flat/src/app.dart';
import 'package:flat/src/data/events_repository.dart';
import 'package:flat/src/data/models.dart';
import 'package:flat/src/router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';

import 'fixtures.dart';
import 'helpers.dart';

/// The sample events plus one a user added, not yet checked.
InMemoryEventRepository _eventsWithPending() {
  final now = DateTime.now();
  return InMemoryEventRepository(
    events: [
      ...sampleEventList(now: now),
      Event(
        id: 'ev-user',
        info: EventInfo(
          name: 'Dino Merlin akustično',
          venue: 'Zetra',
          city: 'Sarajevo',
          date: DateTime(now.year, now.month, now.day + 12, 20),
          category: EventCategory.concerts,
        ),
        status: EventStatus.pending,
        genre: 'folk',
        createdBy: '9',
        createdAt: now,
      ),
    ],
  );
}

Future<FakeAuthRepository> _signedIn(
  WidgetTester tester, {
  InMemoryEventRepository? eventRepository,
  InMemoryAdminRepository? admin,
}) async {
  final auth = await pumpApp(
    tester,
    marketRepository: buildSampleMarket('1'),
    eventRepository: eventRepository ?? buildSampleEvents(),
    adminRepository: admin,
  );
  await auth.signIn(email: 'amra@test.ba', password: 'x', keepSignedIn: true);
  await tester.pumpAndSettle();
  return auth;
}

Future<void> _go(WidgetTester tester, String location) async {
  ProviderScope.containerOf(tester.element(find.byType(FlatApp)))
      .read(routerProvider)
      .push(location);
  await tester.pumpAndSettle();
}

/// Fills name, venue, city, a date a week ahead and the type.
Future<void> _fillForm(WidgetTester tester) async {
  final fields = find.byType(EditableText);
  await tester.enterText(fields.at(0), 'Mostar Blues Festival');
  await tester.enterText(fields.at(1), 'Stari most');
  await tester.enterText(fields.at(2), 'Mostar');
  await tapVisible(tester, find.byIcon(FLucideIcons.calendar));
  await tester.tap(find.text('Uredu').last);
  await tester.pumpAndSettle();
  await tester.tap(find.text('Uredu').last);
  await tester.pumpAndSettle();
  await tapVisible(tester, find.text('Festivali'));
  await tapVisible(tester, find.text('Muzički festivali'));
}

Finder get _submit => find.widgetWithText(FButton, 'Dodaj događaj');

void main() {
  testWidgets('a verified user adds an event from the sell form and sells '
      'tickets for it right away', (tester) async {
    final auth = await _signedIn(tester);
    auth.verifyEmail();
    await tester.pumpAndSettle();
    await _go(tester, '/sell');

    await tapVisible(tester, find.text('Odaberi događaj').first);
    await tester.tap(find.text('Dodaj ga'));
    await tester.pumpAndSettle();

    expect(find.text('Tim će provjeriti događaj'), findsOneWidget);
    expect(
      find.text('Potvrdi e-mail adresu da bi mogao dodavati događaje.'),
      findsNothing,
    );
    await _fillForm(tester);
    await tapVisible(tester, _submit);

    final created = (await events.watchEvents().first).singleWhere(
      (e) => e.info.name == 'Mostar Blues Festival',
    );
    expect(created.status, EventStatus.pending);
    expect(created.createdBy, '1');
    expect(created.genre, 'musicFestival');
    expect(created.info.category, EventCategory.festivals);

    // Back on the sell form with the new event chosen.
    expect(find.text('Objavi ponudu'), findsOneWidget);
    expect(find.text('Mostar Blues Festival'), findsOneWidget);
    expect(find.text('Promijeni'), findsOneWidget);
    expect(find.text('Nije potvrđen'), findsOneWidget);
    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();
  });

  testWidgets('an unverified user is asked to confirm the email first', (
    tester,
  ) async {
    await _signedIn(tester);
    await _go(tester, '/events/new');

    expect(
      find.text('Potvrdi e-mail adresu da bi mogao dodavati događaje.'),
      findsOneWidget,
    );
    expect(find.widgetWithText(FButton, 'Potvrdi'), findsOneWidget);

    await _fillForm(tester);
    await tapVisible(tester, _submit);
    expect(
      (await events.watchEvents().first).where(
        (e) => e.info.name == 'Mostar Blues Festival',
      ),
      isEmpty,
    );
    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();
  });

  testWidgets('everybody sees that an event is not confirmed; normal users '
      'cannot edit it', (tester) async {
    await _signedIn(tester, eventRepository: _eventsWithPending());

    // On its card on the home page.
    expect(find.text('Nije potvrđen'), findsWidgets);

    await _go(tester, '/event/ev-user');
    expect(find.text('Nije potvrđen'), findsOneWidget);
    expect(find.textContaining('tim ga još nije provjerio'), findsOneWidget);
    expect(find.text('Koncerti · Narodna muzika'), findsOneWidget);
    // Tickets can still be sold.
    // Selling is offered below the offers.
    await tester.scrollUntilVisible(
      find.text('Imaš karte za ovaj događaj?'),
      200,
      scrollable: mainScrollable,
    );
    expect(find.text('Imaš karte za ovaj događaj?'), findsOneWidget);
    expect(find.text('Uredi / provjeri'), findsNothing);

    await _go(tester, '/admin/events/ev-user');
    expect(find.text('Nemate pristup'), findsOneWidget);
  });

  testWidgets('a support account corrects and confirms an event', (
    tester,
  ) async {
    await _signedIn(
      tester,
      eventRepository: _eventsWithPending(),
      admin: InMemoryAdminRepository(roles: {'1': StaffRole.support}),
    );

    // The team section in settings leads to the events to check.
    await tester.tap(byLabel('Postavke'));
    await tester.pumpAndSettle();
    await tapVisible(tester, find.text('Događaji na provjeri'));

    expect(find.text('Na provjeri (1)'), findsOneWidget);
    expect(find.text('Dino Merlin akustično'), findsOneWidget);
    // Confirmed events are under their own filter.
    expect(find.text('Bijelo Dugme Tribute'), findsNothing);

    await tester.tap(find.text('Dino Merlin akustično'));
    await tester.pumpAndSettle();
    expect(find.text('Dodao: Korisnik'), findsOneWidget);
    expect(find.text('Nije potvrđen'), findsOneWidget);

    await tester.enterText(
      find.byType(EditableText).first,
      'Dino Merlin – akustični koncert',
    );
    await tapVisible(tester, find.widgetWithText(FButton, 'Potvrdi'));

    final event = await events.watchEvent('ev-user').first;
    expect(event!.status, EventStatus.confirmed);
    expect(event.info.name, 'Dino Merlin – akustični koncert');
    expect(event.genre, 'folk');

    // Back on the list: nothing left to check.
    expect(find.text('Na provjeri (0)'), findsOneWidget);
    expect(find.text('Nema događaja na provjeri'), findsOneWidget);

    await _go(tester, '/event/ev-user');
    expect(find.text('Potvrđen'), findsOneWidget);
    expect(find.text('Nije potvrđen'), findsNothing);
    expect(find.text('Uredi / provjeri'), findsOneWidget);
    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();
  });

  testWidgets('the team confirms an event from its page', (tester) async {
    await _signedIn(
      tester,
      eventRepository: _eventsWithPending(),
      admin: InMemoryAdminRepository(roles: {'1': StaffRole.support}),
    );
    await _go(tester, '/event/ev-user');

    await tapVisible(tester, find.widgetWithText(FButton, 'Potvrdi'));
    expect(find.text('Potvrditi događaj?'), findsOneWidget);
    await tester.tap(find.widgetWithText(FButton, 'Potvrdi').last);
    await tester.pumpAndSettle();

    expect(
      (await events.watchEvent('ev-user').first)!.status,
      EventStatus.confirmed,
    );
    expect(find.text('Potvrđen'), findsOneWidget);
    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();
  });
}
