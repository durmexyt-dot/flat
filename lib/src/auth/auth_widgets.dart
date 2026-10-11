import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:forui/forui.dart';

import '../../l10n/app_localizations.dart';
import '../brand/brand.dart';
import 'auth_repository.dart';

String authErrorText(AppLocalizations l10n, AuthError error) {
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
    case AuthError.cancelled:
      return '';
    case AuthError.unknown:
      return l10n.errorUnknown;
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
    return IconButton(
      icon: const Icon(FLucideIcons.settings),
      tooltip: AppLocalizations.of(context).settingsTitle,
      onPressed: () => context.push('/settings'),
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
              child: context.canPop() ? const BackButton() : null,
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
                        ? Card.filled(
                            color: theme.colorScheme.surfaceContainerLow,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(28),
                            ),
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
  bool _obscure = true;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return TextFormField(
      controller: widget.controller,
      decoration: InputDecoration(
        labelText: widget.label,
        prefixIcon: const Icon(FLucideIcons.lock),
        suffixIcon: IconButton(
          icon: Icon(_obscure ? FLucideIcons.eye : FLucideIcons.eyeOff),
          tooltip: _obscure ? l10n.showPassword : l10n.hidePassword,
          onPressed: () => setState(() => _obscure = !_obscure),
        ),
      ),
      obscureText: _obscure,
      autofillHints: widget.autofillHints,
      textInputAction: widget.textInputAction,
      enabled: widget.enabled,
      onFieldSubmitted: widget.onSubmitted,
      validator: widget.validator,
    );
  }
}

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
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: l10n.emailLabel,
        prefixIcon: const Icon(FLucideIcons.mail),
      ),
      keyboardType: TextInputType.emailAddress,
      autofillHints: const [AutofillHints.email],
      textInputAction: textInputAction,
      enabled: enabled,
      onFieldSubmitted: onSubmitted,
      validator: (value) => validateEmail(l10n, value),
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
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ),
      ),
    );
  }
}

/// Primary action button. While [loading], it shrinks into a circle with a
/// spinner and grows back once the response is there.
class SubmitButton extends StatelessWidget {
  const SubmitButton({
    super.key,
    required this.label,
    required this.loading,
    required this.onPressed,
  });

  final String label;
  final bool loading;
  final VoidCallback onPressed;

  static const _height = 52.0;
  static const _duration = Duration(milliseconds: 350);

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return SizedBox(
      height: _height,
      child: LayoutBuilder(
        builder: (context, constraints) => Center(
          child: AnimatedContainer(
            duration: _duration,
            curve: Curves.easeInOutCubic,
            width: loading ? _height : constraints.maxWidth,
            height: _height,
            child: IgnorePointer(
              ignoring: loading,
              child: FilledButton(
                onPressed: onPressed,
                style: FilledButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: const Size(_height, _height),
                  shape: const StadiumBorder(),
                ),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: loading
                      ? SizedBox.square(
                          key: const ValueKey('loading'),
                          dimension: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: colors.onPrimary,
                          ),
                        )
                      : Text(
                          label,
                          key: const ValueKey('label'),
                          maxLines: 1,
                          softWrap: false,
                          overflow: TextOverflow.clip,
                        ),
                ),
              ),
            ),
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
    return OutlinedButton.icon(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(52)),
      icon: const Text(
        'G',
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: Color(0xFF4285F4),
        ),
      ),
      label: Text(AppLocalizations.of(context).continueWithGoogle),
    );
  }
}

class OrDivider extends StatelessWidget {
  const OrDivider({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        children: [
          const Expanded(child: Divider()),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              AppLocalizations.of(context).orDivider,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          const Expanded(child: Divider()),
        ],
      ),
    );
  }
}
