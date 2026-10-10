import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'auth/auth_repository.dart';
import 'auth/forgot_password_page.dart';
import 'auth/login_page.dart';
import 'auth/signup_page.dart';
import 'home/home_page.dart';
import 'settings/settings_page.dart';
import 'splash/splash_page.dart';
import 'ui/hero_page.dart';

const _authRoutes = {'/login', '/signup', '/forgot-password'};

final routerProvider = Provider<GoRouter>((ref) {
  final auth = ref.watch(authRepositoryProvider);
  final refresh = _RefreshNotifier();
  final sub = auth.authStateChanges().listen((_) => refresh.notify());
  ref.listen(guestModeProvider, (_, _) => refresh.notify());
  ref.onDispose(() {
    sub.cancel();
    refresh.dispose();
  });

  return GoRouter(
    initialLocation: '/splash',
    refreshListenable: refresh,
    redirect: (context, state) {
      final location = state.matchedLocation;
      // Every cold start, also a reload on web, begins with the splash.
      if (!ref.read(splashDoneProvider)) {
        return location == '/splash' ? null : '/splash';
      }
      if (location == '/splash') return null;

      final canBrowse = auth.currentUser != null || ref.read(guestModeProvider);
      if (canBrowse) return _authRoutes.contains(location) ? '/' : null;
      return location == '/' ? '/login' : null;
    },
    routes: [
      _route('/splash', (_) => const SplashPage()),
      _route('/', (_) => const HomePage()),
      _route('/login', (_) => const LoginPage()),
      _route('/signup', (_) => const SignupPage()),
      _route(
        '/forgot-password',
        (state) =>
            ForgotPasswordPage(initialEmail: state.extra as String? ?? ''),
      ),
      _route('/settings', (_) => const SettingsPage()),
    ],
  );
});

GoRoute _route(String path, Widget Function(GoRouterState state) build) =>
    GoRoute(
      path: path,
      pageBuilder: (context, state) => heroPage(state, build(state)),
    );

class _RefreshNotifier extends ChangeNotifier {
  void notify() => notifyListeners();
}
