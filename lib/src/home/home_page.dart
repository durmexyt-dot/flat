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
import '../ui/skeleton.dart';

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
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(l10n.guestSignInPrompt),
          action: SnackBarAction(
            label: l10n.loginButton,
            onPressed: () => ref.read(guestModeProvider.notifier).exit(),
          ),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final user = ref.watch(authStateProvider).value;
    final profile = ref.watch(profileProvider).value;
    final listings = ref.watch(activeListingsProvider);
    final isGuest = user == null;
    final fullName = profile?.displayName ?? user?.displayName;
    final name = fullName?.split(' ').first ?? user?.email ?? '';

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 16,
        title: const Align(
          alignment: Alignment.centerLeft,
          child: BrandHeader(markSize: 32, wordmarkHeight: 22),
        ),
        actions: [
          if (isGuest)
            const SettingsButton()
          else
            IconButton(
              tooltip: l10n.settingsTitle,
              onPressed: () => context.push('/settings'),
              icon: UserAvatar(
                size: 34,
                photoBase64: profile?.photoBase64,
                name: fullName ?? user.email,
              ),
            ),
          const SizedBox(width: 4),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _sell,
        icon: const Icon(Icons.sell_outlined),
        label: Text(l10n.sellTickets),
      ),
      body: RefreshIndicator(
        onRefresh: () async => ref.invalidate(activeListingsProvider),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
          children: [
            Text(
              isGuest ? l10n.homeGuest : l10n.homeGreeting(name),
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
            SearchBar(
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
            ),
            const SizedBox(height: 12),
            SingleChildScrollView(
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
                        onSelected: (on) =>
                            setState(() => _category = on ? c : null),
                      ),
                    ),
                ],
              ),
            ),
            if (isGuest) ...[
              const SizedBox(height: 12),
              Card.filled(
                margin: EdgeInsets.zero,
                color: theme.colorScheme.primaryContainer,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Icon(
                        Icons.lock_open_outlined,
                        color: theme.colorScheme.onPrimaryContainer,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          l10n.guestSignInPrompt,
                          style: TextStyle(
                            color: theme.colorScheme.onPrimaryContainer,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () =>
                            ref.read(guestModeProvider.notifier).exit(),
                        child: Text(l10n.loginButton),
                      ),
                    ],
                  ),
                ),
              ),
            ],
            const SizedBox(height: 20),
            Text(l10n.upcomingEvents, style: theme.textTheme.titleMedium),
            const SizedBox(height: 12),
            AsyncView<List<Listing>>(
              value: listings,
              onRetry: () => ref.invalidate(activeListingsProvider),
              loading: const Shimmer(
                child: Column(
                  children: [
                    SkeletonTicketTile(),
                    SizedBox(height: 12),
                    SkeletonTicketTile(),
                    SizedBox(height: 12),
                    SkeletonTicketTile(),
                  ],
                ),
              ),
              data: (all) {
                final shown = all.where(_matches).toList();
                if (all.isEmpty) {
                  return EmptyState(
                    icon: Icons.local_activity_outlined,
                    title: l10n.noEvents,
                    message: l10n.noEventsInfo,
                  );
                }
                if (shown.isEmpty) {
                  return EmptyState(
                    icon: Icons.search_off,
                    title: l10n.searchNoResults(_search.text.trim()),
                  );
                }
                return Column(
                  children: [
                    for (final l in shown) ...[
                      ListingTicket(
                        listing: l,
                        onTap: () => context.push('/listing/${l.id}', extra: l),
                      ),
                      const SizedBox(height: 12),
                    ],
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
