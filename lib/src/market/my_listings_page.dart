import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../l10n/app_localizations.dart';
import '../data/models.dart';
import '../data/repositories.dart';
import '../ui/async_view.dart';
import '../ui/skeleton.dart';
import 'listing_ticket.dart';
import '../ui/site_scaffold.dart';

enum _Filter { all, active, soldOut, ended }

class MyListingsPage extends ConsumerStatefulWidget {
  const MyListingsPage({super.key});

  @override
  ConsumerState<MyListingsPage> createState() => _MyListingsPageState();
}

class _MyListingsPageState extends ConsumerState<MyListingsPage> {
  _Filter _filter = _Filter.all;

  bool _matches(Listing l) => switch (_filter) {
    _Filter.all => true,
    _Filter.active =>
      l.status == ListingStatus.active || l.status == ListingStatus.reserved,
    _Filter.soldOut => l.status == ListingStatus.soldOut,
    _Filter.ended =>
      l.status == ListingStatus.expired || l.status == ListingStatus.withdrawn,
  };

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final listings = ref.watch(myListingsProvider);
    final labels = {
      _Filter.all: l10n.filterAll,
      _Filter.active: l10n.statusActive,
      _Filter.soldOut: l10n.statusSoldOut,
      _Filter.ended: l10n.ended,
    };

    return SiteScaffold(
      title: l10n.myListings,
      maxWidth: SiteWidth.detail,
      actions: [
        if (isWideLayout(context))
          FilledButton.icon(
            onPressed: () => context.push('/sell'),
            icon: const Icon(Icons.add),
            label: Text(l10n.sellTickets),
          ),
      ],
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/sell'),
        icon: const Icon(Icons.add),
        label: Text(l10n.sellTickets),
      ),
      body: Column(
        children: [
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
            child: AsyncView<List<Listing>>(
              value: listings,
              onRetry: () => ref.invalidate(myListingsProvider),
              loading: const SkeletonTicketList(),
              data: (all) {
                final shown = all.where(_matches).toList();
                if (all.isEmpty) {
                  return EmptyState(
                    icon: Icons.sell_outlined,
                    title: l10n.noListings,
                    message: l10n.noListingsInfo,
                    action: FilledButton(
                      onPressed: () => context.push('/sell'),
                      child: Text(l10n.sellTickets),
                    ),
                  );
                }
                return AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  child: ListView.separated(
                    key: ValueKey(_filter),
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
                    itemCount: shown.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 12),
                    itemBuilder: (context, i) => ListingTicket(
                      listing: shown[i],
                      showStatus: true,
                      onTap: () => context.push(
                        '/listing/${shown[i].id}',
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
