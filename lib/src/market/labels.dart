import 'package:flutter/material.dart';
import 'package:forui/forui.dart';

import '../../l10n/app_localizations.dart';
import '../data/models.dart';
import '../ui/tokens.dart';

String categoryName(AppLocalizations l10n, EventCategory c) => switch (c) {
  EventCategory.concerts => l10n.catConcerts,
  EventCategory.sports => l10n.catSports,
  EventCategory.theater => l10n.catTheater,
  EventCategory.festivals => l10n.catFestivals,
  EventCategory.other => l10n.other,
};

IconData categoryIcon(EventCategory c) => switch (c) {
  EventCategory.concerts => FLucideIcons.music,
  EventCategory.sports => FLucideIcons.volleyball,
  EventCategory.theater => FLucideIcons.drama,
  EventCategory.festivals => FLucideIcons.tent,
  EventCategory.other => FLucideIcons.ticket,
};

String ticketTypeName(AppLocalizations l10n, TicketType t) => switch (t) {
  TicketType.eTicket => l10n.ticketEticket,
  TicketType.mobile => l10n.ticketMobile,
  TicketType.paper => l10n.ticketPaper,
};

String listingStatusName(AppLocalizations l10n, ListingStatus s) => switch (s) {
  ListingStatus.active => l10n.statusActive,
  ListingStatus.reserved => l10n.statusReserved,
  ListingStatus.soldOut => l10n.statusSoldOut,
  ListingStatus.expired => l10n.statusExpired,
  ListingStatus.withdrawn => l10n.statusWithdrawn,
  ListingStatus.removed => l10n.statusRemoved,
};

/// Tone of a status: decides the chip colors.
enum StatusTone { positive, active, waiting, neutral, negative }

StatusTone listingTone(ListingStatus s) => switch (s) {
  ListingStatus.active => StatusTone.active,
  ListingStatus.reserved => StatusTone.waiting,
  ListingStatus.soldOut => StatusTone.positive,
  ListingStatus.expired || ListingStatus.withdrawn => StatusTone.neutral,
  ListingStatus.removed => StatusTone.negative,
};

/// Signal color of a status tone.
Color statusToneColor(StatusTone tone, ColorScheme c) => switch (tone) {
  StatusTone.positive => FixedColors.positive,
  StatusTone.active => c.primary,
  StatusTone.waiting => FixedColors.waiting,
  StatusTone.neutral => c.outline,
  StatusTone.negative => c.error,
};

/// A status label with a colored dot; the color animates on change.
class StatusChip extends StatelessWidget {
  const StatusChip({super.key, required this.label, required this.tone});

  final String label;
  final StatusTone tone;

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).colorScheme;
    // Neutral Forui badge; only the dot carries the status color.
    return FBadge(
      variant: FBadgeVariant.secondary,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: Motion.slow,
            width: 7,
            height: 7,
            decoration: BoxDecoration(
              color: statusToneColor(tone, c),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: Space.sm),
          Text(label),
        ],
      ),
    );
  }
}
