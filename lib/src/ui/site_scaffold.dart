import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../l10n/app_localizations.dart';
import '../account/account_drawer.dart';
import '../account/avatar.dart';
import '../auth/auth_repository.dart';
import '../brand/brand.dart';
import '../data/repositories.dart';

/// From this width on, pages are laid out like a website: header with
/// navigation, account drawer, wider content.
const wideLayoutBreakpoint = 900.0;

bool isWideLayout(BuildContext context) =>
    MediaQuery.sizeOf(context).width >= wideLayoutBreakpoint;

/// Content widths on wide screens.
abstract final class SiteWidth {
  /// Lists and grids.
  static const wide = 1200.0;

  /// Detail pages.
  static const detail = 900.0;

  /// Forms and settings.
  static const form = 760.0;
}

/// A page: an app bar on phones; on wide screens the site header, a page
/// title and centered content.
class SiteScaffold extends StatelessWidget {
  const SiteScaffold({
    super.key,
    required this.title,
    required this.body,
    this.actions = const [],
    this.floatingActionButton,
    this.maxWidth = SiteWidth.form,
    this.narrowAppBar,
    this.showTitle = true,
  });

  final String title;
  final Widget body;

  /// Shown in the app bar on phones, next to the title on wide screens.
  final List<Widget> actions;

  /// Phones only; wide screens show [actions] instead.
  final Widget? floatingActionButton;
  final double maxWidth;

  /// Replaces the default app bar on phones.
  final PreferredSizeWidget? narrowAppBar;
  final bool showTitle;

  @override
  Widget build(BuildContext context) {
    if (!isWideLayout(context)) {
      return Scaffold(
        appBar: narrowAppBar ?? AppBar(title: Text(title), actions: actions),
        floatingActionButton: floatingActionButton,
        body: body,
      );
    }

    final theme = Theme.of(context);
    return Scaffold(
      endDrawer: const AccountDrawer(),
      body: Column(
        children: [
          const SiteHeader(),
          Expanded(
            child: Align(
              alignment: Alignment.topCenter,
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxWidth),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (showTitle)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(8, 24, 16, 8),
                        child: Row(
                          children: [
                            if (context.canPop()) const BackButton(),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                title,
                                style: theme.textTheme.headlineMedium?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            ...actions,
                          ],
                        ),
                      ),
                    Expanded(child: body),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// The website header: brand, navigation, account.
class SiteHeader extends ConsumerWidget {
  const SiteHeader({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final user = ref.watch(authStateProvider).value;
    final profile = ref.watch(profileProvider).value;
    final location = GoRouterState.of(context).uri.path;

    Widget link(String label, String path) {
      final active = location == path;
      return TextButton(
        onPressed: () => context.go(path),
        style: TextButton.styleFrom(
          foregroundColor: active
              ? theme.colorScheme.primary
              : theme.colorScheme.onSurface,
          textStyle: theme.textTheme.titleSmall?.copyWith(
            fontWeight: active ? FontWeight.w700 : FontWeight.w500,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
        child: Text(label),
      );
    }

    return Material(
      color: theme.colorScheme.surface,
      child: Container(
        height: 68,
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: theme.colorScheme.outlineVariant),
          ),
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: SiteWidth.wide),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () => context.go('/'),
                    child: const Padding(
                      padding: EdgeInsets.all(6),
                      child: BrandHeader(markSize: 36, wordmarkHeight: 24),
                    ),
                  ),
                  const SizedBox(width: 24),
                  link(l10n.navEvents, '/'),
                  link(l10n.sellTickets, '/sell'),
                  if (user != null)
                    link(l10n.navMyTickets, '/account/purchases'),
                  const Spacer(),
                  if (user == null) ...[
                    IconButton(
                      tooltip: l10n.settingsTitle,
                      onPressed: () => context.push('/settings'),
                      icon: const Icon(Icons.settings_outlined),
                    ),
                    const SizedBox(width: 8),
                    TextButton(
                      onPressed: () {
                        ref.read(guestModeProvider.notifier).exit();
                        context.go('/login');
                      },
                      child: Text(l10n.loginButton),
                    ),
                    const SizedBox(width: 8),
                    FilledButton(
                      onPressed: () {
                        ref.read(guestModeProvider.notifier).exit();
                        context.go('/login');
                        context.push('/signup');
                      },
                      child: Text(l10n.signUp),
                    ),
                  ] else
                    Builder(
                      builder: (context) => Tooltip(
                        message: l10n.openAccountMenu,
                        child: InkWell(
                          customBorder: const StadiumBorder(),
                          onTap: () => Scaffold.of(context).openEndDrawer(),
                          child: Padding(
                            padding: const EdgeInsets.all(4),
                            child: Row(
                              children: [
                                UserAvatar(
                                  size: 40,
                                  photoBase64: profile?.photoBase64,
                                  name:
                                      profile?.displayName ??
                                      user.displayName ??
                                      user.email,
                                  // The account page shows the flying one.
                                  hero: false,
                                ),
                                const SizedBox(width: 4),
                                const Icon(Icons.expand_more),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
