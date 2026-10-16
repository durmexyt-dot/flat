import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';

import '../../l10n/app_localizations.dart';
import '../data/models.dart';
import '../data/seat_map_repository.dart';
import '../ui/app_style.dart';
import '../ui/tokens.dart';

/// Draws a seat map: the floor plan picture (or a blank area), the stage
/// and the sections. Sections with offers ([counts], by section name) are
/// tinted in the brand color and can be tapped; the [selected] one is
/// filled.
class SeatMapView extends ConsumerWidget {
  const SeatMapView({
    super.key,
    required this.map,
    this.counts = const {},
    this.selected,
    this.onTapSection,
    this.allActive = false,
    this.overlay,
    this.picture,
  });

  final SeatMap map;

  /// Offers per section, keyed by [searchKey] of the section name.
  final Map<String, int> counts;
  final String? selected;
  final ValueChanged<SeatSection>? onTapSection;

  /// Every section looks tappable, e.g. while drawing the map.
  final bool allActive;

  /// Drawn on top, at the map's size, e.g. the editor's gestures.
  final Widget Function(Size size)? overlay;

  /// A picture not saved yet (the editor's preview) instead of the stored
  /// one.
  final Uint8List? picture;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final colors = context.theme.colors;
    final radius = BorderRadius.circular(AppStyle.of(context).cardRadius);
    final picture =
        this.picture ??
        (map.hasImage
            ? ref.watch(seatMapImageProvider((map.id, map.imageVersion))).value
            : null);

    return AspectRatio(
      aspectRatio: map.aspectRatio,
      child: ClipRRect(
        borderRadius: radius,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: colors.muted,
            border: Border.all(color: colors.border),
            borderRadius: radius,
          ),
          child: LayoutBuilder(
            builder: (context, box) {
              final size = box.biggest;
              Rect place(MapRect r) => Rect.fromLTWH(
                r.x * size.width,
                r.y * size.height,
                r.w * size.width,
                r.h * size.height,
              );
              return Stack(
                children: [
                  if (picture != null)
                    Positioned.fill(
                      child: Image.memory(
                        picture,
                        fit: BoxFit.fill,
                        gaplessPlayback: true,
                      ),
                    ),
                  if (map.stage case final stage?)
                    Positioned.fromRect(
                      rect: place(stage),
                      child: _Area(
                        label: l10n.seatMapStage,
                        fill: colors.secondary,
                        border: colors.border,
                        text: colors.secondaryForeground,
                      ),
                    ),
                  for (final s in map.sections)
                    Positioned.fromRect(
                      rect: place(s.rect),
                      child: _SectionArea(
                        section: s,
                        count: counts[searchKey(s.name)] ?? 0,
                        selected: selected != null && s.matches(selected!),
                        active: allActive,
                        onTap: onTapSection == null
                            ? null
                            : () => onTapSection!(s),
                      ),
                    ),
                  if (overlay != null) Positioned.fill(child: overlay!(size)),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _SectionArea extends StatelessWidget {
  const _SectionArea({
    required this.section,
    required this.count,
    required this.selected,
    required this.active,
    required this.onTap,
  });

  final SeatSection section;
  final int count;
  final bool selected;
  final bool active;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.theme.colors;
    final offers = count > 0 || active;
    final (fill, border, text) = selected
        ? (colors.primary, colors.primary, colors.primaryForeground)
        : offers
        ? (
            colors.primary.withValues(alpha: Opacities.tint),
            colors.primary,
            colors.foreground,
          )
        : (
            colors.background.withValues(alpha: Opacities.veil),
            colors.border,
            colors.mutedForeground,
          );
    final area = _Area(
      label: section.name,
      detail: active || count == 0 ? null : '$count',
      fill: fill,
      border: border,
      text: text,
    );
    return Semantics(
      selected: selected,
      child: FTappable(
        semanticsLabel: l10n.seatMapSectionOffers(section.name, count),
        onPress: offers ? onTap : null,
        child: AnimatedContainer(
          duration: Motion.fast,
          curve: Motion.ease,
          child: area,
        ),
      ),
    );
  }
}

/// A labeled rectangle on the map.
class _Area extends StatelessWidget {
  const _Area({
    required this.label,
    required this.fill,
    required this.border,
    required this.text,
    this.detail,
  });

  final String label;
  final String? detail;
  final Color fill;
  final Color border;
  final Color text;

  @override
  Widget build(BuildContext context) {
    final type = context.theme.typography;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: fill,
        border: Border.all(color: border),
        borderRadius: BorderRadius.circular(Radii.mapArea),
      ),
      child: Padding(
        padding: const EdgeInsets.all(Space.xxs),
        child: Center(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  textAlign: TextAlign.center,
                  style: type.body.xs.copyWith(
                    color: text,
                    fontWeight: FontWeights.semibold,
                  ),
                ),
                if (detail != null)
                  Text(detail!, style: type.body.xs.copyWith(color: text)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
