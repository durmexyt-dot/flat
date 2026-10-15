import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';

import '../../l10n/app_localizations.dart';
import '../data/models.dart';
import '../payments/checkout_repository.dart';
import '../ui/app_dialog.dart';
import '../ui/format.dart';
import '../ui/segmented.dart';
import '../ui/snack.dart';
import '../ui/tokens.dart';

String handoverMethodName(AppLocalizations l10n, HandoverMethod m) =>
    switch (m) {
      HandoverMethod.appTransfer => l10n.handoverAppTransfer,
      HandoverMethod.post => l10n.handoverPost,
      HandoverMethod.courier => l10n.handoverCourier,
      HandoverMethod.inPerson => l10n.handoverInPerson,
    };

IconData handoverIcon(HandoverMethod m) => switch (m) {
  HandoverMethod.appTransfer => FLucideIcons.smartphone,
  HandoverMethod.post => FLucideIcons.mail,
  HandoverMethod.courier => FLucideIcons.truck,
  HandoverMethod.inPerson => FLucideIcons.handshake,
};

/// Asks the seller how the mobile or paper tickets went to the buyer, then
/// marks them as sent with these details. Returns true when saved.
Future<bool> showHandoverDialog(
  BuildContext context,
  WidgetRef ref,
  Order order,
) async {
  final l10n = AppLocalizations.of(context);
  final form = GlobalKey<_HandoverFormState>();
  final handover = await showAppDialog<TicketHandover>(
    context: context,
    title: l10n.handoverTitle,
    body: _HandoverForm(key: form, type: order.ticketType),
    actions: (ctx) => [
      FButton(
        variant: FButtonVariant.outline,
        onPress: () => Navigator.pop(ctx),
        child: Text(l10n.cancel),
      ),
      FButton(
        onPress: () => form.currentState?.submit(),
        child: Text(l10n.handoverSubmit),
      ),
    ],
  );
  if (handover == null) return false;
  try {
    await ref.read(checkoutRepositoryProvider).markTicketsSent(order, handover);
    showSnack(l10n.ticketsMarkedSent);
    return true;
  } catch (_) {
    showSnack(l10n.errorUnknown);
    return false;
  }
}

class _HandoverForm extends StatefulWidget {
  const _HandoverForm({super.key, required this.type});
  final TicketType type;

  @override
  State<_HandoverForm> createState() => _HandoverFormState();
}

class _HandoverFormState extends State<_HandoverForm> {
  final _form = GlobalKey<FormState>();
  late HandoverMethod _method = handoverMethods(widget.type).first;
  final _recipient = TextEditingController();
  final _tracking = TextEditingController();
  final _note = TextEditingController();

  @override
  void dispose() {
    _recipient.dispose();
    _tracking.dispose();
    _note.dispose();
    super.dispose();
  }

  void submit() {
    if (!_form.currentState!.validate()) return;
    Navigator.pop(
      context,
      TicketHandover(
        method: _method,
        recipient: _method == HandoverMethod.appTransfer
            ? _recipient.text.trim()
            : '',
        trackingNumber:
            _method == HandoverMethod.post || _method == HandoverMethod.courier
            ? _tracking.text.trim()
            : '',
        note: _note.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final methods = handoverMethods(widget.type);
    final shipped =
        _method == HandoverMethod.post || _method == HandoverMethod.courier;
    return Form(
      key: _form,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            widget.type == TicketType.mobile
                ? l10n.handoverInfoMobile
                : l10n.handoverInfoPaper,
          ),
          const SizedBox(height: Space.lg),
          if (methods.length > 1) ...[
            Segmented<HandoverMethod>(
              values: methods,
              selected: _method,
              label: (m) => handoverMethodName(l10n, m),
              onChanged: (m) => setState(() => _method = m),
            ),
            const SizedBox(height: Space.lg),
          ],
          if (_method == HandoverMethod.appTransfer)
            FTextFormField(
              control: FTextFieldControl.managed(controller: _recipient),
              label: Text(l10n.handoverRecipient),
              description: Text(l10n.handoverRecipientInfo),
              inputFormatters: [LengthLimitingTextInputFormatter(120)],
              validator: (v) => (v ?? '').trim().length < 3
                  ? l10n.handoverRecipientMissing
                  : null,
            ),
          if (shipped)
            FTextFormField(
              control: FTextFieldControl.managed(controller: _tracking),
              label: Text(l10n.handoverTracking),
              description: Text(l10n.handoverTrackingInfo),
              inputFormatters: [LengthLimitingTextInputFormatter(60)],
            ),
          const SizedBox(height: Space.lg),
          FTextFormField(
            control: FTextFieldControl.managed(controller: _note),
            label: Text(l10n.handoverNote),
            description: Text(
              _method == HandoverMethod.inPerson
                  ? l10n.handoverNoteInPerson
                  : l10n.optional,
            ),
            maxLines: 3,
            minLines: 1,
            inputFormatters: [LengthLimitingTextInputFormatter(300)],
            validator: (v) =>
                _method == HandoverMethod.inPerson && (v ?? '').trim().isEmpty
                ? l10n.required
                : null,
          ),
        ],
      ),
    );
  }
}

/// How the tickets were handed over, for buyer, seller and team; the buyer
/// confirms getting them here.
class HandoverCard extends ConsumerStatefulWidget {
  const HandoverCard({super.key, required this.order, required this.isBuyer});

  final Order order;
  final bool isBuyer;

  @override
  ConsumerState<HandoverCard> createState() => _HandoverCardState();
}

class _HandoverCardState extends ConsumerState<HandoverCard> {
  bool _busy = false;

  Future<void> _confirm() async {
    final l10n = AppLocalizations.of(context);
    setState(() => _busy = true);
    try {
      await ref.read(checkoutRepositoryProvider).confirmReceipt(widget.order);
      showSnack(l10n.handoverConfirmed);
    } catch (_) {
      showSnack(l10n.errorUnknown);
    }
    if (mounted) setState(() => _busy = false);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = context.theme;
    final h = widget.order.handover!;
    final muted = theme.mutedText;
    Widget line(String label, String value) => Padding(
      padding: const EdgeInsets.only(top: Space.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 130, child: Text(label, style: muted)),
          Expanded(child: SelectableText(value)),
        ],
      ),
    );
    final canConfirm =
        widget.isBuyer &&
        !h.confirmed &&
        widget.order.status == OrderStatus.ticketsSent;
    return FCard(
      child: Padding(
        padding: const EdgeInsets.all(Space.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(handoverIcon(h.method), size: 18),
                const SizedBox(width: Space.md),
                Expanded(
                  child: Text(
                    handoverMethodName(l10n, h.method),
                    style: theme.titleText,
                  ),
                ),
              ],
            ),
            if (h.recipient.isNotEmpty)
              line(l10n.handoverRecipient, h.recipient),
            if (h.trackingNumber.isNotEmpty)
              line(l10n.handoverTracking, h.trackingNumber),
            if (h.note.isNotEmpty) line(l10n.handoverNote, h.note),
            if (h.sentAt != null)
              line(l10n.handoverSentAt, formatDateTime(context, h.sentAt!)),
            const SizedBox(height: Space.lg),
            if (h.confirmed)
              Row(
                children: [
                  const Icon(FLucideIcons.circleCheck, size: IconSizes.sm),
                  const SizedBox(width: Space.sm),
                  Expanded(
                    child: Text(
                      l10n.handoverConfirmedAt(
                        formatDateTime(context, h.confirmedAt!),
                      ),
                    ),
                  ),
                ],
              )
            else if (canConfirm) ...[
              Text(l10n.handoverConfirmInfo, style: muted),
              const SizedBox(height: Space.md),
              FButton(
                onPress: _busy ? null : _confirm,
                prefix: const Icon(FLucideIcons.packageCheck),
                child: Text(l10n.handoverConfirm),
              ),
            ] else
              Text(l10n.handoverWaiting, style: muted),
          ],
        ),
      ),
    );
  }
}
