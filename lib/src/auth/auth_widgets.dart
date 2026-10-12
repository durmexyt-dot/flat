import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:forui/forui.dart';

import '../../l10n/app_localizations.dart';
import '../brand/brand.dart';
import 'auth_repository.dart';

String authExceptionText(AppLocalizations l10n, AuthException e) =>
    authErrorText(l10n, e.error, code: e.code);

String authErrorText(AppLocalizations l10n, AuthError error, {String? code}) {
  switch (error) {
    case AuthError.invalidCredentials:
      return l10n.errorInvalidCredentials;
    case AuthError.emailInUse:
      return l10n.errorEmailInUse;
    case AuthError.weakPassword:
      return l10n.errorWeakPassword;
    case AuthError.userDisabled:
      return l10n.errorUserDisabled;
    case AuthError.tooManyRequests:
      return l10n.errorTooManyRequests;
    case AuthError.network:
      return l10n.errorNetwork;
    case AuthError.methodDisabled:
      return l10n.errorMethodDisabled;
    case AuthError.popupBlocked:
      return l10n.errorPopupBlocked;
    case AuthError.cancelled:
      return '';
    case AuthError.unknown:
      return code == null ? l10n.errorUnknown : '${l10n.errorUnknown} ($code)';
  }
}

String? validateEmail(AppLocalizations l10n, String? value) {
  final v = value?.trim() ?? '';
  if (v.isEmpty) return l10n.emailRequired;
  if (!RegExp(r'^\S+@\S+\.\S+$').hasMatch(v)) return l10n.emailInvalid;
  return null;
}

class SettingsButton extends StatelessWidget {
  const SettingsButton({super.key});

  @override
  Widget build(BuildContext context) {
    return FTooltip(
      tipBuilder: (context, _) =>
          Text(AppLocalizations.of(context).settingsTitle),
      child: FButton.icon(
        variant: FButtonVariant.ghost,
        semanticsLabel: AppLocalizations.of(context).settingsTitle,
        onPress: () => context.push('/settings'),
        child: const Icon(FLucideIcons.settings),
      ),
    );
  }
}

/// Layout shared by the sign-in screens: brand on top, then a headline that
/// flies in from the previous screen, then the form.
///
/// On large screens the form is centered in a card. On phones it sits in the
/// upper part: on iPhone Safari the keyboard covers the lower half, and
/// Safari shifts the page when a focused field would be hidden, which
/// misaligns Flutter's text fields with their native input.
class AuthScaffold extends StatelessWidget {
  const AuthScaffold({
    super.key,
    required this.title,
    this.subtitle,
    required this.children,
  });

  final String title;
  final String? subtitle;
  final List<Widget> children;

  static const _padding = EdgeInsets.fromLTRB(16, 8, 16, 24);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            SizedBox(
              width: 48,
              child: context.canPop()
                  ? FButton.icon(
                      variant: FButtonVariant.ghost,
                      semanticsLabel: MaterialLocalizations.of(context)
                          .backButtonTooltip,
                      onPress: () => context.pop(),
                      child: const Icon(FLucideIcons.arrowLeft),
                    )
                  : null,
            ),
            const Expanded(child: Center(child: BrandHeader())),
            const SettingsButton(),
          ],
        ),
        const SizedBox(height: 20),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              BrandTagline(
                title,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 6),
                Text(
                  subtitle!,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
              const SizedBox(height: 20),
              ...children,
            ],
          ),
        ),
      ],
    );

    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final large =
                constraints.maxWidth >= 600 && constraints.maxHeight >= 700;
            return SingleChildScrollView(
              padding: _padding,
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight - _padding.vertical,
                ),
                child: Align(
                  // Phones: a third of the free space above the form, which
                  // keeps the fields clear of the iPhone keyboard.
                  alignment: large
                      ? Alignment.center
                      : const Alignment(0, -0.3),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 440),
                    child: large
                        ? FCard(
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(
                                16,
                                16,
                                16,
                                24,
                              ),
                              child: content,
                            ),
                          )
                        : content,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class PasswordField extends StatefulWidget {
  const PasswordField({
    super.key,
    required this.controller,
    required this.label,
    required this.enabled,
    this.validator,
    this.autofillHints = const [AutofillHints.password],
    this.textInputAction = TextInputAction.done,
    this.onSubmitted,
  });

  final TextEditingController controller;
  final String label;
  final bool enabled;
  final FormFieldValidator<String>? validator;
  final Iterable<String> autofillHints;
  final TextInputAction textInputAction;
  final ValueChanged<String>? onSubmitted;

  @override
  State<PasswordField> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<PasswordField> {
  @override
  Widget build(BuildContext context) {
    return FTextFormField.password(
      control: FTextFieldControl.managed(controller: widget.controller),
      label: Text(widget.label),
      prefixBuilder: (context, style, obscure, variants) =>
          const _FieldIcon(FLucideIcons.lock),
      autofillHints: widget.autofillHints,
      textInputAction: widget.textInputAction,
      enabled: widget.enabled,
      onSubmit: widget.onSubmitted,
      validator: widget.validator,
      autovalidateMode: AutovalidateMode.disabled,
    );
  }
}

/// A leading icon inside a Forui text field.
class _FieldIcon extends StatelessWidget {
  const _FieldIcon(this.icon);

  final IconData icon;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsetsDirectional.only(start: 12, end: 2),
    child: Icon(icon, size: 18, color: context.theme.colors.mutedForeground),
  );
}

/// A leading [icon] for [FTextFormField.prefixBuilder].
Widget fieldIcon(IconData icon) => _FieldIcon(icon);

class EmailField extends StatelessWidget {
  const EmailField({
    super.key,
    required this.controller,
    required this.enabled,
    this.textInputAction = TextInputAction.next,
    this.onSubmitted,
  });

  final TextEditingController controller;
  final bool enabled;
  final TextInputAction textInputAction;
  final ValueChanged<String>? onSubmitted;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return FTextFormField.email(
      control: FTextFieldControl.managed(controller: controller),
      label: Text(l10n.emailLabel),
      prefixBuilder: (context, style, variants) =>
          const _FieldIcon(FLucideIcons.mail),
      textInputAction: textInputAction,
      enabled: enabled,
      onSubmit: onSubmitted,
      validator: (value) => validateEmail(l10n, value),
      autovalidateMode: AutovalidateMode.disabled,
    );
  }
}

/// Error line under a form; slides open when an error appears.
class AnimatedErrorText extends StatelessWidget {
  const AnimatedErrorText(this.text, {super.key});

  /// Empty for no error.
  final String text;

  @override
  Widget build(BuildContext context) {
    return AnimatedSize(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOutCubic,
      alignment: Alignment.topCenter,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 250),
        child: text.isEmpty
            ? const SizedBox(width: double.infinity)
            : Padding(
                key: ValueKey(text),
                padding: const EdgeInsets.only(top: 12),
                child: Text(
                  text,
                  textAlign: TextAlign.center,
                  style: context.theme.typography.body.sm.copyWith(
                    color: context.theme.colors.error,
                  ),
                ),
              ),
      ),
    );
  }
}

/// Primary action button. While [loading], it shows a spinner, ignores
/// taps and keeps its size, so the layout doesn't jump.
class SubmitButton extends StatelessWidget {
  const SubmitButton({
    super.key,
    required this.label,
    required this.loading,
    required this.onPressed,
  });

  final String label;
  final bool loading;

  /// Null disables the button.
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      ignoring: loading,
      child: FButton(
        onPress: onPressed,
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: loading
              ? FCircularProgress.loader(
                  key: const ValueKey('loading'),
                  style: .delta(
                    iconStyle: .delta(
                      color: context.theme.colors.primaryForeground,
                    ),
                  ),
                )
              : Text(
                  label,
                  key: const ValueKey('label'),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
        ),
      ),
    );
  }
}

class GoogleButton extends StatelessWidget {
  const GoogleButton({super.key, required this.onPressed});

  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return FButton(
      variant: FButtonVariant.outline,
      onPress: onPressed,
      prefix: const Text(
        'G',
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: Color(0xFF4285F4),
        ),
      ),
      child: Flexible(
        child: Text(
          AppLocalizations.of(context).continueWithGoogle,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}

class OrDivider extends StatelessWidget {
  const OrDivider({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        children: [
          const Expanded(child: FDivider()),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              AppLocalizations.of(context).orDivider,
              style: theme.typography.body.xs.copyWith(
                color: theme.colors.mutedForeground,
              ),
            ),
          ),
          const Expanded(child: FDivider()),
        ],
      ),
    );
  }
}
