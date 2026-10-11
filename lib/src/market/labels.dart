import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../data/models.dart';

String categoryName(AppLocalizations l10n, EventCategory c) => switch (c) {
  EventCategory.concerts => l10n.catConcerts,
  EventCategory.sports => l10n.catSports,
  EventCategory.theater => l10n.catTheater,
  EventCategory.festivals => l10n.catFestivals,
  EventCategory.other => l10n.other,
};

IconData categoryIcon(EventCategory c) => switch (c) {
  EventCategory.concerts => Icons.music_note_outlined,
  EventCategory.sports => Icons.sports_soccer_outlined,
  EventCategory.theater => Icons.theater_comedy_outlined,
  EventCategory.festivals => Icons.festival_outlined,
  EventCategory.other => Icons.local_activity_outlined,
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
};

/// Tone of a status: decides the chip colors.
enum StatusTone { positive, active, waiting, neutral, negative }

StatusTone listingTone(ListingStatus s) => switch (s) {
  ListingStatus.active => StatusTone.active,
  ListingStatus.reserved => StatusTone.waiting,
  ListingStatus.soldOut => StatusTone.positive,
  ListingStatus.expired || ListingStatus.withdrawn => StatusTone.neutral,
};

/// Signal color of a status tone.
Color statusToneColor(StatusTone tone, ColorScheme c) => switch (tone) {
  StatusTone.positive => const Color(0xFF2E9E5B),
  StatusTone.active => c.primary,
  StatusTone.waiting => const Color(0xFFE0A100),
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
    // Neutral chip; only the dot carries the status color.
    final dot = statusToneColor(tone, c);
    return Container(
      padding: const EdgeInsets.fromLTRB(8, 4, 10, 4),
      decoration: BoxDecoration(
        color: c.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: dot, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: Theme.of(context).textTheme.labelMedium!
                .copyWith(color: c.onSurface, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
