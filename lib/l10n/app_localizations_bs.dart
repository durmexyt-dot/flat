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

  @override
  String get themeModeLabel => 'Način prikaza';

  @override
  String get themeColor => 'Boja teme';

  @override
  String get colorViolet => 'Ljubičasta';

  @override
  String get colorIndigo => 'Indigo';

  @override
  String get colorBlue => 'Plava';

  @override
  String get colorTeal => 'Tirkizna';

  @override
  String get colorGreen => 'Zelena';

  @override
  String get colorOrange => 'Narandžasta';

  @override
  String get colorRed => 'Crvena';

  @override
  String get colorPink => 'Ružičasta';

  @override
  String get textSize => 'Veličina teksta';

  @override
  String get textSizeMinimum => 'Minimalna';

  @override
  String get textSizeDefault => 'Standardna';

  @override
  String get textSizeLarge => 'Velika';

  @override
  String get textSizeExtraLarge => 'Vrlo velika';

  @override
  String get uiStyle => 'Stil interfejsa';

  @override
  String get uiRounded => 'Zaobljen';

  @override
  String get uiSoft => 'Mekan';

  @override
  String get uiCrisp => 'Oštar';

  @override
  String get preview => 'Pregled';

  @override
  String get previewTickets => '2 karte · Parter';

  @override
  String get previewButton => 'Kupi karte';

  @override
  String get profileTitle => 'Profil';

  @override
  String get editProfile => 'Uredi profil';

  @override
  String get changePhoto => 'Promijeni fotografiju';

  @override
  String get removePhoto => 'Ukloni fotografiju';

  @override
  String get usernameLabel => 'Korisničko ime';

  @override
  String get usernameHint => '3–20 znakova: mala slova, brojevi, _ i .';

  @override
  String get usernameInvalid => 'Neispravno korisničko ime';

  @override
  String get usernameTaken => 'Korisničko ime je zauzeto';

  @override
  String get save => 'Sačuvaj';

  @override
  String get saved => 'Sačuvano';

  @override
  String get saveError => 'Čuvanje nije uspjelo';

  @override
  String get statListed => 'Ponuđeno';

  @override
  String get statSold => 'Prodano';

  @override
  String get statBought => 'Kupljeno';

  @override
  String get statTickets => 'karata';

  @override
  String get profilePublic => 'Javni profil';

  @override
  String get profilePrivate => 'Privatni profil';

  @override
  String get personalization => 'Personalizacija';

  @override
  String get loadError => 'Učitavanje nije uspjelo';

  @override
  String get loadErrorInfo =>
      'Provjerite internet konekciju i pokušajte ponovo.';

  @override
  String get retry => 'Pokušaj ponovo';

  @override
  String get photoError => 'Fotografija se ne može učitati';

  @override
  String memberSince(String date) {
    return 'Član od $date';
  }

  @override
  String get privacySecurity => 'Privatnost i sigurnost';

  @override
  String get privacy => 'Privatnost';

  @override
  String get profileVisibility => 'Vidljivost profila';

  @override
  String get visibilityPublicInfo =>
      'Kupci vide tvoje ime, korisničko ime i fotografiju uz tvoje ponude.';

  @override
  String get visibilityPrivateInfo =>
      'Kupci vide samo da je prodavac verifikovan. Ime i fotografija ostaju skriveni.';

  @override
  String get security => 'Sigurnost';

  @override
  String get emailVerified => 'Potvrđeno';

  @override
  String get emailNotVerified => 'Nije potvrđeno';

  @override
  String get verifyEmailInfo =>
      'Potvrdi e-mail adresu prije prodaje karata, kako bi te kupci mogli kontaktirati.';

  @override
  String get sendVerification => 'Pošalji link za potvrdu';

  @override
  String verificationSent(String email) {
    return 'Link je poslan na $email';
  }

  @override
  String get checkVerification => 'Već sam potvrdio/la';

  @override
  String get signInMethods => 'Načini prijave';

  @override
  String get methodPassword => 'E-mail i lozinka';

  @override
  String get changePassword => 'Promijeni lozinku';

  @override
  String get currentPassword => 'Trenutna lozinka';

  @override
  String get newPassword => 'Nova lozinka';

  @override
  String get passwordChanged => 'Lozinka je promijenjena';

  @override
  String get dangerZone => 'Opasna zona';

  @override
  String get deleteAccount => 'Obriši račun';

  @override
  String get deleteAccountInfo =>
      'Tvoj profil i aktivne ponude bit će trajno uklonjeni. Narudžbe i isplate čuvamo onoliko dugo koliko zakon zahtijeva.';

  @override
  String get deleteAccountConfirm => 'Potvrdi lozinkom';

  @override
  String get deleteAccountGoogle =>
      'Potvrdit ćeš brisanje svojim Google računom.';

  @override
  String get cancel => 'Odustani';

  @override
  String get notifications => 'Obavještenja';

  @override
  String get channels => 'Kanali';

  @override
  String get channelEmail => 'E-mail';

  @override
  String channelEmailInfo(String email) {
    return 'Obavještenja na $email';
  }

  @override
  String get channelPush => 'Push na ovom uređaju';

  @override
  String get pushUnsupported =>
      'Ovaj preglednik ne podržava obavještenja. Na iPhoneu dodaj Stubswap na početni ekran.';

  @override
  String get pushDenied =>
      'Obavještenja su blokirana u postavkama preglednika.';

  @override
  String get sendTestNotification => 'Pošalji probno obavještenje';

  @override
  String get testNotificationTitle => 'Stubswap obavještenja rade';

  @override
  String get testNotificationBody =>
      'Ovako ćeš saznati kada se tvoje karte prodaju.';

  @override
  String get buying => 'Kupovina';

  @override
  String get selling => 'Prodaja';

  @override
  String get other => 'Ostalo';

  @override
  String get notifOrderUpdates => 'Status narudžbe';

  @override
  String get notifOrderUpdatesInfo => 'Plaćanje, isporuka karata, povrat novca';

  @override
  String get notifEventReminders => 'Podsjetnici za događaje';

  @override
  String get notifEventRemindersInfo => 'Dan prije događaja za koji imaš karte';

  @override
  String get notifPriceAlerts => 'Upozorenja o cijenama';

  @override
  String get notifPriceAlertsInfo =>
      'Kada cijene padnu za događaje koje pratiš';

  @override
  String get notifSaleUpdates => 'Prodane karte';

  @override
  String get notifSaleUpdatesInfo =>
      'Kada se karte prodaju i trebaš ih poslati';

  @override
  String get notifPayoutUpdates => 'Isplate';

  @override
  String get notifPayoutUpdatesInfo =>
      'Planirane, poslane ili neuspjele isplate';

  @override
  String get notifNewsletter => 'Novosti i ponude';

  @override
  String get notifNewsletterInfo => 'Povremeno, o novim događajima';
}
