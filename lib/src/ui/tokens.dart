// Design tokens: the one place for spacing, sizes, motion, type weights,
// widths and the few fixed colors. Change the look here, not in the pages.
//
// What lives elsewhere:
// - Brand colors the user can pick, light/dark palettes: settings_controller
//   (BrandColor) and forui_theme.dart (appColors).
// - Corner radii that follow the "UI style" setting: AppStyle (app_style.dart)
//   and UiStyle in settings_controller.
// - Font family and text sizes: Forui's typography (context.theme.typography);
//   the common combinations are in AppTextStyles below.
// - The logo: brand/brand.dart. The HTML splash: web/index.html.
import 'package:flutter/animation.dart';
import 'package:flutter/painting.dart';
import 'package:forui/forui.dart';

/// Spacing scale for gaps and padding, in steps of [unit].
abstract final class Space {
  /// The base step; everything below is a multiple of it.
  static const double unit = 4;

  static const double xxs = unit * 0.5; // 2
  static const double xs = unit; // 4
  static const double sm = unit * 1.5; // 6
  static const double md = unit * 2; // 8
  static const double lg = unit * 3; // 12
  static const double xl = unit * 4; // 16
  static const double xxl = unit * 5; // 20
  static const double x3l = unit * 6; // 24
  static const double x4l = unit * 7; // 28
  static const double x5l = unit * 8; // 32
}

/// Paddings used by many pages.
abstract final class Insets {
  /// Side padding of page content.
  static const double side = Space.xl;

  /// A scrolling page right below its header or title.
  static const page = EdgeInsets.fromLTRB(side, 0, side, Space.x5l);

  /// A scrolling list of cards, with a little room on top.
  static const pageList = EdgeInsets.fromLTRB(side, Space.md, side, Space.x5l);
}

/// Icon sizes.
abstract final class IconSizes {
  static const double xs = 14;
  static const double sm = 16;
  static const double md = 18;
  static const double lg = 20;

  /// Icons that stand in for a picture: empty states, placeholders.
  static const double feature = 40;
  static const double illustration = 48;
  static const double hero = 64;
  static const double xHero = 96;
}

/// Fixed corner radii. Cards, buttons and inputs follow the UI style
/// setting instead (AppStyle).
abstract final class Radii {
  /// Top corners of bottom sheets.
  static const double sheet = 16;
  static const sheetTop = BorderRadius.vertical(top: Radius.circular(sheet));

  /// The grab handle on top of a sheet.
  static const double handle = 2;
}

/// Animation durations and curves.
///
/// With the system's "reduce motion" setting, [reduced] is set and every
/// duration below is zero: things change at once instead of moving.
abstract final class Motion {
  /// Set by the app (app.dart) from `MediaQuery.disableAnimations`.
  static bool reduced = false;

  static Duration _ms(int ms) =>
      reduced ? Duration.zero : Duration(milliseconds: ms);

  static Duration get fast => _ms(150);
  static Duration get quick => _ms(200);

  /// Most size and content changes.
  static Duration get normal => _ms(250);
  static Duration get slow => _ms(300);
  static Duration get slower => _ms(350);

  /// Count-ups and other attention moments.
  static Duration get long => _ms(900);

  /// One pass of the loading shimmer. It doesn't run with [reduced].
  static const shimmer = Duration(milliseconds: 1400);

  /// Things coming in.
  static const enter = Curves.easeOutCubic;
  static const ease = Curves.easeOut;

  /// A small overshoot, for things that pop in.
  static const pop = Curves.easeOutBack;
}

/// Touch targets.
abstract final class TapTarget {
  /// Nothing tappable is smaller on touch screens (Apple HIG, WCAG 2.5.5).
  static const double min = 44;
}

/// Font weights, by role.
abstract final class FontWeights {
  static const regular = FontWeight.w400;
  static const medium = FontWeight.w500;
  static const semibold = FontWeight.w600;
  static const bold = FontWeight.w700;
  static const heavy = FontWeight.w800;
  static const black = FontWeight.w900;
}

/// Content widths on wide screens.
abstract final class SiteWidth {
  /// The page: header, lists and grids.
  static const wide = 1200.0;

  /// No limit inside the page.
  static const full = double.infinity;

  /// Detail pages.
  static const detail = 900.0;

  /// Forms and settings.
  static const form = 760.0;
}

/// From this width on, pages are laid out like a website: header with
/// navigation, account drawer, wider content.
const wideLayoutBreakpoint = 900.0;

/// Fixed colors that don't follow the brand color or dark mode.
///
/// Status colors are used for dots, icons and fills, not body text: they keep
/// at least 3:1 against light and dark surfaces (WCAG 1.4.11), and
/// [onWaiting] at least 4.5:1 on [waiting]. test/accessibility_test.dart
/// checks this.
abstract final class FixedColors {
  /// Status badges: done / waiting.
  static const positive = Color(0xFF2E9E5B);
  static const waiting = Color(0xFFB98500);
  static const onWaiting = Color(0xFF1B1B1B);

  /// The staging ribbon.
  static const stagingRibbon = Color(0xFFE0A100);
  static const onStagingRibbon = Color(0xFF1B1B1B);

  /// Behind a full-screen picture and its buttons.
  static const imageBackdrop = Color(0xFF000000);
  static const imageControl = Color(0x99000000);
  static const onImageControl = Color(0xFFFFFFFF);

  /// Google's blue, for the "G" on the Google sign-in button.
  static const google = Color(0xFF4285F4);
}

/// Text styles used over and over.
extension AppTextStyles on FThemeData {
  /// Secondary text: hints, descriptions, meta lines.
  TextStyle get mutedText =>
      typography.body.sm.copyWith(color: colors.mutedForeground);

  /// Small secondary text.
  TextStyle get mutedSmallText =>
      typography.body.xs.copyWith(color: colors.mutedForeground);

  /// Titles of cards and rows.
  TextStyle get titleText => typography.body.md.copyWith(
    fontWeight: FontWeights.semibold,
    color: colors.foreground,
  );
}
