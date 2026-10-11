import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:forui/forui.dart';

import '../../l10n/app_localizations.dart';
import 'auth_repository.dart';
import 'auth_widgets.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _keepSignedIn = true;
  bool _loading = false;
  AuthError? _error;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _run(Future<void> Function(AuthRepository auth) action) async {
    if (_loading) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await action(ref.read(authRepositoryProvider));
      // The router moves on to the home screen once signed in.
    } on AuthException catch (e) {
      if (mounted) setState(() => _error = e.error);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _signIn() {
    if (!_formKey.currentState!.validate()) return;
    _run(
      (auth) => auth.signIn(
        email: _email.text.trim(),
        password: _password.text,
        keepSignedIn: _keepSignedIn,
      ),
    );
  }

  void _signInWithGoogle() =>
      _run((auth) => auth.signInWithGoogle(keepSignedIn: _keepSignedIn));

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = context.theme;
    final error = _error == null ? '' : authErrorText(l10n, _error!);

    return AuthScaffold(
      title: l10n.loginWelcome,
      children: [
        Form(
          key: _formKey,
          child: AutofillGroup(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                EmailField(controller: _email, enabled: !_loading),
                const SizedBox(height: 12),
                PasswordField(
                  controller: _password,
                  label: l10n.passwordLabel,
                  enabled: !_loading,
                  onSubmitted: (_) => _signIn(),
                  validator: (value) => (value == null || value.isEmpty)
                      ? l10n.passwordRequired
                      : null,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: FCheckbox(
                label: Text(l10n.keepSignedIn),
                value: _keepSignedIn,
                onChange: (v) => setState(() => _keepSignedIn = v),
              ),
            ),
            Flexible(
              child: FButton(
                variant: FButtonVariant.ghost,
                size: FButtonSizeVariant.sm,
                mainAxisSize: MainAxisSize.min,
                onPress: () =>
                    context.push('/forgot-password', extra: _email.text.trim()),
                child: Text(l10n.forgotPassword, textAlign: TextAlign.end),
              ),
            ),
          ],
        ),
        AnimatedErrorText(error),
        const SizedBox(height: 12),
        SubmitButton(
          label: l10n.loginButton,
          loading: _loading,
          onPressed: _signIn,
        ),
        const OrDivider(),
        GoogleButton(onPressed: _loading ? null : _signInWithGoogle),
        const SizedBox(height: 20),
        Wrap(
          alignment: WrapAlignment.center,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text(
              l10n.noAccount,
              style: theme.typography.body.sm.copyWith(
                color: theme.colors.mutedForeground,
              ),
            ),
            FButton(
              variant: FButtonVariant.ghost,
              size: FButtonSizeVariant.sm,
              mainAxisSize: MainAxisSize.min,
              onPress: () => context.push('/signup'),
              child: Text(l10n.signUp),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Center(
          child: FButton(
            variant: FButtonVariant.ghost,
            size: FButtonSizeVariant.sm,
            mainAxisSize: MainAxisSize.min,
            onPress: () => ref.read(guestModeProvider.notifier).enter(),
            prefix: const Icon(FLucideIcons.search),
            child: Text(
              l10n.continueAsGuest,
              style: TextStyle(color: theme.colors.mutedForeground),
            ),
          ),
        ),
      ],
    );
  }
}
