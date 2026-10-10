import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../l10n/app_localizations.dart';
import '../auth/auth_repository.dart';
import '../auth/auth_widgets.dart';
import '../account/avatar.dart';
import '../brand/brand.dart';
import '../data/repositories.dart';

/// Event discovery. Open to signed-in users and guests.
class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final user = ref.watch(authStateProvider).value;
    final profile = ref.watch(profileProvider).value;
    final isGuest = user == null;
    final fullName = profile?.displayName ?? user?.displayName;
    final name = fullName?.split(' ').first ?? user?.email ?? '';

    final categories = [
      (Icons.music_note_outlined, l10n.catConcerts),
      (Icons.sports_soccer_outlined, l10n.catSports),
      (Icons.theater_comedy_outlined, l10n.catTheater),
      (Icons.festival_outlined, l10n.catFestivals),
    ];

    void sell() {
      final messenger = ScaffoldMessenger.of(context)..hideCurrentSnackBar();
      messenger.showSnackBar(
        SnackBar(
          content: Text(isGuest ? l10n.guestSignInPrompt : l10n.comingSoon),
          action: isGuest
              ? SnackBarAction(
                  label: l10n.loginButton,
                  onPressed: () => ref.read(guestModeProvider.notifier).exit(),
                )
              : null,
        ),
      );
    }

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
              tooltip: AppLocalizations.of(context).settingsTitle,
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
        onPressed: sell,
        icon: const Icon(Icons.sell_outlined),
        label: Text(l10n.sellTickets),
      ),
      body: ListView(
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
            hintText: l10n.searchHint,
            leading: const Icon(Icons.search),
            elevation: const WidgetStatePropertyAll(0),
            padding: const WidgetStatePropertyAll(
              EdgeInsets.symmetric(horizontal: 16),
            ),
          ),
          const SizedBox(height: 16),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                for (final (icon, label) in categories)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ActionChip(
                      avatar: Icon(icon, size: 18),
                      label: Text(label),
                      onPressed: () {},
                    ),
                  ),
              ],
            ),
          ),
          if (isGuest) ...[
            const SizedBox(height: 16),
            Card.filled(
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
          const SizedBox(height: 48),
          Icon(
            Icons.local_activity_outlined,
            size: 64,
            color: theme.colorScheme.outline,
          ),
          const SizedBox(height: 12),
          Text(
            l10n.noEvents,
            textAlign: TextAlign.center,
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: 4),
          Text(
            l10n.noEventsInfo,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
