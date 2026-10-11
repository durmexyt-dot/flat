import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';

import '../l10n/app_localizations.dart';
import 'data/repositories.dart';
import 'notifications/live_alerts.dart';
import 'router.dart';
import 'settings/settings_controller.dart';
import 'ui/forui_theme.dart';
import 'ui/snack.dart';
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
        final brightness = switch (settings.themeMode) {
          ThemeMode.light => Brightness.light,
          ThemeMode.dark => Brightness.dark,
          ThemeMode.system => media.platformBrightness,
        };
        // Larger touch targets on phones and tablets, compact on desktop.
        final touch = media.size.width < 900;
        return MediaQuery(
          data: media.copyWith(
            textScaler: TextScaler.linear(system * settings.textSize.scale),
          ),
          child: FTheme(
            data: buildForuiTheme(settings, brightness, touch: touch),
            motion: const FThemeMotion(duration: Duration(milliseconds: 300)),
            child: FToaster(
              key: toasterKey,
              child: FTooltipGroup(child: LiveAlerts(child: child!)),
            ),
          ),
        );
      },
      locale: settings.locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        FLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      routerConfig: router,
    );
  }
}
