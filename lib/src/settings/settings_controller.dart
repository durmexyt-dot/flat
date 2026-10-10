import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Overridden in main() with the loaded instance.
final sharedPreferencesProvider = Provider<SharedPreferences>(
  (ref) => throw UnimplementedError(),
);

/// Display names of the supported languages, in menu order.
const languageNames = {'bs': 'Bosanski', 'de': 'Deutsch', 'en': 'English'};

enum Currency {
  bam('BAM', 'KM'),
  eur('EUR', '€'),
  usd('USD', r'$');

  const Currency(this.code, this.symbol);
  final String code;
  final String symbol;
}

@immutable
class AppSettings {
  const AppSettings({
    required this.locale,
    required this.themeMode,
    required this.currency,
  });

  final Locale locale;
  final ThemeMode themeMode;
  final Currency currency;

  AppSettings copyWith({
    Locale? locale,
    ThemeMode? themeMode,
    Currency? currency,
  }) => AppSettings(
    locale: locale ?? this.locale,
    themeMode: themeMode ?? this.themeMode,
    currency: currency ?? this.currency,
  );
}

const _localeKey = 'locale';
const _themeKey = 'themeMode';
const _currencyKey = 'currency';

T _byName<T extends Enum>(List<T> values, String? name, T fallback) =>
    values.where((v) => v.name == name).firstOrNull ?? fallback;

class SettingsController extends Notifier<AppSettings> {
  SharedPreferences get _prefs => ref.read(sharedPreferencesProvider);

  @override
  AppSettings build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    final code = prefs.getString(_localeKey);
    return AppSettings(
      locale: Locale(languageNames.containsKey(code) ? code! : 'bs'),
      themeMode: _byName(
        ThemeMode.values,
        prefs.getString(_themeKey),
        ThemeMode.system,
      ),
      currency: _byName(
        Currency.values,
        prefs.getString(_currencyKey),
        Currency.bam,
      ),
    );
  }

  Future<void> setLocale(Locale locale) async {
    state = state.copyWith(locale: locale);
    await _prefs.setString(_localeKey, locale.languageCode);
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    state = state.copyWith(themeMode: mode);
    await _prefs.setString(_themeKey, mode.name);
  }

  Future<void> setCurrency(Currency currency) async {
    state = state.copyWith(currency: currency);
    await _prefs.setString(_currencyKey, currency.name);
  }
}

final settingsProvider = NotifierProvider<SettingsController, AppSettings>(
  SettingsController.new,
);
