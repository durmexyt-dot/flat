import '../data/models.dart';

/// Something about an order the user should hear about right away.
enum OrderAlertKind {
  /// Seller: a buyer paid for tickets.
  sold,

  /// Seller: the buyer reported a problem; the payout waits.
  disputeOpened,

  /// Seller: the e-tickets weren't uploaded in time; the buyer got the
  /// money back.
  refundedDeadline,

  /// Buyer: the seller sent the tickets (or the uploaded files arrived).
  ticketsSent,

  /// Buyer: the seller cancelled the sale; the money is back.
  refundedBySeller,

  /// Buyer: the money is back for another reason (tickets not sent in
  /// time, event cancelled, support's decision); see [Order.cancelledBy].
  refunded,

  /// Buyer: the team rejected the reported problem; the order continues.
  disputeRejected,
}

class OrderAlert {
  const OrderAlert(this.kind, this.order);
  final OrderAlertKind kind;
  final Order order;
}

/// The alerts for a new snapshot of the user's sales or purchases.
///
/// With a [before] snapshot, every status change since then counts. For the
/// first snapshot after starting the app there is no [before]; then changes
/// after [since] count (the last time the user saw alerts), so a sale made
/// while the app was closed still shows up. Without [since] nothing does.
List<OrderAlert> orderAlerts({
  required List<Order>? before,
  required List<Order> after,
  required bool asSeller,
  DateTime? since,
}) {
  final previous = before == null
      ? null
      : {for (final o in before) o.id: o.status};

  /// The alert for [o], given the status it had before (null when unknown
  /// or new).
  OrderAlertKind? kindOf(Order o, OrderStatus? was) {
    if (asSeller) {
      return switch (o.status) {
        OrderStatus.paid when was != OrderStatus.disputed =>
          OrderAlertKind.sold,
        OrderStatus.disputed => OrderAlertKind.disputeOpened,
        OrderStatus.refunded when o.cancelledBy == 'deadline' =>
          OrderAlertKind.refundedDeadline,
        _ => null,
      };
    }
    // Back from a reported problem: the team said no.
    if (o.dispute?.decision == 'reject' &&
        o.status != OrderStatus.disputed &&
        (was == OrderStatus.disputed || previous == null)) {
      return OrderAlertKind.disputeRejected;
    }
    return switch (o.status) {
      OrderStatus.ticketsSent => OrderAlertKind.ticketsSent,
      OrderStatus.refunded when o.cancelledBySeller =>
        OrderAlertKind.refundedBySeller,
      OrderStatus.refunded
          when const {'deadline', 'event', 'support'}.contains(o.cancelledBy) =>
        OrderAlertKind.refunded,
      _ => null,
    };
  }

  /// When [o] got to where [kind] is about.
  DateTime? changedAt(Order o, OrderAlertKind kind) =>
      kind == OrderAlertKind.disputeRejected
      ? o.dispute?.resolvedAt
      : o.reachedAt(o.status);

  return [
    for (final o in after)
      if (previous != null) ...[
        if (previous[o.id] != o.status)
          if (kindOf(o, previous[o.id]) case final kind?) OrderAlert(kind, o),
      ] else if (since != null)
        if (kindOf(o, null) case final kind?)
          if (changedAt(o, kind)?.isAfter(since) ?? false) OrderAlert(kind, o),
  ];
}
