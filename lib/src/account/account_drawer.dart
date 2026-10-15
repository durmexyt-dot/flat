import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:forui/forui.dart';

import '../../l10n/app_localizations.dart';
import '../admin/admin_repository.dart';
import '../auth/auth_repository.dart';
import '../data/repositories.dart';
import 'account_sidebar.dart';
import 'avatar.dart';
import 'profile_header.dart';
import '../ui/tokens.dart';

/// The account menu on wide screens, opened from the avatar in the header.
class AccountDrawer extends ConsumerWidget {
  const AccountDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = context.theme;
    final user = ref.watch(authStateProvider).value;
    final profile = ref.watch(profileProvider).value;

    void open(String path) {
      Navigator.pop(context); // close the drawer first
      context.push(path);
    }

    FSidebarItem item((IconData, String, String) entry) => FSidebarItem(
      icon: AccountEntryIcon(icon: entry.$1, path: entry.$3),
      label: Text(entry.$2),
      onPress: () => open(entry.$3),
    );

    final marketplace = !ref.watch(isStaffProvider);
    final entries = accountEntries(l10n, marketplace: marketplace);
    // Profile; buying and selling (not for team accounts); preferences and
    // help.
    final market = marketplace ? 5 : 0;
    final groups = [
      entries.sublist(0, 1),
      entries.sublist(1, 1 + market),
      entries.sublist(1 + market),
      staffEntries(
        l10n,
        isStaff: ref.watch(isStaffProvider),
        isAdmin: ref.watch(isAdminProvider),
      ),
    ].where((g) => g.isNotEmpty);

    return Drawer(
      width: 340,
      backgroundColor: theme.colors.background,
      shape: const RoundedRectangleBorder(),
      child: SafeArea(
        child: FSidebar(
          style: .delta(
            decoration: const .value(BoxDecoration()),
            constraints: const BoxConstraints.expand(),
          ),
          header: user == null
              ? null
              : Padding(
                  padding: const EdgeInsets.fromLTRB(
                    Space.xxl,
                    Space.xl,
                    Space.xxl,
                    Space.md,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          UserAvatar(
                            size: 48,
                            photoBase64: profile?.photoBase64,
                            name: profile?.displayName ?? user.displayName,
                            hero: false,
                          ),
                          const SizedBox(width: Space.lg),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  profile?.displayName ??
                                      user.displayName ??
                                      user.email ??
                                      '',
                                  style: theme.titleText,
                                ),
                                Text(
                                  profile?.username != null
                                      ? '@${profile!.username}'
                                      : user.email ?? '',
                                  style: theme.mutedText,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      if (marketplace) ...[
                        const SizedBox(height: Space.xl),
                        const StatsRow(),
                      ],
                    ],
                  ),
                ),
          footer: user == null
              ? null
              : LogoutItem(beforeSignOut: () => Navigator.pop(context)),
          children: user == null
              ? [
                  FSidebarGroup(
                    children: [
                      FSidebarItem(
                        icon: const Icon(FLucideIcons.logIn),
                        label: Text(l10n.signInOrUp),
                        onPress: () {
                          Navigator.pop(context);
                          ref.read(guestModeProvider.notifier).exit();
                          context.go('/login');
                        },
                      ),
                      item((
                        FLucideIcons.settings,
                        l10n.settingsTitle,
                        '/settings',
                      )),
                      item(entries.last),
                    ],
                  ),
                ]
              : [
                  for (final group in groups)
                    FSidebarGroup(children: [for (final e in group) item(e)]),
                ],
        ),
      ),
    );
  }
}
