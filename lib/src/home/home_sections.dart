import 'package:flutter/foundation.dart';

import '../data/events_repository.dart';
import '../data/models.dart';
import '../location/cities.dart';

/// What a row on the home page shows.
enum HomeSectionKind {
  recentlyViewed,
  popular,
  recommended,
  nearby,

  /// One of the "popular categories": events of a genre, e.g. football.
  genre,

  /// Like [genre] when no event has a genre: events of a type.
  category,
}

/// A row of events on the home page.
@immutable
class HomeSection {
  const HomeSection(this.kind, this.events, {this.genre, this.category});

  final HomeSectionKind kind;
  final List<Event> events;

  /// For [HomeSectionKind.genre].
  final String? genre;

  /// For [HomeSectionKind.category].
  final EventCategory? category;

  /// Unique on the page, e.g. "genre:rock".
  String get id => switch (kind) {
    HomeSectionKind.genre => 'genre:$genre',
    HomeSectionKind.category => 'category:${category?.name}',
    _ => kind.name,
  };
}

/// Everything the home page shows for the current filters.
@immutable
class HomeSections {
  const HomeSections({
    required this.rows,
    required this.popularCategories,
    required this.all,
  });

  /// Recently viewed, popular, recommended, nearby: the ones with events.
  final List<HomeSection> rows;

  /// Up to three genre (or type) rows under "Popular categories".
  final List<HomeSection> popularCategories;

  /// Every upcoming event of the chosen type, soonest first.
  final List<Event> all;

  bool get isEmpty => all.isEmpty;
}

/// How many events a row shows at most.
const homeRowLimit = 10;

/// How many genre rows "Popular categories" shows at most.
const homeGenreRows = 3;

/// The event types that have upcoming [events], in a fixed order.
List<EventCategory> homeTypes(List<Event> events) {
  final present = {for (final e in events) e.info.category};
  return [
    for (final c in EventCategory.values)
      if (present.contains(c)) c,
  ];
}

/// Picks the home page rows.
///
/// [events] are the upcoming events, [recent] the recently viewed ones
/// (newest view first), [city] the city for "near you" and [type] the
/// chosen event type (null for all).
HomeSections buildHomeSections({
  required List<Event> events,
  required Map<String, EventOffer> offers,
  List<Event> recent = const [],
  String? city,
  EventCategory? type,
  int limit = homeRowLimit,
}) {
  final all = [
    for (final e in events)
      if (type == null || e.info.category == type) e,
  ]..sort((a, b) => a.info.date.compareTo(b.info.date));
  final ids = {for (final e in all) e.id};
  final viewed = [
    for (final e in recent)
      if (ids.contains(e.id)) e,
  ];
  final viewedIds = {for (final e in viewed) e.id};

  final rows = <HomeSection>[];
  void add(HomeSectionKind kind, Iterable<Event> list) {
    final shown = list.take(limit).toList();
    if (shown.isNotEmpty) rows.add(HomeSection(kind, shown));
  }

  add(HomeSectionKind.recentlyViewed, viewed);

  // Most tickets on offer and sold first; the sooner one on a tie.
  int popularity(Event e) {
    final o = offers[e.id];
    return o == null ? 0 : o.tickets + o.sold;
  }

  final withOffers = [
    for (final e in all)
      if (offers.containsKey(e.id)) e,
  ];
  final popular = type != null
      ? const <Event>[]
      : (List.of(withOffers)..sort((a, b) {
              final byPopularity = popularity(b).compareTo(popularity(a));
              return byPopularity != 0
                  ? byPopularity
                  : a.info.date.compareTo(b.info.date);
            }))
            .take(limit)
            .toList();
  add(HomeSectionKind.popular, popular);

  add(
    HomeSectionKind.recommended,
    recommendedEvents(
      all: all,
      viewed: viewed,
      exclude: {...viewedIds, if (viewed.isEmpty) ...popular.map((e) => e.id)},
      offers: offers,
    ),
  );

  if (city != null && city.trim().isNotEmpty) {
    add(HomeSectionKind.nearby, [
      for (final e in all)
        if (sameCity(e.info.city, city)) e,
    ]);
  }

  return HomeSections(
    rows: rows,
    popularCategories: type == null
        ? popularCategoryRows(all, limit: limit)
        : const [],
    all: all,
  );
}

/// With a history: events of the genres, then of the types the user viewed,
/// soonest first. Without one: the soonest events with offers.
List<Event> recommendedEvents({
  required List<Event> all,
  required List<Event> viewed,
  required Set<String> exclude,
  required Map<String, EventOffer> offers,
}) {
  final candidates = [
    for (final e in all)
      if (!exclude.contains(e.id)) e,
  ];
  if (viewed.isEmpty) {
    return [
      for (final e in candidates)
        if (offers.containsKey(e.id)) e,
    ];
  }
  final genres = {
    for (final e in viewed)
      if (e.genre.isNotEmpty) e.genre,
  };
  final types = {for (final e in viewed) e.info.category};
  return [
    for (final e in candidates)
      if (e.genre.isNotEmpty && genres.contains(e.genre)) e,
    for (final e in candidates)
      if (!(e.genre.isNotEmpty && genres.contains(e.genre)) &&
          types.contains(e.info.category))
        e,
  ];
}

/// The genres with the most events, up to [homeGenreRows]. Without any
/// genres, the types with the most events instead when there are several.
List<HomeSection> popularCategoryRows(
  List<Event> all, {
  int limit = homeRowLimit,
}) {
  List<HomeSection> top<K>(
    K Function(Event e) keyOf,
    HomeSection Function(K key, List<Event> events) make,
  ) {
    // Insertion order is soonest event first: it decides ties.
    final groups = <K, List<Event>>{};
    for (final e in all) {
      final key = keyOf(e);
      if (key == null) continue;
      groups.putIfAbsent(key, () => []).add(e);
    }
    final order = groups.keys.toList();
    final sorted = groups.entries.toList()
      ..sort((a, b) {
        final bySize = b.value.length.compareTo(a.value.length);
        return bySize != 0
            ? bySize
            : order.indexOf(a.key).compareTo(order.indexOf(b.key));
      });
    return [
      for (final g in sorted.take(homeGenreRows))
        make(g.key, g.value.take(limit).toList()),
    ];
  }

  final genres = top<String?>(
    (e) => e.genre.isEmpty ? null : e.genre,
    (g, events) => HomeSection(HomeSectionKind.genre, events, genre: g),
  );
  if (genres.isNotEmpty) return genres;
  final types = top<EventCategory>(
    (e) => e.info.category,
    (c, events) => HomeSection(HomeSectionKind.category, events, category: c),
  );
  return types.length > 1 ? types : const [];
}
