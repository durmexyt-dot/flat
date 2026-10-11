import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../l10n/app_localizations.dart';
import '../account/avatar.dart';
import '../auth/auth_repository.dart';
import '../auth/auth_widgets.dart';
import '../brand/brand.dart';
import '../data/models.dart';
import '../data/repositories.dart';
import '../market/labels.dart';
import '../market/listing_ticket.dart';
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
  void dispose() {
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
      ScaffoldMessenger.of(context),
      l10n.guestSignInPrompt,
      action: SnackBarAction(
        label: l10n.loginButton,
        onPressed: () => ref.read(guestModeProvider.notifier).exit(),
      ),
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
      narrowAppBar: _narrowAppBar(context),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _sell,
        icon: const Icon(Icons.sell_outlined),
        label: Text(l10n.sellTickets),
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
              style: wide
                  ? Theme.of(context).textTheme.headlineSmall
                        ?.copyWith(fontWeight: FontWeight.w700)
                  : Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            _listings(context),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _narrowAppBar(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final user = ref.watch(authStateProvider).value;
    final profile = ref.watch(profileProvider).value;
    return AppBar(
      titleSpacing: 16,
      title: const Align(
        alignment: Alignment.centerLeft,
        child: BrandHeader(markSize: 32, wordmarkHeight: 22),
      ),
      actions: [
        if (user == null)
          const SettingsButton()
        else
          IconButton(
            tooltip: l10n.settingsTitle,
            onPressed: () => context.push('/settings'),
            icon: UserAvatar(
              size: 34,
              photoBase64: profile?.photoBase64,
              name: profile?.displayName ?? user.displayName ?? user.email,
            ),
          ),
        const SizedBox(width: 4),
      ],
    );
  }

  Widget _narrowIntro(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
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
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          l10n.homeHeadline,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w700,
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
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return Container(
      padding: const EdgeInsets.fromLTRB(40, 40, 40, 32),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [colors.primaryContainer, colors.tertiaryContainer],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: Text(
              l10n.heroTitle,
              style: theme.textTheme.displaySmall?.copyWith(
                fontWeight: FontWeight.w800,
                color: colors.onPrimaryContainer,
                height: 1.1,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            l10n.heroSubtitle,
            style: theme.textTheme.titleMedium?.copyWith(
              color: colors.onPrimaryContainer,
            ),
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
    return SearchBar(
      controller: _search,
      hintText: l10n.searchHint,
      leading: const Icon(Icons.search),
      trailing: [
        if (_search.text.isNotEmpty)
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => setState(_search.clear),
          ),
      ],
      onChanged: (_) => setState(() {}),
      elevation: const WidgetStatePropertyAll(0),
      padding: const WidgetStatePropertyAll(
        EdgeInsets.symmetric(horizontal: 16),
      ),
    );
  }

  Widget _categories(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (final c in EventCategory.values.where(
            (c) => c != EventCategory.other,
          ))
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilterChip(
                avatar: Icon(categoryIcon(c), size: 18),
                label: Text(categoryName(l10n, c)),
                selected: _category == c,
                onSelected: (on) => setState(() => _category = on ? c : null),
              ),
            ),
        ],
      ),
    );
  }

  Widget _guestBanner(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = Theme.of(context).colorScheme;
    return Card.filled(
      margin: EdgeInsets.zero,
      color: colors.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(Icons.lock_open_outlined, color: colors.onPrimaryContainer),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                l10n.guestSignInPrompt,
                style: TextStyle(color: colors.onPrimaryContainer),
              ),
            ),
            TextButton(
              onPressed: () => ref.read(guestModeProvider.notifier).exit(),
              child: Text(l10n.loginButton),
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
                icon: Icons.local_activity_outlined,
                title: l10n.noEvents,
                message: l10n.noEventsInfo,
              );
            }
            final shown = all.where(_matches).toList();
            if (shown.isEmpty) {
              return EmptyState(
                icon: Icons.search_off,
                title: l10n.searchNoResults(_search.text.trim()),
              );
            }
            return grid([
              for (final l in shown)
                ListingTicket(
                  listing: l,
                  onTap: () => context.push('/listing/${l.id}', extra: l),
                ),
            ]);
          },
        );
      },
    );
  }
}
