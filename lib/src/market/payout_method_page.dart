import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../l10n/app_localizations.dart';
import '../auth/auth_widgets.dart';
import '../data/models.dart';
import '../data/repositories.dart';
import '../ui/snack.dart';

/// Groups an IBAN in blocks of four while typing.
class _IbanFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final raw = newValue.text.replaceAll(' ', '').toUpperCase();
    final grouped = [
      for (var i = 0; i < raw.length; i += 4)
        raw.substring(i, i + 4 > raw.length ? raw.length : i + 4),
    ].join(' ');
    return TextEditingValue(
      text: grouped,
      selection: TextSelection.collapsed(offset: grouped.length),
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
    text: _IbanFormatter()
        .formatEditUpdate(
          TextEditingValue.empty,
          TextEditingValue(
            text: ref.read(payoutMethodProvider).value?.iban ?? '',
          ),
        )
        .text,
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
              iban: _iban.text.replaceAll(' ', ''),
            ),
          );
      showSnack(messenger, l10n.payoutMethodSaved);
      router.pop();
    } catch (_) {
      showSnack(messenger, l10n.saveError);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.payoutMethod)),
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
                autocorrect: false,
                inputFormatters: [_IbanFormatter()],
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
