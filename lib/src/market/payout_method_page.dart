import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../l10n/app_localizations.dart';
import '../auth/auth_widgets.dart';
import '../data/models.dart';
import '../data/repositories.dart';
import '../ui/snack.dart';
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
    final end = newValue.selection.end;
    var before = end < 0 || end > newValue.text.length
        ? raw.length
        : normalizeIban(newValue.text.substring(0, end)).length;
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
    final messenger = ScaffoldMessenger.of(context);
    final router = GoRouter.of(context);
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
      showSnack(messenger, l10n.saveError);
      if (mounted) setState(() => _saving = false);
      return;
    }
    showSnack(messenger, l10n.payoutMethodSaved);
    if (mounted) setState(() => _saving = false);
    // Opened from the sidebar or a link there is nothing to go back to.
    if (router.canPop()) {
      router.pop();
    } else {
      router.go('/account/payouts');
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
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
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _holder,
                decoration: InputDecoration(
                  labelText: l10n.accountHolder,
                  prefixIcon: const Icon(Icons.person_outline),
                ),
                textCapitalization: TextCapitalization.words,
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? l10n.required : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _iban,
                decoration: InputDecoration(
                  labelText: l10n.iban,
                  hintText: 'BA39 1290 0794 0102 8494',
                  prefixIcon: const Icon(Icons.account_balance_outlined),
                ),
                // No autocorrect, suggestions or smart punctuation: iOS would
                // otherwise change letters and digits of the IBAN.
                autocorrect: false,
                enableSuggestions: false,
                smartDashesType: SmartDashesType.disabled,
                smartQuotesType: SmartQuotesType.disabled,
                textCapitalization: TextCapitalization.characters,
                autofillHints: const [],
                inputFormatters: [IbanFormatter()],
                onFieldSubmitted: (_) => _save(),
                validator: (v) =>
                    isValidIban(v ?? '') ? null : l10n.ibanInvalid,
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
