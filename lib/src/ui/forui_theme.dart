import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:forui/forui.dart';

import '../settings/settings_controller.dart';
import 'tokens.dart';

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

/// [constraints] grown to at least [TapTarget.min] in both directions.
BoxConstraints _tapSafe(BoxConstraints constraints) => constraints.copyWith(
  minWidth: math.max(constraints.minWidth, TapTarget.min),
  minHeight: math.max(constraints.minHeight, TapTarget.min),
);

/// [variants] with [f] applied to the base and to every variant.
FVariants<K, E, V, D> _mapVariants<
  K extends FVariantConstraint,
  E extends FVariant,
  V,
  D extends Delta
>(FVariants<K, E, V, D> variants, V Function(V) f) => FVariants.raw(
  f(variants.base),
  {for (final e in variants.variants.entries) e.key: f(e.value)},
);

/// Forui's buttons, with the small sizes (32 and 40 px) grown to
/// [TapTarget.min] on touch screens. They look the same, only taller.
FButtonStyles _buttonStyles(
  FColors colors,
  FTypography typography,
  FStyle style,
) {
  FButtonStyle grow(FButtonStyle s) => s.copyWith(
    contentStyle: .delta(constraints: _tapSafe(s.contentStyle.constraints)),
    iconContentStyle: .delta(
      constraints: _tapSafe(s.iconContentStyle.constraints),
    ),
  );
  final styles = FButtonStyles.inherit(
    colors: colors,
    typography: typography,
    style: style,
    touch: true,
  );
  return FButtonStyles(
    _mapVariants(
      styles,
      (sizes) => FButtonSizeStyles(_mapVariants(sizes, grow)),
    ),
  );
}

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
  final style = styleFor(colors);
  return FThemeData(
    colors: colors,
    touch: touch,
    typography: typography,
    style: style,
    buttonStyles: touch ? _buttonStyles(colors, typography, style) : null,
    tabsStyle: FTabsStyle.inherit(
      colors: colors,
      typography: typography,
      style: style,
    ).copyWith(minHeight: touch ? TapTarget.min : null),
    tileStyles: plain.tileStyles,
    tileGroupStyle: plain.tileGroupStyle,
    itemStyles: plain.itemStyles,
    itemGroupStyle: plain.itemGroupStyle,
    badgeStyles: plain.badgeStyles,
    avatarStyle: plain.avatarStyle,
    debugLabel: 'Stubswap ${brightness.name}',
  );
}
