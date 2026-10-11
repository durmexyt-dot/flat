import 'package:flat/src/data/models.dart';
import 'package:flat/src/notifications/order_alerts.dart';
import 'package:flutter_test/flutter_test.dart';

Order _order(String status, {DateTime? at, bool bySeller = false}) =>
    Order.fromMap('o1', {
      'event': {'name': 'Jazz', 'venue': 'Dom', 'city': 'Sarajevo'},
      'status': status,
      if (bySeller) 'cancelledBy': 'seller',
      'history': [
        {'status': status, 'at': at ?? DateTime(2026, 10, 11, 12)},
      ],
    });

void main() {
  test('seller hears about a sale the moment it is paid', () {
    final alerts = orderAlerts(
      before: [_order('pendingPayment')],
      after: [_order('paid')],
      asSeller: true,
    );
    expect(alerts.single.kind, OrderAlertKind.sold);
    // A brand-new paid order counts too.
    expect(
      orderAlerts(before: [], after: [_order('paid')], asSeller: true),
      hasLength(1),
    );
  });

  test('no alert without a change', () {
    expect(
      orderAlerts(
        before: [_order('paid')],
        after: [_order('paid')],
        asSeller: true,
      ),
      isEmpty,
    );
  });

  test('buyer hears about sent tickets and a cancel by the seller', () {
    expect(
      orderAlerts(
        before: [_order('paid')],
        after: [_order('ticketsSent')],
        asSeller: false,
      ).single.kind,
      OrderAlertKind.ticketsSent,
    );
    expect(
      orderAlerts(
        before: [_order('paid')],
        after: [_order('refunded', bySeller: true)],
        asSeller: false,
      ).single.kind,
      OrderAlertKind.refundedBySeller,
    );
    // The buyer's own payment is no news to them.
    expect(
      orderAlerts(
        before: [_order('pendingPayment')],
        after: [_order('paid')],
        asSeller: false,
      ),
      isEmpty,
    );
  });

  test('on start, only what happened since the last visit counts', () {
    final seen = DateTime(2026, 10, 11, 10);
    List<OrderAlert> start(DateTime paidAt, DateTime? since) => orderAlerts(
      before: null,
      after: [_order('paid', at: paidAt)],
      asSeller: true,
      since: since,
    );
    expect(start(DateTime(2026, 10, 11, 11), seen), hasLength(1));
    expect(start(DateTime(2026, 10, 11, 9), seen), isEmpty);
    // First start ever: quiet.
    expect(start(DateTime(2026, 10, 11, 11), null), isEmpty);
  });
}
