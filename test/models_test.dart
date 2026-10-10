import 'package:flat/src/data/models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('order totals include buyer and seller fees', () {
    final order = Order.fromMap('o1', {
      'number': 'SSW-ABC123',
      'event': {
        'name': 'Dubioza kolektiv',
        'venue': 'Zetra',
        'city': 'Sarajevo',
        'date': DateTime(2027, 5, 1),
        'category': 'concerts',
      },
      'quantity': 2,
      'unitPriceMinor': 5000,
      'currency': 'BAM',
      'status': 'paid',
      'history': [
        {'status': 'pendingPayment', 'at': DateTime(2027, 1, 1)},
        {'status': 'paid', 'at': DateTime(2027, 1, 1, 0, 5)},
      ],
    });
    expect(order.subtotalMinor, 10000);
    expect(order.buyerFeeMinor, 1000);
    expect(order.totalMinor, 11000);
    expect(order.sellerEarningsMinor, 9000);
    expect(order.status, OrderStatus.paid);
    expect(order.reachedAt(OrderStatus.paid), DateTime(2027, 1, 1, 0, 5));
    expect(order.reachedAt(OrderStatus.completed), isNull);
    expect(order.event.category, EventCategory.concerts);
  });

  test('unknown enum values fall back safely', () {
    final listing = Listing.fromMap('l1', {
      'event': {'name': 'X', 'category': 'opera'},
      'status': 'something-new',
      'ticketType': 'hologram',
    });
    expect(listing.status, ListingStatus.active);
    expect(listing.event.category, EventCategory.other);
    expect(listing.ticketType, TicketType.eTicket);
  });

  test('IBAN checksum', () {
    expect(isValidIban('DE89 3704 0044 0532 0130 00'), isTrue);
    expect(isValidIban('BA39 1290 0794 0102 8494'), isTrue);
    expect(isValidIban('DE89 3704 0044 0532 0130 01'), isFalse);
    expect(isValidIban('hello'), isFalse);
    expect(
      const PayoutMethod(
        accountHolder: 'A',
        iban: 'DE89370400440532013000',
      ).masked,
      'IBAN •••• 3000',
    );
  });

  test('notification prefs keep defaults for missing keys', () {
    final prefs = NotificationPrefs.fromMap({'newsletter': true});
    expect(prefs.newsletter, isTrue);
    expect(prefs.orderUpdates, isTrue);
    expect(prefs.copyWithKey('push', true).push, isTrue);
  });
}
