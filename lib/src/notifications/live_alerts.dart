import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/app_localizations.dart';
import '../data/models.dart';
import '../data/repositories.dart';
import '../market/order_labels.dart';
import '../router.dart';
import '../settings/settings_controller.dart';
import '../ui/format.dart';
import '../ui/snack.dart';
import '../web/browser_notifications.dart';
import 'order_alerts.dart';

/// Tells the user live about their sales and purchases: a toast in the app
/// and, while the tab is in the background, a system notification.
///
/// Orders are Firestore streams, so a sale shows up the moment the buyer
/// pays. Sales made while the app was closed are shown on the next start.
/// (Notifications with the app closed need a push server: Firebase Cloud
/// Messaging sent from a Cloud Function.)
class LiveAlerts extends ConsumerStatefulWidget {
  const LiveAlerts({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<LiveAlerts> createState() => _LiveAlertsState();
}

class _LiveAlertsState extends ConsumerState<LiveAlerts> {
  /// The last snapshot per side, with the user it belongs to: after a sign
  /// in, the provider's previous value is the signed-out empty list, which
  /// would make every existing order look new.
  final _last = <bool, (String, List<Order>)>{};

  String _seenKey(String uid) => 'alertsSeen.$uid';

  DateTime? _since(String uid) {
    final ms = ref.read(sharedPreferencesProvider).getInt(_seenKey(uid));
    return ms == null ? null : DateTime.fromMillisecondsSinceEpoch(ms);
  }

  void _markSeen(String uid) => ref
      .read(sharedPreferencesProvider)
      .setInt(_seenKey(uid), DateTime.now().millisecondsSinceEpoch);

  void _onOrders(AsyncValue<List<Order>> next, {required bool asSeller}) {
    final uid = ref.read(currentUidProvider);
    final orders = next.value;
    if (uid == null || orders == null || next.isLoading) return;
    final before = switch (_last[asSeller]) {
      (final owner, final list) when owner == uid => list,
      _ => null,
    };
    _last[asSeller] = (uid, orders);
    final alerts = orderAlerts(
      before: before,
      after: orders,
      asSeller: asSeller,
      since: before == null ? _since(uid) : null,
    );
    // From now on only changes count; the first visit starts quietly.
    _markSeen(uid);

    final prefs =
        ref.read(profileProvider).value?.notifications ??
        const NotificationPrefs();
    if (asSeller ? !prefs.saleUpdates : !prefs.orderUpdates) return;
    // A burst (e.g. after a long time away) shows the newest few.
    for (final alert in alerts.reversed.take(3)) {
      _show(alert, systemToo: prefs.push);
    }
  }

  void _show(OrderAlert alert, {required bool systemToo}) {
    final context = this.context;
    final l10n = AppLocalizations.of(context);
    final o = alert.order;
    final (title, body) = switch (alert.kind) {
      OrderAlertKind.sold => (
        l10n.alertSoldTitle(o.event.name),
        l10n.alertSoldBody(
          '${o.quantity}',
          formatMoney(context, o.sellerEarningsMinor, o.currency),
        ),
      ),
      OrderAlertKind.disputeOpened => (
        l10n.disputeAlertOpenedTitle,
        l10n.disputeAlertOpenedBody(o.event.name),
      ),
      OrderAlertKind.refundedDeadline => (
        l10n.deliveryAlertDeadlineTitle,
        l10n.deliveryAlertDeadlineBody(o.event.name),
      ),
      // Uploaded e-tickets are there to download.
      OrderAlertKind.ticketsSent when o.ticketsDelivered > 0 => (
        l10n.deliveryAlertArrivedTitle,
        l10n.deliveryAlertArrivedBody(o.event.name),
      ),
      OrderAlertKind.ticketsSent => (
        l10n.alertTicketsSentTitle,
        l10n.alertTicketsSentBody(o.event.name),
      ),
      OrderAlertKind.refundedBySeller => (
        l10n.alertRefundTitle,
        l10n.alertRefundBody(o.event.name),
      ),
      OrderAlertKind.refunded => (
        l10n.deliveryAlertRefundTitle,
        l10n.deliveryAlertRefundBody(
          o.event.name,
          orderReasonText(l10n, o) ?? l10n.orderRefunded,
        ),
      ),
      OrderAlertKind.disputeRejected => (
        l10n.disputeAlertRejectedTitle,
        l10n.disputeAlertRejectedBody(o.event.name),
      ),
    };
    void open() => ref.read(routerProvider).push('/order/${o.id}');

    showSnack(
      title,
      description: body,
      actionLabel: l10n.alertView,
      onAction: open,
    );
    if (systemToo && pageHidden()) {
      showSystemNotification(
        title,
        body,
        tag: '${o.id}-${o.status.name}',
        onClick: open,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(salesProvider, (_, next) => _onOrders(next, asSeller: true));
    ref.listen(
      purchasesProvider,
      (_, next) => _onOrders(next, asSeller: false),
    );
    return widget.child;
  }
}
