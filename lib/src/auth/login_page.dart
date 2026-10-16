import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:forui/forui.dart';

import '../../l10n/app_localizations.dart';
import '../info/info_page.dart';
import '../router.dart';
import 'auth_repository.dart';
import 'auth_widgets.dart';
import '../ui/tokens.dart';

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
  AuthException? _error;

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
    // Where to go once signed in: the page that asked for it, or home.
    final target = returnTarget(GoRouterState.of(context).uri) ?? '/';
    final router = GoRouter.of(context);
    try {
      await action(ref.read(authRepositoryProvider));
      router.go(target);
    } on AuthException catch (e) {
      if (mounted) setState(() => _error = e);
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
    final error = _error == null ? '' : authExceptionText(l10n, _error!);
    // Sent here from a page that needs an account; the router goes back
    // there after signing in.
    final from = returnTarget(GoRouterState.of(context).uri);

    return AuthScaffold(
      title: l10n.loginWelcome,
      subtitle: from == null ? null : l10n.signInToContinue,
      children: [
        Form(
          key: _formKey,
          child: AutofillGroup(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                EmailField(controller: _email, enabled: !_loading),
                const SizedBox(height: Space.lg),
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
        const SizedBox(height: Space.md),
        // Side by side; on narrow phones the link moves below instead of
        // being cut off.
        Wrap(
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            // FCheckbox's own label needs a bounded width; a separate,
            // tappable label keeps its natural width in this row. Box and
            // label are one control for screen readers, as tall as a
            // tap target.
            MergeSemantics(
              child: ConstrainedBox(
                constraints: const BoxConstraints(minHeight: TapTarget.min),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  spacing: Space.md,
                  children: [
                    FCheckbox(
                      value: _keepSignedIn,
                      onChange: (v) => setState(() => _keepSignedIn = v),
                    ),
                    FTappable(
                      onPress: () =>
                          setState(() => _keepSignedIn = !_keepSignedIn),
                      child: Text(
                        l10n.keepSignedIn,
                        style: theme.typography.body.sm.copyWith(
                          color: theme.colors.foreground,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            FButton(
              variant: FButtonVariant.ghost,
              size: FButtonSizeVariant.sm,
              mainAxisSize: MainAxisSize.min,
              onPress: () =>
                  context.push('/forgot-password', extra: _email.text.trim()),
              // Bounded by the wrap's width, so the label can shrink.
              child: Flexible(
                child: Text(
                  l10n.forgotPassword,
                  textAlign: TextAlign.end,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ],
        ),
        AnimatedErrorText(error),
        const SizedBox(height: Space.lg),
        SubmitButton(
          label: l10n.loginButton,
          loading: _loading,
          onPressed: _signIn,
        ),
        const OrDivider(),
        GoogleButton(onPressed: _loading ? null : _signInWithGoogle),
        // Google sign-in creates an account on first use.
        const SizedBox(height: Space.md),
        LegalLinksText(
          template: l10n.legalContinueAccept,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: Space.xxl),
        Wrap(
          alignment: WrapAlignment.center,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text(l10n.noAccount, style: theme.mutedText),
            FButton(
              variant: FButtonVariant.ghost,
              size: FButtonSizeVariant.sm,
              mainAxisSize: MainAxisSize.min,
              onPress: () => context.push(
                from == null ? '/signup' : withReturnTo('/signup', from),
              ),
              child: Text(l10n.signUp, overflow: TextOverflow.ellipsis),
            ),
          ],
        ),
        const SizedBox(height: Space.xs),
        Center(
          child: FButton(
            variant: FButtonVariant.ghost,
            size: FButtonSizeVariant.sm,
            mainAxisSize: MainAxisSize.min,
            onPress: () => context.go(
              from != null && !isAccountOnly(Uri.parse(from).path) ? from : '/',
            ),
            prefix: const Icon(FLucideIcons.search),
            child: Text(
              l10n.continueAsGuest,
              style: TextStyle(color: theme.colors.mutedForeground),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ],
    );
  }
}
