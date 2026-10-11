import 'package:flutter/material.dart';
import 'package:forui/forui.dart';

import '../../l10n/app_localizations.dart';
import '../data/models.dart';
import '../market/labels.dart';
import 'genres.dart';

/// The name of an event status.
String eventStatusName(AppLocalizations l10n, EventStatus s) => switch (s) {
  EventStatus.confirmed => l10n.eventStatusConfirmed,
  EventStatus.pending => l10n.eventStatusPending,
  EventStatus.hidden => l10n.eventStatusHidden,
};

IconData eventStatusIcon(EventStatus s) => switch (s) {
  EventStatus.confirmed => FLucideIcons.badgeCheck,
  EventStatus.pending => FLucideIcons.clock,
  EventStatus.hidden => FLucideIcons.eyeOff,
};

/// Whether the team checked an event: "Potvrđen" (subtle), "Nije potvrđen"
/// (muted outline, a note rather than a warning) or "Skriven" (team only).
class EventStatusBadge extends StatelessWidget {
  const EventStatusBadge(this.event, {super.key, this.onImage = false});

  final Event event;

  /// Over a picture: always on a solid background so it stays readable.
  final bool onImage;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.theme.colors;
    final status = event.status;
    final muted = !onImage && status != EventStatus.confirmed;
    final color = muted ? colors.mutedForeground : null;
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 250),
      child: FBadge(
        key: ValueKey(status),
        variant: onImage || status == EventStatus.confirmed
            ? FBadgeVariant.secondary
            : FBadgeVariant.outline,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(eventStatusIcon(status), size: 13, color: color),
            const SizedBox(width: 4),
            Text(
              eventStatusName(l10n, status),
              style: color == null ? null : TextStyle(color: color),
            ),
          ],
        ),
      ),
    );
  }
}

/// The event type with its icon, and the subcategory when there is one.
class EventCategoryBadge extends StatelessWidget {
  const EventCategoryBadge(this.event, {super.key});

  final Event event;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final category = event.info.category;
    return FBadge(
      variant: FBadgeVariant.secondary,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(categoryIcon(category), size: 14),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              [
                categoryName(l10n, category),
                if (event.genre.isNotEmpty) genreName(l10n, event.genre),
              ].join(' · '),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
