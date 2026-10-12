import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../data/models.dart';
import '../ui/format.dart';
import '../ui/status_timeline.dart';
import 'labels.dart';

enum OrderRole { buyer, seller }

String orderStatusName(AppLocalizations l10n, OrderStatus s) => switch (s) {
  OrderStatus.pendingPayment => l10n.orderPendingPayment,
  OrderStatus.paid => l10n.orderPaid,
  OrderStatus.ticketsSent => l10n.orderTicketsSent,
  OrderStatus.completed => l10n.orderCompleted,
  OrderStatus.cancelled => l10n.orderCancelled,
  OrderStatus.refunded => l10n.orderRefunded,
  OrderStatus.disputed => l10n.orderDisputed,
};

/// Why an order ended (refunded or cancelled) or is on hold (a reported
/// problem); null when the status says it all.
String? orderReasonText(AppLocalizations l10n, Order o) => switch (o.status) {
  OrderStatus.disputed => l10n.disputeStatusLine,
  OrderStatus.refunded || OrderStatus.cancelled => switch (o.cancelledBy) {
    'seller' => l10n.deliveryCancelSeller,
    'expired' => l10n.deliveryCancelExpired,
    'deadline' => l10n.deliveryCancelDeadline,
    'event' => l10n.deliveryCancelEvent,
    'support' => l10n.deliveryCancelSupport,
    _ => null,
  },
  _ => null,
};

String disputeReasonName(AppLocalizations l10n, DisputeReason r) => switch (r) {
  DisputeReason.notReceived => l10n.disputeReasonNotReceived,
  DisputeReason.invalid => l10n.disputeReasonInvalid,
  DisputeReason.wrongTickets => l10n.disputeReasonWrongTickets,
  DisputeReason.eventChanged => l10n.disputeReasonEventChanged,
  DisputeReason.other => l10n.disputeReasonOther,
};

StatusTone orderTone(OrderStatus s) => switch (s) {
  OrderStatus.pendingPayment => StatusTone.waiting,
  OrderStatus.paid || OrderStatus.ticketsSent => StatusTone.active,
  OrderStatus.completed => StatusTone.positive,
  OrderStatus.cancelled || OrderStatus.refunded => StatusTone.neutral,
  OrderStatus.disputed => StatusTone.negative,
};

String orderNextStep(AppLocalizations l10n, OrderStatus s, OrderRole role) =>
    switch ((role, s)) {
      (OrderRole.buyer, OrderStatus.pendingPayment) =>
        l10n.buyerNextPendingPayment,
      (OrderRole.buyer, OrderStatus.paid) => l10n.buyerNextPaid,
      (OrderRole.buyer, OrderStatus.ticketsSent) => l10n.buyerNextTicketsSent,
      (OrderRole.buyer, OrderStatus.completed) => l10n.buyerNextCompleted,
      (OrderRole.buyer, OrderStatus.cancelled) => l10n.buyerNextCancelled,
      (OrderRole.buyer, OrderStatus.refunded) => l10n.buyerNextRefunded,
      (OrderRole.buyer, OrderStatus.disputed) => l10n.buyerNextDisputed,
      (OrderRole.seller, OrderStatus.pendingPayment) =>
        l10n.sellerNextPendingPayment,
      (OrderRole.seller, OrderStatus.paid) => l10n.sellerNextPaid,
      (OrderRole.seller, OrderStatus.ticketsSent) => l10n.sellerNextTicketsSent,
      (OrderRole.seller, OrderStatus.completed) => l10n.sellerNextCompleted,
      (OrderRole.seller, OrderStatus.cancelled) => l10n.sellerNextCancelled,
      (OrderRole.seller, OrderStatus.refunded) => l10n.sellerNextRefunded,
      (OrderRole.seller, OrderStatus.disputed) => l10n.sellerNextDisputed,
    };

String payoutStatusName(AppLocalizations l10n, PayoutStatus s) => switch (s) {
  PayoutStatus.pending => l10n.payoutPending,
  PayoutStatus.scheduled => l10n.payoutScheduled,
  PayoutStatus.processing => l10n.payoutProcessing,
  PayoutStatus.paid => l10n.payoutPaid,
  PayoutStatus.failed => l10n.payoutFailed,
};

StatusTone payoutTone(PayoutStatus s) => switch (s) {
  PayoutStatus.pending => StatusTone.waiting,
  PayoutStatus.scheduled || PayoutStatus.processing => StatusTone.active,
  PayoutStatus.paid => StatusTone.positive,
  PayoutStatus.failed => StatusTone.negative,
};

String payoutNextStep(AppLocalizations l10n, PayoutStatus s) => switch (s) {
  PayoutStatus.pending => l10n.payoutNextPending,
  PayoutStatus.scheduled => l10n.payoutNextScheduled,
  PayoutStatus.processing => l10n.payoutNextProcessing,
  PayoutStatus.paid => l10n.payoutNextPaid,
  PayoutStatus.failed => l10n.payoutNextFailed,
};

/// Steps of a flow: the regular [path] up to [status]; an off-path status
/// (cancelled, refunded, failed …) ends the timeline after the steps that
/// were reached.
List<TimelineStep> buildTimeline<S extends Enum>({
  required BuildContext context,
  required List<S> path,
  required S status,
  required String Function(S) label,
  required DateTime? Function(S) reachedAt,
  required bool isEnd,
}) {
  String? when(S s) => switch (reachedAt(s)) {
    final DateTime d => formatDateTime(context, d),
    null => null,
  };
  final index = path.indexOf(status);
  if (index >= 0) {
    return [
      for (var i = 0; i < path.length; i++)
        TimelineStep(
          label: label(path[i]),
          detail: when(path[i]),
          state: i < index || (i == index && isEnd)
              ? TimelineState.done
              : i == index
              ? TimelineState.current
              : TimelineState.upcoming,
        ),
    ];
  }
  final reached = path.where((s) => reachedAt(s) != null).toList();
  return [
    for (final s in reached)
      TimelineStep(label: label(s), detail: when(s), state: TimelineState.done),
    TimelineStep(
      label: label(status),
      detail: when(status),
      state: TimelineState.failed,
    ),
  ];
}

List<TimelineStep> orderTimeline(BuildContext context, Order order) {
  final l10n = AppLocalizations.of(context);
  return buildTimeline(
    context: context,
    path: orderHappyPath,
    status: order.status,
    label: (s) => orderStatusName(l10n, s),
    reachedAt: order.reachedAt,
    isEnd: order.status == OrderStatus.completed,
  );
}

List<TimelineStep> payoutTimeline(BuildContext context, Payout payout) {
  final l10n = AppLocalizations.of(context);
  return buildTimeline(
    context: context,
    path: payoutHappyPath,
    status: payout.status,
    label: (s) => payoutStatusName(l10n, s),
    reachedAt: payout.reachedAt,
    isEnd: payout.status == PayoutStatus.paid,
  );
}
