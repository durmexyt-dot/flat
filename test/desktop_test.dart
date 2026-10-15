import 'package:flat/src/account/account_drawer.dart';
import 'package:flat/src/account/account_sidebar.dart';
import 'package:flat/src/data/memory_repositories.dart';
import 'package:flat/src/ui/site_scaffold.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:flutter_test/flutter_test.dart';

import 'fixtures.dart';
import 'helpers.dart';

Future<FakeAuthRepository> _desktop(
  WidgetTester tester, {
  InMemoryMarketRepository? market,
}) async {
  final auth = await pumpApp(
    tester,
    marketRepository: market,
    eventRepository: market == null ? null : buildSampleEvents(),
  );
  tester.view.physicalSize = const Size(1440, 900);
  tester.view.devicePixelRatio = 1;
  await tester.pumpAndSettle();
  return auth;
}

void main() {
  testWidgets('desktop: website header, events side by side', (tester) async {
    final auth = await _desktop(tester, market: buildSampleMarket('1'));
    await auth.signIn(email: 'amra@test.ba', password: 'x', keepSignedIn: true);
    await tester.pumpAndSettle();

    expect(find.byType(SiteHeader), findsOneWidget);
    expect(find.text('Karte za koncerte, sport i festivale'), findsOneWidget);
    // No phone app bar and no floating button on desktop.
    expect(find.byType(AppBar), findsNothing);
    expect(find.byType(FloatingActionButton), findsNothing);

    // The first row (popular events) shows its cards side by side.
    final derby = tester.getTopLeft(
      find.text('FK Sarajevo – FK Željezničar').first,
    );
    final tribute = tester.getTopLeft(find.text('Bijelo Dugme Tribute').first);
    expect(derby.dy, tribute.dy, reason: 'popular events share a row');
  });

  testWidgets('desktop: account drawer opens and navigates', (tester) async {
    final auth = await _desktop(tester, market: buildSampleMarket('1'));
    await auth.signIn(email: 'amra@test.ba', password: 'x', keepSignedIn: true);
    await tester.pumpAndSettle();

    await tester.tap(byLabel('Otvori meni računa'));
    await tester.pumpAndSettle();
    expect(find.byType(AccountDrawer), findsOneWidget);
    expect(find.text('Amra Test'), findsWidgets);

    await tester.tap(find.text('Isplate'));
    await tester.pumpAndSettle();
    expect(find.byType(AccountDrawer), findsNothing);
    expect(find.text('Uskoro na računu'), findsOneWidget);
    // Page title next to the content, header stays.
    expect(find.byType(SiteHeader), findsOneWidget);
  });

  testWidgets('desktop: account page shows profile beside settings', (
    tester,
  ) async {
    final auth = await _desktop(tester);
    await auth.signIn(email: 'amra@test.ba', password: 'x', keepSignedIn: true);
    await tester.pumpAndSettle();
    await tester.tap(byLabel('Otvori meni računa'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Profil'));
    await tester.pumpAndSettle();

    // Account pages share the sidebar on the left of the content.
    expect(find.byType(AccountSidebar), findsOneWidget);
    final nav = tester.getTopLeft(find.text('Kupovine i računi'));
    final edit = tester.getTopLeft(find.text('Uredi profil'));
    expect(edit.dx, greaterThan(nav.dx + 200));
    // The profile card shows the counts beside the name.
    final stats = tester.getTopLeft(find.text('Ponuđeno'));
    expect(stats.dx, greaterThan(edit.dx));

    // The same sidebar on my listings, so the layout stays consistent.
    await tester.tap(find.text('Moje ponude').last);
    await tester.pumpAndSettle();
    expect(find.byType(AccountSidebar), findsOneWidget);
    expect(find.byType(SiteHeader), findsOneWidget);
  });

  testWidgets('desktop: guests see sign in and sign up', (tester) async {
    await _desktop(tester);
    await tester.tap(find.text('Pretraži događaje kao gost'));
    await tester.pumpAndSettle();
    expect(find.widgetWithText(FButton, 'Prijavi se'), findsWidgets);
    expect(find.widgetWithText(FButton, 'Registruj se'), findsOneWidget);
  });

  testWidgets('desktop: scrollbar at the window edge, wheel on the sides', (
    tester,
  ) async {
    final auth = await _desktop(tester, market: buildSampleMarket('1'));
    await auth.signIn(email: 'amra@test.ba', password: 'x', keepSignedIn: true);
    tester.view.physicalSize = const Size(1800, 900);
    await tester.pumpAndSettle();

    // The page's scrollbar spans the window, not the 1200 px column.
    final bar = find.byType(Scrollbar).first;
    expect(tester.getRect(bar).right, 1800);

    final list = find
        .byWidgetPredicate(
          (w) => w is Scrollable && w.axisDirection == AxisDirection.down,
        )
        .first;
    final position = tester.state<ScrollableState>(list).position;
    expect(position.pixels, 0);

    // Mouse wheel over the empty left side scrolls the page.
    final pointer = TestPointer(1, PointerDeviceKind.mouse);
    pointer.hover(const Offset(40, 500));
    await tester.sendEventToBinding(pointer.scroll(const Offset(0, 300)));
    await tester.pumpAndSettle();
    expect(position.pixels, greaterThan(0));
  });
}

