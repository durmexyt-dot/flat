import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';

import '../../l10n/app_localizations.dart';
import '../data/models.dart';
import '../data/repositories.dart';
import '../ui/format.dart';
import '../ui/hero_tags.dart';
import '../ui/ticket.dart';
import 'labels.dart';
import '../ui/tokens.dart';
import '../ui/app_link.dart';

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
    final theme = context.theme;
    final colors = theme.colors;
    final type = theme.typography;
    final (day, month) = formatStubDate(context, event.date);
    final time = TimeOfDay.fromDateTime(event.date).format(context);

    return Hero(
      tag: heroTag,
      flightShuttleBuilder: _ticketShuttle,
      child: TicketCard(
        onTap: onTap,
        stub: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              day,
              style: type.display.xl.copyWith(
                fontWeight: FontWeights.heavy,
                color: colors.foreground,
                height: 1,
              ),
            ),
            Text(
              month,
              style: type.body.xs.copyWith(
                fontWeight: FontWeights.semibold,
                color: colors.mutedForeground,
                letterSpacing: 0.8,
              ),
            ),
            const SizedBox(height: Space.xs),
            Text(
              time,
              style: type.body.xs.copyWith(color: colors.mutedForeground),
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
                  color: colors.foreground,
                ),
                const SizedBox(width: Space.sm),
                Expanded(
                  child: Text(
                    event.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: type.body.md.copyWith(
                      fontWeight: FontWeights.semibold,
                      color: colors.foreground,
                    ),
                  ),
                ),
                if (trailing != null) ...[
                  const SizedBox(width: Space.md),
                  trailing!,
                ],
              ],
            ),
            const SizedBox(height: Space.xs),
            Text(
              [event.venue, event.city].where((s) => s.isNotEmpty).join(' · '),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: type.body.sm.copyWith(color: colors.mutedForeground),
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

/// Prices as buyers see them: the final price, service fee included.
extension BuyerPrice on Listing {
  /// What a buyer pays for one ticket, service fee included.
  int get buyerPriceMinor => priceMinor + fees.buyerFee(priceMinor);
}

/// [EventTicket] for a listing, as buyers or the seller see it. Buyers see
/// the final price per ticket, service fee included; the seller sees the
/// price they listed.
class ListingTicket extends ConsumerWidget {
  const ListingTicket({
    super.key,
    required this.listing,
    this.showStatus = false,
    this.own = false,
    this.onTap,
  });

  final Listing listing;
  final bool showStatus;

  /// The viewer's own listing (in the market): marked as such.
  final bool own;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final colors = context.theme.colors;
    final type = context.theme.typography;
    final seats = seatText(l10n, listing.section, listing.row, listing.seats);
    final seller = own || listing.sellerId == ref.watch(currentUidProvider);

    return EventTicket(
      heroTag: HeroTags.listing(listing.id),
      event: listing.event,
      onTap: onTap,
      trailing: showStatus
          ? StatusChip(
              label: listingStatusName(l10n, listing.status),
              tone: listingTone(listing.status),
            )
          : own
          ? FBadge(
              variant: FBadgeVariant.outline,
              child: Text(l10n.yourListing),
            )
          : null,
      lines: [
        const SizedBox(height: Space.md),
        Wrap(
          spacing: Space.md,
          runSpacing: Space.xs,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text(
              formatMoney(
                context,
                seller ? listing.priceMinor : listing.buyerPriceMinor,
                listing.currency,
              ),
              style: type.body.lg.copyWith(
                color: colors.foreground,
                fontWeight: FontWeights.bold,
              ),
            ),
            Text(
              l10n.ticketsLeft('${listing.available}', '${listing.quantity}'),
              style: type.body.xs.copyWith(color: colors.mutedForeground),
            ),
          ],
        ),
        if (!seller && listing.fees.buyerPercent > 0)
          Text(
            l10n.priceInclFee('${listing.fees.buyerPercent}'),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: type.body.xs.copyWith(color: colors.mutedForeground),
          ),
        if (seats.isNotEmpty)
          Text(
            seats,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: type.body.xs.copyWith(color: colors.mutedForeground),
          ),
      ],
    );
  }
}

/// While flying, the ticket keeps its natural height and is clipped to the
/// flight's rect, instead of squeezing (and overflowing) its text.
Widget _ticketShuttle(
  BuildContext flightContext,
  Animation<double> animation,
  HeroFlightDirection direction,
  BuildContext fromContext,
  BuildContext toContext,
) {
  final hero =
      (direction == HeroFlightDirection.push ? toContext : fromContext).widget
          as Hero;
  return ClipRect(
    child: OverflowBox(
      alignment: Alignment.topCenter,
      minHeight: 0,
      maxHeight: double.infinity,
      child: hero.child,
    ),
  );
}

/// One offer on an event's page: the event is already known there, so the
/// ticket shows what tells offers apart: price, seats, kind, how many.
class OfferTicket extends ConsumerWidget {
  const OfferTicket({super.key, required this.listing, this.onTap});

  final Listing listing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = context.theme;
    final colors = theme.colors;
    final type = theme.typography;
    final own = listing.sellerId == ref.watch(currentUidProvider);
    final seats = seatText(l10n, listing.section, listing.row, listing.seats);

    return AppLink(
      path: '/listing/${listing.id}',
      onTap: onTap ?? () {},
      builder: (tap) => Hero(
        tag: HeroTags.listing(listing.id),
        flightShuttleBuilder: _ticketShuttle,
        child: TicketCard(
          onTap: tap,
          stub: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${listing.available}',
                style: type.display.xl.copyWith(
                  fontWeight: FontWeights.heavy,
                  color: colors.foreground,
                  height: 1,
                ),
              ),
              const SizedBox(height: Space.xxs),
              Text(
                l10n.offerAvailable,
                textAlign: TextAlign.center,
                style: theme.mutedSmallText,
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
                  Expanded(
                    child: Text(
                      formatMoney(
                        context,
                        own ? listing.priceMinor : listing.buyerPriceMinor,
                        listing.currency,
                      ),
                      style: type.body.xl.copyWith(
                        fontWeight: FontWeights.bold,
                        color: colors.foreground,
                        height: 1.1,
                      ),
                    ),
                  ),
                  if (own)
                    FBadge(
                      variant: FBadgeVariant.outline,
                      child: Text(l10n.yourListing),
                    ),
                ],
              ),
              Text(
                own
                    ? l10n.offerPerTicket
                    : '${l10n.offerPerTicket} · '
                          '${l10n.priceInclFee('${listing.fees.buyerPercent}')}',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.mutedSmallText,
              ),
              const SizedBox(height: Space.md),
              Text(
                seats.isEmpty ? l10n.offerNoSeats : seats,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.titleText,
              ),
              const SizedBox(height: Space.xxs),
              Row(
                children: [
                  Icon(
                    FLucideIcons.ticket,
                    size: IconSizes.xs,
                    color: colors.mutedForeground,
                  ),
                  const SizedBox(width: Space.sm),
                  Text(
                    ticketTypeName(l10n, listing.ticketType),
                    style: theme.mutedText,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
