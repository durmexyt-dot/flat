import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../ui/forui_theme.dart';

/// Overridden in main() with the loaded instance.
final sharedPreferencesProvider = Provider<SharedPreferences>(
  (ref) => throw UnimplementedError(),
);

/// Display names of the supported languages, in menu order.
const languageNames = {'bs': 'Bosanski', 'de': 'Deutsch', 'en': 'English'};

/// The app's language until the user picks one.
const defaultLanguage = 'de';

enum Currency {
  bam('BAM', 'KM'),
  eur('EUR', '€'),
  usd('USD', r'$');

  const Currency(this.code, this.symbol);
  final String code;
  final String symbol;
}

/// Seed colors the user can pick for the theme.
enum BrandColor {
  violet(Color(0xFF6D4AFF)),
  indigo(Color(0xFF3F51B5)),
  blue(Color(0xFF1E88E5)),
  teal(Color(0xFF00897B)),
  green(Color(0xFF2E7D32)),
  orange(Color(0xFFF57C00)),
  red(Color(0xFFE53935)),
  pink(Color(0xFFD81B60));

  const BrandColor(this.seed);
  final Color seed;
}

enum TextSize {
  minimum(0.85),
  normal(1),
  large(1.15),
  extraLarge(1.3);

  const TextSize(this.scale);
  final double scale;
}

/// Corner style of the UI.
enum UiStyle {
  // Card and control radii match Forui's lg and md radii in each style.
  rounded(cardRadius: 28, controlRadius: 20),
  soft(cardRadius: 14, controlRadius: 10),
  crisp(cardRadius: 6, controlRadius: 4);

  const UiStyle({required this.cardRadius, required this.controlRadius});
  final double cardRadius;
  final double controlRadius;
}

@immutable
class AppSettings {
  const AppSettings({
    required this.locale,
    required this.themeMode,
    required this.currency,
    this.color = BrandColor.violet,
    this.textSize = TextSize.normal,
    this.uiStyle = UiStyle.soft,
  });

  final Locale locale;
  final ThemeMode themeMode;
  final Currency currency;
  final BrandColor color;
  final TextSize textSize;
  final UiStyle uiStyle;

  AppSettings copyWith({
    Locale? locale,
    ThemeMode? themeMode,
    Currency? currency,
    BrandColor? color,
    TextSize? textSize,
    UiStyle? uiStyle,
  }) => AppSettings(
    locale: locale ?? this.locale,
    themeMode: themeMode ?? this.themeMode,
    currency: currency ?? this.currency,
    color: color ?? this.color,
    textSize: textSize ?? this.textSize,
    uiStyle: uiStyle ?? this.uiStyle,
  );
}

const _localeKey = 'locale';
const _themeKey = 'themeMode';
const _currencyKey = 'currency';
const _colorKey = 'themeColor';
const _textSizeKey = 'textSize';
const _uiStyleKey = 'uiStyle';

T _byName<T extends Enum>(List<T> values, String? name, T fallback) =>
    values.where((v) => v.name == name).firstOrNull ?? fallback;

class SettingsController extends Notifier<AppSettings> {
  SharedPreferences get _prefs => ref.read(sharedPreferencesProvider);

  @override
  AppSettings build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    final code = prefs.getString(_localeKey);
    return AppSettings(
      locale: Locale(languageNames.containsKey(code) ? code! : defaultLanguage),
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
      color: _byName(
        BrandColor.values,
        prefs.getString(_colorKey),
        BrandColor.violet,
      ),
      textSize: _byName(
        TextSize.values,
        prefs.getString(_textSizeKey),
        TextSize.normal,
      ),
      uiStyle: _byName(
        UiStyle.values,
        prefs.getString(_uiStyleKey),
        UiStyle.soft,
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

  Future<void> setColor(BrandColor color) async {
    state = state.copyWith(color: color);
    await _prefs.setString(_colorKey, color.name);
    await _saveSplashColors(color);
  }

  Future<void> setTextSize(TextSize size) async {
    state = state.copyWith(textSize: size);
    await _prefs.setString(_textSizeKey, size.name);
  }

  Future<void> setUiStyle(UiStyle style) async {
    state = state.copyWith(uiStyle: style);
    await _prefs.setString(_uiStyleKey, style.name);
  }

  /// web/index.html reads these to draw its loading splash in the user's
  /// colors before Flutter starts.
  Future<void> _saveSplashColors(BrandColor color) async {
    String hex(Color c) => '#${c.toARGB32().toRadixString(16).substring(2)}';
    Map<String, String> scheme(Brightness b) {
      final s = appColors(color, b);
      return {
        'surface': hex(s.background),
        'onSurface': hex(s.foreground),
        'primary': hex(s.primary),
        'onPrimary': hex(s.primaryForeground),
      };
    }

    await _prefs.setString(
      'splashColors',
      jsonEncode({
        'light': scheme(Brightness.light),
        'dark': scheme(Brightness.dark),
      }),
    );
  }
}

/// Colors follow the 70/20/10 rule: 70 % neutral surfaces, 20 % neutral
/// containers and text, 10 % brand color for the main actions and active
/// states. So surfaces, text and the secondary role are plain greys, and only
/// primary carries the brand color.
ColorScheme colorSchemeFor(BrandColor color, Brightness brightness) {
  final brand = ColorScheme.fromSeed(
    seedColor: color.seed,
    brightness: brightness,
    dynamicSchemeVariant: DynamicSchemeVariant.vibrant,
  );
  final grey = ColorScheme.fromSeed(
    seedColor: color.seed,
    brightness: brightness,
    dynamicSchemeVariant: DynamicSchemeVariant.monochrome,
  );
  return brand.copyWith(
    secondary: grey.secondary,
    onSecondary: grey.onSecondary,
    secondaryContainer: grey.surfaceContainerHighest,
    onSecondaryContainer: grey.onSurface,
    surface: grey.surface,
    onSurface: grey.onSurface,
    onSurfaceVariant: grey.onSurfaceVariant,
    surfaceDim: grey.surfaceDim,
    surfaceBright: grey.surfaceBright,
    surfaceContainerLowest: grey.surfaceContainerLowest,
    surfaceContainerLow: grey.surfaceContainerLow,
    surfaceContainer: grey.surfaceContainer,
    surfaceContainerHigh: grey.surfaceContainerHigh,
    surfaceContainerHighest: grey.surfaceContainerHighest,
    outline: grey.outline,
    outlineVariant: grey.outlineVariant,
    inverseSurface: grey.inverseSurface,
    onInverseSurface: grey.onInverseSurface,
    // No brand tint on raised surfaces.
    surfaceTint: Colors.transparent,
  );
}

final settingsProvider = NotifierProvider<SettingsController, AppSettings>(
  SettingsController.new,
);
