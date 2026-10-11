import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:forui/forui.dart';

import '../../l10n/app_localizations.dart';
import 'auth_repository.dart';
import 'auth_widgets.dart';

class ForgotPasswordPage extends ConsumerStatefulWidget {
  const ForgotPasswordPage({super.key, this.initialEmail = ''});

  final String initialEmail;

  @override
  ConsumerState<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends ConsumerState<ForgotPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  late final _email = TextEditingController(text: widget.initialEmail);
  bool _loading = false;
  bool _sent = false;
  AuthError? _error;

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_loading || !_formKey.currentState!.validate()) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await ref
          .read(authRepositoryProvider)
          .sendPasswordReset(
            email: _email.text.trim(),
            languageCode: Localizations.localeOf(context).languageCode,
          );
      if (mounted) setState(() => _sent = true);
    } on AuthException catch (e) {
      // Unknown emails count as sent, so the form doesn't reveal accounts.
      if (mounted) {
        setState(() {
          if (e.error == AuthError.invalidCredentials) {
            _sent = true;
          } else {
            _error = e.error;
          }
        });
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = context.theme;
    final error = _error == null ? '' : authErrorText(l10n, _error!);

    return AuthScaffold(
      title: l10n.resetTitle,
      subtitle: _sent ? null : l10n.resetInfo,
      children: _sent
          ? [
              Icon(
                FLucideIcons.mailCheck,
                size: 56,
                color: theme.colors.mutedForeground,
              ),
              const SizedBox(height: 16),
              Text(
                l10n.resetSent(_email.text.trim()),
                textAlign: TextAlign.center,
                style: theme.typography.body.md.copyWith(
                  color: theme.colors.foreground,
                ),
              ),
              const SizedBox(height: 24),
              SubmitButton(
                label: l10n.backToLogin,
                loading: false,
                onPressed: () => context.pop(),
              ),
            ]
          : [
              Form(
                key: _formKey,
                child: EmailField(
                  controller: _email,
                  enabled: !_loading,
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => _submit(),
                ),
              ),
              AnimatedErrorText(error),
              const SizedBox(height: 20),
              SubmitButton(
                label: l10n.resetButton,
                loading: _loading,
                onPressed: _submit,
              ),
            ],
    );
  }
}
