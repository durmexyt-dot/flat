import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'fixtures.dart';
import 'helpers.dart';

Future<void> shot(WidgetTester tester, String name) async {
  await expectLater(find.byType(MaterialApp), matchesGoldenFile('/tmp/claude-0/-home-user-flat/ff195105-d0a2-526b-8488-804fc4b47732/scratchpad/shots/$name.png'));
}

void main() {
  for (final wide in [false, true]) {
    testWidgets('shots $wide', (tester) async {
      final auth = await pumpApp(tester, marketRepository: buildSampleMarket('1'), eventRepository: buildSampleEvents());
      if (wide) {
        tester.view.physicalSize = const Size(1440, 900);
        tester.view.devicePixelRatio = 1;
      }
      await auth.signIn(email: 'amra@test.ba', password: 'x', keepSignedIn: true);
      await tester.pumpAndSettle();
      for (var i = 0; i < 6; i++) {
        await shot(tester, '${wide ? 'wide' : 'phone'}_$i');
        await tester.drag(mainScrollable, Offset(0, wide ? -800 : -700));
        await tester.pumpAndSettle();
      }
      await tester.tap(find.text('Odaberi grad'), warnIfMissed: false);
    });
  }
}
