import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_bs.dart';
import 'app_localizations_de.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('bs'),
    Locale('de'),
    Locale('en'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In bs, this message translates to:
  /// **'Stubswap'**
  String get appTitle;

  /// No description provided for @splashTagline.
  ///
  /// In bs, this message translates to:
  /// **'Kupuj i prodaji karte za događaje'**
  String get splashTagline;

  /// No description provided for @loginWelcome.
  ///
  /// In bs, this message translates to:
  /// **'Dobrodošli na Stubswap'**
  String get loginWelcome;

  /// No description provided for @emailLabel.
  ///
  /// In bs, this message translates to:
  /// **'E-mail'**
  String get emailLabel;

  /// No description provided for @passwordLabel.
  ///
  /// In bs, this message translates to:
  /// **'Lozinka'**
  String get passwordLabel;

  /// No description provided for @showPassword.
  ///
  /// In bs, this message translates to:
  /// **'Prikaži lozinku'**
  String get showPassword;

  /// No description provided for @hidePassword.
  ///
  /// In bs, this message translates to:
  /// **'Sakrij lozinku'**
  String get hidePassword;

  /// No description provided for @keepSignedIn.
  ///
  /// In bs, this message translates to:
  /// **'Ostani prijavljen'**
  String get keepSignedIn;

  /// No description provided for @forgotPassword.
  ///
  /// In bs, this message translates to:
  /// **'Zaboravljena lozinka?'**
  String get forgotPassword;

  /// No description provided for @loginButton.
  ///
  /// In bs, this message translates to:
  /// **'Prijavi se'**
  String get loginButton;

  /// No description provided for @orDivider.
  ///
  /// In bs, this message translates to:
  /// **'ili'**
  String get orDivider;

  /// No description provided for @continueWithGoogle.
  ///
  /// In bs, this message translates to:
  /// **'Nastavi s Google računom'**
  String get continueWithGoogle;

  /// No description provided for @noAccount.
  ///
  /// In bs, this message translates to:
  /// **'Nemate račun?'**
  String get noAccount;

  /// No description provided for @signUp.
  ///
  /// In bs, this message translates to:
  /// **'Registruj se'**
  String get signUp;

  /// No description provided for @continueAsGuest.
  ///
  /// In bs, this message translates to:
  /// **'Pretraži događaje kao gost'**
  String get continueAsGuest;

  /// No description provided for @signupTitle.
  ///
  /// In bs, this message translates to:
  /// **'Kreirajte svoj račun'**
  String get signupTitle;

  /// No description provided for @nameLabel.
  ///
  /// In bs, this message translates to:
  /// **'Ime'**
  String get nameLabel;

  /// No description provided for @nameRequired.
  ///
  /// In bs, this message translates to:
  /// **'Unesite ime'**
  String get nameRequired;

  /// No description provided for @confirmPasswordLabel.
  ///
  /// In bs, this message translates to:
  /// **'Potvrdite lozinku'**
  String get confirmPasswordLabel;

  /// No description provided for @passwordTooShort.
  ///
  /// In bs, this message translates to:
  /// **'Lozinka mora imati najmanje 6 znakova'**
  String get passwordTooShort;

  /// No description provided for @passwordsDontMatch.
  ///
  /// In bs, this message translates to:
  /// **'Lozinke se ne podudaraju'**
  String get passwordsDontMatch;

  /// No description provided for @createAccountButton.
  ///
  /// In bs, this message translates to:
  /// **'Kreiraj račun'**
  String get createAccountButton;

  /// No description provided for @haveAccount.
  ///
  /// In bs, this message translates to:
  /// **'Već imate račun?'**
  String get haveAccount;

  /// No description provided for @resetTitle.
  ///
  /// In bs, this message translates to:
  /// **'Resetujte lozinku'**
  String get resetTitle;

  /// No description provided for @resetInfo.
  ///
  /// In bs, this message translates to:
  /// **'Unesite e-mail adresu i poslat ćemo vam link za resetovanje lozinke.'**
  String get resetInfo;

  /// No description provided for @resetButton.
  ///
  /// In bs, this message translates to:
  /// **'Pošalji link'**
  String get resetButton;

  /// No description provided for @resetSent.
  ///
  /// In bs, this message translates to:
  /// **'Ako postoji račun za {email}, poslali smo link za resetovanje.'**
  String resetSent(String email);

  /// No description provided for @backToLogin.
  ///
  /// In bs, this message translates to:
  /// **'Nazad na prijavu'**
  String get backToLogin;

  /// No description provided for @emailRequired.
  ///
  /// In bs, this message translates to:
  /// **'Unesite e-mail adresu'**
  String get emailRequired;

  /// No description provided for @emailInvalid.
  ///
  /// In bs, this message translates to:
  /// **'Unesite ispravnu e-mail adresu'**
  String get emailInvalid;

  /// No description provided for @passwordRequired.
  ///
  /// In bs, this message translates to:
  /// **'Unesite lozinku'**
  String get passwordRequired;

  /// No description provided for @errorInvalidCredentials.
  ///
  /// In bs, this message translates to:
  /// **'Pogrešan e-mail ili lozinka'**
  String get errorInvalidCredentials;

  /// No description provided for @errorEmailInUse.
  ///
  /// In bs, this message translates to:
  /// **'Ova e-mail adresa je već registrovana'**
  String get errorEmailInUse;

  /// No description provided for @errorWeakPassword.
  ///
  /// In bs, this message translates to:
  /// **'Lozinka je preslaba'**
  String get errorWeakPassword;

  /// No description provided for @errorUserDisabled.
  ///
  /// In bs, this message translates to:
  /// **'Ovaj račun je deaktiviran'**
  String get errorUserDisabled;

  /// No description provided for @errorTooManyRequests.
  ///
  /// In bs, this message translates to:
  /// **'Previše pokušaja. Pokušajte ponovo kasnije'**
  String get errorTooManyRequests;

  /// No description provided for @errorNetwork.
  ///
  /// In bs, this message translates to:
  /// **'Nema internet konekcije'**
  String get errorNetwork;

  /// No description provided for @errorMethodDisabled.
  ///
  /// In bs, this message translates to:
  /// **'Ovaj način prijave nije omogućen'**
  String get errorMethodDisabled;

  /// No description provided for @errorUnknown.
  ///
  /// In bs, this message translates to:
  /// **'Došlo je do greške. Pokušajte ponovo'**
  String get errorUnknown;

  /// No description provided for @homeGreeting.
  ///
  /// In bs, this message translates to:
  /// **'Zdravo, {name}'**
  String homeGreeting(String name);

  /// No description provided for @homeGuest.
  ///
  /// In bs, this message translates to:
  /// **'Pregledate kao gost'**
  String get homeGuest;

  /// No description provided for @homeHeadline.
  ///
  /// In bs, this message translates to:
  /// **'Pronađite karte za sljedeći događaj'**
  String get homeHeadline;

  /// No description provided for @searchHint.
  ///
  /// In bs, this message translates to:
  /// **'Pretraži događaje, izvođače, mjesta'**
  String get searchHint;

  /// No description provided for @catConcerts.
  ///
  /// In bs, this message translates to:
  /// **'Koncerti'**
  String get catConcerts;

  /// No description provided for @catSports.
  ///
  /// In bs, this message translates to:
  /// **'Sport'**
  String get catSports;

  /// No description provided for @catTheater.
  ///
  /// In bs, this message translates to:
  /// **'Pozorište'**
  String get catTheater;

  /// No description provided for @catFestivals.
  ///
  /// In bs, this message translates to:
  /// **'Festivali'**
  String get catFestivals;

  /// No description provided for @noEvents.
  ///
  /// In bs, this message translates to:
  /// **'Još nema događaja'**
  String get noEvents;

  /// No description provided for @noEventsInfo.
  ///
  /// In bs, this message translates to:
  /// **'Uskoro ovdje možete kupovati i prodavati karte.'**
  String get noEventsInfo;

  /// No description provided for @sellTickets.
  ///
  /// In bs, this message translates to:
  /// **'Prodaj karte'**
  String get sellTickets;

  /// No description provided for @comingSoon.
  ///
  /// In bs, this message translates to:
  /// **'Uskoro dostupno'**
  String get comingSoon;

  /// No description provided for @guestSignInPrompt.
  ///
  /// In bs, this message translates to:
  /// **'Prijavite se da biste kupovali i prodavali karte'**
  String get guestSignInPrompt;

  /// No description provided for @settingsTitle.
  ///
  /// In bs, this message translates to:
  /// **'Postavke'**
  String get settingsTitle;

  /// No description provided for @appearance.
  ///
  /// In bs, this message translates to:
  /// **'Izgled'**
  String get appearance;

  /// No description provided for @themeSystem.
  ///
  /// In bs, this message translates to:
  /// **'Sistem'**
  String get themeSystem;

  /// No description provided for @themeLight.
  ///
  /// In bs, this message translates to:
  /// **'Svijetlo'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In bs, this message translates to:
  /// **'Tamno'**
  String get themeDark;

  /// No description provided for @language.
  ///
  /// In bs, this message translates to:
  /// **'Jezik'**
  String get language;

  /// No description provided for @currency.
  ///
  /// In bs, this message translates to:
  /// **'Valuta'**
  String get currency;

  /// No description provided for @account.
  ///
  /// In bs, this message translates to:
  /// **'Račun'**
  String get account;

  /// No description provided for @signedInAs.
  ///
  /// In bs, this message translates to:
  /// **'Prijavljeni kao'**
  String get signedInAs;

  /// No description provided for @guest.
  ///
  /// In bs, this message translates to:
  /// **'Gost'**
  String get guest;

  /// No description provided for @signInOrUp.
  ///
  /// In bs, this message translates to:
  /// **'Prijava ili registracija'**
  String get signInOrUp;

  /// No description provided for @logoutButton.
  ///
  /// In bs, this message translates to:
  /// **'Odjavi se'**
  String get logoutButton;

  /// No description provided for @themeModeLabel.
  ///
  /// In bs, this message translates to:
  /// **'Način prikaza'**
  String get themeModeLabel;

  /// No description provided for @themeColor.
  ///
  /// In bs, this message translates to:
  /// **'Boja teme'**
  String get themeColor;

  /// No description provided for @colorViolet.
  ///
  /// In bs, this message translates to:
  /// **'Ljubičasta'**
  String get colorViolet;

  /// No description provided for @colorIndigo.
  ///
  /// In bs, this message translates to:
  /// **'Indigo'**
  String get colorIndigo;

  /// No description provided for @colorBlue.
  ///
  /// In bs, this message translates to:
  /// **'Plava'**
  String get colorBlue;

  /// No description provided for @colorTeal.
  ///
  /// In bs, this message translates to:
  /// **'Tirkizna'**
  String get colorTeal;

  /// No description provided for @colorGreen.
  ///
  /// In bs, this message translates to:
  /// **'Zelena'**
  String get colorGreen;

  /// No description provided for @colorOrange.
  ///
  /// In bs, this message translates to:
  /// **'Narandžasta'**
  String get colorOrange;

  /// No description provided for @colorRed.
  ///
  /// In bs, this message translates to:
  /// **'Crvena'**
  String get colorRed;

  /// No description provided for @colorPink.
  ///
  /// In bs, this message translates to:
  /// **'Ružičasta'**
  String get colorPink;

  /// No description provided for @textSize.
  ///
  /// In bs, this message translates to:
  /// **'Veličina teksta'**
  String get textSize;

  /// No description provided for @textSizeMinimum.
  ///
  /// In bs, this message translates to:
  /// **'Minimalna'**
  String get textSizeMinimum;

  /// No description provided for @textSizeDefault.
  ///
  /// In bs, this message translates to:
  /// **'Standardna'**
  String get textSizeDefault;

  /// No description provided for @textSizeLarge.
  ///
  /// In bs, this message translates to:
  /// **'Velika'**
  String get textSizeLarge;

  /// No description provided for @textSizeExtraLarge.
  ///
  /// In bs, this message translates to:
  /// **'Vrlo velika'**
  String get textSizeExtraLarge;

  /// No description provided for @uiStyle.
  ///
  /// In bs, this message translates to:
  /// **'Stil interfejsa'**
  String get uiStyle;

  /// No description provided for @uiRounded.
  ///
  /// In bs, this message translates to:
  /// **'Zaobljen'**
  String get uiRounded;

  /// No description provided for @uiSoft.
  ///
  /// In bs, this message translates to:
  /// **'Mekan'**
  String get uiSoft;

  /// No description provided for @uiCrisp.
  ///
  /// In bs, this message translates to:
  /// **'Oštar'**
  String get uiCrisp;

  /// No description provided for @preview.
  ///
  /// In bs, this message translates to:
  /// **'Pregled'**
  String get preview;

  /// No description provided for @previewTickets.
  ///
  /// In bs, this message translates to:
  /// **'2 karte · Parter'**
  String get previewTickets;

  /// No description provided for @previewButton.
  ///
  /// In bs, this message translates to:
  /// **'Kupi karte'**
  String get previewButton;

  /// No description provided for @profileTitle.
  ///
  /// In bs, this message translates to:
  /// **'Profil'**
  String get profileTitle;

  /// No description provided for @editProfile.
  ///
  /// In bs, this message translates to:
  /// **'Uredi profil'**
  String get editProfile;

  /// No description provided for @changePhoto.
  ///
  /// In bs, this message translates to:
  /// **'Promijeni fotografiju'**
  String get changePhoto;

  /// No description provided for @removePhoto.
  ///
  /// In bs, this message translates to:
  /// **'Ukloni fotografiju'**
  String get removePhoto;

  /// No description provided for @usernameLabel.
  ///
  /// In bs, this message translates to:
  /// **'Korisničko ime'**
  String get usernameLabel;

  /// No description provided for @usernameHint.
  ///
  /// In bs, this message translates to:
  /// **'3–20 znakova: mala slova, brojevi, _ i .'**
  String get usernameHint;

  /// No description provided for @usernameInvalid.
  ///
  /// In bs, this message translates to:
  /// **'Neispravno korisničko ime'**
  String get usernameInvalid;

  /// No description provided for @usernameTaken.
  ///
  /// In bs, this message translates to:
  /// **'Korisničko ime je zauzeto'**
  String get usernameTaken;

  /// No description provided for @save.
  ///
  /// In bs, this message translates to:
  /// **'Sačuvaj'**
  String get save;

  /// No description provided for @saved.
  ///
  /// In bs, this message translates to:
  /// **'Sačuvano'**
  String get saved;

  /// No description provided for @saveError.
  ///
  /// In bs, this message translates to:
  /// **'Čuvanje nije uspjelo'**
  String get saveError;

  /// No description provided for @statListed.
  ///
  /// In bs, this message translates to:
  /// **'Ponuđeno'**
  String get statListed;

  /// No description provided for @statSold.
  ///
  /// In bs, this message translates to:
  /// **'Prodano'**
  String get statSold;

  /// No description provided for @statBought.
  ///
  /// In bs, this message translates to:
  /// **'Kupljeno'**
  String get statBought;

  /// No description provided for @statTickets.
  ///
  /// In bs, this message translates to:
  /// **'karata'**
  String get statTickets;

  /// No description provided for @profilePublic.
  ///
  /// In bs, this message translates to:
  /// **'Javni profil'**
  String get profilePublic;

  /// No description provided for @profilePrivate.
  ///
  /// In bs, this message translates to:
  /// **'Privatni profil'**
  String get profilePrivate;

  /// No description provided for @personalization.
  ///
  /// In bs, this message translates to:
  /// **'Personalizacija'**
  String get personalization;

  /// No description provided for @loadError.
  ///
  /// In bs, this message translates to:
  /// **'Učitavanje nije uspjelo'**
  String get loadError;

  /// No description provided for @loadErrorInfo.
  ///
  /// In bs, this message translates to:
  /// **'Provjerite internet konekciju i pokušajte ponovo.'**
  String get loadErrorInfo;

  /// No description provided for @retry.
  ///
  /// In bs, this message translates to:
  /// **'Pokušaj ponovo'**
  String get retry;

  /// No description provided for @photoError.
  ///
  /// In bs, this message translates to:
  /// **'Fotografija se ne može učitati'**
  String get photoError;

  /// No description provided for @memberSince.
  ///
  /// In bs, this message translates to:
  /// **'Član od {date}'**
  String memberSince(String date);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['bs', 'de', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'bs':
      return AppLocalizationsBs();
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
