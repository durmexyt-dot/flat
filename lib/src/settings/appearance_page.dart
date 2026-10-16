import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';

import '../../l10n/app_localizations.dart';
import '../ui/segmented.dart';
import '../ui/ticket.dart';
import 'settings_controller.dart';
import 'settings_widgets.dart';
import '../ui/site_scaffold.dart';
import '../ui/tokens.dart';

String brandColorName(AppLocalizations l10n, BrandColor c) => switch (c) {
  BrandColor.violet => l10n.colorViolet,
  BrandColor.indigo => l10n.colorIndigo,
  BrandColor.blue => l10n.colorBlue,
  BrandColor.teal => l10n.colorTeal,
  BrandColor.green => l10n.colorGreen,
  BrandColor.orange => l10n.colorOrange,
  BrandColor.red => l10n.colorRed,
  BrandColor.pink => l10n.colorPink,
};

String textSizeName(AppLocalizations l10n, TextSize s) => switch (s) {
  TextSize.minimum => l10n.textSizeMinimum,
  TextSize.normal => l10n.textSizeDefault,
  TextSize.large => l10n.textSizeLarge,
  TextSize.extraLarge => l10n.textSizeExtraLarge,
};

String uiStyleName(AppLocalizations l10n, UiStyle s) => switch (s) {
  UiStyle.rounded => l10n.uiRounded,
  UiStyle.soft => l10n.uiSoft,
  UiStyle.crisp => l10n.uiCrisp,
};

String themeModeName(AppLocalizations l10n, ThemeMode m) => switch (m) {
  ThemeMode.system => l10n.themeSystem,
  ThemeMode.light => l10n.themeLight,
  ThemeMode.dark => l10n.themeDark,
};

/// Theme mode, color, text size and UI style, with a live preview on top.
class AppearancePage extends ConsumerWidget {
  const AppearancePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final settings = ref.watch(settingsProvider);
    final controller = ref.read(settingsProvider.notifier);
    final colors = context.theme.colors;
    final last = TextSize.values.length - 1;

    return SiteScaffold(
      title: l10n.appearance,
      maxWidth: SiteWidth.form,
      accountNav: true,
      body: ListView(
        padding: Insets.pageList,
        children: [
          const _Preview(),
          SettingsSectionTitle(l10n.themeModeLabel),
          Segmented<ThemeMode>(
            values: const [ThemeMode.system, ThemeMode.light, ThemeMode.dark],
            selected: settings.themeMode,
            label: (mode) => themeModeName(l10n, mode),
            icon: (mode) => switch (mode) {
              ThemeMode.system => FLucideIcons.sunMoon,
              ThemeMode.light => FLucideIcons.sun,
              ThemeMode.dark => FLucideIcons.moon,
            },
            onChanged: controller.setThemeMode,
          ),
          SettingsSectionTitle(l10n.themeColor),
          Wrap(
            spacing: Space.lg,
            runSpacing: Space.lg,
            children: [
              for (final color in BrandColor.values)
                _ColorDot(
                  color: color,
                  selected: color == settings.color,
                  label: brandColorName(l10n, color),
                  onTap: () => controller.setColor(color),
                ),
            ],
          ),
          SettingsSectionTitle(l10n.textSize),
          Row(
            children: [
              Text(
                'A',
                style: TextStyle(fontSize: 14, color: colors.foreground),
              ),
              const SizedBox(width: Space.lg),
              Expanded(
                child: FSlider(
                  control: .liftedDiscrete(
                    value: FSliderValue(max: settings.textSize.index / last),
                    onChange: (v) => controller.setTextSize(
                      TextSize.values[(v.max * last).round()],
                    ),
                  ),
                  marks: [
                    for (final size in TextSize.values)
                      FSliderMark(value: size.index / last, tick: true),
                  ],
                  tooltipBuilder: (_, v) => Text(
                    textSizeName(l10n, TextSize.values[(v * last).round()]),
                  ),
                  semanticValueFormatterCallback: (v) =>
                      textSizeName(l10n, TextSize.values[(v * last).round()]),
                ),
              ),
              const SizedBox(width: Space.lg),
              Text(
                'A',
                style: TextStyle(fontSize: 24, color: colors.foreground),
              ),
            ],
          ),
          Center(
            child: AnimatedSwitcher(
              duration: Motion.quick,
              child: Text(
                textSizeName(l10n, settings.textSize),
                key: ValueKey(settings.textSize),
                style: context.theme.typography.body.sm.copyWith(
                  color: colors.mutedForeground,
                  fontWeight: FontWeights.medium,
                ),
              ),
            ),
          ),
          SettingsSectionTitle(l10n.uiStyle),
          Row(
            children: [
              for (final style in UiStyle.values) ...[
                if (style != UiStyle.values.first)
                  const SizedBox(width: Space.lg),
                Expanded(
                  child: _StyleOption(
                    style: style,
                    label: uiStyleName(l10n, style),
                    selected: style == settings.uiStyle,
                    onTap: () => controller.setUiStyle(style),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

/// A sample of real UI parts, drawn with the current theme. The app animates
/// theme changes, so the preview morphs when a setting changes.
class _Preview extends StatelessWidget {
  const _Preview();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = context.theme;
    final colors = theme.colors;
    final type = theme.typography.body;

    return FCard(
      child: Padding(
        padding: const EdgeInsets.all(Space.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l10n.preview,
              style: type.sm.copyWith(
                color: colors.mutedForeground,
                fontWeight: FontWeights.medium,
              ),
            ),
            const SizedBox(height: Space.lg),
            TicketCard(
              color: colors.background,
              stub: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '14',
                    style: type.xl.copyWith(
                      fontWeight: FontWeights.heavy,
                      color: colors.foreground,
                    ),
                  ),
                  Text(
                    'JUL',
                    style: type.xs.copyWith(
                      color: colors.mutedForeground,
                      fontWeight: FontWeights.medium,
                    ),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Sarajevo Film Festival',
                    style: type.md.copyWith(
                      fontWeight: FontWeights.bold,
                      color: colors.foreground,
                    ),
                  ),
                  const SizedBox(height: Space.xs),
                  Text(
                    l10n.previewTickets,
                    style: type.sm.copyWith(color: colors.mutedForeground),
                  ),
                  const SizedBox(height: Space.md),
                  Text(
                    '89,00 KM',
                    style: type.md.copyWith(
                      color: colors.foreground,
                      fontWeight: FontWeights.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: Space.lg),
            // Wraps instead of overflowing with large text sizes.
            Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: Space.lg,
              runSpacing: Space.md,
              children: [
                FBadge(
                  variant: .secondary,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(FLucideIcons.music, size: IconSizes.xs),
                      const SizedBox(width: Space.xs),
                      Text(l10n.catConcerts),
                    ],
                  ),
                ),
                FButton(
                  mainAxisSize: MainAxisSize.min,
                  onPress: () {},
                  child: Text(
                    l10n.previewButton,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ColorDot extends StatelessWidget {
  const _ColorDot({
    required this.color,
    required this.selected,
    required this.label,
    required this.onTap,
  });

  final BrandColor color;
  final bool selected;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final brightness = context.theme.colors.brightness;
    final scheme = colorSchemeFor(color, brightness);
    final fill = scheme.primary;

    return MergeSemantics(
      child: FTooltip(
        tipBuilder: (context, _) => Text(label),
        child: FTappable(
          semanticsLabel: label,
          selected: selected,
          onPress: onTap,
          child: AnimatedContainer(
            duration: Motion.normal,
            // No overshooting curve here: padding must not go negative.
            curve: Motion.enter,
            width: 48,
            height: 48,
            padding: EdgeInsets.all(selected ? 4 : 0),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: selected ? fill : Colors.transparent,
                width: 2.5,
              ),
            ),
            child: DecoratedBox(
              decoration: BoxDecoration(color: fill, shape: BoxShape.circle),
              child: AnimatedScale(
                scale: selected ? 1 : 0,
                duration: Motion.normal,
                curve: Motion.pop,
                child: Icon(
                  FLucideIcons.check,
                  size: IconSizes.lg,
                  color: scheme.onPrimary,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _StyleOption extends StatelessWidget {
  const _StyleOption({
    required this.style,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final UiStyle style;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final colors = theme.colors;
    // Miniature: card and button at half size.
    final card = style.cardRadius / 2;
    final button = style == UiStyle.rounded ? 12.0 : style.controlRadius / 2;

    return FTappable(
      selected: selected,
      onPress: onTap,
      child: AnimatedContainer(
        duration: Motion.normal,
        curve: Motion.enter,
        padding: const EdgeInsets.all(Space.lg),
        decoration: BoxDecoration(
          color: selected ? colors.secondary : colors.card,
          borderRadius: theme.style.borderRadius.lg,
          border: Border.all(
            color: selected ? colors.primary : colors.border,
            width: 1.5,
          ),
        ),
        child: Column(
          children: [
            Container(
              height: 44,
              decoration: BoxDecoration(
                color: colors.background,
                borderRadius: BorderRadius.circular(card),
                border: Border.all(color: colors.border),
              ),
              alignment: Alignment.bottomRight,
              padding: const EdgeInsets.all(Space.sm),
              child: Container(
                width: 32,
                height: 12,
                decoration: BoxDecoration(
                  color: colors.primary,
                  borderRadius: BorderRadius.circular(button),
                ),
              ),
            ),
            const SizedBox(height: Space.md),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.typography.body.sm.copyWith(
                fontWeight: selected
                    ? FontWeights.semibold
                    : FontWeights.medium,
                color: colors.foreground,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
