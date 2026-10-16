import 'package:flat/src/data/events_repository.dart';
import 'package:flat/src/data/models.dart';
import 'package:flat/src/events/recently_viewed.dart';
import 'package:flat/src/home/event_row.dart';
import 'package:flat/src/home/home_page.dart';
import 'package:flat/src/home/home_sections.dart';
import 'package:flat/src/info/info_page.dart';
import 'package:flat/src/ui/tokens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';

import 'fixtures.dart';
import 'helpers.dart';

final _now = DateTime.now();

Event _event(
  String id, {
  EventCategory category = EventCategory.concerts,
  String genre = '',
  String city = 'Sarajevo',
  int inDays = 10,
}) => Event(
  id: id,
  genre: genre,
  info: EventInfo(
    name: 'Event $id',
    venue: 'Venue',
    city: city,
    date: DateTime(_now.year, _now.month, _now.day + inDays, 20),
    category: category,
  ),
);

EventOffer _offer(int tickets, [int sold = 0]) => EventOffer(
  tickets: tickets,
  sold: sold,
  minPriceMinor: 1000,
  currency: 'BAM',
);

List<String> _ids(List<Event> events) => [for (final e in events) e.id];

HomeSection? _row(HomeSections s, HomeSectionKind kind) =>
    s.rows.where((r) => r.kind == kind).firstOrNull;

/// The sample events with genres and one more upcoming event in Mostar.
Future<InMemoryEventRepository> _sampleWithGenres() async {
  final t = DateTime.now();
  const genres = {
    'ev-dubioza': 'rock',
    'ev-tribute': 'rock',
    'ev-derby': 'football',
    'ev-sff': 'filmFestival',
  };
  final sample = await buildSampleEvents(now: t)
      .watchEvents(includeHidden: true)
      .first;
  return InMemoryEventRepository(
    events: [
      for (final e in sample) e.copyWith(genre: genres[e.id] ?? ''),
      Event(
        id: 'ev-mostar',
        genre: 'jazz',
        info: EventInfo(
          name: 'Mostar Jazz Night',
          venue: 'Stari most',
          city: 'Mostar',
          date: DateTime(t.year, t.month, t.day + 30, 21),
          category: EventCategory.concerts,
        ),
      ),
    ],
  );
}

Future<void> _home(WidgetTester tester, {bool signIn = true}) async {
  final auth = await pumpApp(
    tester,
    marketRepository: buildSampleMarket('1'),
    eventRepository: await _sampleWithGenres(),
  );
  if (signIn) {
    await auth.signIn(email: 'amra@test.ba', password: 'x', keepSignedIn: true);
  }
  await tester.pumpAndSettle();
}

Finder _inSection(String title, Finder finder) => find.descendant(
  of: find.ancestor(
    of: find.text(title),
    matching: find.byType(EventRowSection),
  ),
  matching: finder,
);

void main() {
  group('buildHomeSections', () {
    test('0, 2 and 5 genres give 0, 2 and 3 genre rows', () {
      // No genres and one type: no "popular categories" at all.
      final none = buildHomeSections(
        events: [_event('a'), _event('b')],
        offers: const {},
      );
      expect(none.popularCategories, isEmpty);

      final two = buildHomeSections(
        events: [
          _event('a', genre: 'rock'),
          _event('b', genre: 'rock'),
          _event('c', genre: 'jazz'),
          _event('d'),
        ],
        offers: const {},
      );
      expect(
        [for (final s in two.popularCategories) s.genre],
        ['rock', 'jazz'],
      );
      expect(_ids(two.popularCategories.first.events), ['a', 'b']);

      final five = buildHomeSections(
        events: [
          _event('a', genre: 'pop', inDays: 1),
          _event('b', genre: 'rock', inDays: 2),
          _event('c', genre: 'rock', inDays: 3),
          _event('d', genre: 'jazz', inDays: 4),
          _event('e', genre: 'football', inDays: 5),
          _event('f', genre: 'football', inDays: 6),
          _event('g', genre: 'football', inDays: 7),
          _event('h', genre: 'folk', inDays: 8),
        ],
        offers: const {},
      );
      // Largest first; on a tie the genre with the sooner event.
      expect(
        [for (final s in five.popularCategories) s.genre],
        ['football', 'rock', 'pop'],
      );
      expect(
        five.popularCategories.every((s) => s.kind.name == 'genre'),
        isTrue,
      );
    });

    test('without genres, several types become the category rows', () {
      final s = buildHomeSections(
        events: [
          _event('a', category: EventCategory.sports),
          _event('b'),
          _event('c'),
        ],
        offers: const {},
      );
      expect(
        [for (final r in s.popularCategories) r.category],
        [EventCategory.concerts, EventCategory.sports],
      );
    });

    test('popular: most tickets and sales first, ties soonest', () {
      final s = buildHomeSections(
        events: [
          _event('soon', inDays: 1),
          _event('later', inDays: 5),
          _event('top', inDays: 9),
          _event('none', inDays: 2),
        ],
        offers: {'soon': _offer(2, 1), 'later': _offer(3), 'top': _offer(1, 9)},
      );
      expect(_ids(_row(s, HomeSectionKind.popular)!.events), [
        'top',
        'soon',
        'later',
      ]);
      // Without a history: the soonest offered events not yet popular.
      expect(_row(s, HomeSectionKind.recommended), isNull);
    });

    test('recommended follows the recently viewed genres and types', () {
      final rock = _event('rock1', genre: 'rock', inDays: 9);
      final s = buildHomeSections(
        events: [
          rock,
          _event('rock2', genre: 'rock', inDays: 8),
          _event('pop', genre: 'pop', inDays: 1),
          _event('derby', category: EventCategory.sports, genre: 'football'),
        ],
        offers: const {},
        recent: [rock],
      );
      expect(_ids(_row(s, HomeSectionKind.recentlyViewed)!.events), ['rock1']);
      // Same genre first, then the same type; never the viewed one.
      expect(_ids(_row(s, HomeSectionKind.recommended)!.events), [
        'rock2',
        'pop',
      ]);
    });

    test('nearby compares cities loosely', () {
      final s = buildHomeSections(
        events: [
          _event('a', city: 'Bihać'),
          _event('b', city: 'Sarajevo'),
          _event('c', city: 'bihac '),
        ],
        offers: const {},
        city: 'BIHAC',
      );
      expect(_ids(_row(s, HomeSectionKind.nearby)!.events), ['a', 'c']);
      final none = buildHomeSections(
        events: [_event('a')],
        offers: const {},
        city: 'Mostar',
      );
      expect(_row(none, HomeSectionKind.nearby), isNull);
    });

    test('a type limits every section to it', () {
      final derby = _event('derby', category: EventCategory.sports);
      final s = buildHomeSections(
        events: [
          derby,
          _event('match', category: EventCategory.sports, genre: 'football'),
          _event('concert', genre: 'rock'),
        ],
        offers: {'derby': _offer(4), 'concert': _offer(9)},
        recent: [
          derby,
          _event('concert', genre: 'rock'),
        ],
        city: 'Sarajevo',
        type: EventCategory.sports,
      );
      expect(
        [for (final r in s.rows) r.kind],
        [
          HomeSectionKind.recentlyViewed,
          HomeSectionKind.recommended,
          HomeSectionKind.nearby,
        ],
      );
      expect(_ids(_row(s, HomeSectionKind.recentlyViewed)!.events), ['derby']);
      expect(_ids(_row(s, HomeSectionKind.recommended)!.events), ['match']);
      expect(s.popularCategories, isEmpty);
      expect(_ids(s.all), ['derby', 'match']);
      expect(homeTypes(s.all), [EventCategory.sports]);
    });
  });

  group('home page', () {
    testWidgets('shows the sections with the sample events', (tester) async {
      await _home(tester);

      expect(find.text('Popularni događaji'), findsOneWidget);
      expect(find.text('Aktuelno u blizini: Sarajevo'), findsOneWidget);
      expect(find.text('Grad s najviše događaja'), findsOneWidget);
      // Most offered first: the derby (4 on sale + 2 sold).
      final popular = _inSection(
        'Popularni događaji',
        find.textContaining('FK Sarajevo'),
      );
      expect(popular, findsOneWidget);
      expect(find.text('Popularne kategorije'), findsOneWidget);
      expect(find.text('Rock'), findsOneWidget);
      expect(find.text('Svi događaji'), findsOneWidget);
      // Nothing viewed yet.
      expect(find.text('Nedavno pregledano'), findsNothing);
      // Past events are nowhere.
      expect(find.text('Hamlet'), findsNothing);

      // Opened events show up as recently viewed and steer recommendations.
      ProviderScope.containerOf(tester.element(find.byType(HomePage)))
          .read(recentlyViewedIdsProvider.notifier)
          .add('ev-mostar');
      await tester.pumpAndSettle();
      expect(find.text('Nedavno pregledano'), findsOneWidget);
      expect(
        _inSection('Nedavno pregledano', find.text('Mostar Jazz Night')),
        findsOneWidget,
      );
      expect(
        _inSection('Preporučeno za vas', find.text('Dubioza kolektiv')),
        findsOneWidget,
      );
    });

    testWidgets('opening a viewed event keeps the row still until it is in', (
      tester,
    ) async {
      await _home(tester);
      final viewed = ProviderScope.containerOf(
        tester.element(find.byType(HomePage)),
      ).read(recentlyViewedIdsProvider.notifier);
      viewed.add('ev-mostar');
      viewed.add('ev-dubioza');
      await tester.pumpAndSettle();

      GoRouter.of(tester.element(find.byType(HomePage)))
          .push('/event/ev-mostar');
      await tester.pump();
      await tester.pump(Motion.page ~/ 2);
      // Mid-transition the home row underneath hasn't reordered.
      expect(viewed.state, ['ev-dubioza', 'ev-mostar']);
      await tester.pumpAndSettle();
      expect(viewed.state, ['ev-mostar', 'ev-dubioza']);
    });

    testWidgets('a type shows only its sections', (tester) async {
      await _home(tester);
      await tester.tap(
        find.descendant(of: find.byType(FTabs), matching: find.text('Sport')),
      );
      await tester.pumpAndSettle();

      expect(find.text('Svi događaji: Sport'), findsOneWidget);
      expect(find.text('Popularni događaji'), findsNothing);
      expect(find.text('Popularne kategorije'), findsNothing);
      expect(find.text('Dubioza kolektiv'), findsNothing);
      expect(find.text('FK Sarajevo – FK Željezničar'), findsWidgets);
    });

    testWidgets('a chosen city shows events near it', (tester) async {
      await _home(tester);
      await tester.tap(find.text('Odaberi grad'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(EditableText).last, 'most');
      await tester.pumpAndSettle();
      await tester.tap(find.text('Mostar').last);
      await tester.pumpAndSettle();

      expect(find.text('Aktuelno u blizini: Mostar'), findsOneWidget);
      expect(
        _inSection(
          'Aktuelno u blizini: Mostar',
          find.text('Mostar Jazz Night'),
        ),
        findsOneWidget,
      );

      // Typing a city that isn't in the list is fine too.
      await tapVisible(tester, find.text('Promijeni'));
      await tester.enterText(find.byType(EditableText).last, 'Jajce');
      await tester.pumpAndSettle();
      await tester.tap(find.text('Koristi „Jajce”'));
      await tester.pumpAndSettle();
      await tester.drag(mainScrollable, const Offset(0, 5000));
      await tester.pumpAndSettle();
      expect(find.text('Jajce'), findsOneWidget);
      expect(find.textContaining('Aktuelno u blizini'), findsNothing);
    });

    testWidgets('search shows only the results', (tester) async {
      await _home(tester);
      await tester.enterText(find.byType(EditableText).first, 'rock');
      await tester.pumpAndSettle();
      expect(find.text('Rezultati pretrage'), findsOneWidget);
      expect(find.text('Popularni događaji'), findsNothing);
      // By genre name.
      expect(find.text('Dubioza kolektiv'), findsOneWidget);
      expect(find.text('Bijelo Dugme Tribute'), findsOneWidget);
      expect(find.text('Mostar Jazz Night'), findsNothing);
    });

    testWidgets('no events: guests are asked to sign in to add one', (
      tester,
    ) async {
      await pumpApp(tester);
      expect(find.text('Još nema događaja'), findsOneWidget);
      await tester.tap(find.text('Dodaj događaj'));
      await tester.pumpAndSettle();
      // Sign-in, saying why; afterwards the user comes back to the form.
      expect(find.text('Dobrodošli na Stubswap'), findsOneWidget);
      expect(
        find.text('Prijavi se ili napravi račun da nastaviš.'),
        findsOneWidget,
      );
    });

    testWidgets('footer links open the info pages', (tester) async {
      await _home(tester, signIn: false);

      await tapVisible(tester, find.text('O nama'));
      expect(find.byType(InfoPage), findsOneWidget);
      expect(find.textContaining('Bosni i Hercegovini'), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('back')));
      await tester.pumpAndSettle();

      await tapVisible(tester, find.text('Kako funkcioniše'));
      expect(find.text('Kupovina'), findsOneWidget);
      expect(find.text('Prodaja'), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('back')));
      await tester.pumpAndSettle();

      // Guests get the help center for "contact support".
      await tapVisible(tester, find.text('Kontaktiraj podršku'));
      expect(find.text('Centar za pomoć'), findsWidgets);
    });

    testWidgets('unknown info topics show an empty state', (tester) async {
      await _home(tester);
      GoRouter.of(tester.element(find.byType(HomePage))).push('/info/nope');
      await tester.pumpAndSettle();
      expect(find.text('Stranica nije pronađena'), findsWidgets);
    });
  });
}
