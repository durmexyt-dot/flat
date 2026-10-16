import 'dart:math';

/// A city with its position, to find the nearest one to the user without
/// an online map service.
class City {
  const City(this.name, this.lat, this.lon);
  final String name;
  final double lat;
  final double lon;
}

/// Cities in Bosnia and Herzegovina and the region where events take place.
const knownCities = [
  City('Sarajevo', 43.8563, 18.4131),
  City('Ilidža', 43.8297, 18.3108),
  City('Banja Luka', 44.7722, 17.1910),
  City('Tuzla', 44.5384, 18.6671),
  City('Zenica', 44.2034, 17.9077),
  City('Mostar', 43.3438, 17.8078),
  City('Bihać', 44.8169, 15.8708),
  City('Brčko', 44.8726, 18.8106),
  City('Bijeljina', 44.7570, 19.2150),
  City('Prijedor', 44.9799, 16.7133),
  City('Trebinje', 42.7119, 18.3436),
  City('Doboj', 44.7319, 18.0872),
  City('Cazin', 44.9669, 15.9431),
  City('Travnik', 44.2264, 17.6658),
  City('Goražde', 43.6679, 18.9761),
  City('Livno', 43.8269, 17.0075),
  City('Široki Brijeg', 43.3833, 17.5939),
  City('Visoko', 43.9889, 18.1781),
  City('Gradačac', 44.8786, 18.4264),
  City('Konjic', 43.6519, 17.9614),
  City('Zagreb', 45.8150, 15.9819),
  City('Split', 43.5081, 16.4402),
  City('Rijeka', 45.3271, 14.4422),
  City('Osijek', 45.5550, 18.6955),
  City('Zadar', 44.1194, 15.2314),
  City('Dubrovnik', 42.6507, 18.0944),
  City('Beograd', 44.7866, 20.4489),
  City('Novi Sad', 45.2671, 19.8335),
  City('Niš', 43.3209, 21.8958),
  City('Kragujevac', 44.0128, 20.9114),
  City('Podgorica', 42.4304, 19.2594),
  City('Budva', 42.2864, 18.8400),
  City('Ljubljana', 46.0569, 14.5058),
  City('Maribor', 46.5547, 15.6459),
  City('Skopje', 41.9981, 21.4254),
  City('Priština', 42.6629, 21.1655),
  City('Beč', 48.2082, 16.3738),
  City('München', 48.1351, 11.5820),
  City('Berlin', 52.5200, 13.4050),
];

double _km(double lat1, double lon1, double lat2, double lon2) {
  const r = 6371.0;
  double rad(double d) => d * pi / 180;
  final dLat = rad(lat2 - lat1);
  final dLon = rad(lon2 - lon1);
  final a =
      pow(sin(dLat / 2), 2) +
      cos(rad(lat1)) * cos(rad(lat2)) * pow(sin(dLon / 2), 2);
  return 2 * r * asin(sqrt(a));
}

/// The known city nearest to a position.
City nearestCity(double lat, double lon) => knownCities.reduce(
  (best, c) => _km(lat, lon, c.lat, c.lon) < _km(lat, lon, best.lat, best.lon)
      ? c
      : best,
);

/// Compares city names loosely: case, spaces and diacritics don't matter
/// ("Banja luka" = "Banja Luka", "Bihac" = "Bihać").
String cityKey(String name) {
  const map = {'č': 'c', 'ć': 'c', 'š': 's', 'ž': 'z', 'đ': 'dj', 'ü': 'u'};
  final lower = name.trim().toLowerCase();
  return lower
      .split('')
      .map((ch) => map[ch] ?? ch)
      .join()
      .replaceAll(RegExp(r'\s+'), ' ');
}

bool sameCity(String a, String b) => cityKey(a) == cityKey(b);

/// Within this distance a place counts as near a city.
const nearbyKm = 40.0;

/// Whether an event in [eventCity] is near [homeCity]: the same city, or
/// both known and at most [nearbyKm] apart.
bool isNearCity(String eventCity, String homeCity) {
  if (sameCity(eventCity, homeCity)) return true;
  City? find(String name) =>
      knownCities.where((c) => sameCity(c.name, name)).firstOrNull;
  final a = find(eventCity), b = find(homeCity);
  return a != null && b != null && _km(a.lat, a.lon, b.lat, b.lon) <= nearbyKm;
}
