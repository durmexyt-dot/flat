import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';

import '../../l10n/app_localizations.dart';
import '../auth/auth_repository.dart';
import '../data/events_repository.dart';
import '../data/models.dart';
import '../data/repositories.dart';
import '../market/labels.dart';
import '../market/listing_ticket.dart';
import '../settings/settings_widgets.dart';
import '../ui/app_style.dart';
import '../ui/async_view.dart';
import '../ui/format.dart';
import '../ui/hero_tags.dart';
import '../ui/responsive_grid.dart';
import '../ui/site_scaffold.dart';
import '../ui/skeleton.dart';
import '../ui/snack.dart';
import 'event_image.dart';

/// One event: picture, details, selling and all offers, cheapest first.
class EventPage extends ConsumerWidget {
  const EventPage({super.key, required this.id, this.initial});

  final String id;

  /// The event as shown on the card, so the picture can fly in at once.
  final Event? initial;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final live = ref.watch(eventProvider(id));
    final event = live.hasValue ? live.value : initial;
    final wide = isWideLayout(context);

    final Widget body;
    if (event == null || event.hidden) {
      body = AsyncView<Event?>(
        value: live,
        onRetry: () => ref.invalidate(eventProvider(id)),
        loading: const SkeletonTicketList(count: 2),
        data: (_) => Center(
          child: SingleChildScrollView(
            child: EmptyState(
              icon: FLucideIcons.calendarX,
              title: l10n.eventsNotFound,
              message: l10n.eventsNotFoundInfo,
            ),
          ),
        ),
      );
    } else {
      final radius = BorderRadius.circular(AppStyle.of(context).cardRadius);
      final picture = EventImage(
        event: event,
        heroTag: HeroTags.event(event.id),
        borderRadius: radius,
        iconSize: 56,
      );
      body = ListView(
        padding: EdgeInsets.fromLTRB(16, wide ? 8 : 4, 16, 32),
        children: [
          if (wide)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 7, child: picture),
                const SizedBox(width: 32),
                Expanded(flex: 5, child: _Details(event: event)),
              ],
            )
          else ...[
            picture,
            const SizedBox(height: 16),
            _Details(event: event),
          ],
          SettingsSectionTitle(l10n.eventsOffers),
          _Offers(event: event, columns: wide ? 2 : 1),
        ],
      );
    }

    return SiteScaffold(
      title: event?.info.name ?? l10n.event,
      maxWidth: SiteWidth.wide,
      body: body,
    );
  }
}

class _Details extends ConsumerWidget {
  const _Details({required this.event});

  final Event event;

  void _sell(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    if (ref.read(currentUidProvider) != null) {
      context.push('/sell?event=${event.id}');
      return;
    }
    showSnack(
      l10n.guestSignInPrompt,
      actionLabel: l10n.loginButton,
      onAction: () => ref.read(guestModeProvider.notifier).exit(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = context.theme;
    final info = event.info;
    final upcoming = event.isUpcoming;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        FBadge(
          variant: FBadgeVariant.secondary,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(categoryIcon(info.category), size: 14),
              const SizedBox(width: 4),
              Text(categoryName(l10n, info.category)),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          info.name,
          style: theme.typography.display.lg.copyWith(
            fontWeight: FontWeight.w700,
            color: theme.colors.foreground,
            height: 1.15,
          ),
        ),
        const SizedBox(height: 12),
        _Fact(
          icon: FLucideIcons.calendar,
          text: formatDateTime(context, info.date),
        ),
        _Fact(icon: FLucideIcons.mapPin, text: info.venue),
        _Fact(icon: FLucideIcons.building2, text: info.city),
        const SizedBox(height: 16),
        AnimatedSize(
          duration: const Duration(milliseconds: 250),
          alignment: Alignment.topCenter,
          child: upcoming
              ? FButton(
                  onPress: () => _sell(context, ref),
                  prefix: const Icon(FLucideIcons.tag),
                  child: Text(
                    l10n.eventsSellForEvent,
                    overflow: TextOverflow.ellipsis,
                  ),
                )
              : FAlert(
                  icon: const Icon(FLucideIcons.calendarCheck),
                  title: Text(l10n.eventsIsOver),
                ),
        ),
      ],
    );
  }
}

class _Fact extends StatelessWidget {
  const _Fact({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Icon(icon, size: 16, color: theme.colors.mutedForeground),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: theme.typography.body.md.copyWith(
                color: theme.colors.foreground,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Offers extends ConsumerWidget {
  const _Offers({required this.event, required this.columns});

  final Event event;
  final int columns;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final uid = ref.watch(currentUidProvider);
    return AsyncView<List<Listing>>(
      value: ref.watch(eventListingsProvider(event.id)),
      onRetry: () => ref.invalidate(eventListingsProvider(event.id)),
      loading: Shimmer(
        child: ResponsiveGrid(
          maxColumns: columns,
          children: [
            for (var i = 0; i < columns * 2; i++) const SkeletonTicketTile(),
          ],
        ),
      ),
      data: (listings) {
        if (listings.isEmpty) {
          return EmptyState(
            icon: FLucideIcons.ticket,
            title: l10n.eventsNoOffers,
            message: event.isUpcoming ? l10n.eventsNoOffersInfo : null,
          );
        }
        return ResponsiveGrid(
          maxColumns: columns,
          children: [
            for (final l in listings)
              ListingTicket(
                listing: l,
                own: l.sellerId == uid,
                onTap: () => context.push('/listing/${l.id}', extra: l),
              ),
          ],
        );
      },
    );
  }
}
