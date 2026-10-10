import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../l10n/app_localizations.dart';
import '../data/models.dart';
import '../data/repositories.dart';
import '../settings/settings_widgets.dart';
import '../ui/async_view.dart';
import '../ui/format.dart';
import '../ui/skeleton.dart';
import '../ui/snack.dart';
import '../ui/status_timeline.dart';
import 'labels.dart';
import 'listing_ticket.dart';
import 'order_labels.dart';
import 'order_ticket.dart';

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

    return Scaffold(
      appBar: AppBar(
        title: Text(
          role == OrderRole.seller ? l10n.saleDetails : l10n.orderDetails,
        ),
      ),
      body: order == null
          ? AsyncView<Order?>(
              value: live,
              onRetry: () => ref.invalidate(orderProvider(id)),
              loading: const SkeletonTicketList(count: 1),
              data: (_) =>
                  EmptyState(icon: Icons.search_off, title: l10n.loadError),
            )
          : ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
              children: [
                OrderTicket(order: order, role: role),
                const SizedBox(height: 16),
                NextStepCard(
                  text: orderNextStep(l10n, order.status, role),
                  tone: orderTone(order.status),
                ),
                SettingsSectionTitle(l10n.statusHistory),
                StatusTimeline(steps: orderTimeline(context, order)),
                SettingsSectionTitle(l10n.invoice),
                _Invoice(order: order, role: role),
                if (role == OrderRole.seller &&
                    order.status == OrderStatus.completed) ...[
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: () => context.push('/account/payouts'),
                    icon: const Icon(Icons.account_balance_outlined),
                    label: Text(l10n.payouts),
                  ),
                ],
              ],
            ),
    );
  }
}

/// What happens next, colored by the status tone.
class NextStepCard extends StatelessWidget {
  const NextStepCard({super.key, required this.text, required this.tone});

  final String text;
  final StatusTone tone;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final c = Theme.of(context).colorScheme;
    final (bg, fg, icon) = switch (tone) {
      StatusTone.negative => (
        c.errorContainer,
        c.onErrorContainer,
        Icons.report_outlined,
      ),
      StatusTone.positive => (
        c.tertiaryContainer,
        c.onTertiaryContainer,
        Icons.check_circle_outline,
      ),
      StatusTone.neutral => (
        c.surfaceContainerHighest,
        c.onSurfaceVariant,
        Icons.info_outline,
      ),
      _ => (c.primaryContainer, c.onPrimaryContainer, Icons.schedule),
    };
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: fg),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.whatsNext,
                  style: Theme.of(context).textTheme.labelLarge
                      ?.copyWith(color: fg),
                ),
                const SizedBox(height: 2),
                Text(text, style: TextStyle(color: fg)),
              ],
            ),
          ),
        ],
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
    final theme = Theme.of(context);
    String money(int m) => formatMoney(context, m, order.currency);
    final seats = seatText(l10n, order.section, order.row, order.seats);

    Widget row(String label, String value, {bool strong = false}) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              label,
              style: strong
                  ? theme.textTheme.titleSmall
                  : theme.textTheme.bodyMedium,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            value,
            textAlign: TextAlign.end,
            style: strong
                ? theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: theme.colorScheme.primary,
                  )
                : theme.textTheme.bodyMedium,
          ),
        ],
      ),
    );

    return Card.filled(
      margin: EdgeInsets.zero,
      color: theme.colorScheme.surfaceContainerLow,
      child: Padding(
        padding: const EdgeInsets.all(16),
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
                        style: theme.textTheme.labelMedium,
                      ),
                      SelectableText(
                        order.number,
                        style: theme.textTheme.titleMedium?.copyWith(
                          letterSpacing: 1,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: l10n.copy,
                  icon: const Icon(Icons.copy_outlined),
                  onPressed: () async {
                    final messenger = ScaffoldMessenger.of(context);
                    await Clipboard.setData(ClipboardData(text: order.number));
                    showSnack(messenger, l10n.copied);
                  },
                ),
              ],
            ),
            const Divider(height: 24),
            if (order.createdAt case final at?)
              row(l10n.orderDate, formatDateTime(context, at)),
            row(l10n.ticketType, ticketTypeName(l10n, order.ticketType)),
            if (seats.isNotEmpty) row(l10n.seats, seats),
            if (role == OrderRole.buyer && order.paymentMethod.isNotEmpty)
              row(l10n.paymentMethod, order.paymentMethod),
            const Divider(height: 24),
            if (role == OrderRole.buyer) ...[
              row(
                '${order.quantity} × ${money(order.unitPriceMinor)}',
                money(order.subtotalMinor),
              ),
              row(
                '${l10n.serviceFee} (${Fees.buyerPercent} %)',
                money(order.buyerFeeMinor),
              ),
              const Divider(height: 24),
              row(l10n.total, money(order.totalMinor), strong: true),
            ] else ...[
              row(l10n.saleAmount, money(order.subtotalMinor)),
              row(
                '${l10n.sellerFeeLabel} (${Fees.sellerPercent} %)',
                '− ${money(order.sellerFeeMinor)}',
              ),
              const Divider(height: 24),
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
