# Stubswap

Marketplace app to buy and sell tickets for events (Flutter: web, Android,
iOS, macOS; Firebase Auth). UI languages: Bosnian (default), German, English.

Web version: https://durmexyt-dot.github.io/flat/

## Current state

- Splash screen; logo, wordmark and tagline fly into the sign-in screen
  (Hero transitions are a core design principle, see `lib/src/ui/`).
- Sign in with email/password or Google, "keep me signed in",
  password reset, sign up, or browse as guest.
- Home: event search (no events yet), sell button.
- Settings (top right): dark mode, language, currency (BAM/EUR/USD), sign out.

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
  src/home/                 Event discovery
  src/settings/             Settings controller and screen
  src/web/                  Removes the HTML loading splash (web only)
web/index.html              HTML splash shown while Flutter loads
```

## Firebase setup

Authentication → Sign-in method: enable **Email/Password** and **Google**.
Authentication → Settings → Authorized domains: `durmexyt-dot.github.io`.

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

## Deployment (web)

GitHub Pages serves the `gh-pages` branch, which contains only the built web
app. To publish the current state:

```sh
tool/deploy_web.sh
```

The script runs the tests, builds with the right base path and pushes the
build to `gh-pages`.

One-time setup:

1. GitHub → Settings → Pages → Source: **Deploy from a branch**,
   Branch: `gh-pages`, folder `/ (root)`.

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
