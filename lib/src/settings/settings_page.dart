import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../l10n/app_localizations.dart';
import '../auth/auth_repository.dart';
import 'appearance_page.dart';
import 'settings_controller.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final settings = ref.watch(settingsProvider);
    final controller = ref.read(settingsProvider.notifier);
    final user = ref.watch(authStateProvider).value;
    final isGuest = ref.watch(guestModeProvider);

    Widget section(String title) => Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Text(
        title,
        style: theme.textTheme.labelLarge?.copyWith(
          color: theme.colorScheme.primary,
        ),
      ),
    );

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settingsTitle)),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 32),
        children: [
          section(l10n.appearance),
          ListTile(
            leading: const Icon(Icons.palette_outlined),
            title: Text(l10n.appearance),
            subtitle: Text(
              '${themeModeName(l10n, settings.themeMode)} · '
              '${brandColorName(l10n, settings.color)} · '
              '${uiStyleName(l10n, settings.uiStyle)}',
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/settings/appearance'),
          ),
          ListTile(
            leading: const Icon(Icons.language),
            title: Text(l10n.language),
            trailing: DropdownButton<String>(
              value: settings.locale.languageCode,
              underline: const SizedBox.shrink(),
              onChanged: (code) => controller.setLocale(Locale(code!)),
              items: [
                for (final e in languageNames.entries)
                  DropdownMenuItem(value: e.key, child: Text(e.value)),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.payments_outlined),
            title: Text(l10n.currency),
            trailing: DropdownButton<Currency>(
              value: settings.currency,
              underline: const SizedBox.shrink(),
              onChanged: (c) => controller.setCurrency(c!),
              items: [
                for (final c in Currency.values)
                  DropdownMenuItem(
                    value: c,
                    child: Text('${c.code} (${c.symbol})'),
                  ),
              ],
            ),
          ),
          if (user != null || isGuest) section(l10n.account),
          if (user != null) ...[
            ListTile(
              leading: CircleAvatar(
                child: Text(
                  (user.displayName ?? user.email ?? '?').characters.first
                      .toUpperCase(),
                ),
              ),
              title: Text(user.displayName ?? user.email ?? ''),
              subtitle: Text('${l10n.signedInAs} ${user.email ?? ''}'),
            ),
            ListTile(
              leading: Icon(Icons.logout, color: theme.colorScheme.error),
              title: Text(
                l10n.logoutButton,
                style: TextStyle(color: theme.colorScheme.error),
              ),
              onTap: () async {
                await ref.read(authRepositoryProvider).signOut();
                if (context.mounted) context.go('/login');
              },
            ),
          ] else if (isGuest) ...[
            ListTile(
              leading: const CircleAvatar(child: Icon(Icons.person_outline)),
              title: Text(l10n.guest),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: FilledButton(
                onPressed: () {
                  ref.read(guestModeProvider.notifier).exit();
                  context.go('/login');
                },
                child: Text(l10n.signInOrUp),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
