import 'package:flat/src/admin/admin_repository.dart';
import 'package:flat/src/app.dart';
import 'package:flat/src/data/models.dart';
import 'package:flat/src/router.dart';
import 'package:flat/src/support/support_repository.dart';
import 'package:flat/src/support/support_widgets.dart';
import 'package:flat/src/ui/site_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers.dart';

/// Opens [path] like a link.
Future<void> go(WidgetTester tester, String path) async {
  ProviderScope.containerOf(tester.element(find.byType(FlatApp)))
      .read(routerProvider)
      .push(path);
  await tester.pumpAndSettle();
}

/// Lets toasts time out, so no timer is left at the end of a test.
Future<void> finishToasts(WidgetTester tester) async {
  await tester.pump(const Duration(seconds: 5));
  await tester.pumpAndSettle();
}

Future<String> _ticketFrom(
  InMemorySupportRepository s, {
  String uid = '1',
  String text = 'My tickets never arrived.',
}) => s.createTicket(
  uid: uid,
  email: uid == '1' ? 'amra@test.ba' : 'kemal@test.ba',
  name: uid == '1' ? 'Amra Test' : 'Kemal Kupac',
  topic: SupportTopic.order,
  reference: 'SSW-9ZC4TB',
  text: text,
);

Future<FakeAuthRepository> _signedIn(
  WidgetTester tester, {
  InMemorySupportRepository? s,
  Map<String, StaffRole> roles = const {},
}) async {
  final auth = await pumpApp(
    tester,
    supportRepository: s,
    adminRepository: InMemoryAdminRepository(roles: roles),
  );
  await auth.signIn(email: 'amra@test.ba', password: 'x', keepSignedIn: true);
  await tester.pumpAndSettle();
  return auth;
}

void main() {
  testWidgets('a new request shows up in the help center', (tester) async {
    await _signedIn(tester);
    await go(tester, '/support');
    expect(find.text('Moji upiti'), findsOneWidget);
    expect(find.text('Još nemaš upita podršci.'), findsOneWidget);

    await tester.tap(find.text('Kontaktiraj podršku'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byType(EditableText).last,
      'I cannot download my e-ticket.',
    );
    await tester.tap(find.text('Pošalji'));
    await tester.pumpAndSettle();
    expect(support.tickets, hasLength(1));
    expect(find.byType(SupportComposer), findsOneWidget);

    await tester.tap(find.byKey(backButtonKey));
    await tester.pumpAndSettle();
    expect(find.text('I cannot download my e-ticket.'), findsOneWidget);
    expect(find.text('Otvoren'), findsOneWidget);
    expect(find.text('Novi odgovor'), findsNothing);
    await finishToasts(tester);
  });

  testWidgets('the team sees a request in the inbox and answers', (
    tester,
  ) async {
    final s = InMemorySupportRepository();
    final id = await _ticketFrom(s, uid: '5');
    await _signedIn(tester, s: s, roles: {'1': StaffRole.support});

    await go(tester, '/admin/support');
    expect(find.text('Upiti podrške'), findsWidgets);
    expect(find.text('My tickets never arrived.'), findsOneWidget);
    expect(find.textContaining('Kemal Kupac'), findsOneWidget);

    await tester.tap(find.text('My tickets never arrived.'));
    await tester.pumpAndSettle();
    // The team sees who wrote and from which order.
    expect(find.text('kemal@test.ba'), findsOneWidget);
    expect(find.text('SSW-9ZC4TB'), findsOneWidget);
    expect(s.tickets.single.unreadForStaff, isFalse);

    await tester.enterText(
      find.byType(EditableText).last,
      'We sent them again, check your inbox.',
    );
    await tester.pump();
    await tester.tap(byLabel('Pošalji').first);
    await tester.pumpAndSettle();

    expect(s.messages[id], hasLength(2));
    expect(s.messages[id]!.last.fromStaff, isTrue);
    expect(s.tickets.single.status, SupportStatus.answered);
    expect(s.tickets.single.unreadForUser, isTrue);
    expect(find.text('We sent them again, check your inbox.'), findsOneWidget);
    expect(find.text('Odgovoreno'), findsOneWidget);
  });

  testWidgets('the user reads the answer and closes the request', (
    tester,
  ) async {
    final s = InMemorySupportRepository();
    final id = await _ticketFrom(s);
    await s.sendMessage(
      ticket: s.tickets.single,
      authorId: '9',
      authorName: 'Lejla',
      fromStaff: true,
      text: 'We sent them again.',
    );
    await _signedIn(tester, s: s);

    await go(tester, '/support');
    expect(find.text('Novi odgovor'), findsOneWidget);
    await tester.tap(find.text('My tickets never arrived.'));
    await tester.pumpAndSettle();

    expect(find.text('We sent them again.'), findsOneWidget);
    expect(find.textContaining('Podrška Stubswap'), findsOneWidget);
    // The team member's name stays internal.
    expect(find.textContaining('Lejla'), findsNothing);
    expect(s.tickets.single.unreadForUser, isFalse);

    await tester.tap(find.text('Problem riješen – zatvori upit'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Zatvori upit'));
    await tester.pumpAndSettle();

    expect(s.tickets.single.status, SupportStatus.closed);
    expect(s.tickets.single.closedBy, 'user');
    expect(find.text('Upit je zatvoren'), findsOneWidget);
    expect(find.byType(SupportComposer), findsNothing);
    expect(find.text('Novi upit'), findsOneWidget);
    expect(s.messages[id], hasLength(2));
  });

  testWidgets('an answer arriving live shows a toast', (tester) async {
    final s = InMemorySupportRepository();
    await _ticketFrom(s);
    await _signedIn(tester, s: s);
    // Existing requests at sign in are no news.
    expect(find.text('Podrška je odgovorila'), findsNothing);

    await s.sendMessage(
      ticket: s.tickets.single,
      authorId: '9',
      authorName: 'Lejla',
      fromStaff: true,
      text: 'Done.',
    );
    await tester.pumpAndSettle();
    expect(find.text('Podrška je odgovorila'), findsOneWidget);
    await finishToasts(tester);
  });

  testWidgets('the team hears about new requests', (tester) async {
    final s = InMemorySupportRepository();
    await _ticketFrom(s, uid: '5');
    await _signedIn(tester, s: s, roles: {'1': StaffRole.admin});
    expect(find.text('Novi upit za podršku'), findsNothing);

    await _ticketFrom(s, uid: '6', text: 'Where is my payout?');
    await tester.pumpAndSettle();
    expect(find.text('Novi upit za podršku'), findsOneWidget);
    await finishToasts(tester);
  });

  testWidgets('the inbox is only for the team', (tester) async {
    final s = InMemorySupportRepository();
    await _ticketFrom(s, uid: '5');
    await _signedIn(tester, s: s);
    await go(tester, '/admin/support');
    expect(find.text('Nemaš pristup'), findsOneWidget);
    expect(find.text('My tickets never arrived.'), findsNothing);
  });

  testWidgets('on desktop the sidebar leads the team to the inbox', (
    tester,
  ) async {
    final s = InMemorySupportRepository();
    await _ticketFrom(s, uid: '5');
    await _signedIn(tester, s: s, roles: {'1': StaffRole.admin});
    tester.view.physicalSize = const Size(1400, 900);
    tester.view.devicePixelRatio = 1;
    await tester.pumpAndSettle();
    await go(tester, '/support');
    expect(find.text('Administracija'), findsOneWidget);
    await tester.tap(find.text('Upiti podrške'));
    await tester.pumpAndSettle();
    expect(find.text('My tickets never arrived.'), findsOneWidget);
    await tester.tap(find.text('My tickets never arrived.'));
    await tester.pumpAndSettle();
    expect(find.text('kemal@test.ba'), findsOneWidget);
  });
}
