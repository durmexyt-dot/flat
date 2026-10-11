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
import '../ui/app_style.dart';
import '../ui/snack.dart';
import '../ui/site_scaffold.dart';

class PrivacySecurityPage extends ConsumerWidget {
  const PrivacySecurityPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
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
              ListTile(
                shape: const RoundedRectangleBorder(),
                leading: const Icon(FLucideIcons.key),
                title: Text(l10n.signInMethods),
                subtitle: Wrap(
                  spacing: 6,
                  children: [
                    if (user.hasPassword)
                      Chip(
                        label: Text(l10n.methodPassword),
                        visualDensity: VisualDensity.compact,
                      ),
                    if (user.providers.contains('google.com'))
                      const Chip(
                        label: Text('Google'),
                        visualDensity: VisualDensity.compact,
                      ),
                  ],
                ),
              ),
              if (user.hasPassword)
                SettingsLinkTile(
                  icon: FLucideIcons.keyRound,
                  title: l10n.changePassword,
                  onTap: () => showDialog<void>(
                    context: context,
                    builder: (_) => const _ChangePasswordDialog(),
                  ),
                ),
            ],
          ),
          SettingsSectionTitle(l10n.dangerZone),
          SettingsGroup(
            children: [
              ListTile(
                shape: const RoundedRectangleBorder(),
                leading: Icon(
                  FLucideIcons.trash2,
                  color: theme.colorScheme.error,
                ),
                title: Text(
                  l10n.deleteAccount,
                  style: TextStyle(color: theme.colorScheme.error),
                ),
                subtitle: Text(l10n.deleteAccountInfo),
                onTap: () => showDialog<void>(
                  context: context,
                  builder: (_) => _DeleteAccountDialog(user: user),
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
    final colors = Theme.of(context).colorScheme;
    final radius = BorderRadius.circular(AppStyle.of(context).cardRadius);
    return Semantics(
      selected: selected,
      button: true,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: radius,
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOutCubic,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: radius,
              color: selected
                  ? colors.surfaceContainerHigh
                  : colors.surfaceContainerLow,
              border: Border.all(
                color: selected ? colors.primary : Colors.transparent,
                width: 2,
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(icon, color: selected ? colors.primary : null),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      const SizedBox(height: 4),
                      Text(info),
                    ],
                  ),
                ),
                AnimatedScale(
                  scale: selected ? 1 : 0,
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeOutBack,
                  child: Icon(FLucideIcons.circleCheck, color: colors.primary),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _EmailTile extends ConsumerStatefulWidget {
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
      showSnack(authErrorText(l10n, e.error));
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = Theme.of(context).colorScheme;
    final verified = widget.user.emailVerified;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(FLucideIcons.mail),
              const SizedBox(width: 16),
              Expanded(child: Text(widget.user.email ?? '')),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                transitionBuilder: (child, animation) =>
                    ScaleTransition(scale: animation, child: child),
                child: Chip(
                  key: ValueKey(verified),
                  avatar: Icon(
                    verified
                        ? FLucideIcons.badgeCheck
                        : FLucideIcons.circleAlert,
                    size: 16,
                    color: verified ? colors.primary : colors.error,
                  ),
                  label: Text(
                    verified ? l10n.emailVerified : l10n.emailNotVerified,
                  ),
                  visualDensity: VisualDensity.compact,
                ),
              ),
            ],
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 250),
            alignment: Alignment.topCenter,
            child: verified
                ? const SizedBox(width: double.infinity)
                : Padding(
                    padding: const EdgeInsets.only(left: 40, top: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(l10n.verifyEmailInfo),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            FilledButton.tonal(
                              onPressed: _sending ? null : _send,
                              child: Text(l10n.sendVerification),
                            ),
                            TextButton(
                              onPressed: () =>
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

class _ChangePasswordDialog extends ConsumerStatefulWidget {
  const _ChangePasswordDialog();

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
      if (mounted) setState(() => _error = authErrorText(l10n, e.error));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AlertDialog(
      title: Text(l10n.changePassword),
      content: SizedBox(
        width: 400,
        child: Form(
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
                    (v == null || v.length < 6) ? l10n.passwordTooShort : null,
              ),
              const SizedBox(height: 12),
              PasswordField(
                controller: _confirm,
                label: l10n.confirmPasswordLabel,
                enabled: !_loading,
                autofillHints: const [AutofillHints.newPassword],
                onSubmitted: (_) => _submit(),
                validator: (v) =>
                    v != _new.text ? l10n.passwordsDontMatch : null,
              ),
              AnimatedErrorText(_error),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.cancel),
        ),
        FilledButton(
          onPressed: _loading ? null : _submit,
          child: Text(l10n.save),
        ),
      ],
    );
  }
}

class _DeleteAccountDialog extends ConsumerStatefulWidget {
  const _DeleteAccountDialog({required this.user});

  final AppUser user;

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
      // Take down active listings and profile data first: afterwards the
      // user can no longer write.
      final market = ref.read(marketRepositoryProvider);
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
      if (mounted) setState(() => _error = authErrorText(l10n, e.error));
    } catch (_) {
      if (mounted) setState(() => _error = l10n.errorUnknown);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = Theme.of(context).colorScheme;
    return AlertDialog(
      icon: Icon(FLucideIcons.trash2, color: colors.error),
      title: Text(l10n.deleteAccount),
      content: SizedBox(
        width: 400,
        child: Column(
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
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.cancel),
        ),
        FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: colors.error,
            foregroundColor: colors.onError,
          ),
          onPressed: _loading ? null : _delete,
          child: Text(l10n.deleteAccount),
        ),
      ],
    );
  }
}
