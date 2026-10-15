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
import 'listing_ticket.dart';
import 'ticket_files_widgets.dart';
import '../ui/segmented.dart';
import '../ui/site_scaffold.dart';
import '../ui/tokens.dart';

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
      maxWidth: SiteWidth.full,
      accountNav: true,
      actions: [
        if (isWideLayout(context))
          FButton(
            mainAxisSize: MainAxisSize.min,
            onPress: () => context.push('/sell'),
            prefix: const Icon(FLucideIcons.plus),
            child: Text(l10n.sellTickets, overflow: TextOverflow.ellipsis),
          ),
      ],
      floatingActionButton: FButton(
        mainAxisSize: MainAxisSize.min,
        onPress: () => context.push('/sell'),
        prefix: const Icon(FLucideIcons.plus),
        child: Text(l10n.sellTickets, overflow: TextOverflow.ellipsis),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              Space.xl,
              Space.md,
              Space.xl,
              Space.md,
            ),
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
            child: AsyncView<List<Listing>>(
              value: listings,
              onRetry: () => ref.invalidate(myListingsProvider),
              loading: const SkeletonTicketList(),
              data: (all) {
                final shown = all.where(_matches).toList();
                if (all.isEmpty) {
                  return EmptyState(
                    icon: FLucideIcons.tag,
                    title: l10n.noListings,
                    message: l10n.noListingsInfo,
                    action: FButton(
                      mainAxisSize: MainAxisSize.min,
                      onPress: () => context.push('/sell'),
                      child: Text(
                        l10n.sellTickets,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  );
                }
                return AnimatedSwitcher(
                  duration: Motion.normal,
                  child: ListView(
                    key: ValueKey(_filter),
                    padding: const EdgeInsets.fromLTRB(
                      Space.xl,
                      Space.md,
                      Space.xl,
                      96,
                    ),
                    children: [
                      const SalesAwaitingTicketsAlert(
                        padding: EdgeInsets.only(bottom: Space.lg),
                      ),
                      ResponsiveGrid(
                        maxColumns: 2,
                        children: [
                          for (final l in shown)
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                ListingTicket(
                                  listing: l,
                                  showStatus: true,
                                  onTap: () => context.push(
                                    '/listing/${l.id}',
                                    extra: l,
                                  ),
                                ),
                                ListingMissingTickets(listing: l),
                              ],
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
