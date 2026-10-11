import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:forui/forui.dart';

import '../../l10n/app_localizations.dart';
import '../account/profile_header.dart';
import '../auth/auth_repository.dart';
import '../brand/brand.dart';
import '../data/repositories.dart';
import '../ui/app_dialog.dart';
import '../config/app_info.dart';
import '../ui/site_scaffold.dart';
import 'appearance_page.dart';
import 'settings_controller.dart';
import 'settings_widgets.dart';

/// Shown in the about dialog; keep in sync with pubspec.yaml.

/// Account hub: profile on top, then grouped settings.
class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = context.theme;
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
    // On wide screens the sidebar holds buying, selling and account links.
    final wide = isWideLayout(context);
    final sections = <Widget>[
      if (user != null && !wide) ...[
        SettingsSectionTitle(l10n.buying),
        SettingsGroup(
          children: [
            SettingsLinkTile(
              icon: FLucideIcons.receipt,
              title: l10n.purchases,
              onTap: () => context.push('/account/purchases'),
            ),
          ],
        ),
        SettingsSectionTitle(l10n.selling),
        SettingsGroup(
          children: [
            SettingsLinkTile(
              icon: FLucideIcons.tag,
              title: l10n.myListings,
              onTap: () => context.push('/account/listings'),
            ),
            SettingsLinkTile(
              icon: FLucideIcons.store,
              title: l10n.sales,
              onTap: () => context.push('/account/sales'),
            ),
            SettingsLinkTile(
              icon: FLucideIcons.wallet,
              title: l10n.payouts,
              onTap: () => context.push('/account/payouts'),
            ),
            SettingsLinkTile(
              icon: FLucideIcons.landmark,
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
            icon: FLucideIcons.palette,
            title: l10n.appearance,
            subtitle:
                '${themeModeName(l10n, settings.themeMode)} · '
                '${brandColorName(l10n, settings.color)} · '
                '${uiStyleName(l10n, settings.uiStyle)}',
            onTap: () => context.push('/settings/appearance'),
          ),
          FSelectMenuTile<String>.fromMap(
            {for (final e in languageNames.entries) e.value: e.key},
            prefix: const Icon(FLucideIcons.languages),
            title: Text(l10n.language),
            selectControl: .lifted(
              value: {settings.locale.languageCode},
              onChange: (codes) {
                final next = codes.difference({settings.locale.languageCode});
                if (next.isNotEmpty) controller.setLocale(Locale(next.first));
              },
            ),
            menuIntrinsicWidth: true,
            detailsBuilder: (context, _, _) => Text(
              languageNames[settings.locale.languageCode] ??
                  settings.locale.languageCode,
            ),
          ),
          FSelectMenuTile<Currency>.fromMap(
            {for (final c in Currency.values) _currencyLabel(c): c},
            prefix: const Icon(FLucideIcons.banknote),
            title: Text(l10n.currency),
            selectControl: .lifted(
              value: {settings.currency},
              onChange: (values) {
                final next = values.difference({settings.currency});
                if (next.isNotEmpty) controller.setCurrency(next.first);
              },
            ),
            menuIntrinsicWidth: true,
            detailsBuilder: (context, _, _) =>
                Text(_currencyLabel(settings.currency)),
          ),
        ],
      ),
      SettingsSectionTitle(l10n.support),
      SettingsGroup(
        children: [
          SettingsLinkTile(
            icon: FLucideIcons.circleQuestionMark,
            title: l10n.helpCenter,
            onTap: () => context.push('/support'),
          ),
          if (user != null)
            SettingsLinkTile(
              icon: FLucideIcons.headset,
              title: l10n.contactSupport,
              onTap: () => context.push('/support/new'),
            ),
          SettingsLinkTile(
            icon: FLucideIcons.info,
            title: l10n.about,
            onTap: () => _showAbout(context),
          ),
        ],
      ),
      if (user != null && !wide) ...[
        SettingsSectionTitle(l10n.account),
        SettingsGroup(
          children: [
            SettingsLinkTile(
              icon: FLucideIcons.bell,
              title: l10n.notifications,
              onTap: () => context.push('/settings/notifications'),
            ),
            SettingsLinkTile(
              icon: FLucideIcons.shield,
              title: l10n.privacySecurity,
              trailing: user.emailVerified
                  ? null
                  : Icon(
                      FLucideIcons.circleAlert,
                      size: 18,
                      color: theme.colors.destructive,
                    ),
              onTap: () => context.push('/settings/privacy'),
            ),
          ],
        ),
        const SizedBox(height: 24),
        SettingsGroup(
          children: [
            FTile(
              variant: .destructive,
              prefix: const Icon(FLucideIcons.logOut),
              title: Text(l10n.logoutButton),
              onPress: () async {
                await ref.read(authRepositoryProvider).signOut();
                if (context.mounted) context.go('/login');
              },
            ),
          ],
        ),
      ],
    ];
    return SiteScaffold(
      title: l10n.settingsTitle,
      maxWidth: SiteWidth.full,
      accountNav: true,
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(statsProvider);
          await ref.read(statsProvider.future).catchError((_) => null);
        },
        child: wide
            // Website account page: profile card, then the settings that
            // aren't in the sidebar.
            ? SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 48),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (user != null)
                      const FCard(
                        child: Padding(
                          padding: EdgeInsets.all(24),
                          child: ProfileHeader(horizontal: true),
                        ),
                      )
                    else
                      ?header,
                    // Same width as the profile card above.
                    ...sections,
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

String _currencyLabel(Currency c) => '${c.code} (${c.symbol})';

/// App name, version and description, with a link to the licenses.
void _showAbout(BuildContext context) {
  final l10n = AppLocalizations.of(context);
  final material = MaterialLocalizations.of(context);
  showAppDialog<void>(
    context: context,
    title: 'Stubswap',
    body: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const BrandMark(size: 48),
            const SizedBox(width: 12),
            Text(
              AppInfo.label,
              style: context.theme.typography.body.sm.copyWith(
                color: context.theme.colors.mutedForeground,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(l10n.aboutText),
      ],
    ),
    actions: (ctx) => [
      FButton(
        variant: .ghost,
        onPress: () => showLicensePage(
          context: ctx,
          applicationName: 'Stubswap',
          applicationVersion: AppInfo.label,
          applicationIcon: const BrandMark(size: 48),
        ),
        child: Flexible(child: Text(material.viewLicensesButtonLabel)),
      ),
      FButton(
        variant: .outline,
        onPress: () => Navigator.pop(ctx),
        child: Flexible(
          child: Text(
            material.closeButtonLabel,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
    ],
  );
}

class _GuestCard extends StatelessWidget {
  const _GuestCard({required this.onSignIn});

  final VoidCallback onSignIn;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = context.theme;
    return FCard(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            FAvatar.raw(
              size: 64,
              child: Icon(
                FLucideIcons.user,
                size: 32,
                color: theme.colors.mutedForeground,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              l10n.guest,
              style: theme.typography.body.lg.copyWith(
                color: theme.colors.foreground,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              l10n.guestSignInPrompt,
              textAlign: TextAlign.center,
              style: theme.typography.body.sm.copyWith(
                color: theme.colors.mutedForeground,
              ),
            ),
            const SizedBox(height: 16),
            FButton(
              onPress: onSignIn,
              child: Flexible(
                child: Text(l10n.signInOrUp, overflow: TextOverflow.ellipsis),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
