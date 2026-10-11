import '../../l10n/app_localizations.dart';
import '../data/models.dart';

/// Finer categories per event type, e.g. football within sports. Stored as
/// the key in the event's `genre` field.
const eventGenres = <EventCategory, List<String>>{
  EventCategory.sports: [
    'football',
    'basketball',
    'handball',
    'tennis',
    'volleyball',
    'combat',
    'motorsport',
    'otherSport',
  ],
  EventCategory.concerts: [
    'rock',
    'pop',
    'folk',
    'jazz',
    'hiphop',
    'electronic',
    'classical',
    'otherMusic',
  ],
  EventCategory.theater: [
    'drama',
    'opera',
    'ballet',
    'standup',
    'musical',
    'exhibition',
    'film',
  ],
  EventCategory.festivals: [
    'musicFestival',
    'filmFestival',
    'foodFestival',
    'otherFestival',
  ],
  EventCategory.other: ['family', 'conference', 'otherEvent'],
};

/// The type a genre belongs to, or null for an unknown key.
EventCategory? categoryOfGenre(String genre) {
  for (final e in eventGenres.entries) {
    if (e.value.contains(genre)) return e.key;
  }
  return null;
}

/// The genre's name; an unknown key is shown as it is.
String genreName(AppLocalizations l10n, String genre) => switch (genre) {
  'football' => l10n.genreFootball,
  'basketball' => l10n.genreBasketball,
  'handball' => l10n.genreHandball,
  'tennis' => l10n.genreTennis,
  'volleyball' => l10n.genreVolleyball,
  'combat' => l10n.genreCombat,
  'motorsport' => l10n.genreMotorsport,
  'otherSport' => l10n.genreOtherSport,
  'rock' => l10n.genreRock,
  'pop' => l10n.genrePop,
  'folk' => l10n.genreFolk,
  'jazz' => l10n.genreJazz,
  'hiphop' => l10n.genreHiphop,
  'electronic' => l10n.genreElectronic,
  'classical' => l10n.genreClassical,
  'otherMusic' => l10n.genreOtherMusic,
  'drama' => l10n.genreDrama,
  'opera' => l10n.genreOpera,
  'ballet' => l10n.genreBallet,
  'standup' => l10n.genreStandup,
  'musical' => l10n.genreMusical,
  'exhibition' => l10n.genreExhibition,
  'film' => l10n.genreFilm,
  'musicFestival' => l10n.genreMusicFestival,
  'filmFestival' => l10n.genreFilmFestival,
  'foodFestival' => l10n.genreFoodFestival,
  'otherFestival' => l10n.genreOtherFestival,
  'family' => l10n.genreFamily,
  'conference' => l10n.genreConference,
  'otherEvent' => l10n.genreOtherEvent,
  _ => genre,
};
