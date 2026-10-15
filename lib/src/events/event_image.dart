import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';

import '../data/events_repository.dart';
import '../data/models.dart';
import '../market/labels.dart';
import '../ui/skeleton.dart';
import '../ui/tokens.dart';

/// An event's 16:9 picture: a shimmer while it loads, a tile with the
/// event's name when there is none.
class EventImage extends ConsumerWidget {
  const EventImage({
    super.key,
    required this.event,
    this.borderRadius = BorderRadius.zero,
    this.heroTag,
    this.iconSize = 36,
  });

  final Event event;
  final BorderRadius borderRadius;

  /// Lets the picture fly between screens.
  final String? heroTag;
  final double iconSize;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<Uint8List?> image = event.hasImage
        ? ref.watch(eventImageProvider((event.id, event.imageVersion)))
        : const AsyncData(null);
    final bytes = image.value;
    final Widget child = bytes != null
        ? Image.memory(
            bytes,
            key: ValueKey(event.imageVersion),
            fit: BoxFit.cover,
            gaplessPlayback: true,
          )
        : image.isLoading && !image.hasError
        ? const Shimmer(
            key: ValueKey('loading'),
            child: SkeletonBox(height: double.infinity, radius: 0),
          )
        : EventImagePlaceholder(
            key: const ValueKey('placeholder'),
            category: event.info.category,
            name: event.info.name,
            iconSize: iconSize,
          );

    final picture = AspectRatio(
      aspectRatio: 16 / 9,
      child: ClipRRect(
        borderRadius: borderRadius,
        child: AnimatedSwitcher(
          duration: Motion.slow,
          layoutBuilder: (current, previous) =>
              Stack(fit: StackFit.expand, children: [...previous, ?current]),
          child: child,
        ),
      ),
    );
    if (heroTag == null) return picture;
    return Hero(tag: heroTag!, child: picture);
  }
}

/// Stand-in for a missing picture: the event's name on a quiet tile, so a
/// list of events without pictures still reads as designed, not broken.
class EventImagePlaceholder extends StatelessWidget {
  const EventImagePlaceholder({
    super.key,
    required this.category,
    this.name = '',
    this.iconSize = 36,
  });

  final EventCategory category;
  final String name;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final colors = theme.colors;
    if (name.isEmpty) {
      return ColoredBox(
        color: colors.muted,
        child: Center(
          child: Icon(
            categoryIcon(category),
            size: iconSize,
            color: colors.mutedForeground,
          ),
        ),
      );
    }
    return ColoredBox(
      color: colors.secondary,
      child: LayoutBuilder(
        builder: (context, box) {
          // Scales with the tile: small on cards, large on the event page.
          final pad = (box.maxWidth * 0.06).clamp(Space.md, Space.x5l);
          final fontSize = (box.maxWidth * 0.075).clamp(14.0, 40.0);
          // A stack, not a column: in very small tiles the name is cut
          // off instead of overflowing.
          return Stack(
            children: [
              Positioned(
                top: pad,
                left: pad,
                child: Icon(
                  categoryIcon(category),
                  size: fontSize * 0.9,
                  color: colors.mutedForeground,
                ),
              ),
              Positioned(
                left: pad,
                right: pad,
                bottom: pad,
                // Decorative: the card or page names the event already, so
                // screen readers skip it (and it isn't a second Text).
                child: ExcludeSemantics(
                  child: RichText(
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    textScaler: MediaQuery.textScalerOf(context),
                    text: TextSpan(
                      text: name,
                      style: theme.typography.body.md.copyWith(
                        fontSize: fontSize,
                        height: 1.15,
                        fontWeight: FontWeights.heavy,
                        color: colors.secondaryForeground,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
