import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';

import '../../l10n/app_localizations.dart';
import '../admin/admin_repository.dart';
import '../data/events_repository.dart';
import '../data/models.dart';
import '../home/city_picker.dart';
import '../location/cities.dart';
import '../location/location_controller.dart';
import '../market/listing_ticket.dart';
import 'event_card.dart';
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

/// One event: picture, details and its dates – near the user first, then
/// in other places – each leading to its tickets.
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
    void record() {
      if (mounted) ref.read(recentlyViewedIdsProvider.notifier).add(id);
    }

    // Only once the page has come in: the list underneath would otherwise
    // reorder (this event moves to the front of "recently viewed") while
    // it still shows through the transition. Checked after the first frame:
    // until then the page is built offstage, as if already in.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final animation = ModalRoute.of(context)?.animation;
      if (animation == null || animation.isCompleted) return record();
      void onStatus(AnimationStatus status) {
        if (status.isAnimating) return;
        animation.removeStatusListener(onStatus);
        if (status.isCompleted) record();
      }

      animation.addStatusListener(onStatus);
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
          _Dates(event: event, columns: wide ? 2 : 1),
          EventSellHint(event: event),
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
          ),
        ),
        if (event.performer.isNotEmpty &&
            searchKey(event.performer) != searchKey(info.name)) ...[
          const SizedBox(height: Space.xs),
          Text(event.performer, style: theme.mutedText),
        ],
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

/// Below the offers: selling tickets for this event. Guests are sent to
/// sign-in first and come back to the form.
class EventSellHint extends ConsumerWidget {
  const EventSellHint({super.key, required this.event});

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

/// The dates of this show: those near the chosen city, then those in other
/// places, or all of them when no city is chosen.
class _Dates extends ConsumerWidget {
  const _Dates({required this.event, required this.columns});

  final Event event;
  final int columns;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = context.theme;
    final found = ref.watch(eventDatesProvider(event.id));
    final dates = found.isEmpty ? [event] : found;
    final city = ref.watch(chosenCityProvider)?.name;

    Widget grid(List<Event> list) => ResponsiveGrid(
      maxColumns: columns,
      children: [for (final e in list) _DateCard(event: e)],
    );

    final cityButton = Align(
      alignment: AlignmentDirectional.centerStart,
      child: FButton(
        variant: FButtonVariant.outline,
        size: FButtonSizeVariant.sm,
        mainAxisSize: MainAxisSize.min,
        prefix: const Icon(FLucideIcons.mapPin),
        suffix: const Icon(FLucideIcons.chevronDown),
        onPress: () => showCityPicker(context),
        child: Flexible(
          child: Text(
            city == null ? l10n.homeCityPick : l10n.datesNearCity(city),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
    );

    if (city == null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SettingsSectionTitle(l10n.datesAllCount(dates.length)),
          Text(l10n.datesPickCity, style: theme.mutedText),
          const SizedBox(height: Space.md),
          cityButton,
          const SizedBox(height: Space.lg),
          grid(dates),
        ],
      );
    }
    final near = [
      for (final e in dates)
        if (isNearCity(e.info.city, city)) e,
    ];
    final other = [
      for (final e in dates)
        if (!near.contains(e)) e,
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SettingsSectionTitle(
          near.isEmpty
              ? l10n.datesNoneNearby
              : l10n.datesNearbyCount(near.length),
        ),
        cityButton,
        const SizedBox(height: Space.lg),
        if (near.isEmpty)
          Text(l10n.datesNoneNearbyInfo(city), style: theme.mutedText)
        else
          grid(near),
        if (other.isNotEmpty) ...[
          SettingsSectionTitle(l10n.datesElsewhereCount(other.length)),
          grid(other),
        ],
      ],
    );
  }
}

/// One date: place and time as a ticket, the cheapest price and the way to
/// its tickets – or that there are none.
class _DateCard extends ConsumerWidget {
  const _DateCard({required this.event});

  final Event event;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = context.theme;
    final from = ref.watch(eventFromPriceProvider)[event.id];
    final tickets = ref.watch(eventOffersProvider)[event.id]?.tickets ?? 0;
    final open = from != null && tickets > 0;
    final path = '/event/${event.id}/tickets';
    void show() => context.push(path, extra: event);

    final Widget status;
    if (event.cancelled) {
      status = Text(l10n.eventPageCancelled, style: theme.mutedText);
    } else if (!event.isUpcoming) {
      status = Text(l10n.eventsIsOver, style: theme.mutedText);
    } else if (!open) {
      status = Text(l10n.noTicketsAvailable, style: theme.mutedText);
    } else {
      status = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${l10n.ticketsFrom(formatMoney(context, from.minor, from.currency))}'
            ' · ${l10n.offersAmount(tickets)}',
            style: theme.titleText,
          ),
          const SizedBox(height: Space.md),
          FButton(
            size: FButtonSizeVariant.sm,
            mainAxisSize: MainAxisSize.min,
            onPress: show,
            child: Text(l10n.showTickets),
          ),
        ],
      );
    }

    return EventTicket(
      heroTag: 'date-${event.id}',
      event: event.info,
      lines: [
        const SizedBox(height: Space.md),
        status,
      ],
      onTap: open ? show : null,
    );
  }
}
