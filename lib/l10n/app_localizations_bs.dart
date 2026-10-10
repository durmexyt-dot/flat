// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Bosnian (`bs`).
class AppLocalizationsBs extends AppLocalizations {
  AppLocalizationsBs([String locale = 'bs']) : super(locale);

  @override
  String get appTitle => 'Stubswap';

  @override
  String get splashTagline => 'Kupuj i prodaji karte za događaje';

  @override
  String get loginWelcome => 'Dobrodošli na Stubswap';

  @override
  String get emailLabel => 'E-mail';

  @override
  String get passwordLabel => 'Lozinka';

  @override
  String get showPassword => 'Prikaži lozinku';

  @override
  String get hidePassword => 'Sakrij lozinku';

  @override
  String get keepSignedIn => 'Ostani prijavljen';

  @override
  String get forgotPassword => 'Zaboravljena lozinka?';

  @override
  String get loginButton => 'Prijavi se';

  @override
  String get orDivider => 'ili';

  @override
  String get continueWithGoogle => 'Nastavi s Google računom';

  @override
  String get noAccount => 'Nemate račun?';

  @override
  String get signUp => 'Registruj se';

  @override
  String get continueAsGuest => 'Pretraži događaje kao gost';

  @override
  String get signupTitle => 'Kreirajte svoj račun';

  @override
  String get nameLabel => 'Ime';

  @override
  String get nameRequired => 'Unesite ime';

  @override
  String get confirmPasswordLabel => 'Potvrdite lozinku';

  @override
  String get passwordTooShort => 'Lozinka mora imati najmanje 6 znakova';

  @override
  String get passwordsDontMatch => 'Lozinke se ne podudaraju';

  @override
  String get createAccountButton => 'Kreiraj račun';

  @override
  String get haveAccount => 'Već imate račun?';

  @override
  String get resetTitle => 'Resetujte lozinku';

  @override
  String get resetInfo =>
      'Unesite e-mail adresu i poslat ćemo vam link za resetovanje lozinke.';

  @override
  String get resetButton => 'Pošalji link';

  @override
  String resetSent(String email) {
    return 'Ako postoji račun za $email, poslali smo link za resetovanje.';
  }

  @override
  String get backToLogin => 'Nazad na prijavu';

  @override
  String get emailRequired => 'Unesite e-mail adresu';

  @override
  String get emailInvalid => 'Unesite ispravnu e-mail adresu';

  @override
  String get passwordRequired => 'Unesite lozinku';

  @override
  String get errorInvalidCredentials => 'Pogrešan e-mail ili lozinka';

  @override
  String get errorEmailInUse => 'Ova e-mail adresa je već registrovana';

  @override
  String get errorWeakPassword => 'Lozinka je preslaba';

  @override
  String get errorUserDisabled => 'Ovaj račun je deaktiviran';

  @override
  String get errorTooManyRequests =>
      'Previše pokušaja. Pokušajte ponovo kasnije';

  @override
  String get errorNetwork => 'Nema internet konekcije';

  @override
  String get errorMethodDisabled => 'Ovaj način prijave nije omogućen';

  @override
  String get errorUnknown => 'Došlo je do greške. Pokušajte ponovo';

  @override
  String homeGreeting(String name) {
    return 'Zdravo, $name';
  }

  @override
  String get homeGuest => 'Pregledate kao gost';

  @override
  String get homeHeadline => 'Pronađite karte za sljedeći događaj';

  @override
  String get searchHint => 'Pretraži događaje, izvođače, mjesta';

  @override
  String get catConcerts => 'Koncerti';

  @override
  String get catSports => 'Sport';

  @override
  String get catTheater => 'Pozorište';

  @override
  String get catFestivals => 'Festivali';

  @override
  String get noEvents => 'Još nema događaja';

  @override
  String get noEventsInfo => 'Uskoro ovdje možete kupovati i prodavati karte.';

  @override
  String get sellTickets => 'Prodaj karte';

  @override
  String get comingSoon => 'Uskoro dostupno';

  @override
  String get guestSignInPrompt =>
      'Prijavite se da biste kupovali i prodavali karte';

  @override
  String get settingsTitle => 'Postavke';

  @override
  String get appearance => 'Izgled';

  @override
  String get themeSystem => 'Sistem';

  @override
  String get themeLight => 'Svijetlo';

  @override
  String get themeDark => 'Tamno';

  @override
  String get language => 'Jezik';

  @override
  String get currency => 'Valuta';

  @override
  String get account => 'Račun';

  @override
  String get signedInAs => 'Prijavljeni kao';

  @override
  String get guest => 'Gost';

  @override
  String get signInOrUp => 'Prijava ili registracija';

  @override
  String get logoutButton => 'Odjavi se';
}
