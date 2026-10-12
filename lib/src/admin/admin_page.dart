import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';

import '../../l10n/app_localizations.dart';
import '../data/events_repository.dart';
import '../data/models.dart';
import '../settings/settings_widgets.dart';
import '../support/support_repository.dart';
import '../ui/async_view.dart';
import '../ui/site_scaffold.dart';
import '../ui/skeleton.dart';
import 'admin_repository.dart';

/// Admin hub: events, service fee, team and support requests.
class AdminPage extends ConsumerWidget {
  const AdminPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    return SiteScaffold(
      title: l10n.adminTitle,
      accountNav: true,
      body: AdminGate(
        builder: (context) {
          final fees = ref.watch(feeConfigProvider).value;
          final unread = ref.watch(unreadForStaffProvider);
          final pending = ref.watch(pendingEventsProvider).length;
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
            children: [
              SettingsSectionTitle(l10n.adminTitle),
              SettingsGroup(
                children: [
                  SettingsLinkTile(
                    icon: FLucideIcons.calendarDays,
                    title: l10n.adminEvents,
                    subtitle: l10n.adminEventsInfo,
                    trailing: CountPill(count: pending),
                    onTap: () => context.push('/admin/events'),
                  ),
                  SettingsLinkTile(
                    icon: FLucideIcons.percent,
                    title: l10n.adminFeesTitle,
                    subtitle: fees == null
                        ? null
                        : l10n.adminFeesSummary(
                            fees.buyerPercent,
                            fees.sellerPercent,
                          ),
                    onTap: () => context.push('/admin/fees'),
                  ),
                  SettingsLinkTile(
                    icon: FLucideIcons.chartNoAxesColumnIncreasing,
                    title: l10n.resaleTitle,
                    subtitle: l10n.resaleIntro,
                    onTap: () => context.push('/admin/resale'),
                  ),
                  SettingsLinkTile(
                    icon: FLucideIcons.gauge,
                    title: l10n.limitsTitle,
                    onTap: () => context.push('/admin/limits'),
                  ),
                  SettingsLinkTile(
                    icon: FLucideIcons.shieldAlert,
                    title: l10n.moderationTitle,
                    subtitle: l10n.moderationInfo,
                    onTap: () => context.push('/admin/moderation'),
                  ),
                  SettingsLinkTile(
                    icon: FLucideIcons.receiptText,
                    title: l10n.adminInvoicesTitle,
                    subtitle: l10n.adminInvoicesInfo,
                    onTap: () => context.push('/admin/invoices'),
                  ),
                  SettingsLinkTile(
                    icon: FLucideIcons.building2,
                    title: l10n.companyTitle,
                    onTap: () => context.push('/admin/company'),
                  ),
                  SettingsLinkTile(
                    icon: FLucideIcons.users,
                    title: l10n.adminTeamTitle,
                    subtitle: l10n.adminTeamInfo,
                    onTap: () => context.push('/admin/team'),
                  ),
                  SettingsLinkTile(
                    icon: FLucideIcons.inbox,
                    title: l10n.adminSupportInbox,
                    subtitle: l10n.adminSupportInboxInfo,
                    trailing: CountPill(count: unread),
                    onTap: () => context.push('/admin/support'),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}

/// Shows [builder] only to admins (or, with [staff], to the whole team): a
/// skeleton while the role loads, and "no access" for everybody else.
class AdminGate extends ConsumerWidget {
  const AdminGate({super.key, required this.builder, this.staff = false});

  final WidgetBuilder builder;

  /// Support accounts may enter too.
  final bool staff;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final role = ref.watch(staffRoleProvider);
    final Widget child = !role.hasValue && !role.hasError
        ? const KeyedSubtree(key: ValueKey('loading'), child: AdminSkeleton())
        : role.value == StaffRole.admin ||
              (staff && role.value == StaffRole.support)
        ? KeyedSubtree(key: const ValueKey('admin'), child: builder(context))
        : Center(
            key: const ValueKey('no-access'),
            child: EmptyState(
              icon: FLucideIcons.shieldOff,
              title: l10n.adminNoAccess,
              message: l10n.adminNoAccessInfo,
            ),
          );
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      layoutBuilder: (current, previous) => Stack(
        alignment: Alignment.topCenter,
        children: [...previous, ?current],
      ),
      child: child,
    );
  }
}

/// Placeholder tiles while the role or data loads.
class AdminSkeleton extends StatelessWidget {
  const AdminSkeleton({super.key, this.count = 4});

  final int count;

  @override
  Widget build(BuildContext context) => Shimmer(
    child: Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SkeletonBox(width: 120, height: 14),
          const SizedBox(height: 12),
          for (var i = 0; i < count; i++) ...[
            const SkeletonBox(height: 56, radius: 10),
            const SizedBox(height: 8),
          ],
        ],
      ),
    ),
  );
}

/// A small count in the brand color for tile details, e.g. unread support
/// requests. Shrinks away at zero.
class CountPill extends StatelessWidget {
  const CountPill({super.key, required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;
    return AnimatedScale(
      scale: count > 0 ? 1 : 0,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOutBack,
      child: Container(
        constraints: const BoxConstraints(minWidth: 22),
        height: 22,
        padding: const EdgeInsets.symmetric(horizontal: 7),
        decoration: BoxDecoration(
          color: colors.primary,
          borderRadius: BorderRadius.circular(11),
        ),
        // Shrink-wrapped: as a tile's details it would otherwise take the
        // whole row and squeeze the title out.
        child: Center(
          widthFactor: 1,
          child: Text(
            count > 99 ? '99+' : '$count',
            style: TextStyle(
              color: colors.primaryForeground,
              fontSize: 12,
              height: 1,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}

/// A muted info box.
class AdminNotice extends StatelessWidget {
  const AdminNotice({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colors.muted,
        borderRadius: theme.style.borderRadius.lg,
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(FLucideIcons.info, size: 18, color: theme.colors.foreground),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                text,
                style: theme.typography.body.sm.copyWith(
                  color: theme.colors.foreground,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
