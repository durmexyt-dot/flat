import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:forui/forui.dart';

import '../../l10n/app_localizations.dart';
import '../admin/admin_repository.dart';
import '../auth/auth_repository.dart';
import '../data/tickets_repository.dart';
import '../support/support_repository.dart';
import '../ui/count_badge.dart';
import '../ui/tokens.dart';
import '../ui/app_link.dart';

/// Pages for buying and selling. Team accounts (admins, support) don't buy
/// or sell, so they don't get these.
const marketplacePaths = ['/sell', '/checkout', '/account/'];

bool isMarketplacePath(String path) => marketplacePaths.any(path.startsWith);

typedef AccountEntry = (IconData icon, String label, String path);

/// Account pages in groups: buying, selling, settings, help. Without
/// [marketplace] (team accounts) buying and selling are left out.
List<(String, List<AccountEntry>)> accountGroups(
  AppLocalizations l10n, {
  bool marketplace = true,
}) => [
  if (marketplace) ...[
    (
      l10n.buying,
      [
        (FLucideIcons.ticket, l10n.purchases, '/account/purchases'),
        (FLucideIcons.receiptText, l10n.invoicesTitle, '/account/invoices'),
      ],
    ),
    (
      l10n.selling,
      [
        (FLucideIcons.tag, l10n.myListings, '/account/listings'),
        (FLucideIcons.store, l10n.sales, '/account/sales'),
        (FLucideIcons.wallet, l10n.payouts, '/account/payouts'),
        (FLucideIcons.landmark, l10n.payoutMethod, '/account/payout-method'),
      ],
    ),
  ],
  (
    l10n.settingsTitle,
    [
      (FLucideIcons.user, l10n.profileTitle, '/settings'),
      (FLucideIcons.palette, l10n.appearance, '/settings/appearance'),
      (FLucideIcons.bell, l10n.notifications, '/settings/notifications'),
      (FLucideIcons.shield, l10n.privacySecurity, '/settings/privacy'),
    ],
  ),
  (
    l10n.accountGroupHelp,
    [(FLucideIcons.circleQuestionMark, l10n.helpCenter, '/support')],
  ),
];

/// Team entries: the support inbox for staff, administration for admins.
List<AccountEntry> staffEntries(
  AppLocalizations l10n, {
  required bool isStaff,
  required bool isAdmin,
}) => [
  if (isStaff) (FLucideIcons.inbox, l10n.supportInbox, '/admin/support'),
  if (isStaff)
    (FLucideIcons.shieldAlert, l10n.moderationTitle, '/admin/moderation'),
  if (isAdmin) (FLucideIcons.shieldUser, l10n.supportAdministration, '/admin'),
];

/// An entry's icon, with the count of unread support answers on the help
/// center, of new requests on the support inbox and of sold tickets still
/// to upload on the sold-tickets page.
class AccountEntryIcon extends ConsumerWidget {
  const AccountEntryIcon({super.key, required this.icon, required this.path});

  final IconData icon;
  final String path;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final count = switch (path) {
      '/support' => ref.watch(unreadSupportAnswersProvider),
      '/admin/support' => ref.watch(unreadForStaffProvider),
      // Sold tickets still to upload.
      '/account/sales' =>
        ref
            .watch(salesAwaitingTicketsProvider)
            .fold(0, (sum, o) => sum + o.ticketsMissing),
      _ => 0,
    };
    final child = Icon(icon);
    return count == 0 && path != '/support' && path != '/admin/support'
        ? child
        : CountBadge(count: count, child: child);
  }
}

/// Left navigation of the account area on wide screens: a Forui sidebar.
class AccountSidebar extends ConsumerWidget {
  const AccountSidebar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final location = GoRouterState.of(context).uri.path;
    final signedIn = ref.watch(authStateProvider).value != null;
    // Guests: settings and help only.
    final groups = signedIn
        ? accountGroups(l10n, marketplace: !ref.watch(isStaffProvider))
        : [
            (
              l10n.settingsTitle,
              [(FLucideIcons.settings, l10n.settingsTitle, '/settings')],
            ),
            accountGroups(l10n).last,
          ];
    final team = signedIn
        ? staffEntries(
            l10n,
            isStaff: ref.watch(isStaffProvider),
            isAdmin: ref.watch(isAdminProvider),
          )
        : const <AccountEntry>[];

    return FSidebar(
      style: .delta(
        decoration: const .value(BoxDecoration()),
        constraints: const BoxConstraints.tightFor(width: 248),
        contentPadding: const .value(EdgeInsets.symmetric(vertical: Space.x3l)),
      ),
      footer: signedIn ? const LogoutItem() : null,
      children: [
        for (final (i, (title, entries)) in groups.indexed)
          FSidebarGroup(
            style: .delta(
              padding: .value(EdgeInsets.only(top: i == 0 ? 0 : Space.lg)),
            ),
            label: Text(title),
            children: [
              for (final (icon, label, path) in entries)
                AppLink(
                  path: path,
                  onTap: () => context.go(path),
                  builder: (tap) => FSidebarItem(
                    icon: AccountEntryIcon(icon: icon, path: path),
                    label: Text(label),
                    selected: location == path,
                    onPress: tap,
                  ),
                ),
            ],
          ),
        if (team.isNotEmpty)
          FSidebarGroup(
            style: const .delta(
              padding: .value(EdgeInsets.only(top: Space.lg)),
            ),
            label: Text(l10n.accountGroupTeam),
            children: [
              for (final (icon, label, path) in team)
                FSidebarItem(
                  icon: AccountEntryIcon(icon: icon, path: path),
                  label: Text(label),
                  selected: location == path,
                  onPress: () => context.go(path),
                ),
            ],
          ),
      ],
    );
  }
}

/// Signs out and goes to the sign-in page; shared by sidebar and drawer.
class LogoutItem extends ConsumerWidget {
  const LogoutItem({super.key, this.beforeSignOut});

  /// E.g. closing the drawer.
  final VoidCallback? beforeSignOut;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final error = context.theme.colors.error;
    return Padding(
      padding: const EdgeInsets.only(top: Space.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const FDivider(),
          FSidebarItem(
            icon: Icon(FLucideIcons.logOut, color: error),
            label: Text(l10n.logoutButton, style: TextStyle(color: error)),
            onPress: () async {
              final router = GoRouter.of(context);
              beforeSignOut?.call();
              await ref.read(authRepositoryProvider).signOut();
              router.go('/');
            },
          ),
        ],
      ),
    );
  }
}
