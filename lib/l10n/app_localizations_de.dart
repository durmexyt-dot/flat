// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get appTitle => 'Stubswap';

  @override
  String get splashTagline => 'Tickets für Events kaufen und verkaufen';

  @override
  String get loginWelcome => 'Willkommen bei Stubswap';

  @override
  String get emailLabel => 'E-Mail';

  @override
  String get passwordLabel => 'Passwort';

  @override
  String get showPassword => 'Passwort anzeigen';

  @override
  String get hidePassword => 'Passwort verbergen';

  @override
  String get keepSignedIn => 'Angemeldet bleiben';

  @override
  String get forgotPassword => 'Passwort vergessen?';

  @override
  String get loginButton => 'Anmelden';

  @override
  String get orDivider => 'oder';

  @override
  String get continueWithGoogle => 'Weiter mit Google';

  @override
  String get noAccount => 'Noch kein Konto?';

  @override
  String get signUp => 'Registrieren';

  @override
  String get continueAsGuest => 'Als Gast Events durchsuchen';

  @override
  String get signupTitle => 'Erstelle dein Konto';

  @override
  String get nameLabel => 'Name';

  @override
  String get nameRequired => 'Bitte Namen eingeben';

  @override
  String get confirmPasswordLabel => 'Passwort bestätigen';

  @override
  String get passwordTooShort => 'Passwort muss mindestens 6 Zeichen haben';

  @override
  String get passwordsDontMatch => 'Passwörter stimmen nicht überein';

  @override
  String get createAccountButton => 'Konto erstellen';

  @override
  String get haveAccount => 'Schon ein Konto?';

  @override
  String get resetTitle => 'Passwort zurücksetzen';

  @override
  String get resetInfo =>
      'Gib deine E-Mail-Adresse ein, und wir senden dir einen Link zum Zurücksetzen.';

  @override
  String get resetButton => 'Link senden';

  @override
  String resetSent(String email) {
    return 'Falls ein Konto für $email existiert, haben wir dir einen Link gesendet.';
  }

  @override
  String get backToLogin => 'Zurück zur Anmeldung';

  @override
  String get emailRequired => 'Bitte E-Mail-Adresse eingeben';

  @override
  String get emailInvalid => 'Bitte gültige E-Mail-Adresse eingeben';

  @override
  String get passwordRequired => 'Bitte Passwort eingeben';

  @override
  String get errorInvalidCredentials => 'E-Mail oder Passwort ist falsch';

  @override
  String get errorEmailInUse => 'Diese E-Mail-Adresse ist bereits registriert';

  @override
  String get errorWeakPassword => 'Das Passwort ist zu schwach';

  @override
  String get errorUserDisabled => 'Dieses Konto wurde deaktiviert';

  @override
  String get errorTooManyRequests =>
      'Zu viele Versuche. Bitte später erneut versuchen';

  @override
  String get errorNetwork => 'Keine Internetverbindung';

  @override
  String get errorMethodDisabled => 'Diese Anmeldemethode ist nicht aktiviert';

  @override
  String get errorUnknown =>
      'Ein Fehler ist aufgetreten. Bitte erneut versuchen';

  @override
  String homeGreeting(String name) {
    return 'Hallo, $name';
  }

  @override
  String get homeGuest => 'Du bist als Gast unterwegs';

  @override
  String get homeHeadline => 'Finde Tickets für dein nächstes Event';

  @override
  String get searchHint => 'Events, Künstler, Orte suchen';

  @override
  String get catConcerts => 'Konzerte';

  @override
  String get catSports => 'Sport';

  @override
  String get catTheater => 'Theater';

  @override
  String get catFestivals => 'Festivals';

  @override
  String get noEvents => 'Noch keine Events';

  @override
  String get noEventsInfo =>
      'Bald kannst du hier Tickets kaufen und verkaufen.';

  @override
  String get sellTickets => 'Tickets verkaufen';

  @override
  String get comingSoon => 'Bald verfügbar';

  @override
  String get guestSignInPrompt =>
      'Melde dich an, um Tickets zu kaufen und zu verkaufen';

  @override
  String get settingsTitle => 'Einstellungen';

  @override
  String get appearance => 'Darstellung';

  @override
  String get themeSystem => 'System';

  @override
  String get themeLight => 'Hell';

  @override
  String get themeDark => 'Dunkel';

  @override
  String get language => 'Sprache';

  @override
  String get currency => 'Währung';

  @override
  String get account => 'Konto';

  @override
  String get signedInAs => 'Angemeldet als';

  @override
  String get guest => 'Gast';

  @override
  String get signInOrUp => 'Anmelden oder registrieren';

  @override
  String get logoutButton => 'Abmelden';

  @override
  String get themeModeLabel => 'Modus';

  @override
  String get themeColor => 'Designfarbe';

  @override
  String get colorViolet => 'Violett';

  @override
  String get colorIndigo => 'Indigo';

  @override
  String get colorBlue => 'Blau';

  @override
  String get colorTeal => 'Petrol';

  @override
  String get colorGreen => 'Grün';

  @override
  String get colorOrange => 'Orange';

  @override
  String get colorRed => 'Rot';

  @override
  String get colorPink => 'Pink';

  @override
  String get textSize => 'Textgröße';

  @override
  String get textSizeMinimum => 'Minimum';

  @override
  String get textSizeDefault => 'Standard';

  @override
  String get textSizeLarge => 'Groß';

  @override
  String get textSizeExtraLarge => 'Sehr groß';

  @override
  String get uiStyle => 'UI-Stil';

  @override
  String get uiRounded => 'Abgerundet';

  @override
  String get uiSoft => 'Weich';

  @override
  String get uiCrisp => 'Kantig';

  @override
  String get preview => 'Vorschau';

  @override
  String get previewTickets => '2 Tickets · Innenraum';

  @override
  String get previewButton => 'Tickets kaufen';
}
