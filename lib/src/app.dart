import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../l10n/app_localizations.dart';
import 'data/repositories.dart';
import 'router.dart';
import 'settings/settings_controller.dart';
import 'ui/theme.dart';

class FlatApp extends ConsumerWidget {
  const FlatApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final settings = ref.watch(settingsProvider);
    ref.watch(profileBootstrapProvider);

    return MaterialApp.router(
      onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
      debugShowCheckedModeBanner: false,
      theme: buildTheme(Brightness.light, settings),
      darkTheme: buildTheme(Brightness.dark, settings),
      themeMode: settings.themeMode,
      themeAnimationDuration: const Duration(milliseconds: 350),
      themeAnimationCurve: Curves.easeOutCubic,
      builder: (context, child) {
        // The user's text size on top of the system's.
        final media = MediaQuery.of(context);
        final system = media.textScaler.scale(1);
        return MediaQuery(
          data: media.copyWith(
            textScaler: TextScaler.linear(system * settings.textSize.scale),
          ),
          child: child!,
        );
      },
      locale: settings.locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      routerConfig: router,
    );
  }
}
