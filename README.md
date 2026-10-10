# Flat

Flutter app (web, Android, iOS, macOS) with Firebase email/password login.
The MVP is a login screen and an empty dashboard. UI languages: Bosnian
(default), German, English.

Web version: https://durmexyt-dot.github.io/flat/

## Project layout

```
lib/
  main.dart                 Firebase + app start
  firebase_options.dart     Firebase config (web; native via flutterfire)
  l10n/app_*.arb            Translations (bs = template, de, en)
  src/app.dart              MaterialApp, theme, localization
  src/router.dart           go_router with login redirect
  src/auth/                 Firebase Auth wrapper and login page
  src/dashboard/            Dashboard page
  src/settings/             Language selection (saved on device)
```

## Run locally

```sh
flutter pub get
flutter run -d chrome        # web
flutter test
```

After editing an `.arb` file, `flutter gen-l10n` (or any build) regenerates
`lib/l10n/app_localizations*.dart`.

## Users

There is no sign-up screen. Create users in the Firebase console:
Authentication → Users → Add user.

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
2. Firebase console → Authentication → Settings → Authorized domains:
   add `durmexyt-dot.github.io`.

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
