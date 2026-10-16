import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';

import '../../l10n/app_localizations.dart';
import '../data/events_repository.dart';
import '../data/models.dart';
import '../data/seat_map_repository.dart';
import '../market/labels.dart';
import '../market/listing_ticket.dart';
import '../settings/settings_widgets.dart';
import '../ui/async_view.dart';
import '../ui/format.dart';
import '../ui/responsive_grid.dart';
import '../ui/segmented.dart';
import '../ui/site_scaffold.dart';
import '../ui/skeleton.dart';
import '../ui/tokens.dart';
import 'event_card.dart';
import 'event_page.dart';
import 'seat_map_view.dart';

/// What the buyer narrows the offers down to.
@immutable
class OfferFilter {
  const OfferFilter({
    this.needed = 0,
    this.together = false,
    this.minPrice,
    this.maxPrice,
    this.types = const {},
    this.section,
  });

  /// Tickets needed together; 0 means any.
  final int needed;

  /// Only listings whose seller says the seats are next to each other;
  /// applies from two tickets on.
  final bool together;

  /// Price per ticket as buyers pay it; null: no limit.
  final int? minPrice;
  final int? maxPrice;

  /// Ticket types to show; empty: all.
  final Set<TicketType> types;

  /// A section picked on the seat map.
  final String? section;

  bool get isEmpty =>
      needed == 0 &&
      !together &&
      minPrice == null &&
      maxPrice == null &&
      types.isEmpty &&
      section == null;

  /// Whether [l] passes; [inSection] says whether it's in [section].
  bool accepts(Listing l, {bool Function(Listing)? inSection}) {
    if (l.available < math.max(needed, 1)) return false;
    if (together && needed >= 2 && !l.together) return false;
    final price = l.buyerPriceMinor;
    if (minPrice != null && price < minPrice!) return false;
    if (maxPrice != null && price > maxPrice!) return false;
    if (types.isNotEmpty && !types.contains(l.ticketType)) return false;
    if (section != null && !(inSection?.call(l) ?? true)) return false;
    return true;
  }

  OfferFilter copyWith({
    int? needed,
    bool? together,
    int? Function()? minPrice,
    int? Function()? maxPrice,
    Set<TicketType>? types,
    String? Function()? section,
  }) => OfferFilter(
    needed: needed ?? this.needed,
    together: together ?? this.together,
    minPrice: minPrice == null ? this.minPrice : minPrice(),
    maxPrice: maxPrice == null ? this.maxPrice : maxPrice(),
    types: types ?? this.types,
    section: section == null ? this.section : section(),
  );
}

/// The tickets for one date: the venue's seat map (tap a section to see its
/// offers), filters, and the offers, cheapest first.
class EventTicketsPage extends ConsumerStatefulWidget {
  const EventTicketsPage({super.key, required this.id, this.initial});

  final String id;
  final Event? initial;

  @override
  ConsumerState<EventTicketsPage> createState() => _EventTicketsPageState();
}

class _EventTicketsPageState extends ConsumerState<EventTicketsPage> {
  var _filter = const OfferFilter();

  void _set(OfferFilter f) => setState(() => _filter = f);

  @override
  void didUpdateWidget(EventTicketsPage old) {
    super.didUpdateWidget(old);
    // Another date in the same place: its filters start fresh.
    if (old.id != widget.id) _filter = const OfferFilter();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final live = ref.watch(eventProvider(widget.id));
    final event = live.hasValue ? live.value : widget.initial;
    final wide = isWideLayout(context);

    final Widget body;
    if (event == null) {
      body = AsyncView<Event?>(
        value: live,
        onRetry: () => ref.invalidate(eventProvider(widget.id)),
        loading: const SkeletonTicketList(count: 2),
        data: (_) => Center(
          child: EmptyState(
            icon: FLucideIcons.calendarX,
            title: l10n.eventsNotFound,
            message: l10n.eventsNotFoundInfo,
          ),
        ),
      );
    } else {
      final mapId = seatMapId(event.info.venue, event.info.city);
      final map = ref.watch(seatMapProvider(mapId));
      final listingsValue = ref.watch(eventListingsProvider(event.id));
      final listings = listingsValue.value ?? const <Listing>[];
      final seatMap = map.value;
      bool inSection(Listing l) =>
          _filter.section != null &&
          (seatMap?.sectionOf(l.section)?.matches(_filter.section!) ??
              searchKey(l.section) == searchKey(_filter.section!));

      // Offers per section, for the map: all filters but the section.
      final counts = <String, int>{};
      for (final l in listings) {
        if (!_filter.copyWith(section: () => null).accepts(l)) continue;
        final s = seatMap?.sectionOf(l.section);
        if (s != null) {
          counts.update(searchKey(s.name), (n) => n + 1, ifAbsent: () => 1);
        }
      }

      final mapBlock = _MapBlock(
        map: map,
        counts: counts,
        selected: _filter.section,
        onTap: (s) => _set(
          _filter.copyWith(
            section: () =>
                _filter.section != null && s.matches(_filter.section!)
                ? null
                : s.name,
          ),
        ),
      );
      final filters = _Filters(
        listings: listings,
        filter: _filter,
        onChanged: _set,
      );
      final offers = _OfferList(
        event: event,
        value: listingsValue,
        filter: _filter,
        inSection: inSection,
        columns: 1,
        onReset: () => _set(const OfferFilter()),
      );

      body = ListView(
        padding: EdgeInsets.fromLTRB(
          Insets.side,
          wide ? Space.md : Space.xs,
          Insets.side,
          Space.x5l,
        ),
        children: [
          _Header(event: event),
          const SizedBox(height: Space.xl),
          if (wide)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 6,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [mapBlock, filters],
                  ),
                ),
                const SizedBox(width: Space.x5l),
                Expanded(flex: 5, child: offers),
              ],
            )
          else ...[
            mapBlock,
            filters,
            offers,
          ],
          EventSellHint(event: event),
        ],
      );
    }

    return SiteScaffold(
      title: l10n.ticketsPageTitle,
      maxWidth: SiteWidth.wide,
      body: body,
    );
  }
}

/// Which date this is, with the way back to the other dates.
class _Header extends StatelessWidget {
  const _Header({required this.event});

  final Event event;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = context.theme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          event.info.name,
          style: theme.typography.display.lg.copyWith(
            fontWeight: FontWeights.bold,
            color: theme.colors.foreground,
          ),
        ),
        const SizedBox(height: Space.sm),
        EventMetaLine(
          icon: FLucideIcons.calendar,
          text: formatDateTime(context, event.info.date),
        ),
        const SizedBox(height: Space.xxs),
        EventMetaLine(icon: FLucideIcons.mapPin, text: placeText(event.info)),
        const SizedBox(height: Space.md),
        FButton(
          variant: FButtonVariant.ghost,
          size: FButtonSizeVariant.sm,
          mainAxisSize: MainAxisSize.min,
          prefix: const Icon(FLucideIcons.calendarRange),
          onPress: () {
            final router = GoRouter.of(context);
            if (router.canPop()) {
              router.pop();
            } else {
              router.go('/event/${event.id}', extra: event);
            }
          },
          child: Text(l10n.otherDates),
        ),
      ],
    );
  }
}

/// The seat map with the tap hint, or a note that it's coming.
class _MapBlock extends StatelessWidget {
  const _MapBlock({
    required this.map,
    required this.counts,
    required this.selected,
    required this.onTap,
  });

  final AsyncValue<SeatMap?> map;
  final Map<String, int> counts;
  final String? selected;
  final ValueChanged<SeatSection> onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = context.theme;
    final m = map.value;
    if (m == null && map.isLoading) {
      return Shimmer(
        child: AspectRatio(
          aspectRatio: SeatMap.defaultAspectRatio,
          child: LayoutBuilder(
            builder: (context, box) => SkeletonBox(height: box.maxHeight),
          ),
        ),
      );
    }
    if (m == null || m.sections.isEmpty) {
      return FCard(
        child: Padding(
          padding: const EdgeInsets.all(Space.xl),
          child: Row(
            children: [
              Icon(FLucideIcons.map, color: theme.colors.mutedForeground),
              const SizedBox(width: Space.lg),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l10n.seatMapSoon, style: theme.titleText),
                    Text(l10n.seatMapSoonInfo, style: theme.mutedText),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SeatMapView(
          map: m,
          counts: counts,
          selected: selected,
          onTapSection: onTap,
        ),
        const SizedBox(height: Space.sm),
        Text(l10n.seatMapHint, style: theme.mutedSmallText),
      ],
    );
  }
}

/// How many tickets, seats together, price per ticket and ticket type.
class _Filters extends StatelessWidget {
  const _Filters({
    required this.listings,
    required this.filter,
    required this.onChanged,
  });

  final List<Listing> listings;
  final OfferFilter filter;
  final ValueChanged<OfferFilter> onChanged;

  static const _choices = [0, 1, 2, 3, 4];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    if (listings.length < 2 && filter.isEmpty) return const SizedBox.shrink();

    final prices = [for (final l in listings) l.buyerPriceMinor];
    final low = prices.isEmpty ? 0 : prices.reduce(math.min);
    final high = prices.isEmpty ? 0 : prices.reduce(math.max);
    final currency = listings.isEmpty ? 'BAM' : listings.first.currency;
    final types = {for (final l in listings) l.ticketType}.toList()
      ..sort((a, b) => a.index.compareTo(b.index));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SettingsSectionTitle(l10n.offersHowMany),
        Segmented<int>(
          values: _choices,
          selected: filter.needed,
          label: (n) => n == 0
              ? l10n.offersAnyAmount
              : n == _choices.last
              ? l10n.offersAmountOrMore(n)
              : '$n',
          onChanged: (n) => onChanged(filter.copyWith(needed: n)),
        ),
        AnimatedSize(
          duration: Motion.normal,
          alignment: Alignment.topCenter,
          child: filter.needed < 2
              ? const SizedBox(width: double.infinity)
              : Padding(
                  padding: const EdgeInsets.only(top: Space.lg),
                  child: SettingsGroup(
                    children: [
                      FTile(
                        prefix: const Icon(FLucideIcons.armchair),
                        title: Text(l10n.filterTogether),
                        subtitle: Text(
                          l10n.filterTogetherInfo,
                          overflow: TextOverflow.visible,
                        ),
                        suffix: FSwitch(
                          value: filter.together,
                          onChange: (v) =>
                              onChanged(filter.copyWith(together: v)),
                        ),
                        onPress: () => onChanged(
                          filter.copyWith(together: !filter.together),
                        ),
                      ),
                    ],
                  ),
                ),
        ),
        if (low < high) ...[
          SettingsSectionTitle(l10n.filterPrice),
          _PriceRange(
            low: low,
            high: high,
            currency: currency,
            min: filter.minPrice,
            max: filter.maxPrice,
            onChanged: (min, max) => onChanged(
              filter.copyWith(minPrice: () => min, maxPrice: () => max),
            ),
          ),
        ],
        if (types.length > 1) ...[
          SettingsSectionTitle(l10n.filterTicketType),
          Wrap(
            spacing: Space.md,
            runSpacing: Space.md,
            children: [
              for (final t in types)
                FButton(
                  variant: filter.types.contains(t)
                      ? FButtonVariant.primary
                      : FButtonVariant.outline,
                  size: FButtonSizeVariant.sm,
                  mainAxisSize: MainAxisSize.min,
                  selected: filter.types.contains(t),
                  onPress: () {
                    final next = {...filter.types};
                    if (!next.remove(t)) next.add(t);
                    onChanged(filter.copyWith(types: next));
                  },
                  child: Text(ticketTypeName(l10n, t)),
                ),
            ],
          ),
        ],
        if (filter.section != null || !filter.isEmpty) ...[
          const SizedBox(height: Space.lg),
          Wrap(
            spacing: Space.md,
            runSpacing: Space.md,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              if (filter.section case final section?)
                FButton(
                  variant: FButtonVariant.secondary,
                  size: FButtonSizeVariant.sm,
                  mainAxisSize: MainAxisSize.min,
                  suffix: const Icon(FLucideIcons.x),
                  onPress: () =>
                      onChanged(filter.copyWith(section: () => null)),
                  child: Text(l10n.sectionFilter(section)),
                ),
              FButton(
                variant: FButtonVariant.ghost,
                size: FButtonSizeVariant.sm,
                mainAxisSize: MainAxisSize.min,
                onPress: () => onChanged(const OfferFilter()),
                child: Text(l10n.filtersReset),
              ),
            ],
          ),
        ],
      ],
    );
  }
}

/// A two-thumb slider for the price per ticket between [low] and [high].
class _PriceRange extends StatelessWidget {
  const _PriceRange({
    required this.low,
    required this.high,
    required this.currency,
    required this.min,
    required this.max,
    required this.onChanged,
  });

  final int low;
  final int high;
  final String currency;
  final int? min;
  final int? max;

  /// Null for a bound at the end of the range: no limit there.
  final void Function(int? min, int? max) onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final span = (high - low).toDouble();
    double fraction(int? v, double fallback) =>
        v == null ? fallback : ((v - low) / span).clamp(0.0, 1.0);
    int price(double f) => (low + f * span).round();
    final from = fraction(min, 0), to = fraction(max, 1);
    String money(int v) => formatMoney(context, v, currency);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          '${money(price(from))} – ${money(price(to))}',
          style: theme.titleText,
        ),
        FSlider(
          control: FSliderControl.liftedContinuousRange(
            value: FSliderValue(min: from, max: to),
            onChange: (v) => onChanged(
              v.min <= 0 ? null : price(v.min),
              v.max >= 1 ? null : price(v.max),
            ),
          ),
          semanticFormatterCallback: (v) =>
              '${money(price(v.min))} – ${money(price(v.max))}',
          tooltipBuilder: (_, v) => Text(money(price(v))),
        ),
      ],
    );
  }
}

/// The offers that pass the filter, cheapest first.
class _OfferList extends ConsumerWidget {
  const _OfferList({
    required this.event,
    required this.value,
    required this.filter,
    required this.inSection,
    required this.columns,
    required this.onReset,
  });

  final Event event;
  final AsyncValue<List<Listing>> value;
  final OfferFilter filter;
  final bool Function(Listing) inSection;
  final int columns;
  final VoidCallback onReset;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final listings = value.value ?? const <Listing>[];
    final shown =
        listings.where((l) => filter.accepts(l, inSection: inSection)).toList()
          ..sort((a, b) {
            final byPrice = a.buyerPriceMinor.compareTo(b.buyerPriceMinor);
            return byPrice != 0 ? byPrice : b.available.compareTo(a.available);
          });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SettingsSectionTitle(
          listings.isEmpty
              ? l10n.eventsOffers
              : l10n.eventsOffersCount(shown.length),
        ),
        AsyncView<List<Listing>>(
          value: value,
          onRetry: () => ref.invalidate(eventListingsProvider(event.id)),
          loading: Shimmer(
            child: ResponsiveGrid(
              maxColumns: columns,
              children: [
                for (var i = 0; i < 2; i++) const SkeletonTicketTile(),
              ],
            ),
          ),
          data: (listings) {
            if (listings.isEmpty) {
              return EmptyState(
                icon: FLucideIcons.ticket,
                title: l10n.eventsNoOffers,
                message: event.isUpcoming ? l10n.eventsNoOffersInfo : null,
              );
            }
            if (shown.isEmpty) {
              return EmptyState(
                icon: FLucideIcons.listFilter,
                title: l10n.offersNoneForFilters,
                action: FButton(
                  variant: FButtonVariant.outline,
                  mainAxisSize: MainAxisSize.min,
                  onPress: onReset,
                  child: Text(l10n.filtersReset),
                ),
              );
            }
            return ResponsiveGrid(
              maxColumns: columns,
              children: [
                for (final l in shown)
                  OfferTicket(
                    listing: l,
                    onTap: () => context.push('/listing/${l.id}', extra: l),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }
}
