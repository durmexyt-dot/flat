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

  /// No description provided for @eventsUserDateTooFar.
  ///
  /// In bs, this message translates to:
  /// **'Datum može biti najviše dvije godine unaprijed'**
  String get eventsUserDateTooFar;

  /// No description provided for @homeCityPick.
  ///
  /// In bs, this message translates to:
  /// **'Odaberi grad'**
  String get homeCityPick;

  /// No description provided for @homeCitySearch.
  ///
  /// In bs, this message translates to:
  /// **'Pretraži gradove'**
  String get homeCitySearch;

  /// No description provided for @homeCityUseTyped.
  ///
  /// In bs, this message translates to:
  /// **'Koristi „{city}”'**
  String homeCityUseTyped(String city);

  /// No description provided for @homeCityUseLocation.
  ///
  /// In bs, this message translates to:
  /// **'Koristi moju lokaciju'**
  String get homeCityUseLocation;

  /// No description provided for @homeCityLocationUnavailable.
  ///
  /// In bs, this message translates to:
  /// **'Lokacija nije dostupna. Odaberi grad ručno.'**
  String get homeCityLocationUnavailable;

  /// No description provided for @homeCityClear.
  ///
  /// In bs, this message translates to:
  /// **'Ukloni'**
  String get homeCityClear;

  /// No description provided for @homeCityFromLocation.
  ///
  /// In bs, this message translates to:
  /// **'Prema tvojoj lokaciji'**
  String get homeCityFromLocation;

  /// No description provided for @homeCityMostEvents.
  ///
  /// In bs, this message translates to:
  /// **'Grad s najviše događaja'**
  String get homeCityMostEvents;

  /// No description provided for @homeAllTypes.
  ///
  /// In bs, this message translates to:
  /// **'Svi tipovi'**
  String get homeAllTypes;

  /// No description provided for @homeRecentlyViewed.
  ///
  /// In bs, this message translates to:
  /// **'Nedavno pregledano'**
  String get homeRecentlyViewed;

  /// No description provided for @homePopular.
  ///
  /// In bs, this message translates to:
  /// **'Popularni događaji'**
  String get homePopular;

  /// No description provided for @homeRecommended.
  ///
  /// In bs, this message translates to:
  /// **'Preporučeno za vas'**
  String get homeRecommended;

  /// No description provided for @homeNearby.
  ///
  /// In bs, this message translates to:
  /// **'Aktuelno u blizini: {city}'**
  String homeNearby(String city);

  /// No description provided for @homeNearbyChange.
  ///
  /// In bs, this message translates to:
  /// **'Promijeni'**
  String get homeNearbyChange;

  /// No description provided for @homePopularCategories.
  ///
  /// In bs, this message translates to:
  /// **'Popularne kategorije'**
  String get homePopularCategories;

  /// No description provided for @homeAllEvents.
  ///
  /// In bs, this message translates to:
  /// **'Svi događaji'**
  String get homeAllEvents;

  /// No description provided for @homeAllEventsOfType.
  ///
  /// In bs, this message translates to:
  /// **'Svi događaji: {type}'**
  String homeAllEventsOfType(String type);

  /// No description provided for @homeSearchResults.
  ///
  /// In bs, this message translates to:
  /// **'Rezultati pretrage'**
  String get homeSearchResults;

  /// No description provided for @homeAddEvent.
  ///
  /// In bs, this message translates to:
  /// **'Dodaj događaj'**
  String get homeAddEvent;

  /// No description provided for @homeScrollBack.
  ///
  /// In bs, this message translates to:
  /// **'Prethodni'**
  String get homeScrollBack;

  /// No description provided for @homeScrollForward.
  ///
  /// In bs, this message translates to:
  /// **'Sljedeći'**
  String get homeScrollForward;

  /// No description provided for @footerClaim.
  ///
  /// In bs, this message translates to:
  /// **'Sigurna preprodaja karata – od fanova za fanove.'**
  String get footerClaim;

  /// No description provided for @footerCompany.
  ///
  /// In bs, this message translates to:
  /// **'Naša kompanija'**
  String get footerCompany;

  /// No description provided for @footerQuestions.
  ///
  /// In bs, this message translates to:
  /// **'Imate pitanja?'**
  String get footerQuestions;

  /// No description provided for @footerCopyright.
  ///
  /// In bs, this message translates to:
  /// **'© {year} Stubswap'**
  String footerCopyright(int year);

  /// No description provided for @footerVersion.
  ///
  /// In bs, this message translates to:
  /// **'Verzija {version}'**
  String footerVersion(String version);

  /// No description provided for @infoAboutTitle.
  ///
  /// In bs, this message translates to:
  /// **'O nama'**
  String get infoAboutTitle;

  /// No description provided for @infoPressTitle.
  ///
  /// In bs, this message translates to:
  /// **'Press'**
  String get infoPressTitle;

  /// No description provided for @infoHowTitle.
  ///
  /// In bs, this message translates to:
  /// **'Kako funkcioniše'**
  String get infoHowTitle;

  /// No description provided for @infoSafetyTitle.
  ///
  /// In bs, this message translates to:
  /// **'Sigurnost kupovine'**
  String get infoSafetyTitle;

  /// No description provided for @infoNotFound.
  ///
  /// In bs, this message translates to:
  /// **'Stranica nije pronađena'**
  String get infoNotFound;

  /// No description provided for @infoNotFoundInfo.
  ///
  /// In bs, this message translates to:
  /// **'Ova stranica ne postoji ili je premještena.'**
  String get infoNotFoundInfo;

  /// No description provided for @infoAboutIntro.
  ///
  /// In bs, this message translates to:
  /// **'Stubswap je tržište na kojem fanovi u Bosni i Hercegovini i regionu sigurno preprodaju karte za koncerte, sport, kulturu i festivale.'**
  String get infoAboutIntro;

  /// No description provided for @infoAboutFansTitle.
  ///
  /// In bs, this message translates to:
  /// **'Od fanova za fanove'**
  String get infoAboutFansTitle;

  /// No description provided for @infoAboutFansText.
  ///
  /// In bs, this message translates to:
  /// **'Ne možeš na događaj? Ponudi kartu nekome ko želi ići, umjesto da propadne. Rasprodano? Možda neko upravo prodaje svoju.'**
  String get infoAboutFansText;

  /// No description provided for @infoAboutTrustTitle.
  ///
  /// In bs, this message translates to:
  /// **'Sigurnost na prvom mjestu'**
  String get infoAboutTrustTitle;

  /// No description provided for @infoAboutTrustText.
  ///
  /// In bs, this message translates to:
  /// **'Plaćanje ide preko Stubswapa: prodavac dobija novac tek nakon događaja, a naša podrška pomaže ako nešto nije u redu.'**
  String get infoAboutTrustText;

  /// No description provided for @infoPressIntro.
  ///
  /// In bs, this message translates to:
  /// **'Pišete o Stubswapu? Rado odgovaramo na pitanja medija.'**
  String get infoPressIntro;

  /// No description provided for @infoPressFactsTitle.
  ///
  /// In bs, this message translates to:
  /// **'Ukratko'**
  String get infoPressFactsTitle;

  /// No description provided for @infoPressFact1.
  ///
  /// In bs, this message translates to:
  /// **'Online tržište za preprodaju karata između fanova.'**
  String get infoPressFact1;

  /// No description provided for @infoPressFact2.
  ///
  /// In bs, this message translates to:
  /// **'Fokus na Bosnu i Hercegovinu i region.'**
  String get infoPressFact2;

  /// No description provided for @infoPressFact3.
  ///
  /// In bs, this message translates to:
  /// **'Dostupno na webu i mobilnim uređajima, na bosanskom, njemačkom i engleskom jeziku.'**
  String get infoPressFact3;

  /// No description provided for @infoPressContactTitle.
  ///
  /// In bs, this message translates to:
  /// **'Kontakt za medije'**
  String get infoPressContactTitle;

  /// No description provided for @infoPressContactText.
  ///
  /// In bs, this message translates to:
  /// **'Upite medija pošaljite preko centra za pomoć. Javit ćemo vam se što prije.'**
  String get infoPressContactText;

  /// No description provided for @infoHowBuyTitle.
  ///
  /// In bs, this message translates to:
  /// **'Kupovina'**
  String get infoHowBuyTitle;

  /// No description provided for @infoHowBuy1.
  ///
  /// In bs, this message translates to:
  /// **'Pronađi događaj i uporedi ponude fanova.'**
  String get infoHowBuy1;

  /// No description provided for @infoHowBuy2.
  ///
  /// In bs, this message translates to:
  /// **'Plati sigurno – novac čuvamo dok karte ne stignu.'**
  String get infoHowBuy2;

  /// No description provided for @infoHowBuy3.
  ///
  /// In bs, this message translates to:
  /// **'Prodavac ti šalje karte, a status pratiš u Kupovine i računi.'**
  String get infoHowBuy3;

  /// No description provided for @infoHowSellTitle.
  ///
  /// In bs, this message translates to:
  /// **'Prodaja'**
  String get infoHowSellTitle;

  /// No description provided for @infoSafetyIntro.
  ///
  /// In bs, this message translates to:
  /// **'Na Stubswapu kupuješ od drugih fanova – a mi pazimo da sve prođe kako treba.'**
  String get infoSafetyIntro;

  /// No description provided for @infoSafetyPaymentTitle.
  ///
  /// In bs, this message translates to:
  /// **'Novac čuvamo do događaja'**
  String get infoSafetyPaymentTitle;

  /// No description provided for @infoSafetyPaymentText.
  ///
  /// In bs, this message translates to:
  /// **'Plaćaš preko Stubswapa, nikad direktno prodavcu. Prodavac dobija novac tek nakon događaja.'**
  String get infoSafetyPaymentText;

  /// No description provided for @infoSafetySellersTitle.
  ///
  /// In bs, this message translates to:
  /// **'Provjereni prodavci'**
  String get infoSafetySellersTitle;

  /// No description provided for @infoSafetySellersText.
  ///
  /// In bs, this message translates to:
  /// **'Prodavci moraju potvrditi svoju e-mail adresu prije nego što objave ponudu.'**
  String get infoSafetySellersText;

  /// No description provided for @infoSafetySupportTitle.
  ///
  /// In bs, this message translates to:
  /// **'Podrška kad zatreba'**
  String get infoSafetySupportTitle;

  /// No description provided for @infoSafetySupportText.
  ///
  /// In bs, this message translates to:
  /// **'Ako karte ne stignu ili nisu važeće, javi se podršci – vraćamo ti novac.'**
  String get infoSafetySupportText;

  /// No description provided for @eventStatusConfirmed.
  ///
  /// In bs, this message translates to:
  /// **'Potvrđen'**
  String get eventStatusConfirmed;

  /// No description provided for @eventStatusPending.
  ///
  /// In bs, this message translates to:
  /// **'Nije potvrđen'**
  String get eventStatusPending;

  /// No description provided for @eventStatusHidden.
  ///
  /// In bs, this message translates to:
  /// **'Skriven'**
  String get eventStatusHidden;

  /// No description provided for @eventStatusPendingInfo.
  ///
  /// In bs, this message translates to:
  /// **'Ovaj događaj je dodao korisnik i tim ga još nije provjerio. Karte možeš kupiti i prodati.'**
  String get eventStatusPendingInfo;

  /// No description provided for @eventsUserNewTitle.
  ///
  /// In bs, this message translates to:
  /// **'Dodaj događaj'**
  String get eventsUserNewTitle;

  /// No description provided for @eventsUserInfoTitle.
  ///
  /// In bs, this message translates to:
  /// **'Tim će provjeriti događaj'**
  String get eventsUserInfoTitle;

  /// No description provided for @eventsUserInfo.
  ///
  /// In bs, this message translates to:
  /// **'Dok ga ne provjerimo, događaj je označen kao „Nije potvrđen“. Karte za njega možeš prodavati odmah.'**
  String get eventsUserInfo;

  /// No description provided for @eventsUserVerifyFirst.
  ///
  /// In bs, this message translates to:
  /// **'Potvrdi e-mail adresu da bi mogao dodavati događaje.'**
  String get eventsUserVerifyFirst;

  /// No description provided for @eventsUserAdded.
  ///
  /// In bs, this message translates to:
  /// **'Događaj dodan – čeka provjeru'**
  String get eventsUserAdded;

  /// No description provided for @eventsUserNotListed.
  ///
  /// In bs, this message translates to:
  /// **'Događaj nije na listi?'**
  String get eventsUserNotListed;

  /// No description provided for @eventsUserAddIt.
  ///
  /// In bs, this message translates to:
  /// **'Dodaj ga'**
  String get eventsUserAddIt;

  /// No description provided for @eventsUserNoneToSellInfo.
  ///
  /// In bs, this message translates to:
  /// **'Još nema nadolazećih događaja. Dodaj svoj događaj i odmah prodaj karte za njega.'**
  String get eventsUserNoneToSellInfo;

  /// No description provided for @eventsReviewEdit.
  ///
  /// In bs, this message translates to:
  /// **'Uredi / provjeri'**
  String get eventsReviewEdit;

  /// No description provided for @eventsReviewConfirm.
  ///
  /// In bs, this message translates to:
  /// **'Potvrdi'**
  String get eventsReviewConfirm;

  /// No description provided for @eventsReviewConfirmTitle.
  ///
  /// In bs, this message translates to:
  /// **'Potvrditi događaj?'**
  String get eventsReviewConfirmTitle;

  /// No description provided for @eventsReviewConfirmInfo.
  ///
  /// In bs, this message translates to:
  /// **'Provjeri naziv, mjesto i datum. Događaj će svima biti prikazan kao potvrđen.'**
  String get eventsReviewConfirmInfo;

  /// No description provided for @eventsReviewConfirmedToast.
  ///
  /// In bs, this message translates to:
  /// **'Događaj je potvrđen'**
  String get eventsReviewConfirmedToast;

  /// No description provided for @eventsReviewTabPending.
  ///
  /// In bs, this message translates to:
  /// **'Na provjeri ({count})'**
  String eventsReviewTabPending(int count);

  /// No description provided for @eventsReviewTabConfirmed.
  ///
  /// In bs, this message translates to:
  /// **'Potvrđeni'**
  String get eventsReviewTabConfirmed;

  /// No description provided for @eventsReviewTabHidden.
  ///
  /// In bs, this message translates to:
  /// **'Skriveni'**
  String get eventsReviewTabHidden;

  /// No description provided for @eventsReviewTabPast.
  ///
  /// In bs, this message translates to:
  /// **'Prošli'**
  String get eventsReviewTabPast;

  /// No description provided for @eventsReviewEmptyPending.
  ///
  /// In bs, this message translates to:
  /// **'Nema događaja na provjeri'**
  String get eventsReviewEmptyPending;

  /// No description provided for @eventsReviewEmptyPendingInfo.
  ///
  /// In bs, this message translates to:
  /// **'Kad korisnik doda događaj, pojavit će se ovdje.'**
  String get eventsReviewEmptyPendingInfo;

  /// No description provided for @eventsReviewEmpty.
  ///
  /// In bs, this message translates to:
  /// **'Ovdje nema događaja'**
  String get eventsReviewEmpty;

  /// No description provided for @eventsReviewAddedBy.
  ///
  /// In bs, this message translates to:
  /// **'Dodao: {who}'**
  String eventsReviewAddedBy(String who);

  /// No description provided for @eventsReviewAddedByYou.
  ///
  /// In bs, this message translates to:
  /// **'Ti'**
  String get eventsReviewAddedByYou;

  /// No description provided for @eventsReviewAddedByUser.
  ///
  /// In bs, this message translates to:
  /// **'Korisnik'**
  String get eventsReviewAddedByUser;

  /// No description provided for @eventsReviewQueue.
  ///
  /// In bs, this message translates to:
  /// **'Događaji na provjeri'**
  String get eventsReviewQueue;

  /// No description provided for @eventsReviewNoAccessInfo.
  ///
  /// In bs, this message translates to:
  /// **'Ovu stranicu mogu otvoriti samo članovi tima.'**
  String get eventsReviewNoAccessInfo;

  /// No description provided for @genreFootball.
  ///
  /// In bs, this message translates to:
  /// **'Fudbal'**
  String get genreFootball;

  /// No description provided for @genreBasketball.
  ///
  /// In bs, this message translates to:
  /// **'Košarka'**
  String get genreBasketball;

  /// No description provided for @genreHandball.
  ///
  /// In bs, this message translates to:
  /// **'Rukomet'**
  String get genreHandball;

  /// No description provided for @genreTennis.
  ///
  /// In bs, this message translates to:
  /// **'Tenis'**
  String get genreTennis;

  /// No description provided for @genreVolleyball.
  ///
  /// In bs, this message translates to:
  /// **'Odbojka'**
  String get genreVolleyball;

  /// No description provided for @genreCombat.
  ///
  /// In bs, this message translates to:
  /// **'Borilački sportovi'**
  String get genreCombat;

  /// No description provided for @genreMotorsport.
  ///
  /// In bs, this message translates to:
  /// **'Moto sport'**
  String get genreMotorsport;

  /// No description provided for @genreOtherSport.
  ///
  /// In bs, this message translates to:
  /// **'Ostali sportovi'**
  String get genreOtherSport;

  /// No description provided for @genreRock.
  ///
  /// In bs, this message translates to:
  /// **'Rock'**
  String get genreRock;

  /// No description provided for @genrePop.
  ///
  /// In bs, this message translates to:
  /// **'Pop'**
  String get genrePop;

  /// No description provided for @genreFolk.
  ///
  /// In bs, this message translates to:
  /// **'Narodna muzika'**
  String get genreFolk;

  /// No description provided for @genreJazz.
  ///
  /// In bs, this message translates to:
  /// **'Jazz'**
  String get genreJazz;

  /// No description provided for @genreHiphop.
  ///
  /// In bs, this message translates to:
  /// **'Hip-hop'**
  String get genreHiphop;

  /// No description provided for @genreElectronic.
  ///
  /// In bs, this message translates to:
  /// **'Elektronska muzika'**
  String get genreElectronic;

  /// No description provided for @genreClassical.
  ///
  /// In bs, this message translates to:
  /// **'Klasična muzika'**
  String get genreClassical;

  /// No description provided for @genreOtherMusic.
  ///
  /// In bs, this message translates to:
  /// **'Ostala muzika'**
  String get genreOtherMusic;

  /// No description provided for @genreDrama.
  ///
  /// In bs, this message translates to:
  /// **'Pozorište'**
  String get genreDrama;

  /// No description provided for @genreOpera.
  ///
  /// In bs, this message translates to:
  /// **'Opera'**
  String get genreOpera;

  /// No description provided for @genreBallet.
  ///
  /// In bs, this message translates to:
  /// **'Balet'**
  String get genreBallet;

  /// No description provided for @genreStandup.
  ///
  /// In bs, this message translates to:
  /// **'Stand-up komedija'**
  String get genreStandup;

  /// No description provided for @genreMusical.
  ///
  /// In bs, this message translates to:
  /// **'Mjuzikl'**
  String get genreMusical;

  /// No description provided for @genreExhibition.
  ///
  /// In bs, this message translates to:
  /// **'Izložbe'**
  String get genreExhibition;

  /// No description provided for @genreFilm.
  ///
  /// In bs, this message translates to:
  /// **'Film'**
  String get genreFilm;

  /// No description provided for @genreMusicFestival.
  ///
  /// In bs, this message translates to:
  /// **'Muzički festivali'**
  String get genreMusicFestival;

  /// No description provided for @genreFilmFestival.
  ///
  /// In bs, this message translates to:
  /// **'Filmski festivali'**
  String get genreFilmFestival;

  /// No description provided for @genreFoodFestival.
  ///
  /// In bs, this message translates to:
  /// **'Gastro festivali'**
  String get genreFoodFestival;

  /// No description provided for @genreOtherFestival.
  ///
  /// In bs, this message translates to:
  /// **'Ostali festivali'**
  String get genreOtherFestival;

  /// No description provided for @genreFamily.
  ///
  /// In bs, this message translates to:
  /// **'Za porodicu'**
  String get genreFamily;

  /// No description provided for @genreConference.
  ///
  /// In bs, this message translates to:
  /// **'Konferencije'**
  String get genreConference;

  /// No description provided for @genreOtherEvent.
  ///
  /// In bs, this message translates to:
  /// **'Ostalo'**
  String get genreOtherEvent;

  /// No description provided for @genreLabel.
  ///
  /// In bs, this message translates to:
  /// **'Podkategorija'**
  String get genreLabel;

  /// No description provided for @genreNone.
  ///
  /// In bs, this message translates to:
  /// **'Bez podkategorije'**
  String get genreNone;

  /// No description provided for @supportUser.
  ///
  /// In bs, this message translates to:
  /// **'Korisnik'**
  String get supportUser;

  /// No description provided for @supportMyRequests.
  ///
  /// In bs, this message translates to:
  /// **'Moji upiti'**
  String get supportMyRequests;

  /// No description provided for @supportNoRequests.
  ///
  /// In bs, this message translates to:
  /// **'Još nemaš upita podršci.'**
  String get supportNoRequests;

  /// No description provided for @supportStatusOpen.
  ///
  /// In bs, this message translates to:
  /// **'Otvoren'**
  String get supportStatusOpen;

  /// No description provided for @supportStatusAnswered.
  ///
  /// In bs, this message translates to:
  /// **'Odgovoreno'**
  String get supportStatusAnswered;

  /// No description provided for @supportStatusClosed.
  ///
  /// In bs, this message translates to:
  /// **'Zatvoren'**
  String get supportStatusClosed;

  /// No description provided for @supportNewAnswer.
  ///
  /// In bs, this message translates to:
  /// **'Novi odgovor'**
  String get supportNewAnswer;

  /// No description provided for @supportRequestSent.
  ///
  /// In bs, this message translates to:
  /// **'Upit poslan'**
  String get supportRequestSent;

  /// No description provided for @supportMessageTooShort.
  ///
  /// In bs, this message translates to:
  /// **'Napiši barem 10 znakova'**
  String get supportMessageTooShort;

  /// No description provided for @supportAnswerInApp.
  ///
  /// In bs, this message translates to:
  /// **'Odgovaramo ovdje u aplikaciji, obično u roku od 24 sata. Dobit ćeš obavijest.'**
  String get supportAnswerInApp;

  /// No description provided for @supportImages.
  ///
  /// In bs, this message translates to:
  /// **'Slike'**
  String get supportImages;

  /// No description provided for @supportImagesInfo.
  ///
  /// In bs, this message translates to:
  /// **'Snimci ekrana ili fotografije, najviše {count}'**
  String supportImagesInfo(int count);

  /// No description provided for @supportAddImage.
  ///
  /// In bs, this message translates to:
  /// **'Dodaj sliku'**
  String get supportAddImage;

  /// No description provided for @supportRemoveImage.
  ///
  /// In bs, this message translates to:
  /// **'Ukloni sliku'**
  String get supportRemoveImage;

  /// No description provided for @supportImageError.
  ///
  /// In bs, this message translates to:
  /// **'Slika se ne može učitati'**
  String get supportImageError;

  /// No description provided for @supportImage.
  ///
  /// In bs, this message translates to:
  /// **'Slika'**
  String get supportImage;

  /// No description provided for @supportTeamName.
  ///
  /// In bs, this message translates to:
  /// **'Podrška Stubswap'**
  String get supportTeamName;

  /// No description provided for @supportYou.
  ///
  /// In bs, this message translates to:
  /// **'Ti'**
  String get supportYou;

  /// No description provided for @supportTicket.
  ///
  /// In bs, this message translates to:
  /// **'Upit'**
  String get supportTicket;

  /// No description provided for @supportCloseTicket.
  ///
  /// In bs, this message translates to:
  /// **'Zatvori upit'**
  String get supportCloseTicket;

  /// No description provided for @supportResolveTicket.
  ///
  /// In bs, this message translates to:
  /// **'Problem riješen – zatvori upit'**
  String get supportResolveTicket;

  /// No description provided for @supportCloseConfirm.
  ///
  /// In bs, this message translates to:
  /// **'Zatvoriti upit?'**
  String get supportCloseConfirm;

  /// No description provided for @supportCloseConfirmInfo.
  ///
  /// In bs, this message translates to:
  /// **'U zatvoreni upit se više ne može pisati. Ako se problem ponovo pojavi, otvori novi upit.'**
  String get supportCloseConfirmInfo;

  /// No description provided for @supportCloseConfirmStaff.
  ///
  /// In bs, this message translates to:
  /// **'Korisnik više neće moći pisati u ovaj upit.'**
  String get supportCloseConfirmStaff;

  /// No description provided for @supportClosed.
  ///
  /// In bs, this message translates to:
  /// **'Upit je zatvoren'**
  String get supportClosed;

  /// No description provided for @supportClosedByUser.
  ///
  /// In bs, this message translates to:
  /// **'Zatvorio ga je korisnik.'**
  String get supportClosedByUser;

  /// No description provided for @supportClosedByYou.
  ///
  /// In bs, this message translates to:
  /// **'Zatvoren na tvoj zahtjev.'**
  String get supportClosedByYou;

  /// No description provided for @supportClosedByStaff.
  ///
  /// In bs, this message translates to:
  /// **'Zatvorila ga je podrška.'**
  String get supportClosedByStaff;

  /// No description provided for @supportNewRequest.
  ///
  /// In bs, this message translates to:
  /// **'Novi upit'**
  String get supportNewRequest;

  /// No description provided for @supportWriteMessage.
  ///
  /// In bs, this message translates to:
  /// **'Napiši poruku…'**
  String get supportWriteMessage;

  /// No description provided for @supportNotFound.
  ///
  /// In bs, this message translates to:
  /// **'Upit nije pronađen'**
  String get supportNotFound;

  /// No description provided for @supportNoAccess.
  ///
  /// In bs, this message translates to:
  /// **'Nemaš pristup'**
  String get supportNoAccess;

  /// No description provided for @supportNoAccessInfo.
  ///
  /// In bs, this message translates to:
  /// **'Ova stranica je samo za tim podrške.'**
  String get supportNoAccessInfo;

  /// No description provided for @supportInbox.
  ///
  /// In bs, this message translates to:
  /// **'Upiti podrške'**
  String get supportInbox;

  /// No description provided for @supportFilterOpen.
  ///
  /// In bs, this message translates to:
  /// **'Otvoreni'**
  String get supportFilterOpen;

  /// No description provided for @supportFilterAnswered.
  ///
  /// In bs, this message translates to:
  /// **'Odgovoreni'**
  String get supportFilterAnswered;

  /// No description provided for @supportFilterClosed.
  ///
  /// In bs, this message translates to:
  /// **'Zatvoreni'**
  String get supportFilterClosed;

  /// No description provided for @supportFilterAll.
  ///
  /// In bs, this message translates to:
  /// **'Svi'**
  String get supportFilterAll;

  /// No description provided for @supportInboxEmpty.
  ///
  /// In bs, this message translates to:
  /// **'Nema upita'**
  String get supportInboxEmpty;

  /// No description provided for @supportAppVersion.
  ///
  /// In bs, this message translates to:
  /// **'Verzija aplikacije'**
  String get supportAppVersion;

  /// No description provided for @supportEmail.
  ///
  /// In bs, this message translates to:
  /// **'E-mail'**
  String get supportEmail;

  /// No description provided for @supportAlertAnswered.
  ///
  /// In bs, this message translates to:
  /// **'Podrška je odgovorila'**
  String get supportAlertAnswered;

  /// No description provided for @supportAlertNew.
  ///
  /// In bs, this message translates to:
  /// **'Novi upit za podršku'**
  String get supportAlertNew;

  /// No description provided for @supportAlertNewMessage.
  ///
  /// In bs, this message translates to:
  /// **'Nova poruka u upitu {number}'**
  String supportAlertNewMessage(String number);

  /// No description provided for @supportAlertOpen.
  ///
  /// In bs, this message translates to:
  /// **'Otvori'**
  String get supportAlertOpen;

  /// No description provided for @supportAdministration.
  ///
  /// In bs, this message translates to:
  /// **'Administracija'**
  String get supportAdministration;

  /// No description provided for @adminTitle.
  ///
  /// In bs, this message translates to:
  /// **'Administracija'**
  String get adminTitle;

  /// No description provided for @adminTeamSection.
  ///
  /// In bs, this message translates to:
  /// **'Tim'**
  String get adminTeamSection;

  /// No description provided for @adminNoAccess.
  ///
  /// In bs, this message translates to:
  /// **'Nemaš pristup'**
  String get adminNoAccess;

  /// No description provided for @adminNoAccessInfo.
  ///
  /// In bs, this message translates to:
  /// **'Ova stranica je samo za administratore.'**
  String get adminNoAccessInfo;

  /// No description provided for @adminEvents.
  ///
  /// In bs, this message translates to:
  /// **'Događaji'**
  String get adminEvents;

  /// No description provided for @adminEventsInfo.
  ///
  /// In bs, this message translates to:
  /// **'Dodaj i uredi događaje'**
  String get adminEventsInfo;

  /// No description provided for @adminFeesTitle.
  ///
  /// In bs, this message translates to:
  /// **'Servisna naknada'**
  String get adminFeesTitle;

  /// No description provided for @adminFeesSummary.
  ///
  /// In bs, this message translates to:
  /// **'Kupac {buyer} % · Prodavac {seller} %'**
  String adminFeesSummary(int buyer, int seller);

  /// No description provided for @adminTeamTitle.
  ///
  /// In bs, this message translates to:
  /// **'Tim i podrška'**
  String get adminTeamTitle;

  /// No description provided for @adminTeamInfo.
  ///
  /// In bs, this message translates to:
  /// **'Računi podrške i administratori'**
  String get adminTeamInfo;

  /// No description provided for @adminSupportInbox.
  ///
  /// In bs, this message translates to:
  /// **'Upiti podrške'**
  String get adminSupportInbox;

  /// No description provided for @adminSupportInboxInfo.
  ///
  /// In bs, this message translates to:
  /// **'Odgovori na upite korisnika'**
  String get adminSupportInboxInfo;

  /// No description provided for @adminBuyerFee.
  ///
  /// In bs, this message translates to:
  /// **'Naknada kupca'**
  String get adminBuyerFee;

  /// No description provided for @adminBuyerFeeInfo.
  ///
  /// In bs, this message translates to:
  /// **'Kupac je plaća povrh cijene karte.'**
  String get adminBuyerFeeInfo;

  /// No description provided for @adminSellerFee.
  ///
  /// In bs, this message translates to:
  /// **'Naknada prodavca'**
  String get adminSellerFee;

  /// No description provided for @adminSellerFeeInfo.
  ///
  /// In bs, this message translates to:
  /// **'Oduzima se od cijene karte koju prodavac dobija.'**
  String get adminSellerFeeInfo;

  /// No description provided for @adminFeeRange.
  ///
  /// In bs, this message translates to:
  /// **'Unesi cijeli broj od 0 do {max}'**
  String adminFeeRange(int max);

  /// No description provided for @adminFeeDecrease.
  ///
  /// In bs, this message translates to:
  /// **'Smanji'**
  String get adminFeeDecrease;

  /// No description provided for @adminFeeIncrease.
  ///
  /// In bs, this message translates to:
  /// **'Povećaj'**
  String get adminFeeIncrease;

  /// No description provided for @adminFeesCurrent.
  ///
  /// In bs, this message translates to:
  /// **'Trenutno: {summary}'**
  String adminFeesCurrent(String summary);

  /// No description provided for @adminFeesExample.
  ///
  /// In bs, this message translates to:
  /// **'Primjer za kartu od {price}'**
  String adminFeesExample(String price);

  /// No description provided for @adminTicketPrice.
  ///
  /// In bs, this message translates to:
  /// **'Cijena karte'**
  String get adminTicketPrice;

  /// No description provided for @adminBuyerPays.
  ///
  /// In bs, this message translates to:
  /// **'Kupac plaća'**
  String get adminBuyerPays;

  /// No description provided for @adminSellerReceives.
  ///
  /// In bs, this message translates to:
  /// **'Prodavac dobija'**
  String get adminSellerReceives;

  /// No description provided for @adminPlatformEarns.
  ///
  /// In bs, this message translates to:
  /// **'Stubswap zarađuje'**
  String get adminPlatformEarns;

  /// No description provided for @adminFeesNotice.
  ///
  /// In bs, this message translates to:
  /// **'Nova naknada vrijedi samo za ponude objavljene od sada. Postojeće ponude i narudžbe zadržavaju svoju naknadu.'**
  String get adminFeesNotice;

  /// No description provided for @adminFeesConfirmTitle.
  ///
  /// In bs, this message translates to:
  /// **'Promijeniti naknadu?'**
  String get adminFeesConfirmTitle;

  /// No description provided for @adminFeesSave.
  ///
  /// In bs, this message translates to:
  /// **'Sačuvaj naknadu'**
  String get adminFeesSave;

  /// No description provided for @adminFeesSaved.
  ///
  /// In bs, this message translates to:
  /// **'Naknada je sačuvana'**
  String get adminFeesSaved;

  /// No description provided for @adminRoleAdmin.
  ///
  /// In bs, this message translates to:
  /// **'Admin'**
  String get adminRoleAdmin;

  /// No description provided for @adminRoleSupport.
  ///
  /// In bs, this message translates to:
  /// **'Podrška'**
  String get adminRoleSupport;

  /// No description provided for @adminTeamMembers.
  ///
  /// In bs, this message translates to:
  /// **'Članovi tima'**
  String get adminTeamMembers;

  /// No description provided for @adminGrantedAt.
  ///
  /// In bs, this message translates to:
  /// **'Dodano {date}'**
  String adminGrantedAt(String date);

  /// No description provided for @adminYou.
  ///
  /// In bs, this message translates to:
  /// **'Ti'**
  String get adminYou;

  /// No description provided for @adminNoName.
  ///
  /// In bs, this message translates to:
  /// **'Bez imena'**
  String get adminNoName;

  /// No description provided for @adminRemoveSupport.
  ///
  /// In bs, this message translates to:
  /// **'Ukloni iz podrške'**
  String get adminRemoveSupport;

  /// No description provided for @adminRemoveSupportTitle.
  ///
  /// In bs, this message translates to:
  /// **'Ukloniti iz podrške?'**
  String get adminRemoveSupportTitle;

  /// No description provided for @adminRemoveSupportBody.
  ///
  /// In bs, this message translates to:
  /// **'{name} više neće vidjeti upite podrške. Korisnički račun ostaje.'**
  String adminRemoveSupportBody(String name);

  /// No description provided for @adminRemove.
  ///
  /// In bs, this message translates to:
  /// **'Ukloni'**
  String get adminRemove;

  /// No description provided for @adminSupportRemoved.
  ///
  /// In bs, this message translates to:
  /// **'Uklonjeno iz podrške'**
  String get adminSupportRemoved;

  /// No description provided for @adminAdminsInfo.
  ///
  /// In bs, this message translates to:
  /// **'Admine dodaješ samo u Firebase konzoli (Firestore → roles → dokument s ID-em korisnika, polje role = admin).'**
  String get adminAdminsInfo;

  /// No description provided for @adminAddSupport.
  ///
  /// In bs, this message translates to:
  /// **'Dodaj račun podrške'**
  String get adminAddSupport;

  /// No description provided for @adminAddSupportInfo.
  ///
  /// In bs, this message translates to:
  /// **'Traži po tačnoj e-mail adresi ili korisničkom imenu. Korisnik se mora barem jednom prijaviti u Stubswap.'**
  String get adminAddSupportInfo;

  /// No description provided for @adminFindUserLabel.
  ///
  /// In bs, this message translates to:
  /// **'E-mail ili korisničko ime'**
  String get adminFindUserLabel;

  /// No description provided for @adminFindUser.
  ///
  /// In bs, this message translates to:
  /// **'Traži'**
  String get adminFindUser;

  /// No description provided for @adminUserNotFound.
  ///
  /// In bs, this message translates to:
  /// **'Korisnik nije pronađen'**
  String get adminUserNotFound;

  /// No description provided for @adminUserNotFoundInfo.
  ///
  /// In bs, this message translates to:
  /// **'Provjeri adresu ili korisničko ime. Korisnik se mora barem jednom prijaviti.'**
  String get adminUserNotFoundInfo;

  /// No description provided for @adminMakeSupport.
  ///
  /// In bs, this message translates to:
  /// **'Dodaj kao podršku'**
  String get adminMakeSupport;

  /// No description provided for @adminSupportAdded.
  ///
  /// In bs, this message translates to:
  /// **'Dodano u podršku'**
  String get adminSupportAdded;

  /// No description provided for @adminAlreadyInTeam.
  ///
  /// In bs, this message translates to:
  /// **'Već je u timu kao {role}'**
  String adminAlreadyInTeam(String role);

  /// No description provided for @adminThatsYou.
  ///
  /// In bs, this message translates to:
  /// **'To si ti'**
  String get adminThatsYou;

  /// No description provided for @eventsOffer.
  ///
  /// In bs, this message translates to:
  /// **'od {price} · {count, plural, one{{count} karta} few{{count} karte} other{{count} karata}}'**
  String eventsOffer(String price, int count);

  /// No description provided for @eventsNoOffers.
  ///
  /// In bs, this message translates to:
  /// **'Još nema ponuda'**
  String get eventsNoOffers;

  /// No description provided for @eventsNoOffersInfo.
  ///
  /// In bs, this message translates to:
  /// **'Budite prvi koji prodaje karte za ovaj događaj.'**
  String get eventsNoOffersInfo;

  /// No description provided for @eventsSellForEvent.
  ///
  /// In bs, this message translates to:
  /// **'Prodaj karte za ovaj događaj'**
  String get eventsSellForEvent;

  /// No description provided for @eventsOffers.
  ///
  /// In bs, this message translates to:
  /// **'Ponude'**
  String get eventsOffers;

  /// No description provided for @eventsNotFound.
  ///
  /// In bs, this message translates to:
  /// **'Događaj nije pronađen'**
  String get eventsNotFound;

  /// No description provided for @eventsNotFoundInfo.
  ///
  /// In bs, this message translates to:
  /// **'Možda je uklonjen ili više nije dostupan.'**
  String get eventsNotFoundInfo;

  /// No description provided for @eventsIsOver.
  ///
  /// In bs, this message translates to:
  /// **'Ovaj događaj je prošao. Karte za njega se više ne prodaju.'**
  String get eventsIsOver;

  /// No description provided for @eventsPick.
  ///
  /// In bs, this message translates to:
  /// **'Odaberi događaj'**
  String get eventsPick;

  /// No description provided for @eventsPickRequired.
  ///
  /// In bs, this message translates to:
  /// **'Odaberite događaj'**
  String get eventsPickRequired;

  /// No description provided for @eventsChange.
  ///
  /// In bs, this message translates to:
  /// **'Promijeni'**
  String get eventsChange;

  /// No description provided for @eventsSearch.
  ///
  /// In bs, this message translates to:
  /// **'Pretraži događaje'**
  String get eventsSearch;

  /// No description provided for @eventsNoneToSell.
  ///
  /// In bs, this message translates to:
  /// **'Trenutno nema događaja'**
  String get eventsNoneToSell;

  /// No description provided for @eventsNoneToSellInfo.
  ///
  /// In bs, this message translates to:
  /// **'Događaje dodaje Stubswap tim. Čim se pojavi novi događaj, ovdje možete prodati karte za njega.'**
  String get eventsNoneToSellInfo;

  /// No description provided for @eventsAllOffers.
  ///
  /// In bs, this message translates to:
  /// **'Sve ponude za ovaj događaj'**
  String get eventsAllOffers;

  /// No description provided for @eventsAdminTitle.
  ///
  /// In bs, this message translates to:
  /// **'Događaji'**
  String get eventsAdminTitle;

  /// No description provided for @eventsAdminNoAccess.
  ///
  /// In bs, this message translates to:
  /// **'Nemate pristup'**
  String get eventsAdminNoAccess;

  /// No description provided for @eventsAdminNoAccessInfo.
  ///
  /// In bs, this message translates to:
  /// **'Ovu stranicu mogu otvoriti samo administratori.'**
  String get eventsAdminNoAccessInfo;

  /// No description provided for @eventsNew.
  ///
  /// In bs, this message translates to:
  /// **'Novi događaj'**
  String get eventsNew;

  /// No description provided for @eventsEdit.
  ///
  /// In bs, this message translates to:
  /// **'Uredi događaj'**
  String get eventsEdit;

  /// No description provided for @eventsHiddenBadge.
  ///
  /// In bs, this message translates to:
  /// **'Skriven'**
  String get eventsHiddenBadge;

  /// No description provided for @eventsPastBadge.
  ///
  /// In bs, this message translates to:
  /// **'Prošao'**
  String get eventsPastBadge;

  /// No description provided for @eventsUpcomingSection.
  ///
  /// In bs, this message translates to:
  /// **'Nadolazeći'**
  String get eventsUpcomingSection;

  /// No description provided for @eventsPastSection.
  ///
  /// In bs, this message translates to:
  /// **'Prošli'**
  String get eventsPastSection;

  /// No description provided for @eventsHide.
  ///
  /// In bs, this message translates to:
  /// **'Sakrij događaj'**
  String get eventsHide;

  /// No description provided for @eventsShow.
  ///
  /// In bs, this message translates to:
  /// **'Prikaži događaj'**
  String get eventsShow;

  /// No description provided for @eventsHideConfirm.
  ///
  /// In bs, this message translates to:
  /// **'Događaj se više neće prikazivati i za njega se neće moći objavljivati nove ponude. Postojeće ponude ostaju.'**
  String get eventsHideConfirm;

  /// No description provided for @eventsShowConfirm.
  ///
  /// In bs, this message translates to:
  /// **'Događaj će ponovo biti vidljiv svima i za njega će se moći prodavati karte.'**
  String get eventsShowConfirm;

  /// No description provided for @eventsHiddenToast.
  ///
  /// In bs, this message translates to:
  /// **'Događaj je sakriven'**
  String get eventsHiddenToast;

  /// No description provided for @eventsShownToast.
  ///
  /// In bs, this message translates to:
  /// **'Događaj je ponovo vidljiv'**
  String get eventsShownToast;

  /// No description provided for @eventsPicture.
  ///
  /// In bs, this message translates to:
  /// **'Slika'**
  String get eventsPicture;

  /// No description provided for @eventsPicturePick.
  ///
  /// In bs, this message translates to:
  /// **'Odaberi sliku'**
  String get eventsPicturePick;

  /// No description provided for @eventsPictureReplace.
  ///
  /// In bs, this message translates to:
  /// **'Zamijeni'**
  String get eventsPictureReplace;

  /// No description provided for @eventsPictureRemove.
  ///
  /// In bs, this message translates to:
  /// **'Ukloni'**
  String get eventsPictureRemove;

  /// No description provided for @eventsPictureHint.
  ///
  /// In bs, this message translates to:
  /// **'Slika se izrezuje na format 16:9.'**
  String get eventsPictureHint;

  /// No description provided for @eventsPictureError.
  ///
  /// In bs, this message translates to:
  /// **'Ova slika se ne može učitati'**
  String get eventsPictureError;

  /// No description provided for @eventsCreated.
  ///
  /// In bs, this message translates to:
  /// **'Događaj je kreiran'**
  String get eventsCreated;

  /// No description provided for @eventsListingsKeepData.
  ///
  /// In bs, this message translates to:
  /// **'Postojeće ponude zadržavaju podatke o događaju iz trenutka kada su objavljene.'**
  String get eventsListingsKeepData;

  /// No description provided for @eventsNameTooShort.
  ///
  /// In bs, this message translates to:
  /// **'Najmanje 2 znaka'**
  String get eventsNameTooShort;

  /// No description provided for @eventsNoneYet.
  ///
  /// In bs, this message translates to:
  /// **'Još nema događaja'**
  String get eventsNoneYet;

  /// No description provided for @eventsNoneYetInfo.
  ///
  /// In bs, this message translates to:
  /// **'Dodajte prvi događaj da bi prodavci mogli objavljivati ponude.'**
  String get eventsNoneYetInfo;

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
  /// **'Lozinka mora imati najmanje 8 znakova'**
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
  /// **'Lozinka je preslaba: najmanje 8 znakova'**
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

  /// No description provided for @errorPopupBlocked.
  ///
  /// In bs, this message translates to:
  /// **'Preglednik je blokirao prozor za Google prijavu. Dozvolite skočne prozore za ovu stranicu i pokušajte ponovo'**
  String get errorPopupBlocked;

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
  /// **'Kultura'**
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

  /// No description provided for @privacySecurity.
  ///
  /// In bs, this message translates to:
  /// **'Privatnost i sigurnost'**
  String get privacySecurity;

  /// No description provided for @privacy.
  ///
  /// In bs, this message translates to:
  /// **'Privatnost'**
  String get privacy;

  /// No description provided for @profileVisibility.
  ///
  /// In bs, this message translates to:
  /// **'Vidljivost profila'**
  String get profileVisibility;

  /// No description provided for @visibilityPublicInfo.
  ///
  /// In bs, this message translates to:
  /// **'Kupci vide tvoje ime, korisničko ime i fotografiju uz tvoje ponude.'**
  String get visibilityPublicInfo;

  /// No description provided for @visibilityPrivateInfo.
  ///
  /// In bs, this message translates to:
  /// **'Kupci vide samo da je prodavac verifikovan. Ime i fotografija ostaju skriveni.'**
  String get visibilityPrivateInfo;

  /// No description provided for @security.
  ///
  /// In bs, this message translates to:
  /// **'Sigurnost'**
  String get security;

  /// No description provided for @emailVerified.
  ///
  /// In bs, this message translates to:
  /// **'Potvrđeno'**
  String get emailVerified;

  /// No description provided for @emailNotVerified.
  ///
  /// In bs, this message translates to:
  /// **'Nije potvrđeno'**
  String get emailNotVerified;

  /// No description provided for @verifyEmailInfo.
  ///
  /// In bs, this message translates to:
  /// **'Potvrdi e-mail adresu prije prodaje karata, kako bi te kupci mogli kontaktirati.'**
  String get verifyEmailInfo;

  /// No description provided for @sendVerification.
  ///
  /// In bs, this message translates to:
  /// **'Pošalji link za potvrdu'**
  String get sendVerification;

  /// No description provided for @verificationSent.
  ///
  /// In bs, this message translates to:
  /// **'Link je poslan na {email}'**
  String verificationSent(String email);

  /// No description provided for @checkVerification.
  ///
  /// In bs, this message translates to:
  /// **'Već sam potvrdio/la'**
  String get checkVerification;

  /// No description provided for @signInMethods.
  ///
  /// In bs, this message translates to:
  /// **'Načini prijave'**
  String get signInMethods;

  /// No description provided for @methodPassword.
  ///
  /// In bs, this message translates to:
  /// **'E-mail i lozinka'**
  String get methodPassword;

  /// No description provided for @changePassword.
  ///
  /// In bs, this message translates to:
  /// **'Promijeni lozinku'**
  String get changePassword;

  /// No description provided for @currentPassword.
  ///
  /// In bs, this message translates to:
  /// **'Trenutna lozinka'**
  String get currentPassword;

  /// No description provided for @newPassword.
  ///
  /// In bs, this message translates to:
  /// **'Nova lozinka'**
  String get newPassword;

  /// No description provided for @passwordChanged.
  ///
  /// In bs, this message translates to:
  /// **'Lozinka je promijenjena'**
  String get passwordChanged;

  /// No description provided for @dangerZone.
  ///
  /// In bs, this message translates to:
  /// **'Opasna zona'**
  String get dangerZone;

  /// No description provided for @deleteAccount.
  ///
  /// In bs, this message translates to:
  /// **'Obriši račun'**
  String get deleteAccount;

  /// No description provided for @deleteAccountInfo.
  ///
  /// In bs, this message translates to:
  /// **'Tvoj profil i aktivne ponude bit će trajno uklonjeni. Narudžbe i isplate čuvamo onoliko dugo koliko zakon zahtijeva.'**
  String get deleteAccountInfo;

  /// No description provided for @deleteAccountConfirm.
  ///
  /// In bs, this message translates to:
  /// **'Potvrdi lozinkom'**
  String get deleteAccountConfirm;

  /// No description provided for @deleteAccountGoogle.
  ///
  /// In bs, this message translates to:
  /// **'Potvrdit ćeš brisanje svojim Google računom.'**
  String get deleteAccountGoogle;

  /// No description provided for @cancel.
  ///
  /// In bs, this message translates to:
  /// **'Odustani'**
  String get cancel;

  /// No description provided for @notifications.
  ///
  /// In bs, this message translates to:
  /// **'Obavještenja'**
  String get notifications;

  /// No description provided for @channels.
  ///
  /// In bs, this message translates to:
  /// **'Kanali'**
  String get channels;

  /// No description provided for @channelEmail.
  ///
  /// In bs, this message translates to:
  /// **'E-mail'**
  String get channelEmail;

  /// No description provided for @channelEmailInfo.
  ///
  /// In bs, this message translates to:
  /// **'Obavještenja na {email}'**
  String channelEmailInfo(String email);

  /// No description provided for @channelPush.
  ///
  /// In bs, this message translates to:
  /// **'Push na ovom uređaju'**
  String get channelPush;

  /// No description provided for @pushUnsupported.
  ///
  /// In bs, this message translates to:
  /// **'Ovaj preglednik ne podržava obavještenja. Na iPhoneu dodaj Stubswap na početni ekran.'**
  String get pushUnsupported;

  /// No description provided for @pushDenied.
  ///
  /// In bs, this message translates to:
  /// **'Obavještenja su blokirana u postavkama preglednika.'**
  String get pushDenied;

  /// No description provided for @sendTestNotification.
  ///
  /// In bs, this message translates to:
  /// **'Pošalji probno obavještenje'**
  String get sendTestNotification;

  /// No description provided for @testNotificationTitle.
  ///
  /// In bs, this message translates to:
  /// **'Stubswap obavještenja rade'**
  String get testNotificationTitle;

  /// No description provided for @testNotificationBody.
  ///
  /// In bs, this message translates to:
  /// **'Ovako ćeš saznati kada se tvoje karte prodaju.'**
  String get testNotificationBody;

  /// No description provided for @buying.
  ///
  /// In bs, this message translates to:
  /// **'Kupovina'**
  String get buying;

  /// No description provided for @selling.
  ///
  /// In bs, this message translates to:
  /// **'Prodaja'**
  String get selling;

  /// No description provided for @other.
  ///
  /// In bs, this message translates to:
  /// **'Ostalo'**
  String get other;

  /// No description provided for @notifOrderUpdates.
  ///
  /// In bs, this message translates to:
  /// **'Status narudžbe'**
  String get notifOrderUpdates;

  /// No description provided for @notifOrderUpdatesInfo.
  ///
  /// In bs, this message translates to:
  /// **'Plaćanje, isporuka karata, povrat novca'**
  String get notifOrderUpdatesInfo;

  /// No description provided for @notifEventReminders.
  ///
  /// In bs, this message translates to:
  /// **'Podsjetnici za događaje'**
  String get notifEventReminders;

  /// No description provided for @notifEventRemindersInfo.
  ///
  /// In bs, this message translates to:
  /// **'Dan prije događaja za koji imaš karte'**
  String get notifEventRemindersInfo;

  /// No description provided for @notifPriceAlerts.
  ///
  /// In bs, this message translates to:
  /// **'Upozorenja o cijenama'**
  String get notifPriceAlerts;

  /// No description provided for @notifPriceAlertsInfo.
  ///
  /// In bs, this message translates to:
  /// **'Kada cijene padnu za događaje koje pratiš'**
  String get notifPriceAlertsInfo;

  /// No description provided for @notifSaleUpdates.
  ///
  /// In bs, this message translates to:
  /// **'Prodane karte'**
  String get notifSaleUpdates;

  /// No description provided for @notifSaleUpdatesInfo.
  ///
  /// In bs, this message translates to:
  /// **'Kada se karte prodaju i trebaš ih poslati'**
  String get notifSaleUpdatesInfo;

  /// No description provided for @notifPayoutUpdates.
  ///
  /// In bs, this message translates to:
  /// **'Isplate'**
  String get notifPayoutUpdates;

  /// No description provided for @notifPayoutUpdatesInfo.
  ///
  /// In bs, this message translates to:
  /// **'Planirane, poslane ili neuspjele isplate'**
  String get notifPayoutUpdatesInfo;

  /// No description provided for @notifNewsletter.
  ///
  /// In bs, this message translates to:
  /// **'Novosti i ponude'**
  String get notifNewsletter;

  /// No description provided for @notifNewsletterInfo.
  ///
  /// In bs, this message translates to:
  /// **'Povremeno, o novim događajima'**
  String get notifNewsletterInfo;

  /// No description provided for @sellTitle.
  ///
  /// In bs, this message translates to:
  /// **'Prodaj karte'**
  String get sellTitle;

  /// No description provided for @event.
  ///
  /// In bs, this message translates to:
  /// **'Događaj'**
  String get event;

  /// No description provided for @eventName.
  ///
  /// In bs, this message translates to:
  /// **'Naziv događaja'**
  String get eventName;

  /// No description provided for @venue.
  ///
  /// In bs, this message translates to:
  /// **'Mjesto održavanja'**
  String get venue;

  /// No description provided for @city.
  ///
  /// In bs, this message translates to:
  /// **'Grad'**
  String get city;

  /// No description provided for @dateTime.
  ///
  /// In bs, this message translates to:
  /// **'Datum i vrijeme'**
  String get dateTime;

  /// No description provided for @pickDate.
  ///
  /// In bs, this message translates to:
  /// **'Odaberi datum'**
  String get pickDate;

  /// No description provided for @category.
  ///
  /// In bs, this message translates to:
  /// **'Kategorija'**
  String get category;

  /// No description provided for @tickets.
  ///
  /// In bs, this message translates to:
  /// **'Karte'**
  String get tickets;

  /// No description provided for @ticketType.
  ///
  /// In bs, this message translates to:
  /// **'Vrsta karte'**
  String get ticketType;

  /// No description provided for @ticketEticket.
  ///
  /// In bs, this message translates to:
  /// **'E-karta'**
  String get ticketEticket;

  /// No description provided for @ticketMobile.
  ///
  /// In bs, this message translates to:
  /// **'Mobilna'**
  String get ticketMobile;

  /// No description provided for @ticketPaper.
  ///
  /// In bs, this message translates to:
  /// **'Papirna'**
  String get ticketPaper;

  /// No description provided for @quantity.
  ///
  /// In bs, this message translates to:
  /// **'Količina'**
  String get quantity;

  /// No description provided for @section.
  ///
  /// In bs, this message translates to:
  /// **'Sektor'**
  String get section;

  /// No description provided for @row.
  ///
  /// In bs, this message translates to:
  /// **'Red'**
  String get row;

  /// No description provided for @seats.
  ///
  /// In bs, this message translates to:
  /// **'Sjedišta'**
  String get seats;

  /// No description provided for @optional.
  ///
  /// In bs, this message translates to:
  /// **'neobavezno'**
  String get optional;

  /// No description provided for @price.
  ///
  /// In bs, this message translates to:
  /// **'Cijena'**
  String get price;

  /// No description provided for @pricePerTicket.
  ///
  /// In bs, this message translates to:
  /// **'Cijena po karti'**
  String get pricePerTicket;

  /// No description provided for @buyerPays.
  ///
  /// In bs, this message translates to:
  /// **'Kupac plaća (s naknadom {percent}%)'**
  String buyerPays(String percent);

  /// No description provided for @youReceive.
  ///
  /// In bs, this message translates to:
  /// **'Dobijaš po karti (naknada {percent}%)'**
  String youReceive(String percent);

  /// No description provided for @totalPayout.
  ///
  /// In bs, this message translates to:
  /// **'Ukupna isplata'**
  String get totalPayout;

  /// No description provided for @noteLabel.
  ///
  /// In bs, this message translates to:
  /// **'Napomena za kupca'**
  String get noteLabel;

  /// No description provided for @publishListing.
  ///
  /// In bs, this message translates to:
  /// **'Objavi ponudu'**
  String get publishListing;

  /// No description provided for @listingPublished.
  ///
  /// In bs, this message translates to:
  /// **'Ponuda je objavljena'**
  String get listingPublished;

  /// No description provided for @required.
  ///
  /// In bs, this message translates to:
  /// **'Obavezno polje'**
  String get required;

  /// No description provided for @dateInPast.
  ///
  /// In bs, this message translates to:
  /// **'Datum mora biti u budućnosti'**
  String get dateInPast;

  /// No description provided for @priceInvalid.
  ///
  /// In bs, this message translates to:
  /// **'Unesite ispravnu cijenu'**
  String get priceInvalid;

  /// No description provided for @verifyBeforeSelling.
  ///
  /// In bs, this message translates to:
  /// **'Potvrdi e-mail adresu da bi kupci mogli vjerovati tvojim ponudama.'**
  String get verifyBeforeSelling;

  /// No description provided for @verifyNow.
  ///
  /// In bs, this message translates to:
  /// **'Potvrdi'**
  String get verifyNow;

  /// No description provided for @myListings.
  ///
  /// In bs, this message translates to:
  /// **'Moje ponude'**
  String get myListings;

  /// No description provided for @filterAll.
  ///
  /// In bs, this message translates to:
  /// **'Sve'**
  String get filterAll;

  /// No description provided for @statusActive.
  ///
  /// In bs, this message translates to:
  /// **'Aktivna'**
  String get statusActive;

  /// No description provided for @statusReserved.
  ///
  /// In bs, this message translates to:
  /// **'Rezervisana'**
  String get statusReserved;

  /// No description provided for @statusSoldOut.
  ///
  /// In bs, this message translates to:
  /// **'Rasprodana'**
  String get statusSoldOut;

  /// No description provided for @statusExpired.
  ///
  /// In bs, this message translates to:
  /// **'Istekla'**
  String get statusExpired;

  /// No description provided for @statusWithdrawn.
  ///
  /// In bs, this message translates to:
  /// **'Povučena'**
  String get statusWithdrawn;

  /// No description provided for @ended.
  ///
  /// In bs, this message translates to:
  /// **'Završene'**
  String get ended;

  /// No description provided for @noListings.
  ///
  /// In bs, this message translates to:
  /// **'Još nemaš ponuda'**
  String get noListings;

  /// No description provided for @noListingsInfo.
  ///
  /// In bs, this message translates to:
  /// **'Imaš karte koje ne trebaš? Prodaj ih za nekoliko minuta.'**
  String get noListingsInfo;

  /// No description provided for @ticketsLeft.
  ///
  /// In bs, this message translates to:
  /// **'{count} od {total} dostupno'**
  String ticketsLeft(String count, String total);

  /// No description provided for @ticketsCount.
  ///
  /// In bs, this message translates to:
  /// **'{count} kom.'**
  String ticketsCount(String count);

  /// No description provided for @perTicket.
  ///
  /// In bs, this message translates to:
  /// **'po karti'**
  String get perTicket;

  /// No description provided for @listingDetails.
  ///
  /// In bs, this message translates to:
  /// **'Detalji ponude'**
  String get listingDetails;

  /// No description provided for @editPrice.
  ///
  /// In bs, this message translates to:
  /// **'Promijeni cijenu'**
  String get editPrice;

  /// No description provided for @withdrawListing.
  ///
  /// In bs, this message translates to:
  /// **'Povuci ponudu'**
  String get withdrawListing;

  /// No description provided for @withdrawConfirm.
  ///
  /// In bs, this message translates to:
  /// **'Ponuda više neće biti vidljiva kupcima. Nastaviti?'**
  String get withdrawConfirm;

  /// No description provided for @listingWithdrawn.
  ///
  /// In bs, this message translates to:
  /// **'Ponuda je povučena'**
  String get listingWithdrawn;

  /// No description provided for @listingNotFound.
  ///
  /// In bs, this message translates to:
  /// **'Ponuda nije pronađena'**
  String get listingNotFound;

  /// No description provided for @yourListing.
  ///
  /// In bs, this message translates to:
  /// **'Tvoja ponuda'**
  String get yourListing;

  /// No description provided for @buyTickets.
  ///
  /// In bs, this message translates to:
  /// **'Kupi karte'**
  String get buyTickets;

  /// No description provided for @total.
  ///
  /// In bs, this message translates to:
  /// **'Ukupno'**
  String get total;

  /// No description provided for @serviceFee.
  ///
  /// In bs, this message translates to:
  /// **'Naknada za uslugu'**
  String get serviceFee;

  /// No description provided for @checkoutSoonTitle.
  ///
  /// In bs, this message translates to:
  /// **'Plaćanje uskoro'**
  String get checkoutSoonTitle;

  /// No description provided for @checkoutSoonInfo.
  ///
  /// In bs, this message translates to:
  /// **'Sigurno plaćanje s garancijom za kupce je u izradi. Ponudu možeš već pregledati.'**
  String get checkoutSoonInfo;

  /// No description provided for @buyerProtection.
  ///
  /// In bs, this message translates to:
  /// **'Garancija za kupce: dobijaš važeće karte na vrijeme ili povrat novca.'**
  String get buyerProtection;

  /// No description provided for @sellerVerified.
  ///
  /// In bs, this message translates to:
  /// **'Verifikovani prodavac'**
  String get sellerVerified;

  /// No description provided for @searchNoResults.
  ///
  /// In bs, this message translates to:
  /// **'Nema rezultata za „{query}”'**
  String searchNoResults(String query);

  /// No description provided for @upcomingEvents.
  ///
  /// In bs, this message translates to:
  /// **'Nadolazeći događaji'**
  String get upcomingEvents;

  /// No description provided for @fromPrice.
  ///
  /// In bs, this message translates to:
  /// **'od {price}'**
  String fromPrice(String price);

  /// No description provided for @ok.
  ///
  /// In bs, this message translates to:
  /// **'U redu'**
  String get ok;

  /// No description provided for @orderPendingPayment.
  ///
  /// In bs, this message translates to:
  /// **'Čeka plaćanje'**
  String get orderPendingPayment;

  /// No description provided for @orderPaid.
  ///
  /// In bs, this message translates to:
  /// **'Plaćeno'**
  String get orderPaid;

  /// No description provided for @orderTicketsSent.
  ///
  /// In bs, this message translates to:
  /// **'Karte poslane'**
  String get orderTicketsSent;

  /// No description provided for @orderCompleted.
  ///
  /// In bs, this message translates to:
  /// **'Završeno'**
  String get orderCompleted;

  /// No description provided for @orderCancelled.
  ///
  /// In bs, this message translates to:
  /// **'Otkazano'**
  String get orderCancelled;

  /// No description provided for @orderRefunded.
  ///
  /// In bs, this message translates to:
  /// **'Novac vraćen'**
  String get orderRefunded;

  /// No description provided for @orderDisputed.
  ///
  /// In bs, this message translates to:
  /// **'U rješavanju'**
  String get orderDisputed;

  /// No description provided for @payoutPending.
  ///
  /// In bs, this message translates to:
  /// **'Čeka događaj'**
  String get payoutPending;

  /// No description provided for @payoutScheduled.
  ///
  /// In bs, this message translates to:
  /// **'Zakazano'**
  String get payoutScheduled;

  /// No description provided for @payoutProcessing.
  ///
  /// In bs, this message translates to:
  /// **'U obradi'**
  String get payoutProcessing;

  /// No description provided for @payoutPaid.
  ///
  /// In bs, this message translates to:
  /// **'Isplaćeno'**
  String get payoutPaid;

  /// No description provided for @payoutFailed.
  ///
  /// In bs, this message translates to:
  /// **'Neuspjelo'**
  String get payoutFailed;

  /// No description provided for @buyerNextPendingPayment.
  ///
  /// In bs, this message translates to:
  /// **'Završi plaćanje da rezervišeš karte.'**
  String get buyerNextPendingPayment;

  /// No description provided for @buyerNextPaid.
  ///
  /// In bs, this message translates to:
  /// **'Prodavac šalje karte. Dobit ćeš ih najkasnije prije događaja.'**
  String get buyerNextPaid;

  /// No description provided for @buyerNextTicketsSent.
  ///
  /// In bs, this message translates to:
  /// **'Karte su ti poslane. Provjeri e-mail ili aplikaciju organizatora.'**
  String get buyerNextTicketsSent;

  /// No description provided for @buyerNextCompleted.
  ///
  /// In bs, this message translates to:
  /// **'Uživaj u događaju!'**
  String get buyerNextCompleted;

  /// No description provided for @buyerNextCancelled.
  ///
  /// In bs, this message translates to:
  /// **'Narudžba je otkazana. Ništa nije naplaćeno.'**
  String get buyerNextCancelled;

  /// No description provided for @buyerNextRefunded.
  ///
  /// In bs, this message translates to:
  /// **'Iznos je vraćen na tvoj način plaćanja.'**
  String get buyerNextRefunded;

  /// No description provided for @buyerNextDisputed.
  ///
  /// In bs, this message translates to:
  /// **'Naš tim provjerava narudžbu i javit će ti se.'**
  String get buyerNextDisputed;

  /// No description provided for @sellerNextPendingPayment.
  ///
  /// In bs, this message translates to:
  /// **'Kupac plaća. Karte su rezervisane.'**
  String get sellerNextPendingPayment;

  /// No description provided for @sellerNextPaid.
  ///
  /// In bs, this message translates to:
  /// **'Pošalji karte kupcu što prije.'**
  String get sellerNextPaid;

  /// No description provided for @sellerNextTicketsSent.
  ///
  /// In bs, this message translates to:
  /// **'Isplata slijedi nakon događaja.'**
  String get sellerNextTicketsSent;

  /// No description provided for @sellerNextCompleted.
  ///
  /// In bs, this message translates to:
  /// **'Prodaja je završena. Pogledaj isplate.'**
  String get sellerNextCompleted;

  /// No description provided for @sellerNextCancelled.
  ///
  /// In bs, this message translates to:
  /// **'Narudžba je otkazana. Karte su ponovo u prodaji.'**
  String get sellerNextCancelled;

  /// No description provided for @sellerNextRefunded.
  ///
  /// In bs, this message translates to:
  /// **'Kupcu je vraćen novac. Za ovu prodaju nema isplate.'**
  String get sellerNextRefunded;

  /// No description provided for @sellerNextDisputed.
  ///
  /// In bs, this message translates to:
  /// **'Kupac je prijavio problem. Isplata čeka rješenje.'**
  String get sellerNextDisputed;

  /// No description provided for @payoutNextPending.
  ///
  /// In bs, this message translates to:
  /// **'Novac se oslobađa nakon održanog događaja.'**
  String get payoutNextPending;

  /// No description provided for @payoutNextScheduled.
  ///
  /// In bs, this message translates to:
  /// **'Isplata je u sljedećem krugu isplata.'**
  String get payoutNextScheduled;

  /// No description provided for @payoutNextProcessing.
  ///
  /// In bs, this message translates to:
  /// **'Banka obrađuje uplatu, obično 1–3 radna dana.'**
  String get payoutNextProcessing;

  /// No description provided for @payoutNextPaid.
  ///
  /// In bs, this message translates to:
  /// **'Novac je na tvom računu.'**
  String get payoutNextPaid;

  /// No description provided for @payoutNextFailed.
  ///
  /// In bs, this message translates to:
  /// **'Provjeri način isplate. Pokušat ćemo ponovo nakon izmjene.'**
  String get payoutNextFailed;

  /// No description provided for @invoice.
  ///
  /// In bs, this message translates to:
  /// **'Račun'**
  String get invoice;

  /// No description provided for @orderNumber.
  ///
  /// In bs, this message translates to:
  /// **'Broj narudžbe'**
  String get orderNumber;

  /// No description provided for @orderDate.
  ///
  /// In bs, this message translates to:
  /// **'Datum narudžbe'**
  String get orderDate;

  /// No description provided for @paymentMethod.
  ///
  /// In bs, this message translates to:
  /// **'Način plaćanja'**
  String get paymentMethod;

  /// No description provided for @saleAmount.
  ///
  /// In bs, this message translates to:
  /// **'Iznos prodaje'**
  String get saleAmount;

  /// No description provided for @sellerFeeLabel.
  ///
  /// In bs, this message translates to:
  /// **'Naknada prodavca'**
  String get sellerFeeLabel;

  /// No description provided for @yourEarnings.
  ///
  /// In bs, this message translates to:
  /// **'Tvoja zarada'**
  String get yourEarnings;

  /// No description provided for @copied.
  ///
  /// In bs, this message translates to:
  /// **'Kopirano'**
  String get copied;

  /// No description provided for @copy.
  ///
  /// In bs, this message translates to:
  /// **'Kopiraj'**
  String get copy;

  /// No description provided for @whatsNext.
  ///
  /// In bs, this message translates to:
  /// **'Šta slijedi'**
  String get whatsNext;

  /// No description provided for @statusHistory.
  ///
  /// In bs, this message translates to:
  /// **'Tok statusa'**
  String get statusHistory;

  /// No description provided for @orderDetails.
  ///
  /// In bs, this message translates to:
  /// **'Detalji narudžbe'**
  String get orderDetails;

  /// No description provided for @saleDetails.
  ///
  /// In bs, this message translates to:
  /// **'Detalji prodaje'**
  String get saleDetails;

  /// No description provided for @payoutDetails.
  ///
  /// In bs, this message translates to:
  /// **'Detalji isplate'**
  String get payoutDetails;

  /// No description provided for @purchases.
  ///
  /// In bs, this message translates to:
  /// **'Kupovine i računi'**
  String get purchases;

  /// No description provided for @sales.
  ///
  /// In bs, this message translates to:
  /// **'Prodaje'**
  String get sales;

  /// No description provided for @payouts.
  ///
  /// In bs, this message translates to:
  /// **'Isplate'**
  String get payouts;

  /// No description provided for @payoutMethod.
  ///
  /// In bs, this message translates to:
  /// **'Način isplate'**
  String get payoutMethod;

  /// No description provided for @noPurchases.
  ///
  /// In bs, this message translates to:
  /// **'Još nemaš kupovina'**
  String get noPurchases;

  /// No description provided for @noPurchasesInfo.
  ///
  /// In bs, this message translates to:
  /// **'Kupljene karte i računi pojavit će se ovdje.'**
  String get noPurchasesInfo;

  /// No description provided for @noSales.
  ///
  /// In bs, this message translates to:
  /// **'Još nemaš prodaja'**
  String get noSales;

  /// No description provided for @noSalesInfo.
  ///
  /// In bs, this message translates to:
  /// **'Kada neko kupi tvoje karte, vidjet ćeš to ovdje.'**
  String get noSalesInfo;

  /// No description provided for @noPayouts.
  ///
  /// In bs, this message translates to:
  /// **'Još nema isplata'**
  String get noPayouts;

  /// No description provided for @noPayoutsInfo.
  ///
  /// In bs, this message translates to:
  /// **'Novac od prodaje stiže na tvoj račun nakon događaja.'**
  String get noPayoutsInfo;

  /// No description provided for @filterInProgress.
  ///
  /// In bs, this message translates to:
  /// **'U toku'**
  String get filterInProgress;

  /// No description provided for @filterCompleted.
  ///
  /// In bs, this message translates to:
  /// **'Završene'**
  String get filterCompleted;

  /// No description provided for @filterCancelled.
  ///
  /// In bs, this message translates to:
  /// **'Otkazane'**
  String get filterCancelled;

  /// No description provided for @payoutsUpcoming.
  ///
  /// In bs, this message translates to:
  /// **'Uskoro na računu'**
  String get payoutsUpcoming;

  /// No description provided for @payoutsPaidTotal.
  ///
  /// In bs, this message translates to:
  /// **'Isplaćeno ukupno'**
  String get payoutsPaidTotal;

  /// No description provided for @expectedOn.
  ///
  /// In bs, this message translates to:
  /// **'Očekivano {date}'**
  String expectedOn(String date);

  /// No description provided for @payoutOrders.
  ///
  /// In bs, this message translates to:
  /// **'Narudžbe u isplati'**
  String get payoutOrders;

  /// No description provided for @failureReason.
  ///
  /// In bs, this message translates to:
  /// **'Razlog'**
  String get failureReason;

  /// No description provided for @setUpPayout.
  ///
  /// In bs, this message translates to:
  /// **'Dodaj način isplate'**
  String get setUpPayout;

  /// No description provided for @payoutMethodMissing.
  ///
  /// In bs, this message translates to:
  /// **'Dodaj bankovni račun da bi primio novac od prodaje.'**
  String get payoutMethodMissing;

  /// No description provided for @accountHolder.
  ///
  /// In bs, this message translates to:
  /// **'Vlasnik računa'**
  String get accountHolder;

  /// No description provided for @iban.
  ///
  /// In bs, this message translates to:
  /// **'IBAN'**
  String get iban;

  /// No description provided for @ibanInvalid.
  ///
  /// In bs, this message translates to:
  /// **'Neispravan IBAN'**
  String get ibanInvalid;

  /// No description provided for @payoutMethodInfo.
  ///
  /// In bs, this message translates to:
  /// **'Isplate stižu na ovaj račun 3–5 radnih dana nakon događaja.'**
  String get payoutMethodInfo;

  /// No description provided for @payoutMethodSaved.
  ///
  /// In bs, this message translates to:
  /// **'Način isplate je sačuvan'**
  String get payoutMethodSaved;

  /// No description provided for @change.
  ///
  /// In bs, this message translates to:
  /// **'Promijeni'**
  String get change;

  /// No description provided for @buyer.
  ///
  /// In bs, this message translates to:
  /// **'Kupac'**
  String get buyer;

  /// No description provided for @support.
  ///
  /// In bs, this message translates to:
  /// **'Podrška'**
  String get support;

  /// No description provided for @helpCenter.
  ///
  /// In bs, this message translates to:
  /// **'Centar za pomoć'**
  String get helpCenter;

  /// No description provided for @contactSupport.
  ///
  /// In bs, this message translates to:
  /// **'Kontaktiraj podršku'**
  String get contactSupport;

  /// No description provided for @about.
  ///
  /// In bs, this message translates to:
  /// **'O aplikaciji'**
  String get about;

  /// No description provided for @aboutText.
  ///
  /// In bs, this message translates to:
  /// **'Stubswap je sigurno tržište za kupovinu i prodaju karata za događaje.'**
  String get aboutText;

  /// No description provided for @getHelpOrder.
  ///
  /// In bs, this message translates to:
  /// **'Pomoć oko ove narudžbe'**
  String get getHelpOrder;

  /// No description provided for @getHelpPayout.
  ///
  /// In bs, this message translates to:
  /// **'Pomoć oko ove isplate'**
  String get getHelpPayout;

  /// No description provided for @topic.
  ///
  /// In bs, this message translates to:
  /// **'Tema'**
  String get topic;

  /// No description provided for @topicOrder.
  ///
  /// In bs, this message translates to:
  /// **'Kupovina'**
  String get topicOrder;

  /// No description provided for @topicSale.
  ///
  /// In bs, this message translates to:
  /// **'Prodaja'**
  String get topicSale;

  /// No description provided for @topicPayout.
  ///
  /// In bs, this message translates to:
  /// **'Isplata'**
  String get topicPayout;

  /// No description provided for @topicAccount.
  ///
  /// In bs, this message translates to:
  /// **'Račun'**
  String get topicAccount;

  /// No description provided for @topicOther.
  ///
  /// In bs, this message translates to:
  /// **'Ostalo'**
  String get topicOther;

  /// No description provided for @reference.
  ///
  /// In bs, this message translates to:
  /// **'Broj narudžbe ili ponude'**
  String get reference;

  /// No description provided for @message.
  ///
  /// In bs, this message translates to:
  /// **'Poruka'**
  String get message;

  /// No description provided for @messageHint.
  ///
  /// In bs, this message translates to:
  /// **'Opiši šta se desilo. Što više detalja, brže pomažemo.'**
  String get messageHint;

  /// No description provided for @messageTooShort.
  ///
  /// In bs, this message translates to:
  /// **'Napiši barem 20 znakova'**
  String get messageTooShort;

  /// No description provided for @send.
  ///
  /// In bs, this message translates to:
  /// **'Pošalji'**
  String get send;

  /// No description provided for @requestSent.
  ///
  /// In bs, this message translates to:
  /// **'Zahtjev je poslan'**
  String get requestSent;

  /// No description provided for @requestSentInfo.
  ///
  /// In bs, this message translates to:
  /// **'Broj tvog zahtjeva je {number}. Odgovorit ćemo na {email}, obično u roku od 24 sata.'**
  String requestSentInfo(String number, String email);

  /// No description provided for @done.
  ///
  /// In bs, this message translates to:
  /// **'Gotovo'**
  String get done;

  /// No description provided for @stillNeedHelp.
  ///
  /// In bs, this message translates to:
  /// **'Nisi pronašao odgovor?'**
  String get stillNeedHelp;

  /// No description provided for @faqBuySafeQ.
  ///
  /// In bs, this message translates to:
  /// **'Da li je kupovina na Stubswapu sigurna?'**
  String get faqBuySafeQ;

  /// No description provided for @faqBuySafeA.
  ///
  /// In bs, this message translates to:
  /// **'Da. Novac zadržavamo dok ne dobiješ karte. Ako karte ne stignu na vrijeme ili nisu važeće, vraćamo ti novac.'**
  String get faqBuySafeA;

  /// No description provided for @faqWhenTicketsQ.
  ///
  /// In bs, this message translates to:
  /// **'Kada ću dobiti karte?'**
  String get faqWhenTicketsQ;

  /// No description provided for @faqWhenTicketsA.
  ///
  /// In bs, this message translates to:
  /// **'Prodavac ih šalje nakon plaćanja, najkasnije prije događaja. Status vidiš u Kupovine i računi.'**
  String get faqWhenTicketsA;

  /// No description provided for @faqFeesQ.
  ///
  /// In bs, this message translates to:
  /// **'Koje su naknade?'**
  String get faqFeesQ;

  /// No description provided for @faqFeesA.
  ///
  /// In bs, this message translates to:
  /// **'Kupac plaća naknadu za uslugu od {buyer}% na cijenu karte. Prodavcu zadržavamo {seller}% od prodajne cijene.'**
  String faqFeesA(String buyer, String seller);

  /// No description provided for @faqPayoutWhenQ.
  ///
  /// In bs, this message translates to:
  /// **'Kada dobijam novac od prodaje?'**
  String get faqPayoutWhenQ;

  /// No description provided for @faqPayoutWhenA.
  ///
  /// In bs, this message translates to:
  /// **'Nakon održanog događaja isplata se zakazuje i stiže na tvoj IBAN za 3–5 radnih dana.'**
  String get faqPayoutWhenA;

  /// No description provided for @faqSendTicketsQ.
  ///
  /// In bs, this message translates to:
  /// **'Kako da pošaljem karte kupcu?'**
  String get faqSendTicketsQ;

  /// No description provided for @faqSendTicketsA.
  ///
  /// In bs, this message translates to:
  /// **'E-karte i mobilne karte prenosiš preko organizatora na e-mail kupca. Papirne karte šalješ preporučeno. Status ažuriraj odmah nakon slanja.'**
  String get faqSendTicketsA;

  /// No description provided for @faqCancelQ.
  ///
  /// In bs, this message translates to:
  /// **'Šta ako je događaj otkazan?'**
  String get faqCancelQ;

  /// No description provided for @faqCancelA.
  ///
  /// In bs, this message translates to:
  /// **'Kupci dobijaju puni povrat novca, a prodaje se poništavaju bez naknade za prodavca.'**
  String get faqCancelA;

  /// No description provided for @checkout.
  ///
  /// In bs, this message translates to:
  /// **'Plaćanje'**
  String get checkout;

  /// No description provided for @payAmount.
  ///
  /// In bs, this message translates to:
  /// **'Plati {amount}'**
  String payAmount(String amount);

  /// No description provided for @testModeBadge.
  ///
  /// In bs, this message translates to:
  /// **'Testni način · bez pravog novca'**
  String get testModeBadge;

  /// No description provided for @stripeSimulator.
  ///
  /// In bs, this message translates to:
  /// **'Stripe simulator'**
  String get stripeSimulator;

  /// No description provided for @simulatorInfo.
  ///
  /// In bs, this message translates to:
  /// **'Simulacija plaćanja. Kasnije je zamjenjuje pravi Stripe.'**
  String get simulatorInfo;

  /// No description provided for @cardNumber.
  ///
  /// In bs, this message translates to:
  /// **'Broj kartice'**
  String get cardNumber;

  /// No description provided for @cardExpiry.
  ///
  /// In bs, this message translates to:
  /// **'Datum isteka'**
  String get cardExpiry;

  /// No description provided for @cardCvc.
  ///
  /// In bs, this message translates to:
  /// **'CVC'**
  String get cardCvc;

  /// No description provided for @simulateSuccess.
  ///
  /// In bs, this message translates to:
  /// **'Plaćanje uspješno'**
  String get simulateSuccess;

  /// No description provided for @simulateSuccessInfo.
  ///
  /// In bs, this message translates to:
  /// **'Isključi da simuliraš odbijenu karticu.'**
  String get simulateSuccessInfo;

  /// No description provided for @declineReason.
  ///
  /// In bs, this message translates to:
  /// **'Razlog odbijanja'**
  String get declineReason;

  /// No description provided for @failCardDeclined.
  ///
  /// In bs, this message translates to:
  /// **'Kartica odbijena'**
  String get failCardDeclined;

  /// No description provided for @failInsufficientFunds.
  ///
  /// In bs, this message translates to:
  /// **'Nedovoljno sredstava'**
  String get failInsufficientFunds;

  /// No description provided for @failExpiredCard.
  ///
  /// In bs, this message translates to:
  /// **'Kartica je istekla'**
  String get failExpiredCard;

  /// No description provided for @failProcessingError.
  ///
  /// In bs, this message translates to:
  /// **'Greška pri obradi'**
  String get failProcessingError;

  /// No description provided for @failSoldOut.
  ///
  /// In bs, this message translates to:
  /// **'Karte su u međuvremenu prodane'**
  String get failSoldOut;

  /// No description provided for @processingPayment.
  ///
  /// In bs, this message translates to:
  /// **'Obrada plaćanja…'**
  String get processingPayment;

  /// No description provided for @paymentSucceeded.
  ///
  /// In bs, this message translates to:
  /// **'Plaćanje uspješno'**
  String get paymentSucceeded;

  /// No description provided for @paymentFailedTitle.
  ///
  /// In bs, this message translates to:
  /// **'Plaćanje nije uspjelo'**
  String get paymentFailedTitle;

  /// No description provided for @paymentFailedInfo.
  ///
  /// In bs, this message translates to:
  /// **'{reason}. Ništa nije naplaćeno. Pokušaj ponovo ili koristi drugu karticu.'**
  String paymentFailedInfo(String reason);

  /// No description provided for @tryAgain.
  ///
  /// In bs, this message translates to:
  /// **'Pokušaj ponovo'**
  String get tryAgain;

  /// No description provided for @payNow.
  ///
  /// In bs, this message translates to:
  /// **'Plati sada'**
  String get payNow;

  /// No description provided for @markTicketsSent.
  ///
  /// In bs, this message translates to:
  /// **'Označi karte kao poslane'**
  String get markTicketsSent;

  /// No description provided for @ticketsMarkedSent.
  ///
  /// In bs, this message translates to:
  /// **'Kupac je obaviješten'**
  String get ticketsMarkedSent;

  /// No description provided for @buyerEmail.
  ///
  /// In bs, this message translates to:
  /// **'Karte stižu na'**
  String get buyerEmail;

  /// No description provided for @notAvailableAnymore.
  ///
  /// In bs, this message translates to:
  /// **'Ova ponuda više nije dostupna'**
  String get notAvailableAnymore;

  /// No description provided for @payoutRequiredTitle.
  ///
  /// In bs, this message translates to:
  /// **'Prvo dodaj način isplate'**
  String get payoutRequiredTitle;

  /// No description provided for @payoutRequiredInfo.
  ///
  /// In bs, this message translates to:
  /// **'Da bismo ti mogli isplatiti novac od prodaje, potreban nam je tvoj bankovni račun (IBAN). Nakon toga možeš odmah objaviti karte.'**
  String get payoutRequiredInfo;

  /// No description provided for @navEvents.
  ///
  /// In bs, this message translates to:
  /// **'Događaji'**
  String get navEvents;

  /// No description provided for @navMyTickets.
  ///
  /// In bs, this message translates to:
  /// **'Moje karte'**
  String get navMyTickets;

  /// No description provided for @openAccountMenu.
  ///
  /// In bs, this message translates to:
  /// **'Otvori meni računa'**
  String get openAccountMenu;

  /// No description provided for @heroTitle.
  ///
  /// In bs, this message translates to:
  /// **'Karte za koncerte, sport i festivale'**
  String get heroTitle;

  /// No description provided for @heroSubtitle.
  ///
  /// In bs, this message translates to:
  /// **'Kupi sigurno od fanova ili prodaj karte koje ne možeš iskoristiti.'**
  String get heroSubtitle;

  /// No description provided for @howSellingWorks.
  ///
  /// In bs, this message translates to:
  /// **'Kako funkcioniše prodaja'**
  String get howSellingWorks;

  /// No description provided for @sellStep1.
  ///
  /// In bs, this message translates to:
  /// **'Objavi ponudu: događaj, sjedišta i cijenu.'**
  String get sellStep1;

  /// No description provided for @sellStep2.
  ///
  /// In bs, this message translates to:
  /// **'Kupac plaća. Novac čuvamo dok karte ne stignu.'**
  String get sellStep2;

  /// No description provided for @sellStep3.
  ///
  /// In bs, this message translates to:
  /// **'Pošalji karte kupcu i označi ih kao poslane.'**
  String get sellStep3;

  /// No description provided for @sellStep4.
  ///
  /// In bs, this message translates to:
  /// **'Nakon događaja novac stiže na tvoj IBAN.'**
  String get sellStep4;

  /// No description provided for @ibanBadFormat.
  ///
  /// In bs, this message translates to:
  /// **'IBAN počinje oznakom zemlje i dvije cifre, npr. BA39 …'**
  String get ibanBadFormat;

  /// No description provided for @ibanWrongLength.
  ///
  /// In bs, this message translates to:
  /// **'IBAN za {country} ima {expected} znakova, uneseno je {actual}.'**
  String ibanWrongLength(String country, int expected, int actual);

  /// No description provided for @ibanBadChecksum.
  ///
  /// In bs, this message translates to:
  /// **'Kontrolni broj ne odgovara. Provjeri cifre IBAN-a.'**
  String get ibanBadChecksum;

  /// No description provided for @cancelSale.
  ///
  /// In bs, this message translates to:
  /// **'Otkaži prodaju'**
  String get cancelSale;

  /// No description provided for @cancelSaleTitle.
  ///
  /// In bs, this message translates to:
  /// **'Otkazati prodaju?'**
  String get cancelSaleTitle;

  /// No description provided for @cancelSaleInfo.
  ///
  /// In bs, this message translates to:
  /// **'Kupac dobija sav novac nazad, a karte se vraćaju u tvoju ponudu. Za ovu prodaju nema isplate. Ovo se ne može poništiti.'**
  String get cancelSaleInfo;

  /// No description provided for @keepSale.
  ///
  /// In bs, this message translates to:
  /// **'Ne, zadrži'**
  String get keepSale;

  /// No description provided for @saleCancelled.
  ///
  /// In bs, this message translates to:
  /// **'Prodaja je otkazana. Kupcu je vraćen novac.'**
  String get saleCancelled;

  /// No description provided for @buyerNextCancelledBySeller.
  ///
  /// In bs, this message translates to:
  /// **'Prodavac je otkazao prodaju. Novac ti je vraćen u cijelosti.'**
  String get buyerNextCancelledBySeller;

  /// No description provided for @sellerNextCancelledBySeller.
  ///
  /// In bs, this message translates to:
  /// **'Otkazao/la si prodaju. Kupcu je vraćen novac, a karte su ponovo u prodaji.'**
  String get sellerNextCancelledBySeller;

  /// No description provided for @cannotBuyOwnListing.
  ///
  /// In bs, this message translates to:
  /// **'Ovo su tvoje karte. Svoju ponudu ne možeš kupiti.'**
  String get cannotBuyOwnListing;

  /// No description provided for @openListing.
  ///
  /// In bs, this message translates to:
  /// **'Otvori ponudu'**
  String get openListing;

  /// No description provided for @alertSoldTitle.
  ///
  /// In bs, this message translates to:
  /// **'Prodane karte: {event}'**
  String alertSoldTitle(String event);

  /// No description provided for @alertSoldBody.
  ///
  /// In bs, this message translates to:
  /// **'{quantity} kom. · {amount}. Pošalji karte kupcu.'**
  String alertSoldBody(String quantity, String amount);

  /// No description provided for @alertTicketsSentTitle.
  ///
  /// In bs, this message translates to:
  /// **'Karte su poslane'**
  String get alertTicketsSentTitle;

  /// No description provided for @alertTicketsSentBody.
  ///
  /// In bs, this message translates to:
  /// **'{event}: prodavac je poslao tvoje karte.'**
  String alertTicketsSentBody(String event);

  /// No description provided for @alertRefundTitle.
  ///
  /// In bs, this message translates to:
  /// **'Prodaja otkazana'**
  String get alertRefundTitle;

  /// No description provided for @alertRefundBody.
  ///
  /// In bs, this message translates to:
  /// **'{event}: prodavac je otkazao prodaju, novac ti je vraćen.'**
  String alertRefundBody(String event);

  /// No description provided for @alertView.
  ///
  /// In bs, this message translates to:
  /// **'Pogledaj'**
  String get alertView;

  /// No description provided for @changeIban.
  ///
  /// In bs, this message translates to:
  /// **'Promijeni IBAN'**
  String get changeIban;

  /// No description provided for @keepCurrentIban.
  ///
  /// In bs, this message translates to:
  /// **'Zadrži sačuvani IBAN'**
  String get keepCurrentIban;

  /// No description provided for @ibanHint.
  ///
  /// In bs, this message translates to:
  /// **'npr. BA39 1290 0794 0102 8494'**
  String get ibanHint;

  /// No description provided for @deleteAccountOpenOrders.
  ///
  /// In bs, this message translates to:
  /// **'Imaš otvorene prodaje ili kupovine. Završi ih ili otkaži prije brisanja računa.'**
  String get deleteAccountOpenOrders;

  /// No description provided for @newVersionTitle.
  ///
  /// In bs, this message translates to:
  /// **'Nova verzija je dostupna'**
  String get newVersionTitle;

  /// No description provided for @newVersionBody.
  ///
  /// In bs, this message translates to:
  /// **'Osvježi stranicu za najnoviju verziju Stubswapa.'**
  String get newVersionBody;

  /// No description provided for @reload.
  ///
  /// In bs, this message translates to:
  /// **'Osvježi'**
  String get reload;
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
