import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:forui/forui.dart';

import '../../l10n/app_localizations.dart';
import '../admin/admin_repository.dart';
import '../data/models.dart';
import '../data/repositories.dart';
import '../auth/auth_widgets.dart';
import '../payments/checkout_repository.dart';
import '../payments/pay_flow.dart';
import '../payments/payment_gateway.dart';
import '../payments/test_payment_gateway.dart';
import '../settings/settings_widgets.dart';
import '../support/contact_support_page.dart';
import '../invoices/invoice_pages.dart' show OrderInvoices;
import 'handover_widgets.dart';
import '../ui/app_dialog.dart';
import '../ui/async_view.dart';
import '../ui/format.dart';
import '../ui/skeleton.dart';
import '../ui/snack.dart';
import '../ui/status_timeline.dart';
import 'labels.dart';
import 'listing_ticket.dart';
import 'order_labels.dart';
import 'order_ticket.dart';
import 'dispute_sheet.dart';
import 'ticket_files_widgets.dart';
import '../ui/site_scaffold.dart';
import '../ui/tokens.dart';

/// One order with its progress and invoice; for the buyer or the seller.
class OrderDetailPage extends ConsumerWidget {
  const OrderDetailPage({super.key, required this.id, this.initial});

  final String id;
  final Order? initial;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final live = ref.watch(orderProvider(id));
    final order = live.value ?? initial;
    final uid = ref.watch(currentUidProvider);
    final role = order?.sellerId == uid ? OrderRole.seller : OrderRole.buyer;
    // The team opens other people's orders, e.g. to decide on a problem.
    final staffView =
        order != null &&
        uid != order.sellerId &&
        uid != order.buyerId &&
        ref.watch(isStaffProvider);
    final buyer = role == OrderRole.buyer && !staffView;

    return SiteScaffold(
      title: role == OrderRole.seller ? l10n.saleDetails : l10n.orderDetails,
      maxWidth: SiteWidth.form,
      accountNav: true,
      body: order == null
          ? AsyncView<Order?>(
              value: live,
              onRetry: () => ref.invalidate(orderProvider(id)),
              loading: const SkeletonTicketList(count: 1),
              data: (_) =>
                  EmptyState(icon: FLucideIcons.searchX, title: l10n.loadError),
            )
          : ListView(
              padding: Insets.pageList,
              children: [
                OrderTicket(order: order, role: role),
                const SizedBox(height: Space.xl),
                if (role == OrderRole.seller && order.ticketsMissing > 0) ...[
                  FAlert(
                    variant: FAlertVariant.destructive,
                    icon: const Icon(FLucideIcons.fileWarning),
                    title: Text(l10n.deliverySellerMissingTitle),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.deliverySellerMissingInfo(
                            formatDateTime(context, order.deliveryDeadline),
                          ),
                        ),
                        const SizedBox(height: Space.md),
                        FButton(
                          variant: FButtonVariant.outline,
                          size: FButtonSizeVariant.sm,
                          mainAxisSize: MainAxisSize.min,
                          prefix: const Icon(FLucideIcons.upload),
                          onPress: () => context.push(
                            '/listing/${order.listingId}/tickets',
                          ),
                          child: Text(
                            l10n.deliveryUploadAction,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: Space.lg),
                ],
                NextStepCard(
                  text: order.failureReason.isNotEmpty
                      ? l10n.paymentFailedInfo(
                          paymentFailureText(
                            l10n,
                            enumByName(
                              PaymentFailure.values,
                              order.failureReason,
                              PaymentFailure.processingError,
                            ),
                          ),
                        )
                      : order.cancelledBySeller
                      ? (role == OrderRole.seller
                            ? l10n.sellerNextCancelledBySeller
                            : l10n.buyerNextCancelledBySeller)
                      : orderNextStep(l10n, order.status, role),
                  tone: orderTone(order.status),
                ),
                if (!staffView) _OrderActions(order: order, role: role),
                if ((buyer || staffView) &&
                    OrderFilesSection.applies(order)) ...[
                  SettingsSectionTitle(l10n.deliveryBuyerSection),
                  OrderFilesSection(order: order),
                ],
                if (order.handover != null) ...[
                  SettingsSectionTitle(l10n.handoverSection),
                  HandoverCard(order: order, isBuyer: buyer),
                ],
                if (order.dispute case final dispute?) ...[
                  SettingsSectionTitle(l10n.disputeBoxTitle),
                  DisputeBox(dispute: dispute, showSupportLink: buyer),
                ],
                if (staffView) ...[
                  SettingsSectionTitle(l10n.disputeStaffTitle),
                  StaffDisputePanel(order: order),
                ],
                SettingsSectionTitle(l10n.statusHistory),
                StatusTimeline(steps: orderTimeline(context, order)),
                SettingsSectionTitle(l10n.invoice),
                _Invoice(order: order, role: role),
                OrderInvoices(orderId: order.id),
                if (buyer && canReportProblem(order)) ...[
                  const SizedBox(height: Space.lg),
                  FButton(
                    variant: FButtonVariant.outline,
                    onPress: () => showDisputeSheet(context, order),
                    prefix: const Icon(FLucideIcons.flag),
                    child: Text(
                      l10n.disputeReport,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
                if (!staffView) ...[
                  const SizedBox(height: Space.lg),
                  FButton(
                    variant: FButtonVariant.outline,
                    onPress: () => context.push(
                      '/support/new',
                      extra: SupportContext(
                        topic: role == OrderRole.buyer
                            ? SupportTopic.order
                            : SupportTopic.sale,
                        reference: order.number,
                      ),
                    ),
                    prefix: const Icon(FLucideIcons.headset),
                    child: Flexible(
                      child: Text(
                        l10n.getHelpOrder,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ],
                if (role == OrderRole.seller &&
                    order.status == OrderStatus.completed) ...[
                  const SizedBox(height: Space.lg),
                  FButton(
                    variant: FButtonVariant.outline,
                    onPress: () => context.push('/account/payouts'),
                    prefix: const Icon(FLucideIcons.landmark),
                    child: Flexible(
                      child: Text(
                        l10n.payouts,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ],
              ],
            ),
    );
  }
}

/// Test-mode actions that the server takes over with real payments.
class _OrderActions extends ConsumerStatefulWidget {
  const _OrderActions({required this.order, required this.role});

  final Order order;
  final OrderRole role;

  @override
  ConsumerState<_OrderActions> createState() => _OrderActionsState();
}

class _OrderActionsState extends ConsumerState<_OrderActions> {
  bool _busy = false;

  Future<void> _run(Future<void> Function() action) async {
    final l10n = AppLocalizations.of(context);
    setState(() => _busy = true);
    try {
      await action();
    } catch (_) {
      showSnack(l10n.errorUnknown);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final order = widget.order;
    final buyerPays =
        widget.role == OrderRole.buyer &&
        order.testMode &&
        order.status == OrderStatus.pendingPayment;
    // E-tickets reach the buyer as uploaded files; mobile and paper
    // tickets are handed over and the seller confirms it here.
    final sellerSends =
        widget.role == OrderRole.seller &&
        order.ticketType != TicketType.eTicket &&
        order.status == OrderStatus.paid;

    // Only the seller can cancel a sale; buyers contact support.
    final sellerCancels =
        widget.role == OrderRole.seller &&
        order.testMode &&
        canSellerCancel(order.status);

    return AnimatedSize(
      duration: Motion.normal,
      alignment: Alignment.topCenter,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (buyerPays || sellerSends)
            Padding(
              padding: const EdgeInsets.only(top: Space.lg),
              child: SubmitButton(
                label: buyerPays ? l10n.payNow : l10n.markTicketsSent,
                loading: _busy,
                // Mobile and paper tickets: how they went to the buyer (the
                // dialog shows its own progress, so no spinner behind it).
                onPressed: buyerPays
                    ? () => _run(() async {
                        final outcome = await payOrder(context, ref, order);
                        if (outcome is PaymentSucceeded && context.mounted) {
                          showSnack(l10n.paymentSucceeded);
                        }
                      })
                    : () => showHandoverDialog(context, ref, order),
              ),
            ),
          if (sellerCancels)
            Padding(
              padding: const EdgeInsets.only(top: Space.md),
              child: FButton(
                variant: FButtonVariant.outline,
                onPress: _busy ? null : () => _confirmCancel(order),
                prefix: Icon(
                  FLucideIcons.circleX,
                  color: context.theme.colors.destructive,
                ),
                child: Text(
                  l10n.cancelSale,
                  style: TextStyle(color: context.theme.colors.destructive),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _confirmCancel(Order order) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showAppDialog<bool>(
      context: context,
      title: l10n.cancelSaleTitle,
      body: Text(l10n.cancelSaleInfo),
      actions: (context) => [
        FButton(
          variant: FButtonVariant.outline,
          onPress: () => Navigator.pop(context, false),
          child: Text(l10n.keepSale),
        ),
        FButton(
          variant: FButtonVariant.destructive,
          onPress: () => Navigator.pop(context, true),
          child: Text(l10n.cancelSale),
        ),
      ],
    );
    if (confirmed != true || !mounted) return;
    await _run(() async {
      await ref.read(checkoutRepositoryProvider).cancelSale(order);
      showSnack(l10n.saleCancelled);
    });
  }
}

/// What happens next; only problems get the destructive alert style.
class NextStepCard extends StatelessWidget {
  const NextStepCard({super.key, required this.text, required this.tone});

  final String text;
  final StatusTone tone;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final icon = switch (tone) {
      StatusTone.negative => FLucideIcons.octagonAlert,
      StatusTone.positive => FLucideIcons.circleCheck,
      StatusTone.neutral => FLucideIcons.info,
      _ => FLucideIcons.clock,
    };
    final negative = tone == StatusTone.negative;
    return AnimatedSwitcher(
      duration: Motion.slow,
      child: FAlert(
        key: ValueKey(tone),
        variant: negative ? FAlertVariant.destructive : FAlertVariant.primary,
        icon: Icon(icon),
        title: Text(l10n.whatsNext),
        subtitle: Text(text),
      ),
    );
  }
}

class _Invoice extends StatelessWidget {
  const _Invoice({required this.order, required this.role});

  final Order order;
  final OrderRole role;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = context.theme;
    final colors = theme.colors;
    final body = theme.typography.body;
    String money(int m) => formatMoney(context, m, order.currency);
    final seats = seatText(l10n, order.section, order.row, order.seats);
    const divider = FDivider(
      style: .delta(padding: .value(EdgeInsets.symmetric(vertical: Space.lg))),
    );

    Widget row(String label, String value, {bool strong = false}) => Padding(
      padding: const EdgeInsets.symmetric(vertical: Space.xs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              label,
              style: strong
                  ? body.sm.copyWith(
                      fontWeight: FontWeights.semibold,
                      color: colors.foreground,
                    )
                  : body.sm.copyWith(color: colors.mutedForeground),
            ),
          ),
          const SizedBox(width: Space.lg),
          Text(
            value,
            textAlign: TextAlign.end,
            style: strong
                ? body.lg.copyWith(
                    fontWeight: FontWeights.heavy,
                    color: colors.foreground,
                  )
                : body.sm.copyWith(color: colors.foreground),
          ),
        ],
      ),
    );

    return FCard(
      child: Padding(
        padding: const EdgeInsets.all(Space.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.orderNumber,
                        style: body.xs.copyWith(
                          color: colors.mutedForeground,
                          fontWeight: FontWeights.medium,
                        ),
                      ),
                      SelectableText(
                        order.number,
                        style: body.lg.copyWith(
                          letterSpacing: 1,
                          fontWeight: FontWeights.bold,
                          color: colors.foreground,
                        ),
                      ),
                    ],
                  ),
                ),
                FTooltip(
                  tipBuilder: (context, _) => Text(l10n.copy),
                  child: FButton.icon(
                    variant: FButtonVariant.ghost,
                    semanticsLabel: l10n.copy,
                    onPress: () async {
                      await Clipboard.setData(
                        ClipboardData(text: order.number),
                      );
                      showSnack(l10n.copied);
                    },
                    child: const Icon(FLucideIcons.copy),
                  ),
                ),
              ],
            ),
            divider,
            if (order.createdAt case final at?)
              row(l10n.orderDate, formatDateTime(context, at)),
            row(l10n.ticketType, ticketTypeName(l10n, order.ticketType)),
            if (seats.isNotEmpty) row(l10n.seats, seats),
            if (role == OrderRole.buyer && order.paymentMethod.isNotEmpty)
              row(l10n.paymentMethod, order.paymentMethod),
            divider,
            if (role == OrderRole.buyer) ...[
              row(
                '${order.quantity} × ${money(order.unitPriceMinor)}',
                money(order.subtotalMinor),
              ),
              row(
                '${l10n.serviceFee} (${order.fees.buyerPercent} %)',
                money(order.buyerFeeMinor),
              ),
              divider,
              row(l10n.total, money(order.totalMinor), strong: true),
            ] else ...[
              row(l10n.saleAmount, money(order.subtotalMinor)),
              row(
                '${l10n.sellerFeeLabel} (${order.fees.sellerPercent} %)',
                '− ${money(order.sellerFeeMinor)}',
              ),
              divider,
              row(
                l10n.yourEarnings,
                money(order.sellerEarningsMinor),
                strong: true,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
