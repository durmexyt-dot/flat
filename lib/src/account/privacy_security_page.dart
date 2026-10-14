import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:forui/forui.dart';

import '../../l10n/app_localizations.dart';
import '../auth/auth_repository.dart';
import '../auth/auth_widgets.dart';
import '../data/models.dart';
import '../data/repositories.dart';
import '../settings/settings_widgets.dart';
import '../ui/snack.dart';
import '../web/save_file.dart';
import 'data_export.dart';

import 'dart:convert';

import '../ui/site_scaffold.dart';

class PrivacySecurityPage extends ConsumerWidget {
  const PrivacySecurityPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final user = ref.watch(authStateProvider).value;
    final profile = ref.watch(profileProvider).value;
    if (user == null) return const Scaffold();
    final visibility = profile?.visibility ?? ProfileVisibility.public;

    Future<void> setVisibility(ProfileVisibility v) async {
      try {
        await ref.read(profileRepositoryProvider).setVisibility(user.uid, v);
      } catch (_) {
        showSnack(l10n.saveError);
      }
    }

    return SiteScaffold(
      title: l10n.privacySecurity,
      maxWidth: SiteWidth.form,
      accountNav: true,
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
        children: [
          SettingsSectionTitle(l10n.profileVisibility),
          _VisibilityOption(
            icon: FLucideIcons.globe,
            title: l10n.profilePublic,
            info: l10n.visibilityPublicInfo,
            selected: visibility == ProfileVisibility.public,
            onTap: () => setVisibility(ProfileVisibility.public),
          ),
          const SizedBox(height: 8),
          _VisibilityOption(
            icon: FLucideIcons.lock,
            title: l10n.profilePrivate,
            info: l10n.visibilityPrivateInfo,
            selected: visibility == ProfileVisibility.private,
            onTap: () => setVisibility(ProfileVisibility.private),
          ),
          SettingsSectionTitle(l10n.security),
          SettingsGroup(
            children: [
              _EmailTile(user: user),
              FTile(
                prefix: const Icon(FLucideIcons.key),
                title: Text(l10n.signInMethods),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      if (user.hasPassword)
                        FBadge(
                          variant: .outline,
                          child: Text(l10n.methodPassword),
                        ),
                      if (user.providers.contains('google.com'))
                        FBadge(variant: .outline, child: const Text('Google')),
                    ],
                  ),
                ),
              ),
              if (user.hasPassword)
                SettingsLinkTile(
                  icon: FLucideIcons.keyRound,
                  title: l10n.changePassword,
                  onTap: () => showFDialog<void>(
                    context: context,
                    builder: (_, _, animation) =>
                        _ChangePasswordDialog(animation: animation),
                  ),
                ),
            ],
          ),
          SettingsSectionTitle(l10n.dataExportSection),
          SettingsGroup(children: [_DataExportTile(user: user)]),
          SettingsSectionTitle(l10n.dangerZone),
          SettingsGroup(
            children: [
              FTile(
                variant: .destructive,
                prefix: const Icon(FLucideIcons.trash2),
                title: Text(l10n.deleteAccount),
                subtitle: Text(
                  l10n.deleteAccountInfo,
                  overflow: TextOverflow.visible,
                ),
                suffix: const Icon(FLucideIcons.chevronRight),
                onPress: () => showFDialog<void>(
                  context: context,
                  builder: (_, _, animation) =>
                      _DeleteAccountDialog(user: user, animation: animation),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _VisibilityOption extends StatelessWidget {
  const _VisibilityOption({
    required this.icon,
    required this.title,
    required this.info,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String info;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final colors = theme.colors;
    return FTappable(
      selected: selected,
      onPress: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: theme.style.borderRadius.lg,
          color: selected ? colors.secondary : colors.card,
          border: Border.all(
            color: selected ? colors.primary : colors.border,
            width: 1.5,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              icon,
              size: 20,
              color: selected ? colors.primary : colors.mutedForeground,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.typography.body.sm.copyWith(
                      fontWeight: FontWeight.w600,
                      color: colors.foreground,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    info,
                    style: theme.typography.body.sm.copyWith(
                      color: colors.mutedForeground,
                    ),
                  ),
                ],
              ),
            ),
            AnimatedScale(
              scale: selected ? 1 : 0,
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOutBack,
              child: Icon(
                FLucideIcons.circleCheck,
                size: 20,
                color: colors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmailTile extends ConsumerStatefulWidget with FTileMixin {
  const _EmailTile({required this.user});

  final AppUser user;

  @override
  ConsumerState<_EmailTile> createState() => _EmailTileState();
}

class _EmailTileState extends ConsumerState<_EmailTile> {
  bool _sending = false;

  Future<void> _send() async {
    final l10n = AppLocalizations.of(context);
    setState(() => _sending = true);
    try {
      await ref
          .read(authRepositoryProvider)
          .sendEmailVerification(Localizations.localeOf(context).languageCode);
      showSnack(l10n.verificationSent(widget.user.email ?? ''));
    } on AuthException catch (e) {
      showSnack(authExceptionText(l10n, e));
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.theme.colors;
    final verified = widget.user.emailVerified;

    return FTile(
      prefix: const Icon(FLucideIcons.mail),
      title: Text(widget.user.email ?? ''),
      // Badge and actions sit under the address: as tile details they
      // would squeeze the buttons on phones.
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              transitionBuilder: (child, animation) =>
                  ScaleTransition(scale: animation, child: child),
              child: FBadge(
                key: ValueKey(verified),
                variant: verified ? .secondary : .destructive,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      verified
                          ? FLucideIcons.badgeCheck
                          : FLucideIcons.circleAlert,
                      size: 14,
                    ),
                    const SizedBox(width: 4),
                    Text(verified ? l10n.emailVerified : l10n.emailNotVerified),
                  ],
                ),
              ),
            ),
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 250),
            alignment: Alignment.topCenter,
            child: verified
                ? const SizedBox.shrink()
                : Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.verifyEmailInfo,
                          overflow: TextOverflow.visible,
                          style: TextStyle(color: colors.mutedForeground),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            FButton(
                              variant: .secondary,
                              size: .sm,
                              mainAxisSize: MainAxisSize.min,
                              onPress: _sending ? null : _send,
                              child: Text(l10n.sendVerification),
                            ),
                            FButton(
                              variant: .ghost,
                              size: .sm,
                              mainAxisSize: MainAxisSize.min,
                              onPress: () =>
                                  ref.read(authRepositoryProvider).reloadUser(),
                              child: Text(l10n.checkVerification),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

/// Dialog body and actions, laid out like [showAppDialog] (which can't hold
/// the form state these dialogs need).
class _DialogLayout extends StatelessWidget {
  const _DialogLayout({
    required this.animation,
    required this.title,
    required this.body,
    required this.actions,
  });

  final Animation<double>? animation;
  final String title;
  final Widget body;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) => FDialog(
    animation: animation,
    builder: (context, style) {
      final narrow = MediaQuery.sizeOf(context).width < 600;
      return Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(title, style: style.titleTextStyle),
            const SizedBox(height: 8),
            DefaultTextStyle.merge(
              style: style.bodyTextStyle.copyWith(
                fontSize: context.theme.typography.body.sm.fontSize,
              ),
              child: body,
            ),
            const SizedBox(height: 20),
            if (narrow)
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                spacing: 8,
                children: actions.reversed.toList(),
              )
            else
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                spacing: 8,
                children: [for (final a in actions) IntrinsicWidth(child: a)],
              ),
          ],
        ),
      );
    },
  );
}

class _ChangePasswordDialog extends ConsumerStatefulWidget {
  const _ChangePasswordDialog({this.animation});

  final Animation<double>? animation;

  @override
  ConsumerState<_ChangePasswordDialog> createState() =>
      _ChangePasswordDialogState();
}

class _ChangePasswordDialogState extends ConsumerState<_ChangePasswordDialog> {
  final _formKey = GlobalKey<FormState>();
  final _current = TextEditingController();
  final _new = TextEditingController();
  final _confirm = TextEditingController();
  bool _loading = false;
  String _error = '';

  @override
  void dispose() {
    _current.dispose();
    _new.dispose();
    _confirm.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_loading || !_formKey.currentState!.validate()) return;
    final l10n = AppLocalizations.of(context);
    setState(() {
      _loading = true;
      _error = '';
    });
    try {
      await ref
          .read(authRepositoryProvider)
          .changePassword(
            currentPassword: _current.text,
            newPassword: _new.text,
          );
      showSnack(l10n.passwordChanged);
      if (mounted) Navigator.pop(context);
    } on AuthException catch (e) {
      if (mounted) setState(() => _error = authExceptionText(l10n, e));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return _DialogLayout(
      animation: widget.animation,
      title: l10n.changePassword,
      body: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            PasswordField(
              controller: _current,
              label: l10n.currentPassword,
              enabled: !_loading,
              textInputAction: TextInputAction.next,
              validator: (v) =>
                  (v == null || v.isEmpty) ? l10n.passwordRequired : null,
            ),
            const SizedBox(height: 12),
            PasswordField(
              controller: _new,
              label: l10n.newPassword,
              enabled: !_loading,
              autofillHints: const [AutofillHints.newPassword],
              textInputAction: TextInputAction.next,
              validator: (v) =>
                  (v == null || v.length < 8) ? l10n.passwordTooShort : null,
            ),
            const SizedBox(height: 12),
            PasswordField(
              controller: _confirm,
              label: l10n.confirmPasswordLabel,
              enabled: !_loading,
              autofillHints: const [AutofillHints.newPassword],
              onSubmitted: (_) => _submit(),
              validator: (v) => v != _new.text ? l10n.passwordsDontMatch : null,
            ),
            AnimatedErrorText(_error),
          ],
        ),
      ),
      actions: [
        FButton(
          variant: .outline,
          onPress: () => Navigator.pop(context),
          child: Flexible(
            child: Text(l10n.cancel, overflow: TextOverflow.ellipsis),
          ),
        ),
        FButton(
          onPress: _loading ? null : _submit,
          child: Flexible(
            child: Text(l10n.save, overflow: TextOverflow.ellipsis),
          ),
        ),
      ],
    );
  }
}

class _DeleteAccountDialog extends ConsumerStatefulWidget {
  const _DeleteAccountDialog({required this.user, this.animation});

  final AppUser user;
  final Animation<double>? animation;

  @override
  ConsumerState<_DeleteAccountDialog> createState() =>
      _DeleteAccountDialogState();
}

class _DeleteAccountDialogState extends ConsumerState<_DeleteAccountDialog> {
  final _password = TextEditingController();
  bool _loading = false;
  String _error = '';

  @override
  void dispose() {
    _password.dispose();
    super.dispose();
  }

  Future<void> _delete() async {
    final l10n = AppLocalizations.of(context);
    final router = GoRouter.of(context);
    final uid = widget.user.uid;
    setState(() {
      _loading = true;
      _error = '';
    });
    try {
      final market = ref.read(marketRepositoryProvider);
      // Not while money or tickets are on their way: buyers would be left
      // without a seller, or the user without their tickets.
      bool open(Order o) =>
          o.status == OrderStatus.paid || o.status == OrderStatus.ticketsSent;
      final sales = await market.watchSales(uid).first;
      final purchases = await market.watchPurchases(uid).first;
      if (sales.any(open) || purchases.any(open)) {
        if (mounted) setState(() => _error = l10n.deleteAccountOpenOrders);
        return;
      }
      // Take down active listings and profile data first: afterwards the
      // user can no longer write.
      final listings = await market.watchMyListings(uid).first;
      for (final l in listings.where((l) => l.status == ListingStatus.active)) {
        await market.withdrawListing(l.id);
      }
      await ref
          .read(profileRepositoryProvider)
          .deleteUserData(uid)
          .catchError((Object _) {});
      await ref
          .read(authRepositoryProvider)
          .deleteAccount(
            password: widget.user.hasPassword ? _password.text : null,
          );
      router.go('/login');
    } on AuthException catch (e) {
      if (mounted) setState(() => _error = authExceptionText(l10n, e));
    } catch (_) {
      if (mounted) setState(() => _error = l10n.errorUnknown);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return _DialogLayout(
      animation: widget.animation,
      title: l10n.deleteAccount,
      body: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(l10n.deleteAccountInfo),
          const SizedBox(height: 16),
          if (widget.user.hasPassword)
            PasswordField(
              controller: _password,
              label: l10n.deleteAccountConfirm,
              enabled: !_loading,
              onSubmitted: (_) => _delete(),
            )
          else
            Text(l10n.deleteAccountGoogle),
          AnimatedErrorText(_error),
        ],
      ),
      actions: [
        FButton(
          variant: .outline,
          onPress: () => Navigator.pop(context),
          child: Flexible(
            child: Text(l10n.cancel, overflow: TextOverflow.ellipsis),
          ),
        ),
        FButton(
          variant: .destructive,
          onPress: _loading ? null : _delete,
          child: Flexible(
            child: Text(l10n.deleteAccount, overflow: TextOverflow.ellipsis),
          ),
        ),
      ],
    );
  }
}

/// Downloads everything stored about the account as a JSON file.
class _DataExportTile extends ConsumerStatefulWidget with FTileMixin {
  const _DataExportTile({required this.user});
  final AppUser user;

  @override
  ConsumerState<_DataExportTile> createState() => _DataExportTileState();
}

class _DataExportTileState extends ConsumerState<_DataExportTile> {
  bool _busy = false;

  Future<void> _export() async {
    final l10n = AppLocalizations.of(context);
    final user = widget.user;
    setState(() => _busy = true);
    try {
      final data = await ref
          .read(dataExportRepositoryProvider)
          .collect(user.uid);
      final now = DateTime.now();
      final json = exportJson(
        data: data,
        account: {
          'uid': user.uid,
          'email': user.email,
          'displayName': user.displayName,
          'emailVerified': user.emailVerified,
          'signInMethods': user.providers,
        },
        now: now,
      );
      final day = now.toIso8601String().substring(0, 10);
      final saved = await saveFile(
        utf8.encode(json),
        'stubswap-podaci-$day.json',
        'application/json',
      );
      showSnack(saved ? l10n.dataExportDone : l10n.invoiceDownloadUnavailable);
    } catch (_) {
      showSnack(l10n.loadError);
    }
    if (mounted) setState(() => _busy = false);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return FTile(
      prefix: const Icon(FLucideIcons.fileDown),
      title: Text(l10n.dataExport),
      subtitle: Text(l10n.dataExportInfo, overflow: TextOverflow.visible),
      suffix: _busy
          ? FCircularProgress.loader()
          : const Icon(FLucideIcons.download),
      onPress: _busy ? null : _export,
    );
  }
}
