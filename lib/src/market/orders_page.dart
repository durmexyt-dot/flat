import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:forui/forui.dart';

import '../../l10n/app_localizations.dart';
import '../data/models.dart';
import '../data/repositories.dart';
import '../ui/async_view.dart';
import '../ui/responsive_grid.dart';
import '../ui/skeleton.dart';
import 'order_labels.dart';
import 'order_ticket.dart';
import '../ui/segmented.dart';
import '../ui/site_scaffold.dart';

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

    return SiteScaffold(
      title: buyer ? l10n.purchases : l10n.sales,
      maxWidth: SiteWidth.full,
      accountNav: true,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: Align(
              alignment: AlignmentDirectional.centerStart,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 560),
                child: Segmented<_Filter>(
                  values: _Filter.values,
                  selected: _filter,
                  label: (f) => labels[f]!,
                  scrollable: !isWideLayout(context),
                  onChanged: (f) => setState(() => _filter = f),
                ),
              ),
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
                    icon: buyer ? FLucideIcons.receipt : FLucideIcons.store,
                    title: buyer ? l10n.noPurchases : l10n.noSales,
                    message: buyer ? l10n.noPurchasesInfo : l10n.noSalesInfo,
                  );
                }
                final shown = all.where(_matches).toList();
                return AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  child: ListView(
                    key: ValueKey(_filter),
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
                    children: [
                      ResponsiveGrid(
                        maxColumns: 2,
                        children: [
                          for (final o in shown)
                            OrderTicket(
                              order: o,
                              role: widget.role,
                              onTap: () =>
                                  context.push('/order/${o.id}', extra: o),
                            ),
                        ],
                      ),
                    ],
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
