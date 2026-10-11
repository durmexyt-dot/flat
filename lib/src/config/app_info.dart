/// Where the app runs. Staging is for testing (test accounts and data),
/// prod is what real users see. Both use the payment simulator until Stripe
/// is added.
enum AppEnvironment { staging, prod }

/// Version, build and environment, passed in at build time by
/// `tool/build_web.sh` (from pubspec.yaml and git), so there is a single
/// source of truth.
abstract final class AppInfo {
  static const version = String.fromEnvironment(
    'APP_VERSION',
    defaultValue: 'dev',
  );

  /// Grows with every release; compared with the deployed `version.json` to
  /// tell that a newer version is online.
  static const build = int.fromEnvironment('APP_BUILD');
  static const commit = String.fromEnvironment('APP_COMMIT');

  /// Defaults to staging: a build without settings never touches real data.
  static const environment = String.fromEnvironment('APP_ENV') == 'prod'
      ? AppEnvironment.prod
      : AppEnvironment.staging;

  static bool get isProd => environment == AppEnvironment.prod;

  /// E.g. "1.1.0 (7 · 3eece17)", for the about dialog and support requests.
  static String get label {
    final details = [if (build > 0) '$build', if (commit.isNotEmpty) commit];
    final env = isProd ? '' : ' · staging';
    return details.isEmpty
        ? '$version$env'
        : '$version (${details.join(' · ')})$env';
  }
}
