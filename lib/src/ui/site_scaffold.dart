import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:forui/forui.dart';

import '../../l10n/app_localizations.dart';
import '../account/account_drawer.dart';
import '../account/account_sidebar.dart';
import '../account/avatar.dart';
import '../auth/auth_repository.dart';
import '../brand/brand.dart';
import '../data/repositories.dart';

/// From this width on, pages are laid out like a website: header with
/// navigation, account drawer, wider content.
const wideLayoutBreakpoint = 900.0;

bool isWideLayout(BuildContext context) =>
    MediaQuery.sizeOf(context).width >= wideLayoutBreakpoint;

/// The page's back button, phone header or wide title row (for tests).
const backButtonKey = ValueKey('back');

/// Content widths on wide screens.
abstract final class SiteWidth {
  /// The page: header, lists and grids.
  static const wide = 1200.0;

  /// No limit inside the page.
  static const full = double.infinity;

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
    this.narrowHeader,
    this.showTitle = true,
    this.accountNav = false,
  });

  final String title;
  final Widget body;

  /// Shown in the app bar on phones, next to the title on wide screens.
  final List<Widget> actions;

  /// Phones only; wide screens show [actions] instead.
  final Widget? floatingActionButton;
  final double maxWidth;

  /// Replaces the default header on phones.
  final Widget? narrowHeader;
  final bool showTitle;

  /// Shows the account sidebar on wide screens.
  final bool accountNav;

  @override
  Widget build(BuildContext context) {
    if (!isWideLayout(context)) {
      return Scaffold(
        floatingActionButton: floatingActionButton,
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SafeArea(
              bottom: false,
              child:
                  narrowHeader ??
                  FHeader.nested(
                    title: Text(title),
                    prefixes: [
                      if (context.canPop())
                        FHeaderAction.back(
                          key: backButtonKey,
                          onPress: () => context.pop(),
                        ),
                    ],
                    suffixes: actions,
                  ),
            ),
            Expanded(child: body),
          ],
        ),
      );
    }

    final theme = context.theme;
    // Title and content, left-aligned; [maxWidth] limits the content only.
    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (showTitle)
          Padding(
            // Page bodies keep 16 px side padding; the title lines up.
            padding: EdgeInsets.fromLTRB(context.canPop() ? 4 : 16, 24, 16, 8),
            child: Row(
              children: [
                if (context.canPop()) ...[
                  FButton.icon(
                    key: backButtonKey,
                    variant: FButtonVariant.ghost,
                    semanticsLabel: MaterialLocalizations.of(context)
                        .backButtonTooltip,
                    onPress: () => context.pop(),
                    child: const Icon(FLucideIcons.arrowLeft),
                  ),
                  const SizedBox(width: 8),
                ],
                Expanded(
                  child: Text(
                    title,
                    style: theme.typography.display.xl2.copyWith(
                      fontWeight: FontWeight.w700,
                      color: theme.colors.foreground,
                    ),
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  spacing: 8,
                  children: actions,
                ),
              ],
            ),
          ),
        Expanded(
          child: Align(
            alignment: Alignment.topLeft,
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: maxWidth),
              child: body,
            ),
          ),
        ),
      ],
    );

    return Scaffold(
      endDrawer: const AccountDrawer(),
      body: Column(
        children: [
          const SiteHeader(),
          Expanded(
            child: Align(
              alignment: Alignment.topCenter,
              child: ConstrainedBox(
                // Every page shares the header's width.
                constraints: const BoxConstraints(maxWidth: SiteWidth.wide),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: accountNav
                      ? Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const SizedBox(width: 248, child: AccountSidebar()),
                            const SizedBox(width: 32),
                            Expanded(child: content),
                          ],
                        )
                      : content,
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
    final theme = context.theme;
    final user = ref.watch(authStateProvider).value;
    final profile = ref.watch(profileProvider).value;
    final location = GoRouterState.of(context).uri.path;

    Widget link(String label, String path) {
      final active = location == path;
      return FButton(
        variant: FButtonVariant.ghost,
        mainAxisSize: MainAxisSize.min,
        selected: active,
        onPress: () => context.go(path),
        child: Text(
          label,
          style: TextStyle(
            color: active
                ? theme.colors.foreground
                : theme.colors.mutedForeground,
            fontWeight: active ? FontWeight.w600 : FontWeight.w500,
          ),
          overflow: TextOverflow.ellipsis,
        ),
      );
    }

    void signIn({bool signUp = false}) {
      ref.read(guestModeProvider.notifier).exit();
      context.go('/login');
      if (signUp) context.push('/signup');
    }

    return ColoredBox(
      color: theme.colors.background,
      child: Container(
        height: 64,
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: theme.colors.border)),
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: SiteWidth.wide),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                spacing: 4,
                children: [
                  FTappable(
                    semanticsLabel: l10n.appTitle,
                    onPress: () => context.go('/'),
                    child: const Padding(
                      padding: EdgeInsets.all(6),
                      child: BrandHeader(markSize: 32, wordmarkHeight: 22),
                    ),
                  ),
                  const SizedBox(width: 20),
                  link(l10n.navEvents, '/'),
                  link(l10n.sellTickets, '/sell'),
                  if (user != null)
                    link(l10n.navMyTickets, '/account/purchases'),
                  const Spacer(),
                  if (user == null) ...[
                    FButton.icon(
                      variant: FButtonVariant.ghost,
                      semanticsLabel: l10n.settingsTitle,
                      onPress: () => context.push('/settings'),
                      child: const Icon(FLucideIcons.settings),
                    ),
                    FButton(
                      variant: FButtonVariant.ghost,
                      mainAxisSize: MainAxisSize.min,
                      onPress: signIn,
                      child: Text(
                        l10n.loginButton,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    FButton(
                      mainAxisSize: MainAxisSize.min,
                      onPress: () => signIn(signUp: true),
                      child: Text(l10n.signUp, overflow: TextOverflow.ellipsis),
                    ),
                  ] else
                    Builder(
                      builder: (context) => FTooltip(
                        tipBuilder: (context, _) => Text(l10n.openAccountMenu),
                        child: FTappable(
                          semanticsLabel: l10n.openAccountMenu,
                          onPress: () => Scaffold.of(context).openEndDrawer(),
                          child: Padding(
                            padding: const EdgeInsets.all(4),
                            child: Row(
                              children: [
                                UserAvatar(
                                  size: 36,
                                  photoBase64: profile?.photoBase64,
                                  name:
                                      profile?.displayName ??
                                      user.displayName ??
                                      user.email,
                                  // The account page shows the flying one.
                                  hero: false,
                                ),
                                const SizedBox(width: 4),
                                Icon(
                                  FLucideIcons.chevronDown,
                                  size: 16,
                                  color: theme.colors.mutedForeground,
                                ),
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
