# Stubswap

Marketplace app to buy and sell tickets for events (Flutter: web, Android,
iOS, macOS; Firebase Auth). UI languages: Bosnian (default), German, English.

Web version: https://durmexyt-dot.github.io/flat/

## Current state

- Splash screen; logo, wordmark and tagline fly into the sign-in screen
  (Hero transitions are a core design principle, see `lib/src/ui/`).
- Sign in with email/password or Google, keep me signed in, password reset,
  sign up, or browse as guest.
- Home: active listings with search and category filters.
- Selling: sell form with fee breakdown, my listings, listing details
  (change price, withdraw).
- Account hub (top right): profile with photo, username and ticket counts;
  purchases with invoices; sales; payouts with payout method (IBAN);
  appearance (dark mode, theme color, text size, UI style), language,
  currency; notifications; privacy & security; help center and support
  requests.
- Demo data (account → tools) shows example orders, sales and payouts in
  every status.

## Payments (test mode)

Buying runs through a **payment simulator** that looks like Stripe Checkout:
test card 4242 4242 4242 4242 and a checkbox whether the payment succeeds
(with a decline reason when it doesn't). No real money moves.

```
lib/src/payments/
  payment_gateway.dart       PaymentGateway interface + provider
  test_payment_gateway.dart  The simulator (TestPaymentGateway)
  checkout_repository.dart   Creates orders, records payments (test mode)
  checkout_page.dart         Checkout screen
  pay_flow.dart              collect → record result
```

Flow: the buyer opens an order (`pendingPayment`), the gateway collects the
payment, then one Firestore transaction marks the order `paid`, takes the
tickets off the listing (`soldOut` when the last ones go) and creates the
seller's payout (`pending`). A failed payment cancels the order. The seller
marks the tickets as sent.

**Switching to real Stripe** (needs the Firebase Blaze plan):
1. Cloud Function `createPaymentIntent(orderId)` with the Stripe secret key.
2. `StripePaymentGateway implements PaymentGateway`: confirm the intent with
   `flutter_stripe` (PaymentSheet) or Stripe Elements on web; return the
   outcome. Register it in `paymentGatewayProvider`.
3. Stripe webhook (Cloud Function) does what `completePayment` does today,
   with the Admin SDK.
4. Remove the test-mode parts from `firestore.rules`.

## Project layout

```
lib/
  main.dart                 Firebase + app start
  firebase_options.dart     Firebase config (web; native via flutterfire)
  l10n/app_*.arb            Translations (bs = template, de, en)
  src/app.dart              MaterialApp, theme
  src/router.dart           Routes and redirects (splash, auth, guest)
  src/brand/                Logo, wordmark, tagline (Hero elements)
  src/ui/                   Hero tags and page transition
  src/splash/               Splash screen
  src/auth/                 Firebase Auth wrapper, sign-in screens
  src/data/                 Models, Firestore repositories, demo data
  src/home/                 Event discovery
  src/market/               Selling, orders, payouts, status timeline
  src/account/              Profile, photo, privacy & security, alerts
  src/support/              Help center and support requests
  src/settings/             Account hub, appearance, settings controller
  src/web/                  Removes the HTML loading splash (web only)
web/index.html              HTML splash shown while Flutter loads
```

## Firebase setup

1. Authentication → Sign-in method: enable **Email/Password** and **Google**.
2. Authentication → Settings → Authorized domains: `durmexyt-dot.github.io`.
3. Firestore Database → **Create database** (production mode, a European
   location such as `eur3`).
4. Firestore Database → **Rules**: replace the rules with the content of
   [`firestore.rules`](firestore.rules) and publish. With the Firebase CLI:
   `firebase deploy --only firestore:rules -P staging` (and `-P prod`).

Test data: `tool/seed_test_data.py` signs in a test seller
(`test.prodavac@stubswap.test`, password via `STUBSWAP_SELLER_PASSWORD`),
adds a profile and payout method and lists a few test events. Safe to run
again.

Test the rules with the Firestore emulator (needs Java):

```sh
cd firestore_test && npm install && npm test
```

Data model (collections): `users` (private profile, notification settings,
`private/payoutMethod`), `publicProfiles`, `usernames`, `roles` (team),
`config/fees`, `events` + `eventImages`, `listings` (each for one event, with
the fees in force when it was created), `orders` and `payouts`
(server-written), `supportTickets` with `messages` (in-app support).
Profile photos, event pictures and support pictures are stored as small
JPEGs in Firestore, so no Storage bucket (Blaze plan) is needed.

## Run locally

```sh
flutter pub get
flutter run -d chrome        # web
flutter test
```

After editing an `.arb` file, `flutter gen-l10n` (or any build) regenerates
`lib/l10n/app_localizations*.dart`.

## Users

Users sign up in the app, or are created in the Firebase console
(Authentication → Users → Add user).

### Team: admins and support

- **Admins** are made only in the Firebase console (once per project,
  staging and prod): copy the user's **User UID** from Authentication →
  Users, then Firestore → `roles` → add a document with that UID as
  **document ID** and a field `role` (string) = `admin`. The rules let no
  app user write this.
- Admins see **Administracija** in the settings: events (with pictures),
  service fee, team, support requests.
- **Events**: users add events too; they stay "unconfirmed" (`pending`) until
  an admin or support account checks, corrects and confirms them
  (Settings → Tim → events to check). Tickets can be sold and bought for
  unconfirmed events.
- **Support accounts** are made by an admin in the app (Administracija →
  Tim): search the user by exact email or username (no user list is
  loaded), then "add as support". They answer support requests in the app.
- **Fees**: a changed service fee applies to listings created afterwards;
  existing listings and their orders keep theirs.

## Environments

| | Firebase project | Web address | Data |
|---|---|---|---|
| **staging** | `stubswap-eda59` (`lib/firebase_options.dart`) | `/flat/staging/` | test accounts and test data |
| **prod** | `stubswap-prod`, database `stubswap-prod` (`lib/firebase_options_prod.dart`) | `/flat/` | real users |

Both use the payment simulator until Stripe is added. Builds are staging
unless built with `APP_ENV=prod` (the scripts do that); staging shows a
"STAGING" banner. The same `firestore.rules` go to both projects
(`firebase deploy --only firestore:rules -P staging` / `-P prod`).

## Versions and releases

Version: `MAJOR.MINOR.PATCH+BUILD` in `pubspec.yaml`, the single source.
The build passes it to the app with build number and commit (about dialog,
support requests); the web app compares its build number with the deployed
`version.json` and offers a reload when a newer one is online.

Changes go under `## [Unreleased]` in [CHANGELOG.md](CHANGELOG.md). A
release:

```sh
tool/release.sh patch     # 1.1.0 → 1.1.1, bug fixes
tool/release.sh minor     # 1.1.0 → 1.2.0, new features
tool/release.sh major     # 1.1.0 → 2.0.0, incompatible changes
tool/release.sh minor all # also deploy prod (only when asked)
```

Rule: new versions go to **staging** first. Prod gets exactly a version
tested there, only on request: `tool/deploy_web.sh prod --ref vX.Y.Z`.

It checks that `main` is clean and pushed, runs analyze and tests, bumps
version and build number, writes the changelog section, commits
`Release vX.Y.Z`, tags `vX.Y.Z`, pushes and deploys (staging by default).

Deploy without a release, or roll back:

```sh
tool/deploy_web.sh staging                 # current main to /flat/staging/
tool/deploy_web.sh prod --ref v1.1.0       # an older version back to /flat/
```

GitHub Pages serves the `gh-pages` branch (Settings → Pages → Deploy from a
branch → `gh-pages`, `/ (root)`).

## Android, iOS and macOS

Firebase is only configured for web so far. On a Mac:

```sh
dart pub global activate flutterfire_cli
flutterfire configure --project=stubswap-eda59 --platforms=android,ios,macos,web
flutter run                  # pick a device / simulator
```

`flutterfire configure` regenerates `lib/firebase_options.dart` and adds
`google-services.json` / `GoogleService-Info.plist`.

macOS: network access is already enabled in the entitlements. Firebase Auth
on macOS also needs Keychain Sharing: open `macos/Runner.xcworkspace` in Xcode →
Runner → Signing & Capabilities → select your team and add **Keychain Sharing**.
