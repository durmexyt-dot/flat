import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../data/models.dart';
import '../ui/format.dart';
import '../ui/hero_tags.dart';
import '../ui/ticket.dart';
import 'labels.dart';

/// Ticket-shaped card for an event: name, place, date stub. Flies between
/// lists and detail pages as a shared element.
class EventTicket extends StatelessWidget {
  const EventTicket({
    super.key,
    required this.heroTag,
    required this.event,
    required this.lines,
    this.trailing,
    this.onTap,
  });

  final String heroTag;
  final EventInfo event;

  /// Extra lines under the place, e.g. seats or price.
  final List<Widget> lines;

  /// Shown at the top right, e.g. a status chip.
  final Widget? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final (day, month) = formatStubDate(context, event.date);
    final time = TimeOfDay.fromDateTime(event.date).format(context);

    return Hero(
      tag: heroTag,
      child: TicketCard(
        onTap: onTap,
        stub: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              day,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w800,
                color: theme.colorScheme.primary,
                height: 1,
              ),
            ),
            Text(month, style: theme.textTheme.labelMedium),
            const SizedBox(height: 4),
            Text(
              time,
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  categoryIcon(event.category),
                  size: 18,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    event.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                if (trailing != null) ...[const SizedBox(width: 8), trailing!],
              ],
            ),
            const SizedBox(height: 4),
            Text(
              [event.venue, event.city].where((s) => s.isNotEmpty).join(' · '),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            ...lines,
          ],
        ),
      ),
    );
  }
}

String seatText(
  AppLocalizations l10n,
  String section,
  String row,
  String seats,
) => [
  if (section.isNotEmpty) '${l10n.section} $section',
  if (row.isNotEmpty) '${l10n.row} $row',
  if (seats.isNotEmpty) seats,
].join(' · ');

/// [EventTicket] for a listing, as buyers or the seller see it.
class ListingTicket extends StatelessWidget {
  const ListingTicket({
    super.key,
    required this.listing,
    this.showStatus = false,
    this.onTap,
  });

  final Listing listing;
  final bool showStatus;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final seats = seatText(l10n, listing.section, listing.row, listing.seats);

    return EventTicket(
      heroTag: HeroTags.listing(listing.id),
      event: listing.event,
      onTap: onTap,
      trailing: showStatus
          ? StatusChip(
              label: listingStatusName(l10n, listing.status),
              tone: listingTone(listing.status),
            )
          : null,
      lines: [
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 4,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text(
              formatMoney(context, listing.priceMinor, listing.currency),
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w800,
              ),
            ),
            Text(
              l10n.ticketsLeft('${listing.available}', '${listing.quantity}'),
              style: theme.textTheme.bodySmall,
            ),
          ],
        ),
        if (seats.isNotEmpty)
          Text(
            seats,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
      ],
    );
  }
}
