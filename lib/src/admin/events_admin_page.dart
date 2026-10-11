import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';

import '../../l10n/app_localizations.dart';
import '../data/events_repository.dart';
import '../data/models.dart';
import '../events/event_picker.dart';
import '../settings/settings_widgets.dart';
import '../ui/async_view.dart';
import '../ui/site_scaffold.dart';
import '../ui/skeleton.dart';
import 'admin_repository.dart';

/// Admins manage events here: upcoming first, then past ones.
class EventsAdminPage extends ConsumerWidget {
  const EventsAdminPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final role = ref.watch(staffRoleProvider);
    final isAdmin = ref.watch(isAdminProvider);
    final wide = isWideLayout(context);
    void create() => context.push('/admin/events/new');

    return SiteScaffold(
      title: l10n.eventsAdminTitle,
      maxWidth: SiteWidth.full,
      accountNav: true,
      actions: [
        if (isAdmin)
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
          : !isAdmin
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
                final upcoming = [
                  for (final e in all)
                    if (e.isUpcoming) e,
                ];
                // Most recent past events first.
                final past = [
                  for (final e in all.reversed)
                    if (!e.isUpcoming) e,
                ];
                return ListView(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
                  children: [
                    if (upcoming.isNotEmpty) ...[
                      SettingsSectionTitle(l10n.eventsUpcomingSection),
                      for (final e in upcoming) _row(context, e),
                    ],
                    if (past.isNotEmpty) ...[
                      SettingsSectionTitle(l10n.eventsPastSection),
                      for (final e in past) _row(context, e),
                    ],
                  ],
                );
              },
            ),
    );
  }

  Widget _row(BuildContext context, Event e) {
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: EventRow(
        event: e,
        onTap: () => context.push('/admin/events/${e.id}'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          spacing: 6,
          children: [
            if (e.hidden)
              FBadge(
                variant: FBadgeVariant.outline,
                child: Text(l10n.eventsHiddenBadge),
              ),
            if (!e.isUpcoming)
              FBadge(
                variant: FBadgeVariant.secondary,
                child: Text(l10n.eventsPastBadge),
              ),
            Icon(
              FLucideIcons.chevronRight,
              size: 16,
              color: context.theme.colors.mutedForeground,
            ),
          ],
        ),
      ),
    );
  }
}

/// Shown to everybody who isn't an admin.
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
          message: l10n.eventsAdminNoAccessInfo,
        ),
      ),
    );
  }
}
