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

/// Left navigation of the account area on wide screens.
class AccountSidebar extends ConsumerWidget {
  const AccountSidebar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final colors = Theme.of(context).colorScheme;
    final location = GoRouterState.of(context).uri.path;
    final signedIn = ref.watch(authStateProvider).value != null;
    final entries = signedIn
        ? accountEntries(l10n)
        : accountEntries(l10n)
              .where((e) => e.$3 == '/settings' || e.$3 == '/support');

    return ListView(
      padding: const EdgeInsets.only(top: 24, bottom: 24),
      children: [
        for (final (icon, label, path) in entries)
          Padding(
            padding: const EdgeInsets.only(bottom: 2),
            child: ListTile(
              dense: true,
              leading: Icon(icon, size: 20),
              title: Text(label),
              selected: location == path,
              selectedColor: colors.primary,
              selectedTileColor: colors.surfaceContainerHigh,
              onTap: () => context.go(path),
            ),
          ),
        if (signedIn) ...[
          const Divider(height: 24),
          ListTile(
            dense: true,
            leading: Icon(FLucideIcons.logOut, size: 20, color: colors.error),
            title: Text(
              l10n.logoutButton,
              style: TextStyle(color: colors.error),
            ),
            onTap: () async {
              final router = GoRouter.of(context);
              await ref.read(authRepositoryProvider).signOut();
              router.go('/login');
            },
          ),
        ],
      ],
    );
  }
}
