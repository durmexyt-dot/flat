// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Flat';

  @override
  String get loginTitle => 'Sign in';

  @override
  String get loginSubtitle => 'Sign in to your account';

  @override
  String get emailLabel => 'Email';

  @override
  String get passwordLabel => 'Password';

  @override
  String get loginButton => 'Sign in';

  @override
  String get logoutButton => 'Sign out';

  @override
  String get emailRequired => 'Please enter your email address';

  @override
  String get emailInvalid => 'Please enter a valid email address';

  @override
  String get passwordRequired => 'Please enter your password';

  @override
  String get errorInvalidCredentials => 'Incorrect email or password';

  @override
  String get errorUserDisabled => 'This account has been disabled';

  @override
  String get errorTooManyRequests =>
      'Too many attempts. Please try again later';

  @override
  String get errorNetwork => 'No internet connection';

  @override
  String get errorUnknown => 'Something went wrong. Please try again';

  @override
  String get dashboardTitle => 'Dashboard';

  @override
  String welcome(String email) {
    return 'Welcome, $email';
  }

  @override
  String get dashboardEmpty => 'Nothing here yet.';

  @override
  String get language => 'Language';

  @override
  String get showPassword => 'Show password';

  @override
  String get hidePassword => 'Hide password';
}
