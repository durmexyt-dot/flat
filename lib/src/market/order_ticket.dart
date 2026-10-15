import 'package:flutter/material.dart';
import 'package:forui/forui.dart';

import '../../l10n/app_localizations.dart';
import '../data/models.dart';
import '../ui/format.dart';
import '../ui/hero_tags.dart';
import 'labels.dart';
import 'listing_ticket.dart';
import 'order_labels.dart';
import '../ui/tokens.dart';

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
    final colors = context.theme.colors;
    final type = context.theme.typography;
    final amount = role == OrderRole.buyer
        ? order.totalMinor
        : order.sellerEarningsMinor;

    return EventTicket(
      heroTag: HeroTags.order(order.id),
      event: order.event,
      onTap: onTap,
      lines: [
        const SizedBox(height: Space.md),
        StatusChip(
          label: orderStatusName(l10n, order.status),
          tone: orderTone(order.status),
        ),
        if (orderReasonText(l10n, order) case final reason?) ...[
          const SizedBox(height: Space.xs),
          Text(
            reason,
            style: type.body.xs.copyWith(color: colors.mutedForeground),
          ),
        ],
        const SizedBox(height: Space.md),
        Wrap(
          spacing: Space.md,
          runSpacing: Space.xs,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text(
              formatMoney(context, amount, order.currency),
              style: type.body.lg.copyWith(
                color: colors.foreground,
                fontWeight: FontWeights.bold,
              ),
            ),
            Text(
              l10n.ticketsCount('${order.quantity}'),
              style: type.body.xs.copyWith(color: colors.mutedForeground),
            ),
          ],
        ),
        Text(
          order.number,
          style: type.body.xs.copyWith(
            color: colors.mutedForeground,
            letterSpacing: 0.8,
          ),
        ),
      ],
    );
  }
}
