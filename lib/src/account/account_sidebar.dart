import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:forui/forui.dart';

import '../../l10n/app_localizations.dart';
import '../auth/auth_repository.dart';

/// Account entries, shared by the sidebar and the drawer.
List<(IconData, String, String)> accountEntries(AppLocalizations l10n) => [
  (FLucideIcons.user, l10n.profileTitle, '/settings'),
  (FLucideIcons.receipt, l10n.purchases, '/account/purchases'),
  (FLucideIcons.tag, l10n.myListings, '/account/listings'),
  (FLucideIcons.store, l10n.sales, '/account/sales'),
  (FLucideIcons.wallet, l10n.payouts, '/account/payouts'),
  (FLucideIcons.landmark, l10n.payoutMethod, '/account/payout-method'),
  (FLucideIcons.palette, l10n.appearance, '/settings/appearance'),
  (FLucideIcons.bell, l10n.notifications, '/settings/notifications'),
  (FLucideIcons.shield, l10n.privacySecurity, '/settings/privacy'),
  (FLucideIcons.circleQuestionMark, l10n.helpCenter, '/support'),
];

/// Left navigation of the account area on wide screens: a Forui sidebar.
class AccountSidebar extends ConsumerWidget {
  const AccountSidebar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final location = GoRouterState.of(context).uri.path;
    final signedIn = ref.watch(authStateProvider).value != null;
    final entries = signedIn
        ? accountEntries(l10n)
        : accountEntries(l10n)
              .where((e) => e.$3 == '/settings' || e.$3 == '/support');

    return FSidebar(
      style: .delta(
        decoration: const .value(BoxDecoration()),
        constraints: const BoxConstraints.tightFor(width: 248),
        contentPadding: const .value(EdgeInsets.symmetric(vertical: 24)),
      ),
      footer: signedIn ? const LogoutItem() : null,
      children: [
        FSidebarGroup(
          style: const .delta(padding: .value(EdgeInsets.zero)),
          children: [
            for (final (icon, label, path) in entries)
              FSidebarItem(
                icon: Icon(icon),
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
      padding: const EdgeInsets.only(top: 8),
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
              router.go('/login');
            },
          ),
        ],
      ),
    );
  }
}
