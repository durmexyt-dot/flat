import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'account/edit_profile_page.dart';
import 'account/account_sidebar.dart';
import 'admin/admin_page.dart';
import 'admin/admin_repository.dart';
import 'admin/event_editor_page.dart';
import 'admin/events_admin_page.dart';
import 'admin/fees_page.dart';
import 'admin/team_page.dart';
import 'account/notifications_page.dart';
import 'account/privacy_security_page.dart';
import 'auth/auth_repository.dart';
import 'auth/forgot_password_page.dart';
import 'auth/login_page.dart';
import 'auth/signup_page.dart';
import 'data/models.dart';
import 'events/event_page.dart';
import 'home/home_page.dart';
import 'info/info_page.dart';
import 'market/listing_detail_page.dart';
import 'market/listing_tickets_page.dart';
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
import 'support/support_inbox_page.dart';
import 'support/support_ticket_page.dart';
import 'ui/hero_page.dart';
import 'admin/moderation_pages.dart';
import 'admin/platform_settings_pages.dart';
import 'invoices/invoice_pages.dart';

const _authRoutes = {'/login', '/signup', '/forgot-password'};
const _accountOnly = [
  '/sell',
  '/checkout',
  '/account',
  '/order',
  '/payout',
  '/support/new',
  '/support/ticket',
  '/admin',
  '/invoice',
  '/events/new',
  '/settings/profile',
  '/settings/privacy',
  '/settings/notifications',
];

/// [path] with `?from=` set to [target], the page to come back to.
String withReturnTo(String path, String target) =>
    Uri(path: path, queryParameters: {'from': target}).toString();

/// Whether [path] needs an account (selling, the account, checkout).
bool isAccountOnly(String path) => _accountOnly.any(path.startsWith);

/// Opens sign-in (or sign-up) and comes back to the current page after it.
void openSignIn(BuildContext context, {bool signUp = false}) {
  final here = GoRouterState.of(context).uri;
  final back = _authRoutes.contains(here.path)
      ? returnTarget(here)
      : here.toString();
  final path = signUp ? '/signup' : '/login';
  context.push(back == null ? path : withReturnTo(path, back));
}

/// The page to come back to after signing in or the splash, if it is a safe
/// address inside the app.
String? returnTarget(Uri uri) {
  final from = uri.queryParameters['from'];
  if (from == null || !from.startsWith('/') || from.startsWith('//')) {
    return null;
  }
  final path = Uri.parse(from).path;
  if (path == '/splash' || _authRoutes.contains(path)) return null;
  return from;
}

final routerProvider = Provider<GoRouter>((ref) {
  final auth = ref.watch(authRepositoryProvider);
  final refresh = _RefreshNotifier();
  final sub = auth.authStateChanges().listen((_) => refresh.notify());
  ref.listen(isStaffProvider, (_, _) => refresh.notify());
  ref.onDispose(() {
    sub.cancel();
    refresh.dispose();
  });

  return GoRouter(
    initialLocation: '/splash',
    refreshListenable: refresh,
    redirect: (context, state) {
      final location = state.matchedLocation;
      // Every cold start, also a reload on web, begins with the splash; it
      // then goes on to the address that was opened.
      if (!ref.read(splashDoneProvider)) {
        if (location == '/splash') return null;
        return withReturnTo('/splash', state.uri.toString());
      }
      if (location == '/splash') return null;

      final signedIn = auth.currentUser != null;
      // Browsing is open to everyone; selling and the account need an
      // account, and after signing in the user comes back here.
      if (!signedIn && isAccountOnly(location)) {
        return withReturnTo('/login', state.uri.toString());
      }
      // Team accounts (admins, support) don't buy or sell.
      if (signedIn &&
          ref.read(isStaffProvider) &&
          isMarketplacePath(location)) {
        return '/';
      }
      if (signedIn && _authRoutes.contains(location)) {
        return returnTarget(state.uri) ?? '/';
      }
      return null;
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
      _route(
        '/sell',
        (state) => SellPage(eventId: state.uri.queryParameters['event']),
      ),
      _route(
        '/event/:id',
        (state) => EventPage(
          id: state.pathParameters['id']!,
          initial: state.extra as Event?,
        ),
      ),
      _route(
        '/listing/:id',
        (state) => ListingDetailPage(
          id: state.pathParameters['id']!,
          initial: state.extra as Listing?,
        ),
      ),
      _route(
        '/listing/:id/tickets',
        (state) => ListingTicketsPage(listingId: state.pathParameters['id']!),
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
        final (listing, quantity) =
            state.extra as (Listing, int)? ??
            (null, int.tryParse(state.uri.queryParameters['qty'] ?? '') ?? 1);
        return CheckoutPage(
          listingId: state.pathParameters['id']!,
          initial: listing,
          quantity: quantity,
        );
      }),
      _route('/support', (_) => const HelpCenterPage()),
      _route(
        '/support/ticket/:id',
        (state) => SupportTicketPage(id: state.pathParameters['id']!),
      ),
      _route('/admin', (_) => const AdminPage()),
      _route('/admin/support', (_) => const SupportInboxPage()),
      _route('/admin/fees', (_) => const FeesPage()),
      _route('/admin/team', (_) => const TeamPage()),
      _route('/admin/resale', (_) => const ResaleRulesPage()),
      _route('/admin/limits', (_) => const SellerLimitsPage()),
      _route('/admin/company', (_) => const CompanyPage()),
      _route('/admin/invoices', (_) => const AdminInvoicesPage()),
      _route('/admin/moderation', (_) => const ModerationPage()),
      _route(
        '/admin/users/:uid',
        (state) => UserModerationPage(uid: state.pathParameters['uid']!),
      ),
      _route('/account/invoices', (_) => const MyInvoicesPage()),
      _route(
        '/invoice/:id',
        (state) => InvoicePage(id: state.pathParameters['id']!),
      ),
      _route('/admin/events', (_) => const EventsAdminPage()),
      _route('/admin/events/new', (_) => const EventEditorPage()),
      // Users add events too (unconfirmed until the team checks them).
      _route(
        '/events/new',
        (state) =>
            EventEditorPage(forSale: state.uri.queryParameters['sell'] == '1'),
      ),
      _route(
        '/info/:topic',
        (state) => InfoPage(topic: state.pathParameters['topic']!),
      ),
      _route(
        '/admin/events/:id',
        (state) => EventEditorPage(id: state.pathParameters['id']),
      ),
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
