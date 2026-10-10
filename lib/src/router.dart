import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'account/edit_profile_page.dart';
import 'account/notifications_page.dart';
import 'account/privacy_security_page.dart';
import 'auth/auth_repository.dart';
import 'auth/forgot_password_page.dart';
import 'auth/login_page.dart';
import 'auth/signup_page.dart';
import 'data/models.dart';
import 'home/home_page.dart';
import 'market/listing_detail_page.dart';
import 'market/my_listings_page.dart';
import 'market/order_detail_page.dart';
import 'market/order_labels.dart';
import 'market/orders_page.dart';
import 'market/payout_method_page.dart';
import 'market/payouts_page.dart';
import 'market/sell_page.dart';
import 'payments/checkout_page.dart';
import 'settings/appearance_page.dart';
import 'settings/settings_page.dart';
import 'splash/splash_page.dart';
import 'support/contact_support_page.dart';
import 'support/help_center_page.dart';
import 'ui/hero_page.dart';

const _authRoutes = {'/login', '/signup', '/forgot-password'};
const _accountOnly = [
  '/sell',
  '/checkout',
  '/account',
  '/order',
  '/payout',
  '/support/new',
  '/settings/profile',
  '/settings/privacy',
  '/settings/notifications',
];

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

      final signedIn = auth.currentUser != null;
      // Selling and the account need an account; browsing doesn't.
      if (!signedIn && _accountOnly.any(location.startsWith)) return '/login';
      final canBrowse = signedIn || ref.read(guestModeProvider);
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
      _route('/settings/appearance', (_) => const AppearancePage()),
      _route('/settings/profile', (_) => const EditProfilePage()),
      _route('/settings/privacy', (_) => const PrivacySecurityPage()),
      _route('/settings/notifications', (_) => const NotificationsPage()),
      _route('/sell', (_) => const SellPage()),
      _route(
        '/listing/:id',
        (state) => ListingDetailPage(
          id: state.pathParameters['id']!,
          initial: state.extra as Listing?,
        ),
      ),
      _route('/account/listings', (_) => const MyListingsPage()),
      _route(
        '/account/purchases',
        (_) => const OrdersPage(role: OrderRole.buyer),
      ),
      _route('/account/sales', (_) => const OrdersPage(role: OrderRole.seller)),
      _route('/account/payouts', (_) => const PayoutsPage()),
      _route('/account/payout-method', (_) => const PayoutMethodPage()),
      _route('/checkout/:id', (state) {
        final (listing, quantity) = state.extra as (Listing, int)? ?? (null, 1);
        return CheckoutPage(
          listingId: state.pathParameters['id']!,
          initial: listing,
          quantity: quantity,
        );
      }),
      _route('/support', (_) => const HelpCenterPage()),
      _route(
        '/support/new',
        (state) => ContactSupportPage(initial: state.extra as SupportContext?),
      ),
      _route(
        '/order/:id',
        (state) => OrderDetailPage(
          id: state.pathParameters['id']!,
          initial: state.extra as Order?,
        ),
      ),
      _route(
        '/payout/:id',
        (state) => PayoutDetailPage(
          id: state.pathParameters['id']!,
          initial: state.extra as Payout?,
        ),
      ),
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
