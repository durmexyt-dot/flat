import 'package:flat/src/admin/admin_repository.dart';
import 'package:flat/src/data/memory_repositories.dart';
import 'package:flat/src/data/models.dart';
import 'package:flat/src/data/platform_repository.dart';
import 'package:flat/src/home/home_page.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'helpers.dart';

void main() {
  testWidgets('the team opens a report and sees what it can do', (
    tester,
  ) async {
    final p = InMemoryPlatformRepository();
    p.reports['dup'] = const Report(
      id: 'dup',
      type: ReportType.duplicateTicket,
      listingId: 'L1',
      sellerId: 'other',
      eventName: 'Jazz',
    );
    final auth = await pumpApp(
      tester,
      adminRepository: InMemoryAdminRepository(roles: {'1': StaffRole.support}),
      platformRepository: p,
      marketRepository: InMemoryMarketRepository(
        listings: [
          Listing.fromMap('L1', {
            'sellerId': 'other',
            'eventId': 'e',
            'event': {
              'name': 'Jazz',
              'venue': 'Z',
              'city': 'S',
              'date': DateTime(2030),
              'category': 'concerts',
            },
            'quantity': 2,
            'quantitySold': 0,
            'priceMinor': 4500,
            'currency': 'BAM',
            'status': 'removed',
          }),
        ],
      ),
    );
    await auth.signIn(email: 'a@b.ba', password: 'x', keepSignedIn: true);
    await tester.pumpAndSettle();
    GoRouter.of(tester.element(find.byType(HomePage).first))
        .push('/admin/moderation');
    await tester.pumpAndSettle();
    await tester.tap(find.text('Kopirana karta'));
    await tester.pumpAndSettle();
    expect(find.text('Prodavac'), findsOneWidget);
  });
}
