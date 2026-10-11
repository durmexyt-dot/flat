import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../l10n/app_localizations.dart';
import '../auth/auth_repository.dart';
import '../data/repositories.dart';
import 'avatar.dart';
import 'profile_header.dart';

/// The account menu on wide screens, opened from the avatar in the header.
class AccountDrawer extends ConsumerWidget {
  const AccountDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final user = ref.watch(authStateProvider).value;
    final profile = ref.watch(profileProvider).value;

    void open(String path) {
      Navigator.pop(context); // close the drawer first
      context.push(path);
    }

    Widget item(IconData icon, String label, String path) => ListTile(
      leading: Icon(icon),
      title: Text(label),
      onTap: () => open(path),
    );

    return Drawer(
      width: 360,
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: 16),
          children: [
            if (user != null) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    UserAvatar(
                      size: 56,
                      photoBase64: profile?.photoBase64,
                      name: profile?.displayName ?? user.displayName,
                      hero: false,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            profile?.displayName ??
                                user.displayName ??
                                user.email ??
                                '',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            profile?.username != null
                                ? '@${profile!.username}'
                                : user.email ?? '',
                            style: theme.textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const Padding(
                padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: StatsRow(),
              ),
              item(Icons.person_outline, l10n.profileTitle, '/settings'),
              const Divider(),
              item(
                Icons.receipt_long_outlined,
                l10n.purchases,
                '/account/purchases',
              ),
              item(Icons.sell_outlined, l10n.myListings, '/account/listings'),
              item(Icons.point_of_sale_outlined, l10n.sales, '/account/sales'),
              item(
                Icons.account_balance_wallet_outlined,
                l10n.payouts,
                '/account/payouts',
              ),
              item(
                Icons.account_balance_outlined,
                l10n.payoutMethod,
                '/account/payout-method',
              ),
              const Divider(),
              item(
                Icons.palette_outlined,
                l10n.appearance,
                '/settings/appearance',
              ),
              item(
                Icons.notifications_outlined,
                l10n.notifications,
                '/settings/notifications',
              ),
              item(
                Icons.shield_outlined,
                l10n.privacySecurity,
                '/settings/privacy',
              ),
              item(Icons.help_outline, l10n.helpCenter, '/support'),
              const Divider(),
              ListTile(
                leading: Icon(Icons.logout, color: theme.colorScheme.error),
                title: Text(
                  l10n.logoutButton,
                  style: TextStyle(color: theme.colorScheme.error),
                ),
                onTap: () async {
                  final router = GoRouter.of(context);
                  Navigator.pop(context);
                  await ref.read(authRepositoryProvider).signOut();
                  router.go('/login');
                },
              ),
            ] else ...[
              ListTile(
                leading: const Icon(Icons.login),
                title: Text(l10n.signInOrUp),
                onTap: () {
                  Navigator.pop(context);
                  ref.read(guestModeProvider.notifier).exit();
                  context.go('/login');
                },
              ),
              item(Icons.settings_outlined, l10n.settingsTitle, '/settings'),
              item(Icons.help_outline, l10n.helpCenter, '/support'),
            ],
          ],
        ),
      ),
    );
  }
}
