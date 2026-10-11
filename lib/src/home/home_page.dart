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
import '../data/events_repository.dart';
import '../data/models.dart';
import '../data/repositories.dart';
import '../events/genres.dart';
import '../events/recently_viewed.dart';
import '../location/location_controller.dart';
import '../market/labels.dart';
import '../ui/app_style.dart';
import '../ui/async_view.dart';
import '../ui/segmented.dart';
import '../ui/site_footer.dart';
import '../ui/site_scaffold.dart';
import '../ui/snack.dart';
import 'city_picker.dart';
import 'event_row.dart';
import 'home_sections.dart';

/// Event discovery: filters by city and type, rows of recently viewed,
/// popular, recommended and nearby events, popular categories and all
/// events. Open to guests too.
class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  final _search = TextEditingController();

  /// The chosen event type; null for all.
  EventCategory? _type;

  /// The section whose card was opened last: only its pictures fly, as an
  /// event can be in several sections.
  String? _heroSection;

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

  bool _matches(AppLocalizations l10n, Event e) {
    final q = _search.text.trim().toLowerCase();
    if (q.isEmpty) return true;
    return [
      e.info.name,
      e.info.venue,
      e.info.city,
      if (e.genre.isNotEmpty) genreName(l10n, e.genre),
    ].any((s) => s.toLowerCase().contains(q));
  }

  void _open(String section, Event e) {
    setState(() => _heroSection = section);
    context.push('/event/${e.id}', extra: e);
  }

  /// Signed-in users go to [path]; guests are asked to sign in.
  void _signedInOnly(String path) {
    final l10n = AppLocalizations.of(context);
    if (ref.read(currentUidProvider) != null) {
      context.push(path);
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
    final events = ref.watch(upcomingEventsProvider);
    final types = homeTypes(events.value ?? const []);
    final type = types.contains(_type) ? _type : null;
    // Phones: content keeps 16 px to the edge, rows scroll up to it.
    final gutter = wide ? 0.0 : 16.0;
    Widget padded(Widget child) => wide
        ? child
        : Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: child,
          );

    return SiteScaffold(
      title: l10n.navEvents,
      showTitle: false,
      maxWidth: SiteWidth.wide,
      narrowHeader: _narrowHeader(context),
      floatingActionButton: FButton(
        mainAxisSize: MainAxisSize.min,
        onPress: () => _signedInOnly('/sell'),
        prefix: const Icon(FLucideIcons.tag),
        child: Text(l10n.sellTickets, overflow: TextOverflow.ellipsis),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref
            ..invalidate(eventsProvider)
            ..invalidate(activeListingsProvider);
        },
        child: ListView(
          padding: wide
              ? const EdgeInsets.fromLTRB(16, 32, 16, 32)
              : const EdgeInsets.only(top: 8),
          children: [
            padded(wide ? _wideIntro(context) : _narrowIntro(context)),
            const SizedBox(height: 16),
            padded(_filters(context, types, type)),
            if (ref.watch(authStateProvider).value == null) ...[
              const SizedBox(height: 12),
              padded(_guestBanner(context)),
            ],
            SizedBox(height: wide ? 40 : 28),
            AsyncView<List<Event>>(
              value: events,
              onRetry: () => ref.invalidate(eventsProvider),
              loading: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                spacing: 32,
                children: [
                  for (var i = 0; i < 2; i++) SkeletonEventRow(gutter: gutter),
                ],
              ),
              data: (all) => all.isEmpty
                  ? EmptyState(
                      icon: FLucideIcons.ticket,
                      title: l10n.noEvents,
                      message: l10n.noEventsInfo,
                      action: FButton(
                        mainAxisSize: MainAxisSize.min,
                        prefix: const Icon(FLucideIcons.calendarPlus),
                        onPress: () => _signedInOnly('/events/new'),
                        child: Text(
                          l10n.homeAddEvent,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    )
                  : _sections(context, all, type, gutter, padded),
            ),
            SizedBox(height: wide ? 56 : 40),
            SiteFooter(bottomInset: wide ? 0 : 72),
          ],
        ),
      ),
    );
  }

  /// City and event type.
  Widget _filters(
    BuildContext context,
    List<EventCategory> types,
    EventCategory? type,
  ) {
    final l10n = AppLocalizations.of(context);
    final theme = context.theme;
    final wide = isWideLayout(context);
    final chosen = ref.watch(chosenCityProvider);

    final city = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(
          child: FButton(
            variant: FButtonVariant.outline,
            mainAxisSize: MainAxisSize.min,
            prefix: const Icon(FLucideIcons.mapPin),
            suffix: const Icon(FLucideIcons.chevronDown),
            onPress: () => showCityPicker(context),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: Text(
                chosen?.name ?? l10n.homeCityPick,
                key: ValueKey(chosen?.name),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ),
        if (chosen?.source == CitySource.location) ...[
          const SizedBox(width: 10),
          Flexible(
            child: Text(
              l10n.homeCityFromLocation,
              overflow: TextOverflow.ellipsis,
              style: theme.typography.body.xs.copyWith(
                color: theme.colors.mutedForeground,
              ),
            ),
          ),
        ],
      ],
    );
    if (types.isEmpty) {
      return Align(alignment: Alignment.centerLeft, child: city);
    }

    final typeBar = Segmented<EventCategory?>(
      values: [null, ...types],
      selected: type,
      scrollable: !wide,
      label: (c) => c == null ? l10n.homeAllTypes : categoryName(l10n, c),
      icon: (c) => c == null ? FLucideIcons.layoutGrid : categoryIcon(c),
      onChanged: (c) => setState(() => _type = c),
    );
    if (wide) {
      return Row(
        children: [
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 320),
            child: city,
          ),
          const SizedBox(width: 16),
          Expanded(child: typeBar),
        ],
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Align(alignment: Alignment.centerLeft, child: city),
        const SizedBox(height: 12),
        typeBar,
      ],
    );
  }

  Widget _sections(
    BuildContext context,
    List<Event> all,
    EventCategory? type,
    double gutter,
    Widget Function(Widget child) padded,
  ) {
    final l10n = AppLocalizations.of(context);
    final wide = isWideLayout(context);
    final city = ref.watch(homeCityProvider);
    final sections = buildHomeSections(
      events: all,
      offers: ref.watch(eventOffersProvider),
      recent: ref.watch(recentlyViewedEventsProvider),
      city: city?.name,
      type: type,
    );
    final gap = SizedBox(height: wide ? 48 : 36);

    // Searching shows only the matching events.
    final query = _search.text.trim();
    if (query.isNotEmpty) {
      final found = [
        for (final e in sections.all)
          if (_matches(l10n, e)) e,
      ];
      return padded(
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            HomeSectionHeader(title: l10n.homeSearchResults),
            const SizedBox(height: 12),
            if (found.isEmpty)
              EmptyState(
                icon: FLucideIcons.searchX,
                title: l10n.searchNoResults(query),
              )
            else
              EventGrid(
                events: found,
                heroes: _heroSection == 'search',
                onOpen: (e) => _open('search', e),
              ),
          ],
        ),
      );
    }

    Widget row(HomeSection s, {bool small = false}) {
      final (title, subtitle, actions) = switch (s.kind) {
        HomeSectionKind.recentlyViewed => (
          l10n.homeRecentlyViewed,
          null,
          const <Widget>[],
        ),
        HomeSectionKind.popular => (l10n.homePopular, null, const <Widget>[]),
        HomeSectionKind.recommended => (
          l10n.homeRecommended,
          null,
          const <Widget>[],
        ),
        HomeSectionKind.nearby => (
          l10n.homeNearby(city?.name ?? ''),
          switch (city?.source) {
            CitySource.location => l10n.homeCityFromLocation,
            CitySource.fallback => l10n.homeCityMostEvents,
            _ => null,
          },
          [
            FButton(
              variant: FButtonVariant.ghost,
              size: FButtonSizeVariant.sm,
              mainAxisSize: MainAxisSize.min,
              onPress: () => showCityPicker(context),
              child: Text(
                l10n.homeNearbyChange,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        HomeSectionKind.genre => (
          genreName(l10n, s.genre ?? ''),
          null,
          const <Widget>[],
        ),
        HomeSectionKind.category => (
          categoryName(l10n, s.category ?? EventCategory.other),
          null,
          const <Widget>[],
        ),
      };
      return EventRowSection(
        key: ValueKey(s.id),
        title: title,
        subtitle: subtitle,
        actions: actions,
        events: s.events,
        small: small,
        gutter: gutter,
        heroes: _heroSection == s.id,
        onOpen: (e) => _open(s.id, e),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final s in sections.rows) ...[row(s), gap],
        if (sections.popularCategories.isNotEmpty) ...[
          padded(HomeSectionHeader(title: l10n.homePopularCategories)),
          const SizedBox(height: 16),
          for (final (i, s) in sections.popularCategories.indexed) ...[
            if (i > 0) const SizedBox(height: 28),
            row(s, small: true),
          ],
          gap,
        ],
        padded(
          HomeSectionHeader(
            title: type == null
                ? l10n.homeAllEvents
                : l10n.homeAllEventsOfType(categoryName(l10n, type)),
          ),
        ),
        const SizedBox(height: 12),
        padded(
          EventGrid(
            events: sections.all,
            heroes: _heroSection == 'all',
            onOpen: (e) => _open('all', e),
          ),
        ),
      ],
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
}
