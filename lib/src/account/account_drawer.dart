import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:forui/forui.dart';

import '../../l10n/app_localizations.dart';
import '../auth/auth_repository.dart';
import '../data/repositories.dart';
import 'account_sidebar.dart';
import 'avatar.dart';
import 'profile_header.dart';

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
      icon: Icon(entry.$1),
      label: Text(entry.$2),
      onPress: () => open(entry.$3),
    );

    final entries = accountEntries(l10n);
    // Profile; buying and selling; preferences and help.
    final groups = [
      entries.sublist(0, 1),
      entries.sublist(1, 6),
      entries.sublist(6),
    ];

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
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
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
                                  style: theme.typography.body.md.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: theme.colors.foreground,
                                  ),
                                ),
                                Text(
                                  profile?.username != null
                                      ? '@${profile!.username}'
                                      : user.email ?? '',
                                  style: theme.typography.body.sm.copyWith(
                                    color: theme.colors.mutedForeground,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const StatsRow(),
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
