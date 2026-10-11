import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/app_localizations.dart';
import '../ui/app_style.dart';
import '../ui/ticket.dart';
import 'settings_controller.dart';
import 'settings_widgets.dart';
import '../ui/site_scaffold.dart';

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

    return SiteScaffold(
      title: l10n.appearance,
      maxWidth: SiteWidth.form,
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          const _Preview(),
          SettingsSectionTitle(l10n.themeModeLabel),
          SegmentedButton<ThemeMode>(
            segments: [
              for (final (mode, icon) in [
                (ThemeMode.system, Icons.brightness_auto_outlined),
                (ThemeMode.light, Icons.light_mode_outlined),
                (ThemeMode.dark, Icons.dark_mode_outlined),
              ])
                ButtonSegment(
                  value: mode,
                  icon: Icon(icon),
                  label: Text(themeModeName(l10n, mode)),
                ),
            ],
            selected: {settings.themeMode},
            onSelectionChanged: (s) => controller.setThemeMode(s.first),
          ),
          SettingsSectionTitle(l10n.themeColor),
          Wrap(
            spacing: 12,
            runSpacing: 12,
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
              const Text('A', style: TextStyle(fontSize: 14)),
              Expanded(
                child: Slider(
                  value: settings.textSize.index.toDouble(),
                  max: TextSize.values.length - 1,
                  divisions: TextSize.values.length - 1,
                  label: textSizeName(l10n, settings.textSize),
                  onChanged: (v) =>
                      controller.setTextSize(TextSize.values[v.round()]),
                ),
              ),
              const Text('A', style: TextStyle(fontSize: 24)),
            ],
          ),
          Center(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: Text(
                textSizeName(l10n, settings.textSize),
                key: ValueKey(settings.textSize),
                style: Theme.of(context).textTheme.labelLarge,
              ),
            ),
          ),
          SettingsSectionTitle(l10n.uiStyle),
          Row(
            children: [
              for (final style in UiStyle.values) ...[
                if (style != UiStyle.values.first) const SizedBox(width: 12),
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
    final theme = Theme.of(context);

    return Card.filled(
      color: theme.colorScheme.surfaceContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l10n.preview,
              style: theme.textTheme.labelLarge?.copyWith(
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 12),
            TicketCard(
              color: theme.colorScheme.surface,
              stub: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '14',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  Text('JUL', style: theme.textTheme.labelMedium),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Sarajevo Film Festival',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    l10n.previewTickets,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '89,00 KM',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            // Wraps instead of overflowing with large text sizes.
            Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 12,
              runSpacing: 8,
              children: [
                ActionChip(
                  avatar: const Icon(Icons.music_note_outlined, size: 18),
                  label: Text(l10n.catConcerts),
                  onPressed: () {},
                ),
                FilledButton(onPressed: () {}, child: Text(l10n.previewButton)),
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
    final theme = Theme.of(context);
    final fill = colorSchemeFor(color, theme.brightness).primary;

    return Semantics(
      label: label,
      selected: selected,
      button: true,
      child: Tooltip(
        message: label,
        child: GestureDetector(
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            // No overshooting curve here: padding must not go negative.
            curve: Curves.easeOutCubic,
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
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeOutBack,
                child: Icon(
                  Icons.check,
                  size: 20,
                  color: colorSchemeFor(color, theme.brightness).onPrimary,
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
    final colors = Theme.of(context).colorScheme;
    final current = AppStyle.of(context);
    // Miniature: card and button at half size.
    final card = style.cardRadius / 2;
    final button = style == UiStyle.rounded ? 12.0 : style.controlRadius / 2;

    return Semantics(
      selected: selected,
      button: true,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: selected
                ? colors.primaryContainer
                : colors.surfaceContainerHighest.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(current.controlRadius + 4),
            border: Border.all(
              color: selected ? colors.primary : Colors.transparent,
              width: 2,
            ),
          ),
          child: Column(
            children: [
              Container(
                height: 44,
                decoration: BoxDecoration(
                  color: colors.surface,
                  borderRadius: BorderRadius.circular(card),
                ),
                alignment: Alignment.bottomRight,
                padding: const EdgeInsets.all(6),
                child: Container(
                  width: 32,
                  height: 12,
                  decoration: BoxDecoration(
                    color: colors.primary,
                    borderRadius: BorderRadius.circular(button),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                  color: selected ? colors.onPrimaryContainer : null,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
