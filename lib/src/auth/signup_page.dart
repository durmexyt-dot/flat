import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:forui/forui.dart';

import '../../l10n/app_localizations.dart';
import '../data/repositories.dart';
import '../info/info_page.dart';
import '../info/legal_texts.dart';
import 'auth_repository.dart';
import 'auth_widgets.dart';
import '../router.dart';
import '../ui/tokens.dart';

class SignupPage extends ConsumerStatefulWidget {
  const SignupPage({super.key});

  @override
  ConsumerState<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends ConsumerState<SignupPage> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  bool _loading = false;
  AuthException? _error;

  /// The terms of use and privacy policy are accepted.
  bool _accepted = false;

  /// Sign up was tried without accepting them.
  bool _acceptMissing = false;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_loading) return;
    final valid = _formKey.currentState!.validate();
    setState(() => _acceptMissing = !_accepted);
    if (!valid || !_accepted) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    // Read before signing up: the page goes once signed in.
    final target = returnTarget(GoRouterState.of(context).uri) ?? '/';
    final router = GoRouter.of(context);
    final auth = ref.read(authRepositoryProvider);
    final profiles = ref.read(profileRepositoryProvider);
    try {
      await auth.signUp(
        name: _name.text.trim(),
        email: _email.text.trim(),
        password: _password.text,
      );
      final uid = auth.currentUser?.uid;
      if (uid != null) _recordAcceptance(profiles, uid);
      // Back to the page that asked for an account, or home.
      router.go(target);
    } on AuthException catch (e) {
      if (mounted) setState(() => _error = e);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  /// Records the accepted terms version on the new profile. Waits until
  /// the profile exists, so its creation doesn't see a document with only
  /// these fields and skip the rest. Failures don't stop the sign-up.
  static Future<void> _recordAcceptance(
    ProfileRepository profiles,
    String uid,
  ) async {
    try {
      await profiles
          .watchProfile(uid)
          .firstWhere((p) => p != null)
          .timeout(const Duration(seconds: 20));
      await profiles.acceptTerms(uid, termsVersion);
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final error = _error == null ? '' : authExceptionText(l10n, _error!);

    return AuthScaffold(
      title: l10n.signupTitle,
      children: [
        Form(
          key: _formKey,
          child: AutofillGroup(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                FTextFormField(
                  control: FTextFieldControl.managed(controller: _name),
                  inputFormatters: [LengthLimitingTextInputFormatter(80)],
                  label: Text(l10n.nameLabel),
                  prefixBuilder: (context, style, variants) =>
                      fieldIcon(FLucideIcons.user),
                  textCapitalization: TextCapitalization.words,
                  autofillHints: const [AutofillHints.name],
                  textInputAction: TextInputAction.next,
                  enabled: !_loading,
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? l10n.nameRequired
                      : null,
                  autovalidateMode: AutovalidateMode.onUserInteractionIfError,
                ),
                const SizedBox(height: Space.lg),
                EmailField(controller: _email, enabled: !_loading),
                const SizedBox(height: Space.lg),
                PasswordField(
                  controller: _password,
                  label: l10n.passwordLabel,
                  enabled: !_loading,
                  autofillHints: const [AutofillHints.newPassword],
                  textInputAction: TextInputAction.next,
                  validator: (v) => (v == null || v.length < 8)
                      ? l10n.passwordTooShort
                      : null,
                ),
                const SizedBox(height: Space.lg),
                PasswordField(
                  controller: _confirm,
                  label: l10n.confirmPasswordLabel,
                  enabled: !_loading,
                  autofillHints: const [AutofillHints.newPassword],
                  onSubmitted: (_) => _submit(),
                  validator: (v) =>
                      v != _password.text ? l10n.passwordsDontMatch : null,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: Space.xl),
        FCheckbox(
          semanticsLabel: l10n.legalAcceptTerms(
            l10n.legalTermsLink,
            l10n.legalPrivacyLink,
          ),
          label: LegalLinksText(template: l10n.legalAcceptTerms),
          error: _acceptMissing && !_accepted
              ? Text(l10n.legalAcceptRequired)
              : null,
          value: _accepted,
          enabled: !_loading,
          onChange: (v) => setState(() => _accepted = v),
        ),
        AnimatedErrorText(error),
        const SizedBox(height: Space.xxl),
        SubmitButton(
          label: l10n.createAccountButton,
          loading: _loading,
          onPressed: _submit,
        ),
        const SizedBox(height: Space.lg),
        Wrap(
          alignment: WrapAlignment.center,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text(l10n.haveAccount, style: context.theme.mutedText),
            FButton(
              variant: FButtonVariant.ghost,
              size: FButtonSizeVariant.sm,
              mainAxisSize: MainAxisSize.min,
              onPress: () => context.pop(),
              child: Text(l10n.loginButton, overflow: TextOverflow.ellipsis),
            ),
          ],
        ),
      ],
    );
  }
}
