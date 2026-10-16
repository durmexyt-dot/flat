import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';

import '../l10n/app_localizations.dart';
import 'data/repositories.dart';
import 'config/app_info.dart';
import 'notifications/live_alerts.dart';
import 'notifications/support_alerts.dart';
import 'notifications/update_notifier.dart';
import 'router.dart';
import 'settings/settings_controller.dart';
import 'ui/forui_theme.dart';
import 'ui/snack.dart';
import 'ui/theme.dart';
import 'ui/tokens.dart';
import 'web/reduced_motion.dart';

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
      themeAnimationDuration: Motion.slower,
      themeAnimationCurve: Motion.enter,
      builder: (context, child) => ValueListenableBuilder(
        valueListenable: prefersReducedMotion,
        builder: (context, browserReduced, _) {
          // The user's text size on top of the system's.
          final media = MediaQuery.of(context);
          final system = media.textScaler.scale(1);
          final brightness = switch (settings.themeMode) {
            ThemeMode.light => Brightness.light,
            ThemeMode.dark => Brightness.dark,
            ThemeMode.system => media.platformBrightness,
          };
          // "Reduce motion" from the system or the browser: no movement.
          final reduced = media.disableAnimations || browserReduced;
          Motion.reduced = reduced;
          // Larger touch targets on phones and tablets, compact on desktop.
          final touch = media.size.width < wideLayoutBreakpoint;
          return MediaQuery(
            data: media.copyWith(
              textScaler: TextScaler.linear(system * settings.textSize.scale),
              disableAnimations: reduced,
            ),
            child: FTheme(
              data: buildForuiTheme(settings, brightness, touch: touch),
              motion: FThemeMotion(duration: Motion.slow),
              child: FToaster(
                key: toasterKey,
                child: FTooltipGroup(
                  child: UpdateNotifier(
                    child: LiveAlerts(
                      child: SupportAlerts(
                        child: _StagingBanner(child: child!),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
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

/// Marks staging builds, so test and real data are never mixed up.
class _StagingBanner extends StatelessWidget {
  const _StagingBanner({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (AppInfo.isProd) return child;
    return Banner(
      message: 'STAGING',
      location: BannerLocation.topEnd,
      color: FixedColors.stagingRibbon,
      textStyle: const TextStyle(
        color: FixedColors.onStagingRibbon,
        fontSize: 10,
        fontWeight: FontWeights.heavy,
        letterSpacing: 1,
      ),
      child: child,
    );
  }
}
