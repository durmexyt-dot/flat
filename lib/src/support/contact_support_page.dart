import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';

import '../../l10n/app_localizations.dart';
import '../auth/auth_repository.dart';
import '../auth/auth_widgets.dart';
import '../data/repositories.dart';
import '../data/models.dart';
import '../settings/settings_widgets.dart';
import '../ui/snack.dart';
import '../ui/site_scaffold.dart';
import 'support_repository.dart';
import 'support_widgets.dart';

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
  final _images = <String>[];
  bool _encoding = false;
  bool _sending = false;

  @override
  void dispose() {
    _reference.dispose();
    _message.dispose();
    super.dispose();
  }

  Future<void> _addImage() async {
    final l10n = AppLocalizations.of(context);
    setState(() => _encoding = true);
    final data = await pickSupportImage(l10n);
    if (!mounted) return;
    setState(() {
      _encoding = false;
      if (data != null && _images.length < maxSupportImages) _images.add(data);
    });
  }

  Future<void> _send() async {
    if (_sending || _encoding || !_formKey.currentState!.validate()) return;
    final user = ref.read(authStateProvider).value;
    if (user == null) return;
    final l10n = AppLocalizations.of(context);
    final router = GoRouter.of(context);
    final profileName = ref.read(profileProvider).value?.displayName;
    final name = [
      profileName,
      user.displayName,
      user.email,
    ].firstWhere((s) => s != null && s.trim().isNotEmpty, orElse: () => '')!;
    setState(() => _sending = true);
    try {
      final id = await ref
          .read(supportRepositoryProvider)
          .createTicket(
            uid: user.uid,
            email: user.email ?? '',
            name: name.trim(),
            topic: _topic,
            reference: _reference.text.trim(),
            text: _message.text.trim(),
            images: [..._images],
          );
      showSnack(l10n.supportRequestSent);
      router.pushReplacement('/support/ticket/$id');
    } catch (_) {
      showSnack(l10n.saveError);
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = context.theme;

    return SiteScaffold(
      title: l10n.contactSupport,
      maxWidth: SiteWidth.form,
      accountNav: true,
      body: SingleChildScrollView(
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
                    FButton(
                      size: FButtonSizeVariant.sm,
                      mainAxisSize: MainAxisSize.min,
                      variant: _topic == t
                          ? FButtonVariant.primary
                          : FButtonVariant.outline,
                      selected: _topic == t,
                      onPress: () => setState(() => _topic = t),
                      child: Text(
                        supportTopicName(l10n, t),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              FTextFormField(
                control: FTextFieldControl.managed(controller: _reference),
                inputFormatters: [LengthLimitingTextInputFormatter(60)],
                label: Text(l10n.reference),
                description: Text(l10n.optional),
                prefixBuilder: (context, style, variants) =>
                    fieldIcon(FLucideIcons.hash),
                textCapitalization: TextCapitalization.characters,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 16),
              FTextFormField.multiline(
                control: FTextFieldControl.managed(controller: _message),
                label: Text(l10n.message),
                hint: l10n.messageHint,
                minLines: 5,
                maxLines: 10,
                maxLength: 2000,
                autovalidateMode: AutovalidateMode.disabled,
                validator: (v) => (v ?? '').trim().length < 10
                    ? l10n.supportMessageTooShort
                    : null,
              ),
              SettingsSectionTitle(l10n.supportImages),
              Text(
                l10n.supportImagesInfo(maxSupportImages),
                style: theme.typography.body.sm.copyWith(
                  color: theme.colors.mutedForeground,
                ),
              ),
              const SizedBox(height: 12),
              SupportAttachments(
                images: _images,
                busy: _encoding,
                onAdd: _addImage,
                onRemove: (i) => setState(() => _images.removeAt(i)),
              ),
              const SizedBox(height: 24),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    FLucideIcons.messagesSquare,
                    size: 18,
                    color: theme.colors.mutedForeground,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      l10n.supportAnswerInApp,
                      style: theme.typography.body.sm.copyWith(
                        color: theme.colors.mutedForeground,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SubmitButton(
                label: l10n.send,
                loading: _sending,
                onPressed: _send,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
