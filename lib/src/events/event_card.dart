import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';

import '../../l10n/app_localizations.dart';
import '../data/events_repository.dart';
import '../data/models.dart';
import '../data/repositories.dart';
import '../ui/app_style.dart';
import '../ui/format.dart';
import '../ui/hero_tags.dart';
import '../ui/skeleton.dart';
import 'event_image.dart';
import 'event_status_badge.dart';

/// An upcoming event on the home page: picture, name, when, where and the
/// cheapest offer. The picture flies into the event page.
class EventCard extends ConsumerWidget {
  const EventCard({super.key, required this.event, this.onTap});

  final Event event;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = context.theme;
    final colors = theme.colors;
    final type = theme.typography;
    final radius = AppStyle.of(context).cardRadius;
    final offer = ref.watch(eventOffersProvider)[event.id];
    final from = ref.watch(eventFromPriceProvider)[event.id];
    final info = event.info;

    return FTappable(
      onPress: onTap,
      semanticsLabel: info.name,
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: colors.card,
          border: Border.all(color: colors.border),
          borderRadius: BorderRadius.circular(radius),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              children: [
                EventImage(event: event, heroTag: HeroTags.event(event.id)),
                // Only unconfirmed events are marked: most are confirmed,
                // and a badge on every card would be noise.
                if (!event.confirmed)
                  PositionedDirectional(
                    start: 8,
                    top: 8,
                    child: EventStatusBadge(event, onImage: true),
                  ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    info.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: type.body.lg.copyWith(
                      fontWeight: FontWeight.w600,
                      color: colors.foreground,
                    ),
                  ),
                  const SizedBox(height: 6),
                  EventMetaLine(
                    icon: FLucideIcons.calendar,
                    text: formatDateTime(context, info.date),
                  ),
                  const SizedBox(height: 2),
                  EventMetaLine(
                    icon: FLucideIcons.mapPin,
                    text: placeText(info),
                  ),
                  const SizedBox(height: 10),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 250),
                    child: Text(
                      offer == null || from == null
                          ? l10n.eventsNoOffers
                          : l10n.eventsOffer(
                              formatMoney(context, from.minor, from.currency),
                              offer.tickets,
                            ),
                      key: ValueKey('${from?.minor}-${offer?.tickets}'),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: offer == null || from == null
                          ? type.body.sm.copyWith(color: colors.mutedForeground)
                          : type.body.sm.copyWith(
                              fontWeight: FontWeight.w600,
                              color: colors.foreground,
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Per event: the cheapest ticket on sale as buyers pay it, service fee
/// included (prices shown to buyers are final prices). Events without
/// tickets have no entry.
final eventFromPriceProvider =
    Provider<Map<String, ({int minor, String currency})>>((ref) {
      final listings = ref.watch(activeListingsProvider).value ?? const [];
      final prices = <String, ({int minor, String currency})>{};
      for (final l in listings) {
        if (l.eventId.isEmpty || l.available <= 0) continue;
        final minor = l.priceMinor + l.fees.buyerFee(l.priceMinor);
        final current = prices[l.eventId];
        if (current == null || minor < current.minor) {
          prices[l.eventId] = (minor: minor, currency: l.currency);
        }
      }
      return prices;
    });

/// "Venue · City".
String placeText(EventInfo info) =>
    [info.venue, info.city].where((s) => s.isNotEmpty).join(' · ');

/// A small icon and one line of muted text.
class EventMetaLine extends StatelessWidget {
  const EventMetaLine({super.key, required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;
    return Row(
      children: [
        Icon(icon, size: 14, color: colors.mutedForeground),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: context.theme.typography.body.sm.copyWith(
              color: colors.mutedForeground,
            ),
          ),
        ),
      ],
    );
  }
}

/// Placeholder for an [EventCard] while events load. Use inside a [Shimmer].
class SkeletonEventCard extends StatelessWidget {
  const SkeletonEventCard({super.key});

  @override
  Widget build(BuildContext context) {
    final radius = AppStyle.of(context).cardRadius;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        AspectRatio(
          aspectRatio: 16 / 9,
          child: SkeletonBox(height: double.infinity, radius: radius),
        ),
        const SizedBox(height: 12),
        const SkeletonBox(width: 200, height: 18),
        const SizedBox(height: 8),
        const SkeletonBox(width: 140, height: 12),
        const SizedBox(height: 6),
        const SkeletonBox(width: 160, height: 12),
        const SizedBox(height: 10),
        const SkeletonBox(width: 120, height: 14),
      ],
    );
  }
}
