import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:forui/forui.dart';

import '../../l10n/app_localizations.dart';
import '../account/avatar.dart';
import '../support/support_badge.dart';
import '../auth/auth_repository.dart';
import '../auth/auth_widgets.dart';
import '../brand/brand.dart';
import '../data/models.dart';
import '../data/repositories.dart';
import '../market/labels.dart';
import '../market/listing_ticket.dart';
import '../ui/app_style.dart';
import '../ui/async_view.dart';
import '../ui/site_scaffold.dart';
import '../ui/skeleton.dart';
import '../ui/snack.dart';

/// Event discovery: listings from all sellers. Open to guests too.
class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  final _search = TextEditingController();
  EventCategory? _category;

  @override
  void initState() {
    super.initState();
    // Rebuild on typing and when the clear button empties the field.
    _search.addListener(_onSearchChanged);
  }

  void _onSearchChanged() => setState(() {});

  @override
  void dispose() {
    _search.removeListener(_onSearchChanged);
    _search.dispose();
    super.dispose();
  }

  bool _matches(Listing l) {
    if (_category != null && l.event.category != _category) return false;
    final q = _search.text.trim().toLowerCase();
    if (q.isEmpty) return true;
    return [
      l.event.name,
      l.event.venue,
      l.event.city,
    ].any((s) => s.toLowerCase().contains(q));
  }

  void _sell() {
    final l10n = AppLocalizations.of(context);
    if (ref.read(currentUidProvider) != null) {
      context.push('/sell');
      return;
    }
    showSnack(
      l10n.guestSignInPrompt,
      actionLabel: l10n.loginButton,
      onAction: () => ref.read(guestModeProvider.notifier).exit(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final wide = isWideLayout(context);

    return SiteScaffold(
      title: l10n.navEvents,
      showTitle: false,
      maxWidth: SiteWidth.wide,
      narrowHeader: _narrowHeader(context),
      floatingActionButton: FButton(
        mainAxisSize: MainAxisSize.min,
        onPress: _sell,
        prefix: const Icon(FLucideIcons.tag),
        child: Text(l10n.sellTickets, overflow: TextOverflow.ellipsis),
      ),
      body: RefreshIndicator(
        onRefresh: () async => ref.invalidate(activeListingsProvider),
        child: ListView(
          padding: wide
              ? const EdgeInsets.fromLTRB(16, 32, 16, 48)
              : const EdgeInsets.fromLTRB(16, 8, 16, 96),
          children: [
            if (wide) _wideIntro(context) else _narrowIntro(context),
            const SizedBox(height: 12),
            _categories(context),
            if (ref.watch(authStateProvider).value == null) ...[
              const SizedBox(height: 12),
              _guestBanner(context),
            ],
            const SizedBox(height: 24),
            Text(
              l10n.upcomingEvents,
              style:
                  (wide
                          ? context.theme.typography.display.xl
                          : context.theme.typography.body.lg)
                      .copyWith(
                        fontWeight: FontWeight.w600,
                        color: context.theme.colors.foreground,
                      ),
            ),
            const SizedBox(height: 12),
            _listings(context),
          ],
        ),
      ),
    );
  }

  Widget _narrowHeader(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final user = ref.watch(authStateProvider).value;
    final profile = ref.watch(profileProvider).value;
    return FHeader(
      title: const Align(
        alignment: Alignment.centerLeft,
        child: BrandHeader(markSize: 32, wordmarkHeight: 22),
      ),
      suffixes: [
        if (user == null)
          const SettingsButton()
        else
          FTooltip(
            tipBuilder: (context, _) => Text(l10n.settingsTitle),
            child: FTappable(
              semanticsLabel: l10n.settingsTitle,
              onPress: () => context.push('/settings'),
              child: AccountBadge(
                child: UserAvatar(
                  size: 34,
                  photoBase64: profile?.photoBase64,
                  name: profile?.displayName ?? user.displayName ?? user.email,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _narrowIntro(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = context.theme;
    final user = ref.watch(authStateProvider).value;
    final profile = ref.watch(profileProvider).value;
    final name =
        (profile?.displayName ?? user?.displayName)?.split(' ').first ??
        user?.email ??
        '';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          user == null ? l10n.homeGuest : l10n.homeGreeting(name),
          style: theme.typography.body.md.copyWith(
            color: theme.colors.mutedForeground,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          l10n.homeHeadline,
          style: theme.typography.display.xl.copyWith(
            fontWeight: FontWeight.w700,
            color: theme.colors.foreground,
          ),
        ),
        const SizedBox(height: 16),
        _searchBar(context),
      ],
    );
  }

  /// A landing section like on a website: big headline and a wide search.
  Widget _wideIntro(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final type = context.theme.typography;
    final colors = context.theme.colors;
    return Container(
      padding: const EdgeInsets.fromLTRB(40, 40, 40, 32),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppStyle.of(context).cardRadius),
        color: colors.muted,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: Text(
              l10n.heroTitle,
              style: type.display.xl3.copyWith(
                fontWeight: FontWeight.w800,
                color: colors.foreground,
                height: 1.1,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            l10n.heroSubtitle,
            style: type.body.lg.copyWith(color: colors.mutedForeground),
          ),
          const SizedBox(height: 28),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: _searchBar(context),
          ),
        ],
      ),
    );
  }

  Widget _searchBar(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return FTextField(
      control: FTextFieldControl.managed(controller: _search),
      hint: l10n.searchHint,
      textInputAction: TextInputAction.search,
      prefixBuilder: (context, style, variants) =>
          fieldIcon(FLucideIcons.search),
      clearable: (value) => value.text.isNotEmpty,
    );
  }

  Widget _categories(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        spacing: 8,
        children: [
          for (final c in EventCategory.values.where(
            (c) => c != EventCategory.other,
          ))
            FButton(
              size: FButtonSizeVariant.sm,
              mainAxisSize: MainAxisSize.min,
              variant: _category == c
                  ? FButtonVariant.primary
                  : FButtonVariant.outline,
              prefix: Icon(categoryIcon(c)),
              onPress: () =>
                  setState(() => _category = _category == c ? null : c),
              child: Text(
                categoryName(l10n, c),
                overflow: TextOverflow.ellipsis,
              ),
            ),
        ],
      ),
    );
  }

  Widget _guestBanner(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.theme.colors;
    return FCard(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 12, 12),
        child: Row(
          children: [
            Icon(
              FLucideIcons.lockOpen,
              size: 20,
              color: colors.mutedForeground,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                l10n.guestSignInPrompt,
                style: context.theme.typography.body.sm.copyWith(
                  color: colors.foreground,
                ),
              ),
            ),
            const SizedBox(width: 8),
            FButton(
              variant: FButtonVariant.outline,
              size: FButtonSizeVariant.sm,
              mainAxisSize: MainAxisSize.min,
              onPress: () => ref.read(guestModeProvider.notifier).exit(),
              child: Text(l10n.loginButton, overflow: TextOverflow.ellipsis),
            ),
          ],
        ),
      ),
    );
  }

  /// Listings in as many columns as fit (one on phones).
  Widget _listings(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final listings = ref.watch(activeListingsProvider);
    return LayoutBuilder(
      builder: (context, constraints) {
        const gap = 16.0;
        final columns = (constraints.maxWidth / 380).floor().clamp(1, 3);
        final itemWidth =
            (constraints.maxWidth - gap * (columns - 1)) / columns;

        Widget grid(List<Widget> children) => Wrap(
          spacing: gap,
          runSpacing: gap,
          children: [
            for (final c in children) SizedBox(width: itemWidth, child: c),
          ],
        );

        return AsyncView<List<Listing>>(
          value: listings,
          onRetry: () => ref.invalidate(activeListingsProvider),
          loading: Shimmer(
            child: grid([
              for (var i = 0; i < columns * 2; i++) const SkeletonTicketTile(),
            ]),
          ),
          data: (all) {
            if (all.isEmpty) {
              return EmptyState(
                icon: FLucideIcons.ticket,
                title: l10n.noEvents,
                message: l10n.noEventsInfo,
              );
            }
            final shown = all.where(_matches).toList();
            if (shown.isEmpty) {
              return EmptyState(
                icon: FLucideIcons.searchX,
                title: l10n.searchNoResults(_search.text.trim()),
              );
            }
            return grid([
              for (final l in shown)
                ListingTicket(
                  listing: l,
                  own: l.sellerId == ref.watch(currentUidProvider),
                  onTap: () => context.push('/listing/${l.id}', extra: l),
                ),
            ]);
          },
        );
      },
    );
  }
}
