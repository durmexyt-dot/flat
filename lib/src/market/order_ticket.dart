import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../data/models.dart';
import '../ui/format.dart';
import '../ui/hero_tags.dart';
import 'labels.dart';
import 'listing_ticket.dart';
import 'order_labels.dart';

/// An order as a ticket: number, quantity, amount and status.
class OrderTicket extends StatelessWidget {
  const OrderTicket({
    super.key,
    required this.order,
    required this.role,
    this.onTap,
  });

  final Order order;
  final OrderRole role;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final amount = role == OrderRole.buyer
        ? order.totalMinor
        : order.sellerEarningsMinor;

    return EventTicket(
      heroTag: HeroTags.order(order.id),
      event: order.event,
      onTap: onTap,
      lines: [
        const SizedBox(height: 8),
        StatusChip(
          label: orderStatusName(l10n, order.status),
          tone: orderTone(order.status),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 4,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text(
              formatMoney(context, amount, order.currency),
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w800,
              ),
            ),
            Text(
              l10n.ticketsCount('${order.quantity}'),
              style: theme.textTheme.bodySmall,
            ),
          ],
        ),
        Text(
          order.number,
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            letterSpacing: 0.8,
          ),
        ),
      ],
    );
  }
}
