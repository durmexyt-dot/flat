import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../l10n/app_localizations.dart';
import '../auth/auth_repository.dart';
import '../brand/brand.dart';
import '../web/html_splash.dart';

/// How long the splash stays at least, so the brand can be seen.
const splashMinDuration = Duration(milliseconds: 1800);

/// Set once the splash has finished; until then every route leads here.
class SplashDone extends Notifier<bool> {
  @override
  bool build() => false;

  void complete() => state = true;
}

final splashDoneProvider = NotifierProvider<SplashDone, bool>(SplashDone.new);

/// Shows the brand while the auth state loads, then hands the brand over to
/// the next screen: logo, wordmark and tagline fly to their places there.
class SplashPage extends ConsumerStatefulWidget {
  const SplashPage({super.key});

  @override
  ConsumerState<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends ConsumerState<SplashPage> {
  @override
  void initState() {
    super.initState();
    // This page looks like the HTML splash, so the swap is invisible.
    WidgetsBinding.instance.addPostFrameCallback((_) => removeHtmlSplash());
    _continue();
  }

  Future<void> _continue() async {
    final auth = ref.read(authRepositoryProvider);
    await Future.wait([
      Future<void>.delayed(splashMinDuration),
      auth.authStateChanges().first,
    ]);
    if (!mounted) return;
    ref.read(splashDoneProvider.notifier).complete();
    context.go(auth.currentUser != null ? '/' : '/login');
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const BrandMark(size: 96),
              const SizedBox(height: 20),
              const BrandWordmark(height: 48),
              const SizedBox(height: 14),
              _FadeIn(
                child: BrandTagline(
                  l10n.splashTagline,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FadeIn extends StatelessWidget {
  const _FadeIn({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeOut,
      builder: (context, value, child) => Opacity(opacity: value, child: child),
      child: child,
    );
  }
}
