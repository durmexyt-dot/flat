import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';

import '../../l10n/app_localizations.dart';
import '../auth/auth_widgets.dart';
import '../data/models.dart';
import '../data/server_actions.dart';
import '../ui/app_dialog.dart';
import '../ui/format.dart';
import '../ui/snack.dart';
import 'labels.dart';
import 'order_labels.dart';
import 'ticket_files_widgets.dart';

/// Whether the buyer can report a problem with [o] now.
bool canReportProblem(Order o, [DateTime? now]) =>
    const {
      OrderStatus.paid,
      OrderStatus.ticketsSent,
      OrderStatus.completed,
    }.contains(o.status) &&
    (o.dispute == null || !o.dispute!.open) &&
    (now ?? DateTime.now()).isBefore(o.event.date.add(disputeWindowAfterEvent));

/// Asks the buyer what is wrong and opens the report. True when sent.
Future<bool> showDisputeSheet(BuildContext context, Order order) async {
  final sent = await showFSheet<bool>(
    context: context,
    side: FLayout.btt,
    mainAxisMaxRatio: null,
    builder: (_) => _DisputeSheet(order: order),
  );
  return sent == true;
}

class _DisputeSheet extends ConsumerStatefulWidget {
  const _DisputeSheet({required this.order});

  final Order order;

  @override
  ConsumerState<_DisputeSheet> createState() => _DisputeSheetState();
}

class _DisputeSheetState extends ConsumerState<_DisputeSheet> {
  final _formKey = GlobalKey<FormState>();
  final _text = TextEditingController();
  late DisputeReason _reason = widget.order.ticketsMissing > 0
      ? DisputeReason.notReceived
      : DisputeReason.invalid;
  bool _sending = false;

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    if (_sending || !_formKey.currentState!.validate()) return;
    final l10n = AppLocalizations.of(context);
    final navigator = Navigator.of(context);
    setState(() => _sending = true);
    try {
      await ref
          .read(serverActionsProvider)
          .openDispute(
            orderId: widget.order.id,
            reason: _reason,
            text: _text.text.trim(),
          );
      showSnack(l10n.disputeSent);
      navigator.pop(true);
    } catch (e) {
      showSnack(serverErrorText(l10n, e));
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = context.theme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colors.background,
        border: Border(top: BorderSide(color: theme.colors.border)),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: SafeArea(
        top: false,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                16,
                16,
                16,
                16 + MediaQuery.viewInsetsOf(context).bottom,
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            l10n.disputeSheetTitle,
                            style: theme.typography.body.lg.copyWith(
                              fontWeight: FontWeight.w700,
                              color: theme.colors.foreground,
                            ),
                          ),
                        ),
                        FButton.icon(
                          variant: FButtonVariant.ghost,
                          semanticsLabel: l10n.cancel,
                          onPress: _sending
                              ? null
                              : () => Navigator.pop(context, false),
                          child: const Icon(FLucideIcons.x),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      l10n.disputeSheetInfo,
                      style: theme.typography.body.sm.copyWith(
                        color: theme.colors.mutedForeground,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      l10n.disputeReasonLabel,
                      style: theme.typography.body.sm.copyWith(
                        fontWeight: FontWeight.w600,
                        color: theme.colors.foreground,
                      ),
                    ),
                    const SizedBox(height: 8),
                    for (final r in DisputeReason.values)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: FRadio(
                          label: Text(disputeReasonName(l10n, r)),
                          value: _reason == r,
                          onChange: _sending
                              ? null
                              : (_) => setState(() => _reason = r),
                        ),
                      ),
                    const SizedBox(height: 12),
                    FTextFormField.multiline(
                      control: FTextFieldControl.managed(controller: _text),
                      label: Text(l10n.disputeTextLabel),
                      hint: l10n.disputeTextHint,
                      enabled: !_sending,
                      inputFormatters: [LengthLimitingTextInputFormatter(2000)],
                      validator: (v) => (v ?? '').trim().length < 10
                          ? l10n.disputeTextTooShort
                          : null,
                    ),
                    const SizedBox(height: 16),
                    SubmitButton(
                      label: l10n.disputeSubmit,
                      loading: _sending,
                      onPressed: _send,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// A reported problem: reason, the buyer's words, and the team's decision.
class DisputeBox extends StatelessWidget {
  const DisputeBox({
    super.key,
    required this.dispute,
    this.showSupportLink = false,
  });

  final OrderDispute dispute;

  /// The buyer can open the support request the report started.
  final bool showSupportLink;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = context.theme;
    final muted = theme.typography.body.sm.copyWith(
      color: theme.colors.mutedForeground,
    );
    final (status, tone) = switch (dispute.decision) {
      'refund' => (l10n.disputeStatusRefund, StatusTone.positive),
      'reject' => (l10n.disputeStatusReject, StatusTone.neutral),
      _ => (l10n.disputeStatusOpen, StatusTone.waiting),
    };
    return FCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 8,
          children: [
            Row(
              children: [
                Icon(
                  FLucideIcons.messageSquareWarning,
                  size: 18,
                  color: theme.colors.foreground,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    disputeReasonName(l10n, dispute.reason),
                    style: theme.typography.body.md.copyWith(
                      fontWeight: FontWeight.w600,
                      color: theme.colors.foreground,
                    ),
                  ),
                ),
              ],
            ),
            if (dispute.openedAt case final at?)
              Text(formatDateTime(context, at), style: muted),
            Text(
              dispute.text,
              style: theme.typography.body.sm.copyWith(
                color: theme.colors.foreground,
              ),
            ),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              child: StatusChip(
                key: ValueKey(dispute.decision),
                label: status,
                tone: tone,
              ),
            ),
            if (dispute.note.isNotEmpty)
              Text(l10n.disputeNote(dispute.note), style: muted),
            if (showSupportLink && dispute.supportTicketId.isNotEmpty)
              FButton(
                variant: FButtonVariant.outline,
                size: FButtonSizeVariant.sm,
                mainAxisSize: MainAxisSize.min,
                prefix: const Icon(FLucideIcons.headset),
                onPress: () =>
                    context.push('/support/ticket/${dispute.supportTicketId}'),
                child: Text(
                  l10n.disputeOpenRequest,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// The team's view of an order: who bought and sold, and the decision on
/// an open report.
class StaffDisputePanel extends ConsumerStatefulWidget {
  const StaffDisputePanel({super.key, required this.order});

  final Order order;

  @override
  ConsumerState<StaffDisputePanel> createState() => _StaffDisputePanelState();
}

class _StaffDisputePanelState extends ConsumerState<StaffDisputePanel> {
  bool _busy = false;

  Future<void> _decide({required bool refund}) async {
    final l10n = AppLocalizations.of(context);
    final note = TextEditingController();
    final ok = await showAppDialog<bool>(
      context: context,
      title: refund ? l10n.disputeRefund : l10n.disputeReject,
      body: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(refund ? l10n.disputeRefundConfirm : l10n.disputeRejectConfirm),
          const SizedBox(height: 12),
          FTextFormField.multiline(
            control: FTextFieldControl.managed(controller: note),
            label: Text('${l10n.disputeNoteLabel} (${l10n.optional})'),
            minLines: 2,
            inputFormatters: [LengthLimitingTextInputFormatter(1000)],
          ),
        ],
      ),
      actions: (ctx) => [
        FButton(
          variant: FButtonVariant.outline,
          onPress: () => Navigator.pop(ctx, false),
          child: Text(l10n.cancel),
        ),
        FButton(
          variant: refund ? FButtonVariant.destructive : FButtonVariant.primary,
          onPress: () => Navigator.pop(ctx, true),
          child: Text(refund ? l10n.disputeRefund : l10n.disputeReject),
        ),
      ],
    );
    final text = note.text.trim();
    if (ok != true || !mounted) return;
    setState(() => _busy = true);
    try {
      await ref
          .read(serverActionsProvider)
          .resolveDispute(orderId: widget.order.id, refund: refund, note: text);
      showSnack(l10n.disputeDecided);
    } catch (e) {
      showSnack(serverErrorText(l10n, e));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = context.theme;
    final order = widget.order;
    final dispute = order.dispute;
    final muted = theme.typography.body.sm.copyWith(
      color: theme.colors.mutedForeground,
    );
    final value = theme.typography.body.sm.copyWith(
      color: theme.colors.foreground,
    );
    final open =
        order.status == OrderStatus.disputed && (dispute?.open ?? false);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FCard(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              spacing: 6,
              children: [
                for (final (label, id) in [
                  (l10n.disputeStaffBuyer, order.buyerId),
                  (l10n.disputeStaffSeller, order.sellerId),
                ])
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(width: 120, child: Text(label, style: muted)),
                      Expanded(child: SelectableText(id, style: value)),
                    ],
                  ),
              ],
            ),
          ),
        ),
        if (open) ...[
          const SizedBox(height: 12),
          FButton(
            variant: FButtonVariant.destructive,
            onPress: _busy ? null : () => _decide(refund: true),
            prefix: const Icon(FLucideIcons.undo2),
            child: Text(l10n.disputeRefund, overflow: TextOverflow.ellipsis),
          ),
          const SizedBox(height: 8),
          FButton(
            variant: FButtonVariant.outline,
            onPress: _busy ? null : () => _decide(refund: false),
            prefix: const Icon(FLucideIcons.circleX),
            child: Text(l10n.disputeReject, overflow: TextOverflow.ellipsis),
          ),
        ],
      ],
    );
  }
}
