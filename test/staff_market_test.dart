import 'package:flat/src/admin/admin_repository.dart';
import 'package:flat/src/data/models.dart';
import 'package:flat/src/home/home_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';

import 'fixtures.dart';
import 'helpers.dart';

Future<void> _signedIn(WidgetTester tester, StaffRole? role) async {
  final auth = await pumpApp(
    tester,
    marketRepository: buildSampleMarket('9'),
    eventRepository: buildSampleEvents(),
    adminRepository: InMemoryAdminRepository(roles: {'1': ?role}),
  );
  await auth.signIn(email: 'amra@test.ba', password: 'x', keepSignedIn: true);
  await tester.pumpAndSettle();
}

Future<void> _go(WidgetTester tester, String location) async {
  GoRouter.of(tester.element(find.byType(Navigator).first)).push(location);
  await tester.pumpAndSettle();
}

void main() {
  for (final role in StaffRole.values) {
    testWidgets('${role.name} accounts neither buy nor sell', (tester) async {
      await _signedIn(tester, role);
      // No sell button on home.
      expect(find.text('Prodaj karte'), findsNothing);

      // Selling and buying pages lead back home.
      await _go(tester, '/sell');
      expect(find.byType(HomePage), findsOneWidget);
      await _go(tester, '/account/purchases');
      expect(find.text('Kupovine i računi'), findsNothing);

      // A listing shows why there is no buy button.
      final listing = market.watchActiveListings();
      final first = (await tester.runAsync(() => listing.first))!.first;
      await _go(tester, '/listing/${first.id}');
      expect(find.text('Timski računi ne kupuju i ne prodaju'), findsOneWidget);
      expect(find.widgetWithText(FButton, 'Kupi karte'), findsNothing);

      // The settings have no buying and selling sections.
      await _go(tester, '/settings');
      expect(find.text('Kupovine i računi'), findsNothing);
      expect(find.text('Moje ponude'), findsNothing);
    });
  }

  testWidgets('normal users still buy and sell', (tester) async {
    await _signedIn(tester, null);
    expect(find.text('Prodaj karte'), findsWidgets);
    await _go(tester, '/settings');
    expect(find.text('Kupovine i računi'), findsOneWidget);
  });
}
