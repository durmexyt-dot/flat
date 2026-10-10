import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../l10n/app_localizations.dart';
import '../data/models.dart';
import '../data/repositories.dart';
import '../ui/async_view.dart';
import '../ui/skeleton.dart';
import 'demo_banner.dart';
import 'order_labels.dart';
import 'order_ticket.dart';

enum _Filter { all, inProgress, completed, cancelled }

/// Purchases (as buyer) or sales (as seller).
class OrdersPage extends ConsumerStatefulWidget {
  const OrdersPage({super.key, required this.role});

  final OrderRole role;

  @override
  ConsumerState<OrdersPage> createState() => _OrdersPageState();
}

class _OrdersPageState extends ConsumerState<OrdersPage> {
  _Filter _filter = _Filter.all;

  bool _matches(Order o) => switch (_filter) {
    _Filter.all => true,
    _Filter.inProgress => const {
      OrderStatus.pendingPayment,
      OrderStatus.paid,
      OrderStatus.ticketsSent,
      OrderStatus.disputed,
    }.contains(o.status),
    _Filter.completed => o.status == OrderStatus.completed,
    _Filter.cancelled =>
      o.status == OrderStatus.cancelled || o.status == OrderStatus.refunded,
  };

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final buyer = widget.role == OrderRole.buyer;
    final provider = buyer ? purchasesProvider : salesProvider;
    final orders = ref.watch(provider);
    final labels = {
      _Filter.all: l10n.filterAll,
      _Filter.inProgress: l10n.filterInProgress,
      _Filter.completed: l10n.filterCompleted,
      _Filter.cancelled: l10n.filterCancelled,
    };

    return Scaffold(
      appBar: AppBar(title: Text(buyer ? l10n.purchases : l10n.sales)),
      body: Column(
        children: [
          const DemoBanner(),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: Row(
              children: [
                for (final f in _Filter.values)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(labels[f]!),
                      selected: _filter == f,
                      onSelected: (_) => setState(() => _filter = f),
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            child: AsyncView<List<Order>>(
              value: orders,
              onRetry: () => ref.invalidate(provider),
              loading: const SkeletonTicketList(),
              data: (all) {
                if (all.isEmpty) {
                  return EmptyState(
                    icon: buyer
                        ? Icons.receipt_long_outlined
                        : Icons.point_of_sale_outlined,
                    title: buyer ? l10n.noPurchases : l10n.noSales,
                    message: buyer ? l10n.noPurchasesInfo : l10n.noSalesInfo,
                  );
                }
                final shown = all.where(_matches).toList();
                return AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  child: ListView.separated(
                    key: ValueKey(_filter),
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
                    itemCount: shown.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 12),
                    itemBuilder: (context, i) => OrderTicket(
                      order: shown[i],
                      role: widget.role,
                      onTap: () => context.push(
                        '/order/${shown[i].id}',
                        extra: shown[i],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
