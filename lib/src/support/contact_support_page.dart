import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';

import '../../l10n/app_localizations.dart';
import '../auth/auth_repository.dart';
import '../auth/auth_widgets.dart';
import '../data/models.dart';
import '../data/repositories.dart';
import '../settings/settings_widgets.dart';
import '../ui/async_view.dart';
import '../ui/snack.dart';
import '../ui/nav.dart';
import '../ui/site_scaffold.dart';

/// What a support request is about, passed from order or payout pages.
class SupportContext {
  const SupportContext({required this.topic, this.reference = ''});
  final SupportTopic topic;
  final String reference;
}

String supportTopicName(AppLocalizations l10n, SupportTopic t) => switch (t) {
  SupportTopic.order => l10n.topicOrder,
  SupportTopic.sale => l10n.topicSale,
  SupportTopic.payout => l10n.topicPayout,
  SupportTopic.account => l10n.topicAccount,
  SupportTopic.other => l10n.topicOther,
};

class ContactSupportPage extends ConsumerStatefulWidget {
  const ContactSupportPage({super.key, this.initial});

  final SupportContext? initial;

  @override
  ConsumerState<ContactSupportPage> createState() => _ContactSupportPageState();
}

class _ContactSupportPageState extends ConsumerState<ContactSupportPage> {
  final _formKey = GlobalKey<FormState>();
  late SupportTopic _topic = widget.initial?.topic ?? SupportTopic.order;
  late final _reference = TextEditingController(
    text: widget.initial?.reference ?? '',
  );
  final _message = TextEditingController();
  bool _sending = false;
  String? _sentNumber;

  @override
  void dispose() {
    _reference.dispose();
    _message.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    if (_sending || !_formKey.currentState!.validate()) return;
    final user = ref.read(authStateProvider).value;
    if (user == null) return;
    final l10n = AppLocalizations.of(context);
    setState(() => _sending = true);
    try {
      final number = await ref
          .read(marketRepositoryProvider)
          .createSupportRequest(
            uid: user.uid,
            email: user.email ?? '',
            topic: _topic,
            reference: _reference.text.trim(),
            message: _message.text.trim(),
          );
      if (mounted) setState(() => _sentNumber = number);
    } catch (_) {
      showSnack(l10n.saveError);
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final email = ref.watch(authStateProvider).value?.email ?? '';

    return SiteScaffold(
      title: l10n.contactSupport,
      maxWidth: SiteWidth.form,
      accountNav: true,
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 350),
        child: _sentNumber != null
            ? Center(
                key: const ValueKey('sent'),
                child: EmptyState(
                  icon: FLucideIcons.mailCheck,
                  title: l10n.requestSent,
                  message: l10n.requestSentInfo(_sentNumber!, email),
                  action: FilledButton(
                    onPressed: () => popOrGo(context, '/support'),
                    child: Text(l10n.done),
                  ),
                ),
              )
            : SingleChildScrollView(
                key: const ValueKey('form'),
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SettingsSectionTitle(l10n.topic),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          for (final t in SupportTopic.values)
                            ChoiceChip(
                              label: Text(supportTopicName(l10n, t)),
                              selected: _topic == t,
                              onSelected: (_) => setState(() => _topic = t),
                            ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _reference,
                        decoration: InputDecoration(
                          labelText: l10n.reference,
                          helperText: l10n.optional,
                          prefixIcon: const Icon(FLucideIcons.hash),
                        ),
                        textCapitalization: TextCapitalization.characters,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _message,
                        decoration: InputDecoration(
                          labelText: l10n.message,
                          hintText: l10n.messageHint,
                          alignLabelWithHint: true,
                        ),
                        minLines: 5,
                        maxLines: 10,
                        maxLength: 2000,
                        validator: (v) => (v ?? '').trim().length < 20
                            ? l10n.messageTooShort
                            : null,
                      ),
                      const SizedBox(height: 12),
                      SubmitButton(
                        label: l10n.send,
                        loading: _sending,
                        onPressed: _send,
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}
