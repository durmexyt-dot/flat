import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/app_localizations.dart';
import '../admin/admin_repository.dart';
import '../data/models.dart';
import '../data/repositories.dart';
import '../router.dart';
import '../support/support_repository.dart';
import '../ui/snack.dart';
import '../web/browser_notifications.dart';

/// Tells live about support: the user when the team answered (or closed)
/// one of their requests, the team when a request comes in or a user
/// writes again. A toast in the app and, while the tab is in the
/// background, a system notification.
///
/// Only changes count: the first snapshot after a sign in or app start is
/// taken as it is.
class SupportAlerts extends ConsumerStatefulWidget {
  const SupportAlerts({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<SupportAlerts> createState() => _SupportAlertsState();
}

class _SupportAlertsState extends ConsumerState<SupportAlerts> {
  /// The last snapshot per side (user / team), with the user it belongs to.
  final _last = <bool, (String, Map<String, SupportTicket>)>{};

  Map<String, SupportTicket>? _before(bool staff, String uid) =>
      switch (_last[staff]) {
        (final owner, final map) when owner == uid => map,
        _ => null,
      };

  void _onMine(AsyncValue<List<SupportTicket>> next) {
    final uid = ref.read(currentUidProvider);
    final list = next.value;
    if (uid == null || list == null || next.isLoading) {
      if (uid == null) _last.remove(false);
      return;
    }
    final before = _before(false, uid);
    _last[false] = (uid, {for (final t in list) t.id: t});
    if (before == null) return;
    final l10n = AppLocalizations.of(context);
    for (final t in list) {
      final prev = before[t.id];
      if (!t.unreadForUser) continue;
      final changed =
          prev == null ||
          !prev.unreadForUser ||
          prev.lastMessageAt != t.lastMessageAt ||
          prev.status != t.status;
      if (changed) _show(t, l10n.supportAlertAnswered, t.subject);
    }
  }

  void _onTeam(AsyncValue<List<SupportTicket>> next) {
    final uid = ref.read(currentUidProvider);
    final list = next.value;
    // Not (yet) on the team: the list is a placeholder, not a baseline.
    if (uid == null || !ref.read(isStaffProvider)) {
      _last.remove(true);
      return;
    }
    if (list == null || next.isLoading) return;
    final before = _before(true, uid);
    _last[true] = (uid, {for (final t in list) t.id: t});
    if (before == null) return;
    final l10n = AppLocalizations.of(context);
    for (final t in list) {
      // Their own requests are the user side's business.
      if (t.uid == uid) continue;
      final prev = before[t.id];
      if (prev == null) {
        _show(t, l10n.supportAlertNew, t.subject);
      } else if (t.unreadForStaff &&
          (!prev.unreadForStaff || prev.lastMessageAt != t.lastMessageAt)) {
        _show(t, l10n.supportAlertNew, l10n.supportAlertNewMessage(t.number));
      }
    }
  }

  void _show(SupportTicket t, String title, String body) {
    final l10n = AppLocalizations.of(context);
    void open() => ref.read(routerProvider).push('/support/ticket/${t.id}');
    showSnack(
      title,
      description: body,
      actionLabel: l10n.supportAlertOpen,
      onAction: open,
    );
    final prefs =
        ref.read(profileProvider).value?.notifications ??
        const NotificationPrefs();
    if (prefs.push && pageHidden()) {
      showSystemNotification(
        title,
        body,
        tag: 'support-${t.id}-${t.lastMessageAt?.millisecondsSinceEpoch}',
        onClick: open,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(myTicketsProvider, (_, next) => _onMine(next));
    ref.listen(staffTicketsProvider, (_, next) => _onTeam(next));
    return widget.child;
  }
}
