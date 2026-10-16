import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:forui/forui.dart';

import '../../l10n/app_localizations.dart';
import '../account/account_drawer.dart';
import '../account/account_sidebar.dart';
import '../account/avatar.dart';
import '../support/support_badge.dart';
import '../admin/admin_repository.dart';
import '../auth/auth_repository.dart';
import '../brand/brand.dart';
import '../data/repositories.dart';
import 'app_tab_bar.dart';
import 'tokens.dart';
import '../router.dart';
import 'app_link.dart';

export 'tokens.dart' show SiteWidth, wideLayoutBreakpoint;

bool isWideLayout(BuildContext context) =>
    MediaQuery.sizeOf(context).width >= wideLayoutBreakpoint;

/// The page's back button, phone header or wide title row (for tests).
const backButtonKey = ValueKey('back');

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
    this.selectable = false,
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

  /// Shows the account sidebar on wide screens; the content then fills
  /// the page and [maxWidth] is ignored.
  final bool accountNav;

  /// Lets the text be selected and copied, e.g. order numbers, IBANs and
  /// tracking numbers on detail pages.
  final bool selectable;

  @override
  Widget build(BuildContext context) {
    final body = selectable ? SelectionArea(child: this.body) : this.body;
    if (!isWideLayout(context)) {
      final tabs = AppTabBar.isTabPath(GoRouterState.of(context).uri.path);
      return Scaffold(
        floatingActionButton: floatingActionButton,
        bottomNavigationBar: tabs ? const AppTabBar() : null,
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
                  const SizedBox(width: Space.md),
                ],
                Expanded(
                  child: Text(
                    title,
                    style: theme.typography.display.xl2.copyWith(
                      fontWeight: FontWeights.bold,
                      color: theme.colors.foreground,
                    ),
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  spacing: Space.md,
                  children: actions,
                ),
              ],
            ),
          ),
        Expanded(
          child: Align(
            alignment: Alignment.topLeft,
            child: ConstrainedBox(
              // Pages beside the account sidebar all fill the page, like
              // the profile, so switching between them doesn't jump.
              constraints: BoxConstraints(
                maxWidth: accountNav ? SiteWidth.full : maxWidth,
              ),
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
            child: _WindowScroll(
              child: Align(
                alignment: Alignment.topCenter,
                child: ConstrainedBox(
                  // Every page shares the header's width.
                  constraints: const BoxConstraints(maxWidth: SiteWidth.wide),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: Space.xl),
                    child: accountNav
                        ? Row(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // Its own list must not take the page's
                              // scroll controller.
                              const SizedBox(
                                width: 248,
                                child: PrimaryScrollController.none(
                                  child: AccountSidebar(),
                                ),
                              ),
                              const SizedBox(width: Space.x5l),
                              Expanded(child: content),
                            ],
                          )
                        : content,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// On wide screens the content sits in a centered column, but the page
/// scrolls like a website: the scrollbar is at the window's edge and the
/// mouse wheel works over the empty sides too.
///
/// The page's main vertical list (the first one without its own controller)
/// takes [_controller] as its primary scroll controller; its own scrollbar
/// is hidden and drawn here instead.
class _WindowScroll extends StatefulWidget {
  const _WindowScroll({required this.child});
  final Widget child;

  @override
  State<_WindowScroll> createState() => _WindowScrollState();
}

class _WindowScrollState extends State<_WindowScroll> {
  final _controller = ScrollController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool get _single => _controller.positions.length == 1;

  bool _fromMainList(ScrollNotification n) =>
      _single &&
      n.metrics.axis == Axis.vertical &&
      n.context == _controller.position.context.notificationContext;

  // Wheel over the sides: the list itself didn't take the event.
  void _onPointerSignal(PointerSignalEvent event) {
    if (event is! PointerScrollEvent || !_single) return;
    GestureBinding.instance.pointerSignalResolver.register(event, (e) {
      final delta = (e as PointerScrollEvent).scrollDelta.dy;
      if (delta != 0) _controller.position.pointerScroll(delta);
    });
  }

  @override
  Widget build(BuildContext context) {
    final behavior = ScrollConfiguration.of(context);
    return Listener(
      behavior: HitTestBehavior.opaque,
      onPointerSignal: _onPointerSignal,
      child: Scrollbar(
        controller: _controller,
        notificationPredicate: _fromMainList,
        child: PrimaryScrollController(
          controller: _controller,
          automaticallyInheritForPlatforms: TargetPlatform.values.toSet(),
          scrollDirection: Axis.vertical,
          child: ScrollConfiguration(
            behavior: _HideScrollbarOf(behavior, _controller),
            child: widget.child,
          ),
        ),
      ),
    );
  }
}

/// [parent], except that the list using [controller] gets no scrollbar.
class _HideScrollbarOf extends ScrollBehavior {
  const _HideScrollbarOf(this.parent, this.controller);
  final ScrollBehavior parent;
  final ScrollController controller;

  @override
  Widget buildScrollbar(
    BuildContext context,
    Widget child,
    ScrollableDetails details,
  ) => details.controller == controller
      ? child
      : parent.buildScrollbar(context, child, details);

  @override
  Widget buildOverscrollIndicator(
    BuildContext context,
    Widget child,
    ScrollableDetails details,
  ) => parent.buildOverscrollIndicator(context, child, details);

  @override
  Set<PointerDeviceKind> get dragDevices => parent.dragDevices;

  @override
  Set<LogicalKeyboardKey> get pointerAxisModifiers =>
      parent.pointerAxisModifiers;

  @override
  MultitouchDragStrategy getMultitouchDragStrategy(BuildContext context) =>
      parent.getMultitouchDragStrategy(context);

  @override
  TargetPlatform getPlatform(BuildContext context) =>
      parent.getPlatform(context);

  @override
  ScrollPhysics getScrollPhysics(BuildContext context) =>
      parent.getScrollPhysics(context);

  @override
  ScrollViewKeyboardDismissBehavior getKeyboardDismissBehavior(
    BuildContext context,
  ) => parent.getKeyboardDismissBehavior(context);

  @override
  GestureVelocityTrackerBuilder velocityTrackerBuilder(BuildContext context) =>
      parent.velocityTrackerBuilder(context);

  @override
  bool shouldNotify(_HideScrollbarOf oldDelegate) =>
      parent.runtimeType != oldDelegate.parent.runtimeType ||
      parent.shouldNotify(oldDelegate.parent) ||
      controller != oldDelegate.controller;
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
    final staff = user != null && ref.watch(isStaffProvider);

    Widget link(String label, String path) {
      final active = location == path;
      Widget button(VoidCallback tap) => FButton(
        variant: FButtonVariant.ghost,
        mainAxisSize: MainAxisSize.min,
        selected: active,
        onPress: tap,
        child: Text(
          label,
          style: TextStyle(
            color: active
                ? theme.colors.foreground
                : theme.colors.mutedForeground,
            fontWeight: active ? FontWeights.semibold : FontWeights.medium,
          ),
          overflow: TextOverflow.ellipsis,
        ),
      );
      return AppLink(
        path: path,
        onTap: () => context.go(path),
        builder: button,
      );
    }

    void signIn({bool signUp = false}) => openSignIn(context, signUp: signUp);

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
              padding: const EdgeInsets.symmetric(horizontal: Space.xl),
              child: Row(
                spacing: Space.xs,
                children: [
                  FTappable(
                    semanticsLabel: l10n.appTitle,
                    onPress: () => context.go('/'),
                    child: const Padding(
                      padding: EdgeInsets.all(Space.sm),
                      child: BrandHeader(markSize: 32, wordmarkHeight: 22),
                    ),
                  ),
                  const SizedBox(width: Space.xxl),
                  link(l10n.navEvents, '/'),
                  // Team accounts don't buy or sell.
                  if (!staff) ...[
                    link(l10n.sellTickets, '/sell'),
                    if (user != null)
                      link(l10n.navMyTickets, '/account/purchases'),
                  ],
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
                      builder: (context) => MergeSemantics(
                        child: FTooltip(
                          tipBuilder: (context, _) =>
                              Text(l10n.openAccountMenu),
                          child: FTappable(
                            semanticsLabel: l10n.openAccountMenu,
                            onPress: () => Scaffold.of(context).openEndDrawer(),
                            child: Padding(
                              padding: const EdgeInsets.all(Space.xs),
                              child: Row(
                                children: [
                                  AccountBadge(
                                    child: UserAvatar(
                                      size: 36,
                                      photoBase64: profile?.photoBase64,
                                      name:
                                          profile?.displayName ??
                                          user.displayName ??
                                          user.email,
                                      // The account page shows the flying one.
                                      hero: false,
                                    ),
                                  ),
                                  const SizedBox(width: Space.xs),
                                  Icon(
                                    FLucideIcons.chevronDown,
                                    size: IconSizes.sm,
                                    color: theme.colors.mutedForeground,
                                  ),
                                ],
                              ),
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
