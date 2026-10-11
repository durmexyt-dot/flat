import 'package:flutter/material.dart';
import 'package:forui/forui.dart';

import '../../l10n/app_localizations.dart';
import '../auth/auth_widgets.dart';
import 'format.dart';

/// Asks for a day, then a time. Null if either picker is cancelled.
Future<DateTime?> pickDateTime(
  BuildContext context, {
  DateTime? initial,
}) async {
  final now = DateTime.now();
  final start = initial ?? now.add(const Duration(days: 7));
  // An existing (past) date stays pickable, so editing doesn't break.
  final first = start.isBefore(now) ? start : now;
  final day = await showDatePicker(
    context: context,
    initialDate: start,
    firstDate: first,
    lastDate: now.add(const Duration(days: 730)),
  );
  if (day == null || !context.mounted) return null;
  final time = await showTimePicker(
    context: context,
    initialTime: initial != null
        ? TimeOfDay.fromDateTime(initial)
        : const TimeOfDay(hour: 20, minute: 0),
  );
  if (time == null) return null;
  return DateTime(day.year, day.month, day.day, time.hour, time.minute);
}

/// A read-only field showing a date and time; tapping it calls [onTap]
/// (usually [pickDateTime]).
class DateTimeField extends StatefulWidget {
  const DateTimeField({
    super.key,
    required this.date,
    required this.error,
    required this.onTap,
  });

  final DateTime? date;
  final String? error;
  final VoidCallback onTap;

  @override
  State<DateTimeField> createState() => _DateTimeFieldState();
}

class _DateTimeFieldState extends State<DateTimeField> {
  final _controller = TextEditingController();
  bool _built = false;

  String _text() =>
      widget.date == null ? '' : formatDateTime(context, widget.date!);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Also on a locale change. Before the first build nobody listens yet.
    _sync();
  }

  @override
  void didUpdateWidget(DateTimeField old) {
    super.didUpdateWidget(old);
    if (old.date != widget.date) _sync();
  }

  /// The field's form state listens to the controller, so changing it while
  /// building would rebuild the form mid-build: update after the frame.
  void _sync() {
    final text = _text();
    if (_controller.text == text) return;
    if (!_built) {
      _controller.text = text;
      return;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _controller.text = _text();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _built = true;
    final l10n = AppLocalizations.of(context);
    // Read-only: tapping opens the date and time pickers.
    return FTextFormField(
      control: FTextFieldControl.managed(controller: _controller),
      label: Text(l10n.dateTime),
      prefixBuilder: (context, style, variants) =>
          fieldIcon(FLucideIcons.calendar),
      suffixBuilder: (context, style, variants) => Padding(
        padding: const EdgeInsetsDirectional.only(end: 12),
        child: Icon(
          FLucideIcons.chevronDown,
          size: 16,
          color: context.theme.colors.mutedForeground,
        ),
      ),
      readOnly: true,
      enableInteractiveSelection: false,
      onTap: widget.onTap,
      forceErrorText: widget.error,
    );
  }
}
