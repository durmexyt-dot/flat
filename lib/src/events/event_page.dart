import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';

import '../../l10n/app_localizations.dart';
import '../admin/admin_repository.dart';
import '../auth/auth_repository.dart';
import '../data/events_repository.dart';
import '../data/models.dart';
import '../data/repositories.dart';
import '../market/listing_ticket.dart';
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
          child: event.hidden || event.cancelled || ref.watch(isStaffProvider)
              ? const SizedBox(width: double.infinity)
              : upcoming
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
