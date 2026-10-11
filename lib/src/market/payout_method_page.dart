import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';

import '../../l10n/app_localizations.dart';
import '../auth/auth_widgets.dart';
import '../data/models.dart';
import '../data/repositories.dart';
import '../ui/snack.dart';
import '../ui/nav.dart';
import '../ui/site_scaffold.dart';

/// Groups an IBAN in blocks of four while typing. Keeps the cursor where
/// it was, so a digit can be fixed in the middle.
class IbanFormatter extends TextInputFormatter {
  static String group(String raw) => [
    for (var i = 0; i < raw.length; i += 4)
      raw.substring(i, i + 4 > raw.length ? raw.length : i + 4),
  ].join(' ');

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    var raw = normalizeIban(newValue.text);
    // No IBAN is longer; extra characters (e.g. a pasted line) are dropped.
    if (raw.length > ibanMaxLength) raw = raw.substring(0, ibanMaxLength);
    final end = newValue.selection.end;
    var before = end < 0 || end > newValue.text.length
        ? raw.length
        : normalizeIban(newValue.text.substring(0, end)).length;
    if (before > raw.length) before = raw.length;
    // Backspace on a group space deletes the character before it instead.
    final deleted = newValue.text.length < oldValue.text.length;
    if (deleted && before > 0 && raw == normalizeIban(oldValue.text)) {
      raw = raw.substring(0, before - 1) + raw.substring(before);
      before--;
    }
    final grouped = group(raw);
    // Each full block before the cursor adds one space.
    final offset = before == 0 ? 0 : before + (before - 1) ~/ 4;
    return TextEditingValue(
      text: grouped,
      selection: TextSelection.collapsed(
        offset: offset.clamp(0, grouped.length),
      ),
    );
  }
}

class PayoutMethodPage extends ConsumerStatefulWidget {
  const PayoutMethodPage({super.key});

  @override
  ConsumerState<PayoutMethodPage> createState() => _PayoutMethodPageState();
}

class _PayoutMethodPageState extends ConsumerState<PayoutMethodPage> {
  final _formKey = GlobalKey<FormState>();
  late final _holder = TextEditingController(
    text:
        ref.read(payoutMethodProvider).value?.accountHolder ??
        ref.read(profileProvider).value?.displayName ??
        '',
  );
  late final _iban = TextEditingController(
    text: IbanFormatter.group(
      normalizeIban(ref.read(payoutMethodProvider).value?.iban ?? ''),
    ),
  );
  bool _saving = false;

  @override
  void dispose() {
    _holder.dispose();
    _iban.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_saving || !_formKey.currentState!.validate()) return;
    final uid = ref.read(currentUidProvider);
    if (uid == null) return;
    final l10n = AppLocalizations.of(context);
    setState(() => _saving = true);
    try {
      await ref
          .read(marketRepositoryProvider)
          .setPayoutMethod(
            uid,
            PayoutMethod(
              accountHolder: _holder.text.trim(),
              iban: normalizeIban(_iban.text),
            ),
          );
    } catch (_) {
      showSnack(l10n.saveError);
      if (mounted) setState(() => _saving = false);
      return;
    }
    showSnack(l10n.payoutMethodSaved);
    if (!mounted) return;
    setState(() => _saving = false);
    popOrGo(context, '/account/payouts');
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = context.theme;
    // The saved method may arrive after the page opened: fill it in then,
    // unless the user already started typing.
    ref.listen(payoutMethodProvider, (_, next) {
      final method = next.value;
      if (method == null) return;
      if (_iban.text.isEmpty) {
        _iban.text = IbanFormatter.group(normalizeIban(method.iban));
      }
      if (_holder.text.isEmpty) _holder.text = method.accountHolder;
    });
    return SiteScaffold(
      title: l10n.payoutMethod,
      maxWidth: SiteWidth.form,
      accountNav: true,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                l10n.payoutMethodInfo,
                style: theme.typography.body.sm.copyWith(
                  color: theme.colors.mutedForeground,
                ),
              ),
              const SizedBox(height: 16),
              FCard(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      FTextFormField(
                        control: FTextFieldControl.managed(controller: _holder),
                        label: Text(l10n.accountHolder),
                        prefixBuilder: (context, style, variants) =>
                            fieldIcon(FLucideIcons.user),
                        textCapitalization: TextCapitalization.words,
                        textInputAction: TextInputAction.next,
                        autovalidateMode: AutovalidateMode.disabled,
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? l10n.required
                            : null,
                      ),
                      const SizedBox(height: 16),
                      FTextFormField(
                        control: FTextFieldControl.managed(controller: _iban),
                        label: Text(l10n.iban),
                        hint: 'BA39 1290 0794 0102 8494',
                        prefixBuilder: (context, style, variants) =>
                            fieldIcon(FLucideIcons.landmark),
                        // No autocorrect, suggestions or smart punctuation: iOS would
                        // otherwise change letters and digits of the IBAN.
                        autocorrect: false,
                        enableSuggestions: false,
                        smartDashesType: SmartDashesType.disabled,
                        smartQuotesType: SmartQuotesType.disabled,
                        textCapitalization: TextCapitalization.characters,
                        autofillHints: const [],
                        inputFormatters: [IbanFormatter()],
                        onSubmit: (_) => _save(),
                        autovalidateMode: AutovalidateMode.disabled,
                        // Says what is wrong, so a hidden leftover character
                        // or a typo can be found.
                        validator: (v) => switch (checkIban(v ?? '')) {
                          null => null,
                          IbanBadFormat() => l10n.ibanBadFormat,
                          IbanWrongLength(
                            :final country,
                            :final expected,
                            :final actual,
                          ) =>
                            l10n.ibanWrongLength(country, expected, actual),
                          IbanBadChecksum() => l10n.ibanBadChecksum,
                        },
                        // Clears the whole IBAN in one tap; on phones deleting
                        // from the middle easily leaves old characters behind.
                        clearable: (value) => value.text.isNotEmpty,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              SubmitButton(
                label: l10n.save,
                loading: _saving,
                onPressed: _save,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
