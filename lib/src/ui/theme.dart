import 'package:flutter/material.dart';

import '../settings/settings_controller.dart';
import 'app_style.dart';

ThemeData buildTheme(Brightness brightness, AppSettings settings) {
  final colors = colorSchemeFor(settings.color, brightness);
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
