import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../l10n/app_localizations.dart';
import '../account/profile_header.dart';
import '../auth/auth_repository.dart';
import '../brand/brand.dart';
import '../data/repositories.dart';
import '../ui/site_scaffold.dart';
import 'appearance_page.dart';
import 'settings_controller.dart';
import 'settings_widgets.dart';

/// Shown in the about dialog; keep in sync with pubspec.yaml.
const appVersion = '1.0.0';

/// Account hub: profile on top, then grouped settings.
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
    final payoutMethod = user == null
        ? null
        : ref.watch(payoutMethodProvider).value;

    final Widget? header = user != null
        ? const ProfileHeader()
        : isGuest
        ? _GuestCard(
            onSignIn: () {
              ref.read(guestModeProvider.notifier).exit();
              context.go('/login');
            },
          )
        : null;
    final sections = <Widget>[
      if (user != null) ...[
        SettingsSectionTitle(l10n.buying),
        SettingsGroup(
          children: [
            SettingsLinkTile(
              icon: Icons.receipt_long_outlined,
              title: l10n.purchases,
              onTap: () => context.push('/account/purchases'),
            ),
          ],
        ),
        SettingsSectionTitle(l10n.selling),
        SettingsGroup(
          children: [
            SettingsLinkTile(
              icon: Icons.sell_outlined,
              title: l10n.myListings,
              onTap: () => context.push('/account/listings'),
            ),
            SettingsLinkTile(
              icon: Icons.point_of_sale_outlined,
              title: l10n.sales,
              onTap: () => context.push('/account/sales'),
            ),
            SettingsLinkTile(
              icon: Icons.account_balance_wallet_outlined,
              title: l10n.payouts,
              onTap: () => context.push('/account/payouts'),
            ),
            SettingsLinkTile(
              icon: Icons.account_balance_outlined,
              title: l10n.payoutMethod,
              subtitle: payoutMethod?.masked ?? l10n.payoutMethodMissing,
              onTap: () => context.push('/account/payout-method'),
            ),
          ],
        ),
      ],
      SettingsSectionTitle(l10n.personalization),
      SettingsGroup(
        children: [
          SettingsLinkTile(
            icon: Icons.palette_outlined,
            title: l10n.appearance,
            subtitle:
                '${themeModeName(l10n, settings.themeMode)} · '
                '${brandColorName(l10n, settings.color)} · '
                '${uiStyleName(l10n, settings.uiStyle)}',
            onTap: () => context.push('/settings/appearance'),
          ),
          ListTile(
            shape: const RoundedRectangleBorder(),
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
            shape: const RoundedRectangleBorder(),
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
        ],
      ),
      SettingsSectionTitle(l10n.support),
      SettingsGroup(
        children: [
          SettingsLinkTile(
            icon: Icons.help_outline,
            title: l10n.helpCenter,
            onTap: () => context.push('/support'),
          ),
          if (user != null)
            SettingsLinkTile(
              icon: Icons.support_agent,
              title: l10n.contactSupport,
              onTap: () => context.push('/support/new'),
            ),
          SettingsLinkTile(
            icon: Icons.info_outline,
            title: l10n.about,
            onTap: () => showAboutDialog(
              context: context,
              applicationName: 'Stubswap',
              applicationVersion: appVersion,
              applicationIcon: const BrandMark(size: 48),
              children: [Text(l10n.aboutText)],
            ),
          ),
        ],
      ),
      if (user != null) ...[
        SettingsSectionTitle(l10n.account),
        SettingsGroup(
          children: [
            SettingsLinkTile(
              icon: Icons.notifications_outlined,
              title: l10n.notifications,
              onTap: () => context.push('/settings/notifications'),
            ),
            SettingsLinkTile(
              icon: Icons.shield_outlined,
              title: l10n.privacySecurity,
              trailing: user.emailVerified
                  ? null
                  : Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 18,
                          color: theme.colorScheme.error,
                        ),
                        const Icon(Icons.chevron_right),
                      ],
                    ),
              onTap: () => context.push('/settings/privacy'),
            ),
          ],
        ),
        const SizedBox(height: 24),
        SettingsGroup(
          children: [
            ListTile(
              shape: const RoundedRectangleBorder(),
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
          ],
        ),
      ],
    ];
    final wide = isWideLayout(context);

    return SiteScaffold(
      title: l10n.settingsTitle,
      maxWidth: SiteWidth.wide,
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(statsProvider);
          await ref.read(statsProvider.future).catchError((_) => null);
        },
        child: wide
            // Website account page: profile on the left, settings right.
            ? SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 48),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (header != null) ...[
                      SizedBox(
                        width: 360,
                        child: Card.filled(
                          margin: EdgeInsets.zero,
                          color: theme.colorScheme.surfaceContainerLow,
                          child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: header,
                          ),
                        ),
                      ),
                      const SizedBox(width: 32),
                    ],
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: sections,
                      ),
                    ),
                  ],
                ),
              )
            : ListView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
                children: [?header, ...sections],
              ),
      ),
    );
  }
}

class _GuestCard extends StatelessWidget {
  const _GuestCard({required this.onSignIn});

  final VoidCallback onSignIn;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return Card.filled(
      margin: EdgeInsets.zero,
      color: theme.colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            CircleAvatar(
              radius: 32,
              backgroundColor: theme.colorScheme.primary,
              child: Icon(
                Icons.person_outline,
                size: 32,
                color: theme.colorScheme.onPrimary,
              ),
            ),
            const SizedBox(height: 12),
            Text(l10n.guest, style: theme.textTheme.titleLarge),
            const SizedBox(height: 4),
            Text(
              l10n.guestSignInPrompt,
              textAlign: TextAlign.center,
              style: TextStyle(color: theme.colorScheme.onPrimaryContainer),
            ),
            const SizedBox(height: 16),
            FilledButton(onPressed: onSignIn, child: Text(l10n.signInOrUp)),
          ],
        ),
      ),
    );
  }
}
