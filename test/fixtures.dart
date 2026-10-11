import 'package:flat/src/data/memory_repositories.dart';
import 'package:flat/src/data/models.dart';

/// Sample marketplace data around [uid], dated relative to [now]: orders,
/// sales and payouts in every status.
InMemoryMarketRepository buildSampleMarket(String uid, {DateTime? now}) {
  final t = now ?? DateTime.now();
  DateTime days(int d, [int h = 20]) => DateTime(t.year, t.month, t.day + d, h);

  Map<String, dynamic> event(
    String name,
    String venue,
    String city,
    DateTime date,
    EventCategory category,
  ) => {
    'name': name,
    'venue': venue,
    'city': city,
    'date': date,
    'category': category.name,
  };

  final dubioza = event(
    'Dubioza kolektiv',
    'Zetra',
    'Sarajevo',
    days(24),
    EventCategory.concerts,
  );
  final derby = event(
    'FK Sarajevo – FK Željezničar',
    'Koševo',
    'Sarajevo',
    days(10, 18),
    EventCategory.sports,
  );
  final sff = event(
    'Sarajevo Film Festival – Otvaranje',
    'Narodno pozorište',
    'Sarajevo',
    days(40, 19),
    EventCategory.festivals,
  );
  final hamlet = event(
    'Hamlet',
    'Kamerni teatar 55',
    'Sarajevo',
    days(-6),
    EventCategory.theater,
  );
  final exit = event(
    'EXIT Festival',
    'Petrovaradin',
    'Novi Sad',
    days(-30, 22),
    EventCategory.festivals,
  );
  final zdravko = event(
    'Zdravko Čolić',
    'Arena Zenica',
    'Zenica',
    days(-12),
    EventCategory.concerts,
  );

  Listing listing(
    String id,
    String seller,
    Map<String, dynamic> e, {
    int qty = 2,
    int sold = 0,
    int price = 4500,
    ListingStatus status = ListingStatus.active,
    String section = '',
    String row = '',
  }) => Listing.fromMap(id, {
    'sellerId': seller,
    'event': e,
    'quantity': qty,
    'quantitySold': sold,
    'priceMinor': price,
    'currency': 'BAM',
    'status': status.name,
    'section': section,
    'row': row,
    'createdAt': days(-20, 10),
  });

  List<Map<String, Object>> history(List<(OrderStatus, int)> steps) => [
    for (final (s, d) in steps) {'status': s.name, 'at': days(d, 12)},
  ];

  Order order(
    String id,
    String number,
    Map<String, dynamic> e, {
    required String buyer,
    required String seller,
    required OrderStatus status,
    required List<(OrderStatus, int)> steps,
    int qty = 2,
    int price = 4500,
  }) => Order.fromMap(id, {
    'number': number,
    'listingId': 'demo-listing',
    'buyerId': buyer,
    'sellerId': seller,
    'event': e,
    'quantity': qty,
    'unitPriceMinor': price,
    'currency': 'BAM',
    'status': status.name,
    'section': 'B',
    'row': '12',
    'paymentMethod': 'Visa •••• 4242',
    'history': history(steps),
    'createdAt': days(steps.first.$2, 12),
  });

  const other = 'demo-other-user';
  final orders = [
    // Purchases.
    order(
      'demo-p1',
      'SSW-7KQ2MD',
      derby,
      buyer: uid,
      seller: other,
      status: OrderStatus.paid,
      qty: 2,
      price: 3000,
      steps: [(OrderStatus.pendingPayment, -2), (OrderStatus.paid, -2)],
    ),
    order(
      'demo-p2',
      'SSW-H3XW9A',
      sff,
      buyer: uid,
      seller: other,
      status: OrderStatus.ticketsSent,
      qty: 1,
      price: 8000,
      steps: [
        (OrderStatus.pendingPayment, -9),
        (OrderStatus.paid, -9),
        (OrderStatus.ticketsSent, -7),
      ],
    ),
    order(
      'demo-p3',
      'SSW-2PLM6R',
      hamlet,
      buyer: uid,
      seller: other,
      status: OrderStatus.completed,
      qty: 2,
      price: 2500,
      steps: [
        (OrderStatus.pendingPayment, -20),
        (OrderStatus.paid, -20),
        (OrderStatus.ticketsSent, -18),
        (OrderStatus.completed, -5),
      ],
    ),
    order(
      'demo-p4',
      'SSW-9ZC4TB',
      exit,
      buyer: uid,
      seller: other,
      status: OrderStatus.refunded,
      qty: 1,
      price: 19000,
      steps: [
        (OrderStatus.pendingPayment, -60),
        (OrderStatus.paid, -60),
        (OrderStatus.refunded, -45),
      ],
    ),
    // Sales.
    order(
      'demo-s1',
      'SSW-4NB8YE',
      dubioza,
      buyer: other,
      seller: uid,
      status: OrderStatus.pendingPayment,
      qty: 2,
      steps: [(OrderStatus.pendingPayment, 0)],
    ),
    order(
      'demo-s2',
      'SSW-6VT3JH',
      dubioza,
      buyer: other,
      seller: uid,
      status: OrderStatus.paid,
      qty: 1,
      steps: [(OrderStatus.pendingPayment, -1), (OrderStatus.paid, -1)],
    ),
    order(
      'demo-s3',
      'SSW-8RD5KU',
      derby,
      buyer: other,
      seller: uid,
      status: OrderStatus.ticketsSent,
      qty: 2,
      price: 3500,
      steps: [
        (OrderStatus.pendingPayment, -6),
        (OrderStatus.paid, -6),
        (OrderStatus.ticketsSent, -5),
      ],
    ),
    order(
      'demo-s4',
      'SSW-3GW7PX',
      zdravko,
      buyer: other,
      seller: uid,
      status: OrderStatus.completed,
      qty: 4,
      price: 6000,
      steps: [
        (OrderStatus.pendingPayment, -25),
        (OrderStatus.paid, -25),
        (OrderStatus.ticketsSent, -24),
        (OrderStatus.completed, -11),
      ],
    ),
    order(
      'demo-s5',
      'SSW-5MJ9QC',
      hamlet,
      buyer: other,
      seller: uid,
      status: OrderStatus.disputed,
      qty: 1,
      price: 2500,
      steps: [
        (OrderStatus.pendingPayment, -15),
        (OrderStatus.paid, -15),
        (OrderStatus.ticketsSent, -14),
        (OrderStatus.disputed, -5),
      ],
    ),
  ];

  List<Map<String, Object>> payoutHistory(List<(PayoutStatus, int)> steps) => [
    for (final (s, d) in steps) {'status': s.name, 'at': days(d, 9)},
  ];

  Payout payout(
    String id,
    List<String> numbers,
    int amount,
    PayoutStatus status,
    List<(PayoutStatus, int)> steps, {
    int? expected,
    String failure = '',
  }) => Payout.fromMap(id, {
    'sellerId': uid,
    'orderNumbers': numbers,
    'amountMinor': amount,
    'currency': 'BAM',
    'status': status.name,
    'method': 'IBAN •••• 8494',
    'failureReason': failure,
    'expectedAt': expected == null ? null : days(expected, 9),
    'history': payoutHistory(steps),
    'createdAt': days(steps.first.$2, 9),
  });

  final payouts = [
    payout(
      'demo-o1',
      ['SSW-6VT3JH', 'SSW-8RD5KU'],
      4050 + 6300,
      PayoutStatus.pending,
      [(PayoutStatus.pending, -1)],
      expected: 15,
    ),
    payout(
      'demo-o2',
      ['SSW-3GW7PX'],
      21600,
      PayoutStatus.processing,
      [
        (PayoutStatus.pending, -25),
        (PayoutStatus.scheduled, -10),
        (PayoutStatus.processing, -1),
      ],
      expected: 2,
    ),
    payout(
      'demo-o3',
      ['SSW-1AB2CD'],
      8100,
      PayoutStatus.paid,
      [
        (PayoutStatus.pending, -70),
        (PayoutStatus.scheduled, -50),
        (PayoutStatus.processing, -48),
        (PayoutStatus.paid, -46),
      ],
    ),
    payout(
      'demo-o4',
      ['SSW-0XY9ZW'],
      5400,
      PayoutStatus.failed,
      [
        (PayoutStatus.pending, -40),
        (PayoutStatus.scheduled, -33),
        (PayoutStatus.processing, -32),
        (PayoutStatus.failed, -30),
      ],
      failure: 'IBAN account closed',
    ),
  ];

  return InMemoryMarketRepository(
    listings: [
      listing('demo-l1', uid, dubioza, qty: 4, sold: 3, section: 'Parter'),
      listing(
        'demo-l2',
        uid,
        zdravko,
        qty: 4,
        sold: 4,
        price: 6000,
        status: ListingStatus.soldOut,
      ),
      listing(
        'demo-l3',
        uid,
        hamlet,
        qty: 2,
        price: 2500,
        status: ListingStatus.expired,
      ),
      listing(
        'demo-l4',
        other,
        derby,
        qty: 6,
        sold: 2,
        price: 3500,
        section: 'Sjever',
        row: '8',
      ),
      listing('demo-l5', other, sff, qty: 2, price: 8000, section: 'Balkon'),
      listing(
        'demo-l6',
        other,
        event(
          'Bijelo Dugme Tribute',
          'Skenderija',
          'Sarajevo',
          days(17),
          EventCategory.concerts,
        ),
        qty: 3,
        price: 3900,
      ),
    ],
    orders: orders,
    payouts: payouts,
    payoutMethod: const PayoutMethod(
      accountHolder: 'Demo',
      iban: 'BA391290079401028494',
    ),
  );
}
