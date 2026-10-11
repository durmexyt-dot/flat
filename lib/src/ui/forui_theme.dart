import 'package:flutter/material.dart';
import 'package:forui/forui.dart';

import '../settings/settings_controller.dart';

/// Forui's neutral palette with the user's brand color as primary: neutral
/// surfaces and text (70/20 %), brand only for main actions (10 %).
FColors appColors(BrandColor color, Brightness brightness) {
  final base = brightness == Brightness.light
      ? FColors.neutralLight
      : FColors.neutralDark;
  final brand = colorSchemeFor(color, brightness);
  return base.copyWith(
    primary: brand.primary,
    primaryForeground: brand.onPrimary,
  );
}

/// Corner radii per UI style, relative to Forui's defaults.
double _radiusScale(UiStyle style) => switch (style) {
  UiStyle.rounded => 2,
  UiStyle.soft => 1,
  UiStyle.crisp => 0.4,
};

/// The Forui theme for the user's settings. [touch] picks the larger touch
/// sizes on phones and tablets.
FThemeData buildForuiTheme(
  AppSettings settings,
  Brightness brightness, {
  required bool touch,
}) {
  final colors = appColors(settings.color, brightness);
  final neutral = brightness == Brightness.light
      ? FColors.neutralLight
      : FColors.neutralDark;
  final typography = FTypography.inherit(colors: colors, touch: touch);
  FStyle styleFor(FColors c) =>
      FStyle.inherit(colors: c, typography: typography, touch: touch).copyWith(
        borderRadius: FBorderRadius().scale(_radiusScale(settings.uiStyle)),
      );

  // Lists of tiles stay neutral: a brand-colored icon in every row would
  // break the 10 % rule.
  final plain = FThemeData(
    colors: neutral,
    touch: touch,
    typography: FTypography.inherit(colors: neutral, touch: touch),
    style: styleFor(neutral),
  );
  return FThemeData(
    colors: colors,
    touch: touch,
    typography: typography,
    style: styleFor(colors),
    tileStyles: plain.tileStyles,
    tileGroupStyle: plain.tileGroupStyle,
    itemStyles: plain.itemStyles,
    itemGroupStyle: plain.itemGroupStyle,
    badgeStyles: plain.badgeStyles,
    avatarStyle: plain.avatarStyle,
    debugLabel: 'Stubswap ${brightness.name}',
  );
}
