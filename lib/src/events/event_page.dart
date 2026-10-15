import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';

import '../../l10n/app_localizations.dart';
import '../admin/admin_repository.dart';
import '../data/events_repository.dart';
import '../data/models.dart';
import '../market/listing_ticket.dart';
import '../ui/segmented.dart';
import '../settings/settings_widgets.dart';
import '../ui/app_dialog.dart';
import '../ui/app_style.dart';
import '../ui/async_view.dart';
import '../ui/format.dart';
import '../ui/hero_tags.dart';
import '../ui/responsive_grid.dart';
import '../ui/site_scaffold.dart';
import '../ui/skeleton.dart';
import '../ui/snack.dart';
import 'event_image.dart';
import 'event_status_badge.dart';
import 'recently_viewed.dart';
import '../ui/tokens.dart';

/// One event: picture, details, selling and all offers, cheapest first.
class EventPage extends ConsumerStatefulWidget {
  const EventPage({super.key, required this.id, this.initial});

  final String id;

  /// The event as shown on the card, so the picture can fly in at once.
  final Event? initial;

  @override
  ConsumerState<EventPage> createState() => _EventPageState();
}

class _EventPageState extends ConsumerState<EventPage> {
  /// The id last remembered as viewed: once per opened event.
  String? _recorded;

  void _remember() {
    if (_recorded == widget.id) return;
    _recorded = widget.id;
    final id = widget.id;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) ref.read(recentlyViewedIdsProvider.notifier).add(id);
    });
  }

  @override
  Widget build(BuildContext context) {
    _remember();
    final id = widget.id;
    final l10n = AppLocalizations.of(context);
    final live = ref.watch(eventProvider(id));
    final event = live.hasValue ? live.value : widget.initial;
    final wide = isWideLayout(context);
    // The team still sees hidden events, e.g. to show them again.
    final isStaff = ref.watch(isStaffProvider);

    final Widget body;
    if (event == null || (event.hidden && !isStaff)) {
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
                const SizedBox(width: Space.x5l),
                Expanded(flex: 5, child: _Details(event: event)),
              ],
            )
          else ...[
            picture,
            const SizedBox(height: Space.xl),
            _Details(event: event),
          ],
          _Offers(event: event, columns: wide ? 2 : 1),
          _SellHint(event: event),
        ],
      );
    }

    // The name is the page's heading; the bar only says what this is.
    return SiteScaffold(
      title: l10n.event,
      maxWidth: SiteWidth.wide,
      body: body,
    );
  }
}

class _Details extends ConsumerWidget {
  const _Details({required this.event});

  final Event event;

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
        Wrap(
          spacing: Space.sm,
          runSpacing: Space.sm,
          children: [EventCategoryBadge(event), EventStatusBadge(event)],
        ),
        const SizedBox(height: Space.md),
        Text(
          info.name,
          style: theme.typography.display.lg.copyWith(
            fontWeight: FontWeights.bold,
            color: theme.colors.foreground,
            height: 1.15,
          ),
        ),
        AnimatedSize(
          duration: Motion.normal,
          alignment: Alignment.topCenter,
          child: event.pending
              ? Padding(
                  padding: const EdgeInsets.only(top: Space.md),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: Space.xxs),
                        child: Icon(
                          FLucideIcons.info,
                          size: IconSizes.xs,
                          color: theme.colors.mutedForeground,
                        ),
                      ),
                      const SizedBox(width: Space.sm),
                      Expanded(
                        child: Text(
                          l10n.eventStatusPendingInfo,
                          style: theme.mutedText,
                        ),
                      ),
                    ],
                  ),
                )
              : const SizedBox(width: double.infinity),
        ),
        if (event.cancelled) ...[
          const SizedBox(height: Space.lg),
          FAlert(
            variant: FAlertVariant.destructive,
            icon: const Icon(FLucideIcons.ban),
            title: Text(l10n.eventPageCancelled),
            subtitle: Text(
              [
                if (event.cancelReason.isNotEmpty) event.cancelReason,
                l10n.eventPageCancelledInfo,
              ].join('\n'),
            ),
          ),
        ] else if (event.postponed) ...[
          const SizedBox(height: Space.lg),
          FAlert(
            icon: const Icon(FLucideIcons.calendarClock),
            title: Text(l10n.eventPagePostponed),
            subtitle: Text(
              l10n.eventPagePostponedInfo(
                formatDateTime(context, event.postponedFrom!),
              ),
            ),
          ),
        ],
        const SizedBox(height: Space.lg),
        _Fact(
          icon: FLucideIcons.calendar,
          text: formatDateTime(context, info.date),
        ),
        _Fact(icon: FLucideIcons.mapPin, text: info.venue),
        _Fact(icon: FLucideIcons.building2, text: info.city),
        const SizedBox(height: Space.xl),
        AnimatedSize(
          duration: Motion.normal,
          alignment: Alignment.topCenter,
          // Team accounts don't sell: they get the team actions below.
          // Selling is offered below the offers: most visitors come to buy.
          child: event.hidden || event.cancelled || upcoming
              ? const SizedBox(width: double.infinity)
              : FAlert(
                  icon: const Icon(FLucideIcons.calendarCheck),
                  title: Text(l10n.eventsIsOver),
                ),
        ),
        if (ref.watch(isStaffProvider)) ...[
          const SizedBox(height: Space.md),
          _TeamActions(event: event),
        ],
      ],
    );
  }
}

/// For admins and support accounts: review the event.
class _TeamActions extends ConsumerWidget {
  const _TeamActions({required this.event});

  final Event event;

  Future<void> _confirm(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    final ok = await confirmEventDialog(context);
    if (!ok) return;
    try {
      await ref
          .read(eventRepositoryProvider)
          .setStatus(event.id, EventStatus.confirmed);
      showSnack(l10n.eventsReviewConfirmedToast);
    } catch (_) {
      showSnack(l10n.saveError);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    return Wrap(
      spacing: Space.md,
      runSpacing: Space.md,
      children: [
        FButton(
          variant: FButtonVariant.outline,
          size: FButtonSizeVariant.sm,
          mainAxisSize: MainAxisSize.min,
          onPress: () => context.push('/admin/events/${event.id}'),
          prefix: const Icon(FLucideIcons.squarePen),
          child: Text(l10n.eventsReviewEdit, overflow: TextOverflow.ellipsis),
        ),
        if (event.pending)
          FButton(
            variant: FButtonVariant.outline,
            size: FButtonSizeVariant.sm,
            mainAxisSize: MainAxisSize.min,
            onPress: () => _confirm(context, ref),
            prefix: const Icon(FLucideIcons.badgeCheck),
            child: Text(
              l10n.eventsReviewConfirm,
              overflow: TextOverflow.ellipsis,
            ),
          ),
      ],
    );
  }
}

/// Asks the team member to confirm an event. True when confirmed.
Future<bool> confirmEventDialog(BuildContext context) async {
  final l10n = AppLocalizations.of(context);
  final ok = await showAppDialog<bool>(
    context: context,
    title: l10n.eventsReviewConfirmTitle,
    body: Text(l10n.eventsReviewConfirmInfo),
    actions: (ctx) => [
      FButton(
        variant: FButtonVariant.outline,
        onPress: () => Navigator.pop(ctx, false),
        child: Flexible(
          child: Text(l10n.cancel, overflow: TextOverflow.ellipsis),
        ),
      ),
      FButton(
        onPress: () => Navigator.pop(ctx, true),
        child: Flexible(
          child: Text(
            l10n.eventsReviewConfirm,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
    ],
  );
  return ok == true;
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
          Icon(icon, size: IconSizes.sm, color: theme.colors.mutedForeground),
          const SizedBox(width: Space.md),
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

/// The offers, cheapest first, with a filter for how many tickets are
/// needed together.
class _Offers extends ConsumerStatefulWidget {
  const _Offers({required this.event, required this.columns});

  final Event event;
  final int columns;

  @override
  ConsumerState<_Offers> createState() => _OffersState();
}

class _OffersState extends ConsumerState<_Offers> {
  /// Tickets needed together; 0 means any.
  int _needed = 0;

  static const _choices = [0, 1, 2, 3, 4];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final event = widget.event;
    final columns = widget.columns;
    final value = ref.watch(eventListingsProvider(event.id));
    final listings = value.value ?? const <Listing>[];
    final count = listings.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SettingsSectionTitle(
          count == 0 ? l10n.eventsOffers : l10n.eventsOffersCount(count),
        ),
        if (count > 1) ...[
          // Short labels, so all fit on phones; the question says what
          // the numbers mean.
          Text(l10n.offersHowMany, style: context.theme.mutedText),
          const SizedBox(height: Space.sm),
          Segmented<int>(
            values: _choices,
            selected: _needed,
            label: (n) => n == 0
                ? l10n.offersAnyAmount
                : n == _choices.last
                ? l10n.offersAmountOrMore(n)
                : '$n',
            onChanged: (n) => setState(() => _needed = n),
          ),
          const SizedBox(height: Space.lg),
        ],
        AsyncView<List<Listing>>(
          value: value,
          onRetry: () => ref.invalidate(eventListingsProvider(event.id)),
          loading: Shimmer(
            child: ResponsiveGrid(
              maxColumns: columns,
              children: [
                for (var i = 0; i < columns * 2; i++)
                  const SkeletonTicketTile(),
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
            final shown = listings.where((l) => l.available >= _needed).toList()
              ..sort((a, b) {
                final byPrice = a.buyerPriceMinor.compareTo(b.buyerPriceMinor);
                return byPrice != 0
                    ? byPrice
                    : b.available.compareTo(a.available);
              });
            if (shown.isEmpty) {
              return EmptyState(
                icon: FLucideIcons.listFilter,
                title: l10n.offersNoneForAmount(_needed),
                message: l10n.offersNoneForAmountInfo,
              );
            }
            return ResponsiveGrid(
              maxColumns: columns,
              children: [
                for (final l in shown)
                  OfferTicket(
                    listing: l,
                    onTap: () => context.push('/listing/${l.id}', extra: l),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }
}

/// Below the offers: selling tickets for this event. Guests are sent to
/// sign-in first and come back to the form.
class _SellHint extends ConsumerWidget {
  const _SellHint({required this.event});

  final Event event;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = context.theme;
    // Team accounts don't sell; past, hidden and cancelled events can't be.
    if (!event.isUpcoming ||
        event.hidden ||
        event.cancelled ||
        ref.watch(isStaffProvider)) {
      return const SizedBox.shrink();
    }
    return Padding(
      padding: const EdgeInsets.only(top: Space.x3l),
      child: FCard(
        child: Padding(
          padding: const EdgeInsets.all(Space.xl),
          child: Row(
            children: [
              Icon(FLucideIcons.tag, color: theme.colors.mutedForeground),
              const SizedBox(width: Space.lg),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l10n.eventsHaveTickets, style: theme.titleText),
                    Text(l10n.eventsHaveTicketsInfo, style: theme.mutedText),
                  ],
                ),
              ),
              const SizedBox(width: Space.lg),
              FButton(
                variant: FButtonVariant.outline,
                mainAxisSize: MainAxisSize.min,
                onPress: () => context.push('/sell?event=${event.id}'),
                child: Text(l10n.sellTickets),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
