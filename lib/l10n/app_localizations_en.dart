// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Stubswap';

  @override
  String get splashTagline => 'Buy and sell tickets for events';

  @override
  String get loginWelcome => 'Welcome to Stubswap';

  @override
  String get emailLabel => 'Email';

  @override
  String get passwordLabel => 'Password';

  @override
  String get showPassword => 'Show password';

  @override
  String get hidePassword => 'Hide password';

  @override
  String get keepSignedIn => 'Keep me signed in';

  @override
  String get forgotPassword => 'Forgot password?';

  @override
  String get loginButton => 'Sign in';

  @override
  String get orDivider => 'or';

  @override
  String get continueWithGoogle => 'Continue with Google';

  @override
  String get noAccount => 'Don\'t have an account?';

  @override
  String get signUp => 'Sign up';

  @override
  String get continueAsGuest => 'Browse events as guest';

  @override
  String get signupTitle => 'Create your account';

  @override
  String get nameLabel => 'Name';

  @override
  String get nameRequired => 'Please enter your name';

  @override
  String get confirmPasswordLabel => 'Confirm password';

  @override
  String get passwordTooShort => 'Password must be at least 6 characters';

  @override
  String get passwordsDontMatch => 'Passwords don\'t match';

  @override
  String get createAccountButton => 'Create account';

  @override
  String get haveAccount => 'Already have an account?';

  @override
  String get resetTitle => 'Reset your password';

  @override
  String get resetInfo =>
      'Enter your email and we\'ll send you a link to reset your password.';

  @override
  String get resetButton => 'Send link';

  @override
  String resetSent(String email) {
    return 'If an account exists for $email, we\'ve sent a reset link.';
  }

  @override
  String get backToLogin => 'Back to sign in';

  @override
  String get emailRequired => 'Please enter your email address';

  @override
  String get emailInvalid => 'Please enter a valid email address';

  @override
  String get passwordRequired => 'Please enter your password';

  @override
  String get errorInvalidCredentials => 'Incorrect email or password';

  @override
  String get errorEmailInUse => 'This email is already registered';

  @override
  String get errorWeakPassword => 'Password is too weak';

  @override
  String get errorUserDisabled => 'This account has been disabled';

  @override
  String get errorTooManyRequests =>
      'Too many attempts. Please try again later';

  @override
  String get errorNetwork => 'No internet connection';

  @override
  String get errorMethodDisabled => 'This sign-in method is not enabled';

  @override
  String get errorUnknown => 'Something went wrong. Please try again';

  @override
  String homeGreeting(String name) {
    return 'Hi, $name';
  }

  @override
  String get homeGuest => 'You\'re browsing as a guest';

  @override
  String get homeHeadline => 'Find tickets for your next event';

  @override
  String get searchHint => 'Search events, artists, venues';

  @override
  String get catConcerts => 'Concerts';

  @override
  String get catSports => 'Sports';

  @override
  String get catTheater => 'Theater';

  @override
  String get catFestivals => 'Festivals';

  @override
  String get noEvents => 'No events yet';

  @override
  String get noEventsInfo =>
      'Soon you\'ll be able to buy and sell tickets here.';

  @override
  String get sellTickets => 'Sell tickets';

  @override
  String get comingSoon => 'Coming soon';

  @override
  String get guestSignInPrompt => 'Sign in to buy and sell tickets';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get appearance => 'Appearance';

  @override
  String get themeSystem => 'System';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get language => 'Language';

  @override
  String get currency => 'Currency';

  @override
  String get account => 'Account';

  @override
  String get signedInAs => 'Signed in as';

  @override
  String get guest => 'Guest';

  @override
  String get signInOrUp => 'Sign in or sign up';

  @override
  String get logoutButton => 'Sign out';

  @override
  String get themeModeLabel => 'Mode';

  @override
  String get themeColor => 'Theme color';

  @override
  String get colorViolet => 'Violet';

  @override
  String get colorIndigo => 'Indigo';

  @override
  String get colorBlue => 'Blue';

  @override
  String get colorTeal => 'Teal';

  @override
  String get colorGreen => 'Green';

  @override
  String get colorOrange => 'Orange';

  @override
  String get colorRed => 'Red';

  @override
  String get colorPink => 'Pink';

  @override
  String get textSize => 'Text size';

  @override
  String get textSizeMinimum => 'Minimum';

  @override
  String get textSizeDefault => 'Default';

  @override
  String get textSizeLarge => 'Large';

  @override
  String get textSizeExtraLarge => 'Extra large';

  @override
  String get uiStyle => 'UI style';

  @override
  String get uiRounded => 'Rounded';

  @override
  String get uiSoft => 'Soft';

  @override
  String get uiCrisp => 'Crisp';

  @override
  String get preview => 'Preview';

  @override
  String get previewTickets => '2 tickets · Floor';

  @override
  String get previewButton => 'Buy tickets';
}
