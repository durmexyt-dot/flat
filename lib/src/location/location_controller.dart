import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/events_repository.dart';
import '../settings/settings_controller.dart';
import 'cities.dart';
import 'geolocation.dart';

/// How the home page's city was chosen.
enum CitySource {
  /// Typed or picked by the user.
  manual,

  /// The nearest known city to the device's position.
  location,

  /// Nothing chosen: the city with the most upcoming events.
  fallback,
}

@immutable
class HomeCity {
  const HomeCity(this.name, this.source);
  final String name;
  final CitySource source;
}

/// The city the user chose (or their location gave), remembered on this
/// device. Null when none was chosen.
class ChosenCity extends Notifier<HomeCity?> {
  static const _nameKey = 'homeCity';
  static const _sourceKey = 'homeCitySource';

  @override
  HomeCity? build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    final name = prefs.getString(_nameKey);
    if (name == null || name.isEmpty) return null;
    final source = prefs.getString(_sourceKey) == 'location'
        ? CitySource.location
        : CitySource.manual;
    return HomeCity(name, source);
  }

  void _save(HomeCity? city) {
    final prefs = ref.read(sharedPreferencesProvider);
    if (city == null) {
      prefs.remove(_nameKey);
      prefs.remove(_sourceKey);
    } else {
      prefs.setString(_nameKey, city.name);
      prefs.setString(_sourceKey, city.source.name);
    }
    state = city;
  }

  void setCity(String name) {
    final trimmed = name.trim();
    _save(trimmed.isEmpty ? null : HomeCity(trimmed, CitySource.manual));
  }

  void clear() => _save(null);

  /// Asks for the device position and picks the nearest known city.
  /// Returns false when the position isn't available or not allowed.
  Future<bool> useMyLocation() async {
    final position = await currentPosition();
    if (position == null) return false;
    _save(
      HomeCity(nearestCity(position.$1, position.$2).name, CitySource.location),
    );
    return true;
  }
}

final chosenCityProvider = NotifierProvider<ChosenCity, HomeCity?>(
  ChosenCity.new,
);

/// The city for "events near …": the chosen one, otherwise the city with
/// the most upcoming events. Null if there are no events at all.
final homeCityProvider = Provider<HomeCity?>((ref) {
  final chosen = ref.watch(chosenCityProvider);
  if (chosen != null) return chosen;
  final events = ref.watch(upcomingEventsProvider).value ?? const [];
  final counts = <String, (String, int)>{};
  for (final e in events) {
    final key = cityKey(e.info.city);
    final c = counts[key];
    counts[key] = (c?.$1 ?? e.info.city, (c?.$2 ?? 0) + 1);
  }
  if (counts.isEmpty) return null;
  final best = counts.values.reduce((a, b) => b.$2 > a.$2 ? b : a);
  return HomeCity(best.$1, CitySource.fallback);
});

/// City names to suggest when typing: those with events first, then known
/// cities.
final citySuggestionsProvider = Provider<List<String>>((ref) {
  final events = ref.watch(eventsProvider).value ?? const [];
  final seen = <String>{};
  final names = <String>[];
  for (final name in [
    for (final e in events) e.info.city,
    for (final c in knownCities) c.name,
  ]) {
    if (name.trim().isEmpty || !seen.add(cityKey(name))) continue;
    names.add(name.trim());
  }
  return names;
});
