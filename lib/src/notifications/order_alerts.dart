import '../data/models.dart';

/// Something about an order the user should hear about right away.
enum OrderAlertKind {
  /// Seller: a buyer paid for tickets.
  sold,

  /// Buyer: the seller sent the tickets.
  ticketsSent,

  /// Buyer: the seller cancelled the sale; the money is back.
  refundedBySeller,
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
  OrderAlertKind? kindOf(Order o) {
    if (asSeller) {
      return o.status == OrderStatus.paid ? OrderAlertKind.sold : null;
    }
    return switch (o.status) {
      OrderStatus.ticketsSent => OrderAlertKind.ticketsSent,
      OrderStatus.refunded when o.cancelledBySeller =>
        OrderAlertKind.refundedBySeller,
      _ => null,
    };
  }

  final previous = before == null
      ? null
      : {for (final o in before) o.id: o.status};
  return [
    for (final o in after)
      if (kindOf(o) case final kind?)
        if (previous != null
            ? previous[o.id] != o.status
            : since != null && (o.reachedAt(o.status)?.isAfter(since) ?? false))
          OrderAlert(kind, o),
  ];
}
