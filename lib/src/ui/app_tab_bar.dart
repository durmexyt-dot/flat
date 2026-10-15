import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';

import '../../l10n/app_localizations.dart';
import '../admin/admin_repository.dart';
import '../auth/auth_repository.dart';
import '../support/support_repository.dart';
import 'count_badge.dart';

typedef _Tab = (IconData icon, String label, String path);

/// The main sections on phones. Team accounts don't buy or sell: they get
/// their inbox instead.
List<_Tab> _tabs(AppLocalizations l10n, {required bool staff}) => [
  (FLucideIcons.compass, l10n.navEvents, '/'),
  if (staff)
    (FLucideIcons.inbox, l10n.navInbox, '/admin/support')
  else ...[
    (FLucideIcons.tickets, l10n.navMyTickets, '/account/purchases'),
    (FLucideIcons.ticketPlus, l10n.navSell, '/sell'),
  ],
  (FLucideIcons.user, l10n.profileTitle, '/settings'),
];

/// Tab bar at the bottom of the phone layout, shown on the sections' first
/// pages. Guests are sent to sign-in by the router where a tab needs an
/// account, and come back to it.
class AppTabBar extends ConsumerWidget {
  const AppTabBar({super.key});

  /// Whether [path] is one of the tabs, so the page shows the bar.
  static bool isTabPath(String path) => const {
    '/',
    '/account/purchases',
    '/sell',
    '/settings',
    '/admin/support',
  }.contains(path);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final signedIn = ref.watch(authStateProvider).value != null;
    final staff = signedIn && ref.watch(isStaffProvider);
    final tabs = _tabs(l10n, staff: staff);
    final path = GoRouterState.of(context).uri.path;
    final index = tabs.indexWhere((t) => t.$3 == path);
    final unread = !signedIn
        ? 0
        : staff
        ? ref.watch(unreadForStaffProvider)
        : ref.watch(unreadSupportAnswersProvider);

    Widget icon(_Tab t) {
      final child = Icon(t.$1);
      final count = switch (t.$3) {
        '/settings' when !staff => unread,
        '/admin/support' => unread,
        _ => 0,
      };
      return count == 0 ? child : CountBadge(count: count, child: child);
    }

    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: context.theme.colors.border)),
      ),
      child: FBottomNavigationBar(
        safeAreaBottom: true,
        index: index,
        onChange: (i) {
          if (i != index) context.go(tabs[i].$3);
        },
        children: [
          for (final t in tabs)
            FBottomNavigationBarItem(icon: icon(t), label: Text(t.$2)),
        ],
      ),
    );
  }
}
