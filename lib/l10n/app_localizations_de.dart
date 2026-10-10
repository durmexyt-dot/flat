// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get appTitle => 'Flat';

  @override
  String get loginTitle => 'Anmelden';

  @override
  String get loginSubtitle => 'Melde dich bei deinem Konto an';

  @override
  String get emailLabel => 'E-Mail';

  @override
  String get passwordLabel => 'Passwort';

  @override
  String get loginButton => 'Anmelden';

  @override
  String get logoutButton => 'Abmelden';

  @override
  String get emailRequired => 'Bitte E-Mail-Adresse eingeben';

  @override
  String get emailInvalid => 'Bitte gültige E-Mail-Adresse eingeben';

  @override
  String get passwordRequired => 'Bitte Passwort eingeben';

  @override
  String get errorInvalidCredentials => 'E-Mail oder Passwort ist falsch';

  @override
  String get errorUserDisabled => 'Dieses Konto wurde deaktiviert';

  @override
  String get errorTooManyRequests =>
      'Zu viele Versuche. Bitte später erneut versuchen';

  @override
  String get errorNetwork => 'Keine Internetverbindung';

  @override
  String get errorUnknown =>
      'Ein Fehler ist aufgetreten. Bitte erneut versuchen';

  @override
  String get dashboardTitle => 'Dashboard';

  @override
  String welcome(String email) {
    return 'Willkommen, $email';
  }

  @override
  String get dashboardEmpty => 'Hier gibt es noch nichts.';

  @override
  String get language => 'Sprache';

  @override
  String get showPassword => 'Passwort anzeigen';

  @override
  String get hidePassword => 'Passwort verbergen';
}
