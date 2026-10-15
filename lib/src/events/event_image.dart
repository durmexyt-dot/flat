import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';

import '../data/events_repository.dart';
import '../data/models.dart';
import '../market/labels.dart';
import '../ui/skeleton.dart';
import '../ui/tokens.dart';

/// An event's 16:9 picture: a shimmer while it loads, a muted box with the
/// category icon when there is none.
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

/// Neutral stand-in for a missing picture.
class EventImagePlaceholder extends StatelessWidget {
  const EventImagePlaceholder({
    super.key,
    required this.category,
    this.iconSize = 36,
  });

  final EventCategory category;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;
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
}
