import 'package:flutter/material.dart';
import 'package:forui/forui.dart';

import '../../l10n/app_localizations.dart';
import '../data/models.dart';
import '../events/event_card.dart';
import '../ui/responsive_grid.dart';
import '../ui/site_scaffold.dart';
import '../ui/skeleton.dart';
import '../ui/tokens.dart';

const _gap = 16.0;

/// Width of a card in a row: about 280 on phones, four in a row on wide
/// screens.
double _cardWidth(BuildContext context, double maxWidth) =>
    isWideLayout(context)
    ? (maxWidth - _gap * 3) / 4
    : (maxWidth * 0.82).clamp(220, 280).toDouble();

/// A home page section title, with an optional hint below and actions on
/// the right.
class HomeSectionHeader extends StatelessWidget {
  const HomeSectionHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.actions = const [],
    this.small = false,
  });

  final String title;
  final String? subtitle;
  final List<Widget> actions;

  /// For rows within a group, e.g. genres under "Popular categories".
  final bool small;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final wide = isWideLayout(context);
    final style = small
        ? theme.typography.body.md
        : wide
        ? theme.typography.body.xl
        : theme.typography.body.lg;
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                style: style.copyWith(
                  fontWeight: small ? FontWeights.semibold : FontWeights.bold,
                  color: theme.colors.foreground,
                ),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: Space.xxs),
                Text(subtitle!, style: theme.mutedText),
              ],
            ],
          ),
        ),
        ...actions,
      ],
    );
  }
}

/// A titled, horizontally scrolling row of event cards. Wide screens get
/// buttons to page through it.
class EventRowSection extends StatefulWidget {
  const EventRowSection({
    super.key,
    required this.title,
    required this.events,
    required this.onOpen,
    this.subtitle,
    this.actions = const [],
    this.heroes = false,
    this.small = false,
    this.gutter = 0,
  });

  final String title;
  final String? subtitle;

  /// Side padding. The row scrolls under it, up to the screen edge.
  final double gutter;
  final List<Widget> actions;
  final List<Event> events;
  final ValueChanged<Event> onOpen;

  /// Whether the pictures fly to the event page. Only one card per event
  /// on the page may.
  final bool heroes;
  final bool small;

  @override
  State<EventRowSection> createState() => _EventRowSectionState();
}

class _EventRowSectionState extends State<EventRowSection> {
  final _scroll = ScrollController();

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  void _page(int direction) {
    if (!_scroll.hasClients) return;
    final p = _scroll.position;
    _scroll.animateTo(
      (p.pixels + direction * (p.viewportDimension + _gap)).clamp(
        0,
        p.maxScrollExtent,
      ),
      duration: Motion.slower,
      curve: Motion.enter,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final wide = isWideLayout(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: widget.gutter),
          child: HomeSectionHeader(
            title: widget.title,
            subtitle: widget.subtitle,
            small: widget.small,
            actions: [
              ...widget.actions,
              if (wide && widget.events.length > 4) ...[
                const SizedBox(width: Space.xs),
                FButton.icon(
                  variant: FButtonVariant.ghost,
                  semanticsLabel: l10n.homeScrollBack,
                  onPress: () => _page(-1),
                  child: const Icon(FLucideIcons.chevronLeft),
                ),
                FButton.icon(
                  variant: FButtonVariant.ghost,
                  semanticsLabel: l10n.homeScrollForward,
                  onPress: () => _page(1),
                  child: const Icon(FLucideIcons.chevronRight),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: Space.lg),
        LayoutBuilder(
          builder: (context, constraints) {
            final width = _cardWidth(
              context,
              constraints.maxWidth - widget.gutter * 2,
            );
            return HeroMode(
              enabled: widget.heroes,
              child: SingleChildScrollView(
                controller: _scroll,
                padding: EdgeInsets.symmetric(horizontal: widget.gutter),
                scrollDirection: Axis.horizontal,
                // Cards in a row share their height.
                child: IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    spacing: _gap,
                    children: [
                      for (final e in widget.events)
                        SizedBox(
                          key: ValueKey(e.id),
                          width: width,
                          child: EventCard(
                            event: e,
                            onTap: () => widget.onOpen(e),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

/// Events in as many columns as fit (one on phones).
class EventGrid extends StatelessWidget {
  const EventGrid({
    super.key,
    required this.events,
    required this.onOpen,
    this.heroes = false,
  });

  final List<Event> events;
  final ValueChanged<Event> onOpen;
  final bool heroes;

  @override
  Widget build(BuildContext context) {
    return HeroMode(
      enabled: heroes,
      child: ResponsiveGrid(
        minItemWidth: 280,
        maxColumns: 4,
        gap: _gap,
        children: [
          for (final e in events)
            EventCard(key: ValueKey(e.id), event: e, onTap: () => onOpen(e)),
        ],
      ),
    );
  }
}

/// A placeholder section while events load.
class SkeletonEventRow extends StatelessWidget {
  const SkeletonEventRow({super.key, this.gutter = 0});

  final double gutter;

  @override
  Widget build(BuildContext context) {
    return Shimmer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: gutter),
            child: const SkeletonBox(width: 180, height: 20),
          ),
          const SizedBox(height: Space.lg),
          LayoutBuilder(
            builder: (context, constraints) {
              final width = _cardWidth(
                context,
                constraints.maxWidth - gutter * 2,
              );
              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(horizontal: gutter),
                physics: const NeverScrollableScrollPhysics(),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: _gap,
                  children: [
                    for (var i = 0; i < 4; i++)
                      SizedBox(width: width, child: const SkeletonEventCard()),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
