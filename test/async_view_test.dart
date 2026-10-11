import 'package:flat/l10n/app_localizations.dart';
import 'package:flat/src/ui/async_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

final _failing = StreamProvider<List<int>>(
  (ref) => Stream.error(Exception('permission-denied')),
);
final _empty = StreamProvider<List<int>>((ref) => Stream.value(const []));

Widget _app(StreamProvider<List<int>> provider) => ProviderScope(
  child: MaterialApp(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: Scaffold(
      body: Consumer(
        builder: (context, ref, _) => AsyncView<List<int>>(
          value: ref.watch(provider),
          loading: const Text('skeleton'),
          data: (items) => Text(items.isEmpty ? 'empty' : 'items'),
        ),
      ),
    ),
  ),
);

void main() {
  testWidgets('errors show right away, also while Riverpod retries', (
    tester,
  ) async {
    await tester.pumpWidget(_app(_failing));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('skeleton'), findsNothing);
    expect(find.text("Couldn't load"), findsOneWidget);
    // Let the scheduled retries run out.
    await tester.pump(const Duration(minutes: 2));
  });

  testWidgets('no data shows the empty state, not a skeleton', (tester) async {
    await tester.pumpWidget(_app(_empty));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('skeleton'), findsNothing);
    expect(find.text('empty'), findsOneWidget);
  });
}
