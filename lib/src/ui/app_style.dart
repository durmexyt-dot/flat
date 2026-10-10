import 'package:flutter/material.dart';

/// Shape values that follow the user's UI style setting.
@immutable
class AppStyle extends ThemeExtension<AppStyle> {
  const AppStyle({required this.cardRadius, required this.controlRadius});

  /// Cards, sheets, dialogs.
  final double cardRadius;

  /// Buttons, inputs, chips.
  final double controlRadius;

  static const fallback = AppStyle(cardRadius: 20, controlRadius: 14);

  static AppStyle of(BuildContext context) =>
      Theme.of(context).extension<AppStyle>() ?? fallback;

  @override
  AppStyle copyWith({double? cardRadius, double? controlRadius}) => AppStyle(
    cardRadius: cardRadius ?? this.cardRadius,
    controlRadius: controlRadius ?? this.controlRadius,
  );

  @override
  AppStyle lerp(AppStyle? other, double t) {
    if (other == null) return this;
    return AppStyle(
      cardRadius: lerpDouble(cardRadius, other.cardRadius, t),
      controlRadius: lerpDouble(controlRadius, other.controlRadius, t),
    );
  }

  static double lerpDouble(double a, double b, double t) => a + (b - a) * t;
}
