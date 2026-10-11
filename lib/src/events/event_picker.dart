import 'package:flutter/material.dart';
import 'package:forui/forui.dart';

import '../../l10n/app_localizations.dart';
import '../auth/auth_widgets.dart';
import '../data/models.dart';
import '../ui/app_style.dart';
import '../ui/async_view.dart';
import '../ui/format.dart';
import 'event_card.dart';
import 'event_image.dart';
import 'event_status_badge.dart';

/// A sheet with a search field and the given events. Returns the chosen
/// one, or null if dismissed.
Future<Event?> showEventPicker(
  BuildContext context, {
  required List<Event> events,
  String? selectedId,
  VoidCallback? onAddEvent,
}) => showFSheet<Event>(
  context: context,
  side: FLayout.btt,
  mainAxisMaxRatio: 0.85,
  constraints: const BoxConstraints(maxWidth: 640),
  builder: (_) => _EventPickerSheet(
    events: events,
    selectedId: selectedId,
    onAddEvent: onAddEvent,
  ),
);

class _EventPickerSheet extends StatefulWidget {
  const _EventPickerSheet({
    required this.events,
    this.selectedId,
    this.onAddEvent,
  });

  final List<Event> events;
  final String? selectedId;

  /// Shows "Event not listed? Add it"; called after the sheet closes.
  final VoidCallback? onAddEvent;

  @override
  State<_EventPickerSheet> createState() => _EventPickerSheetState();
}

class _EventPickerSheetState extends State<_EventPickerSheet> {
  final _search = TextEditingController();

  @override
  void initState() {
    super.initState();
    _search.addListener(_onChanged);
  }

  void _onChanged() => setState(() {});

  @override
  void dispose() {
    _search
      ..removeListener(_onChanged)
      ..dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = context.theme;
    final q = _search.text.trim().toLowerCase();
    final shown = [
      for (final e in widget.events)
        if (q.isEmpty ||
            [
              e.info.name,
              e.info.venue,
              e.info.city,
            ].any((s) => s.toLowerCase().contains(q)))
          e,
    ];

    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colors.background,
        border: Border(top: BorderSide(color: theme.colors.border)),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                l10n.eventsPick,
                style: theme.typography.body.lg.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.colors.foreground,
                ),
              ),
              const SizedBox(height: 12),
              FTextField(
                control: FTextFieldControl.managed(controller: _search),
                hint: l10n.eventsSearch,
                textInputAction: TextInputAction.search,
                prefixBuilder: (context, style, variants) =>
                    fieldIcon(FLucideIcons.search),
                clearable: (value) => value.text.isNotEmpty,
              ),
              const SizedBox(height: 8),
              Flexible(
                child: AnimatedSize(
                  duration: const Duration(milliseconds: 200),
                  alignment: Alignment.topCenter,
                  child: shown.isEmpty
                      ? EmptyState(
                          icon: FLucideIcons.searchX,
                          title: l10n.searchNoResults(_search.text.trim()),
                        )
                      : ListView.separated(
                          shrinkWrap: true,
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          itemCount: shown.length,
                          separatorBuilder: (_, _) => const SizedBox(height: 4),
                          itemBuilder: (context, i) => EventRow(
                            event: shown[i],
                            selected: shown[i].id == widget.selectedId,
                            onTap: () => Navigator.pop(context, shown[i]),
                          ),
                        ),
                ),
              ),
              if (widget.onAddEvent != null) ...[
                const SizedBox(height: 4),
                AddEventPrompt(
                  onPress: () {
                    Navigator.pop(context);
                    widget.onAddEvent!();
                  },
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// "Event not listed? Add it": leads users to add a missing event.
class AddEventPrompt extends StatelessWidget {
  const AddEventPrompt({super.key, required this.onPress});

  final VoidCallback onPress;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = context.theme;
    return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 4,
      children: [
        Text(
          l10n.eventsUserNotListed,
          style: theme.typography.body.sm.copyWith(
            color: theme.colors.mutedForeground,
          ),
        ),
        FButton(
          variant: FButtonVariant.ghost,
          size: FButtonSizeVariant.sm,
          mainAxisSize: MainAxisSize.min,
          onPress: onPress,
          prefix: const Icon(FLucideIcons.calendarPlus),
          child: Text(l10n.eventsUserAddIt, overflow: TextOverflow.ellipsis),
        ),
      ],
    );
  }
}

/// A compact event line: thumbnail, name, date, place.
class EventRow extends StatelessWidget {
  const EventRow({
    super.key,
    required this.event,
    this.selected = false,
    this.trailing,
    this.onTap,
    this.showStatus = true,
    this.showConfirmed = false,
  });

  final Event event;
  final bool selected;

  /// Marks events that aren't confirmed (confirmed ones stay unmarked).
  final bool showStatus;

  /// Marks confirmed events too, e.g. in the team's list.
  final bool showConfirmed;
  final Widget? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final colors = theme.colors;
    final radius = AppStyle.of(context).controlRadius;
    return FTappable(
      onPress: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: selected ? colors.muted : null,
          borderRadius: BorderRadius.circular(radius),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 96,
              child: EventImage(
                event: event,
                borderRadius: BorderRadius.circular(radius * 0.6),
                iconSize: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    event.info.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.typography.body.md.copyWith(
                      fontWeight: FontWeight.w600,
                      color: colors.foreground,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    formatDateTime(context, event.info.date),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.typography.body.xs.copyWith(
                      color: colors.mutedForeground,
                    ),
                  ),
                  Text(
                    placeText(event.info),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.typography.body.xs.copyWith(
                      color: colors.mutedForeground,
                    ),
                  ),
                  if (showStatus && (showConfirmed || !event.confirmed)) ...[
                    const SizedBox(height: 4),
                    EventStatusBadge(event),
                  ],
                ],
              ),
            ),
            if (trailing != null) ...[const SizedBox(width: 8), trailing!],
            if (selected) ...[
              const SizedBox(width: 8),
              Icon(FLucideIcons.check, size: 18, color: colors.primary),
            ],
          ],
        ),
      ),
    );
  }
}

/// The sell form's event choice: a bordered box showing the chosen event,
/// or a prompt; tapping opens the picker.
class EventField extends StatelessWidget {
  const EventField({
    super.key,
    required this.event,
    required this.error,
    required this.onTap,
  });

  final Event? event;
  final String? error;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = context.theme;
    final colors = theme.colors;
    final radius = AppStyle.of(context).controlRadius;
    final e = event;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        FTappable(
          onPress: onTap,
          semanticsLabel: l10n.eventsPick,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              color: colors.card,
              border: Border.all(
                color: error != null ? colors.error : colors.border,
              ),
              borderRadius: BorderRadius.circular(radius),
            ),
            child: AnimatedSize(
              duration: const Duration(milliseconds: 250),
              alignment: Alignment.topCenter,
              child: e == null
                  ? Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 14,
                      ),
                      child: Row(
                        children: [
                          Icon(
                            FLucideIcons.ticket,
                            size: 18,
                            color: colors.mutedForeground,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              l10n.eventsPick,
                              style: theme.typography.body.sm.copyWith(
                                color: colors.mutedForeground,
                              ),
                            ),
                          ),
                          Icon(
                            FLucideIcons.chevronDown,
                            size: 16,
                            color: colors.mutedForeground,
                          ),
                        ],
                      ),
                    )
                  : EventRow(
                      key: ValueKey(e.id),
                      event: e,
                      trailing: Text(
                        l10n.eventsChange,
                        style: theme.typography.body.sm.copyWith(
                          fontWeight: FontWeight.w500,
                          color: colors.foreground,
                        ),
                      ),
                    ),
            ),
          ),
        ),
        AnimatedSize(
          duration: const Duration(milliseconds: 200),
          alignment: Alignment.topCenter,
          child: error == null
              ? const SizedBox(width: double.infinity)
              : Padding(
                  padding: const EdgeInsets.fromLTRB(2, 6, 2, 0),
                  child: Text(
                    error!,
                    style: theme.typography.body.xs.copyWith(
                      color: colors.error,
                    ),
                  ),
                ),
        ),
      ],
    );
  }
}
