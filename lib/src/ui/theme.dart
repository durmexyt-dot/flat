import 'package:flutter/material.dart';
import 'package:forui/forui.dart';

import '../settings/settings_controller.dart';
import 'app_style.dart';
import 'forui_theme.dart';

/// Neutral greys for Material's surface steps, which Forui has no names for.
abstract final class _Surface {
  static const lightLow = Color(0xFFF5F5F5);
  static const light = Color(0xFFF0F0F0);
  static const lightHigh = Color(0xFFEBEBEB);
  static const lightHighest = Color(0xFFE5E5E5);
  static const dark = Color(0xFF1F1F1F);
  static const darkHighest = Color(0xFF2E2E2E);
}

/// Material colors taken from the Forui palette, so the few remaining
/// Material widgets and our own painters match the Forui widgets.
ColorScheme materialColors(BrandColor color, Brightness brightness) {
  final f = appColors(color, brightness);
  final light = brightness == Brightness.light;
  return colorSchemeFor(color, brightness).copyWith(
    primary: f.primary,
    onPrimary: f.primaryForeground,
    secondary: f.secondaryForeground,
    onSecondary: f.secondary,
    secondaryContainer: f.secondary,
    onSecondaryContainer: f.secondaryForeground,
    error: f.error,
    onError: f.errorForeground,
    surface: f.background,
    onSurface: f.foreground,
    onSurfaceVariant: f.mutedForeground,
    surfaceDim: f.background,
    surfaceBright: f.background,
    surfaceContainerLowest: f.background,
    surfaceContainerLow: light ? _Surface.lightLow : f.card,
    surfaceContainer: light ? _Surface.light : _Surface.dark,
    surfaceContainerHigh: light ? _Surface.lightHigh : f.secondary,
    surfaceContainerHighest: light
        ? _Surface.lightHighest
        : _Surface.darkHighest,
    outline: f.mutedForeground,
    outlineVariant: light ? f.border : _Surface.darkHighest,
    inverseSurface: f.foreground,
    onInverseSurface: f.background,
  );
}

ThemeData buildTheme(Brightness brightness, AppSettings settings) {
  final colors = materialColors(settings.color, brightness);
  final style = AppStyle(
    cardRadius: settings.uiStyle.cardRadius,
    controlRadius: settings.uiStyle.controlRadius,
  );
  final control = RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(style.controlRadius),
  );
  final card = RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(style.cardRadius),
  );
  final inputRadius = BorderRadius.circular(
    settings.uiStyle == UiStyle.rounded ? 28 : style.controlRadius + 2,
  );
  ButtonStyle buttons() => ButtonStyle(shape: WidgetStatePropertyAll(control));

  return ThemeData(
    colorScheme: colors,
    useMaterial3: true,
    // Forui's Inter, so Material text matches Forui text.
    fontFamily: FTypeface.defaultFontFamily,
    scaffoldBackgroundColor: colors.surface,
    extensions: [style],
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: colors.surfaceContainerHighest.withValues(alpha: 0.5),
      border: OutlineInputBorder(
        borderRadius: inputRadius,
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: inputRadius,
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: inputRadius,
        borderSide: BorderSide(color: colors.primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: inputRadius,
        borderSide: BorderSide(color: colors.error),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: inputRadius,
        borderSide: BorderSide(color: colors.error, width: 2),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(style: buttons()),
    outlinedButtonTheme: OutlinedButtonThemeData(style: buttons()),
    elevatedButtonTheme: ElevatedButtonThemeData(style: buttons()),
    segmentedButtonTheme: SegmentedButtonThemeData(style: buttons()),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(style.cardRadius.clamp(4, 20)),
      ),
    ),
    cardTheme: CardThemeData(shape: card),
    chipTheme: ChipThemeData(shape: control),
    dialogTheme: DialogThemeData(shape: card),
    bottomSheetTheme: BottomSheetThemeData(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(style.cardRadius),
        ),
      ),
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      shape: control,
    ),
    searchBarTheme: SearchBarThemeData(
      shape: WidgetStatePropertyAll(
        RoundedRectangleBorder(borderRadius: inputRadius),
      ),
    ),
    listTileTheme: ListTileThemeData(shape: control),
    appBarTheme: const AppBarTheme(scrolledUnderElevation: 0),
  );
}
