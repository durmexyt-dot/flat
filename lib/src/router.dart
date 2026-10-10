import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'auth/auth_repository.dart';
import 'auth/login_page.dart';
import 'dashboard/dashboard_page.dart';
import 'ui/hero_page.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final auth = ref.watch(authRepositoryProvider);
  final refresh = _StreamListenable(auth.authStateChanges());
  ref.onDispose(refresh.dispose);

  return GoRouter(
    initialLocation: '/',
    refreshListenable: refresh,
    redirect: (context, state) {
      final loggedIn = auth.currentUser != null;
      final onLogin = state.matchedLocation == '/login';
      if (!loggedIn) return onLogin ? null : '/login';
      if (onLogin) return '/';
      return null;
    },
    routes: [
      GoRoute(
        path: '/',
        pageBuilder: (context, state) => heroPage(state, const DashboardPage()),
      ),
      GoRoute(
        path: '/login',
        pageBuilder: (context, state) => heroPage(state, const LoginPage()),
      ),
    ],
  );
});

/// Notifies the router whenever the auth state changes.
class _StreamListenable extends ChangeNotifier {
  _StreamListenable(Stream<Object?> stream) {
    _sub = stream.listen((_) => notifyListeners());
  }

  late final StreamSubscription<Object?> _sub;

  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }
}
