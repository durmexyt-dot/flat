import 'package:flat/l10n/app_localizations.dart';
import 'package:flat/src/auth/login_page.dart';
import 'package:flat/src/settings/locale_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> _pumpLogin(WidgetTester tester) async {
  SharedPreferences.setMockInitialValues({});
  final prefs = await SharedPreferences.getInstance();
  await tester.pumpWidget(
    ProviderScope(
      overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
      child: Consumer(
        builder: (context, ref, _) => MaterialApp(
          locale: ref.watch(localeProvider),
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          home: const LoginPage(),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('login page defaults to Bosnian', (tester) async {
    await _pumpLogin(tester);
    expect(find.text('Prijavite se na svoj račun'), findsOneWidget);
  });

  testWidgets('empty form shows validation errors', (tester) async {
    await _pumpLogin(tester);
    await tester.tap(find.text('Prijavi se'));
    await tester.pumpAndSettle();
    expect(find.text('Unesite e-mail adresu'), findsOneWidget);
    expect(find.text('Unesite lozinku'), findsOneWidget);
  });

  testWidgets('language can be switched to German', (tester) async {
    await _pumpLogin(tester);
    await tester.tap(find.byIcon(Icons.language));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Deutsch'));
    await tester.pumpAndSettle();
    expect(find.text('Melde dich bei deinem Konto an'), findsOneWidget);
  });
}
