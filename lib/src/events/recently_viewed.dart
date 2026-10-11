import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/events_repository.dart';
import '../data/models.dart';
import '../settings/settings_controller.dart';

/// Events the user opened, newest first, remembered on this device.
class RecentlyViewed extends Notifier<List<String>> {
  static const _key = 'recentlyViewedEvents';
  static const max = 12;

  @override
  List<String> build() =>
      ref.watch(sharedPreferencesProvider).getStringList(_key) ?? const [];

  void add(String eventId) {
    final next = [
      eventId,
      ...state.where((id) => id != eventId),
    ].take(max).toList();
    ref.read(sharedPreferencesProvider).setStringList(_key, next);
    state = next;
  }

  void clear() {
    ref.read(sharedPreferencesProvider).remove(_key);
    state = const [];
  }
}

final recentlyViewedIdsProvider =
    NotifierProvider<RecentlyViewed, List<String>>(RecentlyViewed.new);

/// The recently viewed events that are still upcoming and visible, newest
/// view first.
final recentlyViewedEventsProvider = Provider<List<Event>>((ref) {
  final ids = ref.watch(recentlyViewedIdsProvider);
  final byId = {
    for (final e in ref.watch(upcomingEventsProvider).value ?? const <Event>[])
      e.id: e,
  };
  return [for (final id in ids) ?byId[id]];
});
