import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Overridden in main() with the loaded instance.
final sharedPreferencesProvider = Provider<SharedPreferences>(
  (ref) => throw UnimplementedError(),
);

const _localeKey = 'locale';
const defaultLocale = Locale('bs');

/// Display names of the supported languages, in menu order.
const languageNames = {'bs': 'Bosanski', 'de': 'Deutsch', 'en': 'English'};

class LocaleController extends Notifier<Locale> {
  @override
  Locale build() {
    final code = ref.watch(sharedPreferencesProvider).getString(_localeKey);
    return languageNames.containsKey(code) ? Locale(code!) : defaultLocale;
  }

  Future<void> setLocale(Locale locale) async {
    state = locale;
    await ref
        .read(sharedPreferencesProvider)
        .setString(_localeKey, locale.languageCode);
  }
}

final localeProvider = NotifierProvider<LocaleController, Locale>(
  LocaleController.new,
);
