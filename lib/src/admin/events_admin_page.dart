import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';

import '../../l10n/app_localizations.dart';
import '../data/events_repository.dart';
import '../data/models.dart';
import '../events/event_picker.dart';
import '../ui/async_view.dart';
import '../ui/segmented.dart';
import '../ui/site_scaffold.dart';
import '../ui/skeleton.dart';
import 'admin_repository.dart';
import '../ui/tokens.dart';

/// Which events the team's list shows.
enum EventsFilter { pending, confirmed, hidden, past, cancelled }

/// Whether [e] belongs under [filter]. Events waiting for a check stay
/// under "pending" whatever their date, so nothing slips through.
bool eventMatches(Event e, EventsFilter filter) => switch (filter) {
  EventsFilter.pending => e.pending,
  EventsFilter.confirmed => e.confirmed && e.isUpcoming,
  EventsFilter.hidden => e.hidden,
  EventsFilter.past => e.confirmed && !e.isUpcoming,
  EventsFilter.cancelled => e.cancelled,
};

/// The team (admins and support accounts) reviews events here: those users
/// added and that wait for a check first, then confirmed, hidden and past
/// ones.
class EventsAdminPage extends ConsumerStatefulWidget {
  const EventsAdminPage({super.key});

  @override
  ConsumerState<EventsAdminPage> createState() => _EventsAdminPageState();
}

class _EventsAdminPageState extends ConsumerState<EventsAdminPage> {
  /// Events to check come first, if there are any.
  EventsFilter? _filter;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final role = ref.watch(staffRoleProvider);
    final isStaff = ref.watch(isStaffProvider);
    final wide = isWideLayout(context);
    void create() => context.push('/admin/events/new');

    return SiteScaffold(
      title: l10n.eventsAdminTitle,
      maxWidth: SiteWidth.full,
      accountNav: true,
      actions: [
        if (isStaff)
          wide
              ? FButton(
                  mainAxisSize: MainAxisSize.min,
                  onPress: create,
                  prefix: const Icon(FLucideIcons.plus),
                  child: Text(l10n.eventsNew, overflow: TextOverflow.ellipsis),
                )
              : FHeaderAction(
                  icon: const Icon(FLucideIcons.plus),
                  semanticsLabel: l10n.eventsNew,
                  onPress: create,
                ),
      ],
      body: !role.hasValue && !role.hasError
          ? const SkeletonTicketList(count: 4)
          : !isStaff
          ? const EventsNoAccess()
          : AsyncView<List<Event>>(
              value: ref.watch(allEventsProvider),
              onRetry: () => ref.invalidate(allEventsProvider),
              loading: const SkeletonTicketList(count: 4),
              data: (all) {
                if (all.isEmpty) {
                  return Center(
                    child: SingleChildScrollView(
                      child: EmptyState(
                        icon: FLucideIcons.calendarPlus,
                        title: l10n.eventsNoneYet,
                        message: l10n.eventsNoneYetInfo,
                        action: FButton(
                          mainAxisSize: MainAxisSize.min,
                          onPress: create,
                          prefix: const Icon(FLucideIcons.plus),
                          child: Text(
                            l10n.eventsNew,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    ),
                  );
                }
                return _list(context, all);
              },
            ),
    );
  }

  Widget _list(BuildContext context, List<Event> all) {
    final l10n = AppLocalizations.of(context);
    final pendingCount = all.where((e) => e.pending).length;
    // Decided once, when the events first load: confirming the last event
    // to check doesn't switch the list away under the reviewer.
    final filter = _filter ??= pendingCount > 0
        ? EventsFilter.pending
        : EventsFilter.confirmed;
    final shown = [
      for (final e in all)
        if (eventMatches(e, filter)) e,
    ];
    // Most recent past events first; everything else soonest first.
    final ordered =
        filter == EventsFilter.past || filter == EventsFilter.cancelled
        ? shown.reversed.toList()
        : shown;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            Space.xl,
            Space.md,
            Space.xl,
            Space.md,
          ),
          child: Segmented<EventsFilter>(
            values: EventsFilter.values,
            selected: filter,
            scrollable: true,
            label: (f) => switch (f) {
              EventsFilter.pending => l10n.eventsReviewTabPending(pendingCount),
              EventsFilter.confirmed => l10n.eventsReviewTabConfirmed,
              EventsFilter.hidden => l10n.eventsReviewTabHidden,
              EventsFilter.past => l10n.eventsReviewTabPast,
              EventsFilter.cancelled => l10n.eventChangeFilterCancelled,
            },
            onChanged: (f) => setState(() => _filter = f),
          ),
        ),
        Expanded(
          child: AnimatedSwitcher(
            duration: Motion.normal,
            child: ordered.isEmpty
                ? Center(
                    key: ValueKey('empty-$filter'),
                    child: SingleChildScrollView(
                      child: EmptyState(
                        icon: filter == EventsFilter.pending
                            ? FLucideIcons.badgeCheck
                            : FLucideIcons.calendarX,
                        title: filter == EventsFilter.pending
                            ? l10n.eventsReviewEmptyPending
                            : l10n.eventsReviewEmpty,
                        message: filter == EventsFilter.pending
                            ? l10n.eventsReviewEmptyPendingInfo
                            : null,
                      ),
                    ),
                  )
                : ListView(
                    key: ValueKey(filter),
                    padding: const EdgeInsets.fromLTRB(
                      Space.xl,
                      Space.xs,
                      Space.xl,
                      Space.x5l,
                    ),
                    children: [for (final e in ordered) _row(context, e)],
                  ),
          ),
        ),
      ],
    );
  }

  Widget _row(BuildContext context, Event e) {
    return Padding(
      padding: const EdgeInsets.only(bottom: Space.xs),
      child: EventRow(
        event: e,
        showConfirmed: true,
        onTap: () => context.push('/admin/events/${e.id}'),
        trailing: Icon(
          FLucideIcons.chevronRight,
          size: IconSizes.sm,
          color: context.theme.colors.mutedForeground,
        ),
      ),
    );
  }
}

/// Shown to everybody who isn't in the team.
class EventsNoAccess extends StatelessWidget {
  const EventsNoAccess({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Center(
      child: SingleChildScrollView(
        child: EmptyState(
          icon: FLucideIcons.shieldOff,
          title: l10n.eventsAdminNoAccess,
          message: l10n.eventsReviewNoAccessInfo,
        ),
      ),
    );
  }
}
