// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get eventStatusCancelled => 'Abgesagt';

  @override
  String get eventStatusPostponed => 'Verschoben';

  @override
  String get legalImprintTitle => 'Impressum';

  @override
  String get legalTermsTitle => 'AGB';

  @override
  String get legalPrivacyTitle => 'Datenschutz';

  @override
  String get legalCookiesTitle => 'Cookies';

  @override
  String get legalFooterTitle => 'Rechtliches';

  @override
  String get legalTermsLink => 'AGB';

  @override
  String get legalPrivacyLink => 'Datenschutzerklärung';

  @override
  String legalAcceptTerms(String terms, String privacy) {
    return 'Ich akzeptiere die $terms und die $privacy';
  }

  @override
  String get legalAcceptRequired =>
      'Bitte akzeptiere die AGB und die Datenschutzerklärung, um dich zu registrieren.';

  @override
  String legalContinueAccept(String terms, String privacy) {
    return 'Mit dem Fortfahren akzeptierst du die $terms und die $privacy.';
  }

  @override
  String priceInclFee(String percent) {
    return 'inkl. $percent % Servicegebühr';
  }

  @override
  String get priceFaceValue => 'Originalpreis pro Ticket';

  @override
  String get priceFaceValueInfo =>
      'Der auf dem Ticket gedruckte Preis, ohne Gebühren';

  @override
  String get priceFaceValueShort => 'Originalpreis';

  @override
  String get priceFaceValueInvalid => 'Gib den Originalpreis des Tickets ein';

  @override
  String get priceSalePrice => 'Verkaufspreis';

  @override
  String priceSellerFee(String percent) {
    return 'Verkäufergebühr ($percent %)';
  }

  @override
  String get priceYouReceive => 'Du erhältst pro Ticket';

  @override
  String get priceProfit => 'Gewinn pro Ticket';

  @override
  String get priceTotalProfit => 'Gewinn gesamt';

  @override
  String priceForQuantity(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Tickets',
      one: '1 Ticket',
    );
    return 'Für $_temp0';
  }

  @override
  String get priceBelowFaceValue =>
      'Nach der Gebühr erhältst du weniger als den Originalpreis.';

  @override
  String get staffNoMarketTitle => 'Team-Konten kaufen und verkaufen nicht';

  @override
  String get staffNoMarketInfo =>
      'Admin- und Support-Konten sind nur für Team-Aufgaben. Zum Kaufen und Verkaufen nutze ein normales Konto.';

  @override
  String get eventsUserDateTooFar =>
      'Das Datum darf höchstens zwei Jahre in der Zukunft liegen';

  @override
  String get homeCityPick => 'Stadt wählen';

  @override
  String get homeCitySearch => 'Städte suchen';

  @override
  String homeCityUseTyped(String city) {
    return '„$city“ verwenden';
  }

  @override
  String get homeCityUseLocation => 'Meinen Standort verwenden';

  @override
  String get homeCityLocationUnavailable =>
      'Standort nicht verfügbar. Wähle die Stadt bitte selbst.';

  @override
  String get homeCityClear => 'Entfernen';

  @override
  String get homeCityFromLocation => 'Nach deinem Standort';

  @override
  String get homeCityMostEvents => 'Stadt mit den meisten Events';

  @override
  String get homeAllTypes => 'Alle Arten';

  @override
  String get homeRecentlyViewed => 'Zuletzt angesehen';

  @override
  String get homePopular => 'Beliebte Events';

  @override
  String get homeRecommended => 'Für dich empfohlen';

  @override
  String homeNearby(String city) {
    return 'In deiner Nähe: $city';
  }

  @override
  String get homeNearbyChange => 'Ändern';

  @override
  String get homePopularCategories => 'Beliebte Kategorien';

  @override
  String get homeAllEvents => 'Alle Events';

  @override
  String homeAllEventsOfType(String type) {
    return 'Alle Events: $type';
  }

  @override
  String get homeSearchResults => 'Suchergebnisse';

  @override
  String get homeAddEvent => 'Event hinzufügen';

  @override
  String get homeScrollBack => 'Zurück';

  @override
  String get homeScrollForward => 'Weiter';

  @override
  String get footerClaim =>
      'Sicherer Ticket-Wiederverkauf – von Fans für Fans.';

  @override
  String get footerCompany => 'Unser Unternehmen';

  @override
  String get footerQuestions => 'Noch Fragen?';

  @override
  String footerCopyright(int year) {
    return '© $year Stubswap';
  }

  @override
  String footerVersion(String version) {
    return 'Version $version';
  }

  @override
  String get infoAboutTitle => 'Über uns';

  @override
  String get infoPressTitle => 'Presse';

  @override
  String get infoHowTitle => 'So funktioniert’s';

  @override
  String get infoSafetyTitle => 'Sicher kaufen';

  @override
  String get infoNotFound => 'Seite nicht gefunden';

  @override
  String get infoNotFoundInfo =>
      'Diese Seite gibt es nicht oder sie wurde verschoben.';

  @override
  String get infoAboutIntro =>
      'Stubswap ist ein Marktplatz, auf dem Fans in Bosnien und Herzegowina und der Region Tickets für Konzerte, Sport, Kultur und Festivals sicher weiterverkaufen.';

  @override
  String get infoAboutFansTitle => 'Von Fans für Fans';

  @override
  String get infoAboutFansText =>
      'Du kannst nicht hin? Biete dein Ticket jemandem an, der gerne hingeht, statt es verfallen zu lassen. Ausverkauft? Vielleicht verkauft gerade jemand seines.';

  @override
  String get infoAboutTrustTitle => 'Sicherheit zuerst';

  @override
  String get infoAboutTrustText =>
      'Bezahlt wird über Stubswap: Verkäufer erhalten ihr Geld erst nach dem Event, und unser Support hilft, wenn etwas nicht stimmt.';

  @override
  String get infoPressIntro =>
      'Sie schreiben über Stubswap? Wir beantworten gerne Presseanfragen.';

  @override
  String get infoPressFactsTitle => 'Kurz gesagt';

  @override
  String get infoPressFact1 =>
      'Online-Marktplatz für den Ticket-Wiederverkauf zwischen Fans.';

  @override
  String get infoPressFact2 =>
      'Schwerpunkt Bosnien und Herzegowina und die Region.';

  @override
  String get infoPressFact3 =>
      'Verfügbar im Web und auf Mobilgeräten, auf Bosnisch, Deutsch und Englisch.';

  @override
  String get infoPressContactTitle => 'Pressekontakt';

  @override
  String get infoPressContactText =>
      'Senden Sie Presseanfragen bitte über das Hilfe-Center. Wir melden uns so schnell wie möglich.';

  @override
  String get infoHowBuyTitle => 'Kaufen';

  @override
  String get infoHowBuy1 =>
      'Finde dein Event und vergleiche die Angebote von Fans.';

  @override
  String get infoHowBuy2 =>
      'Bezahle sicher – wir halten das Geld zurück, bis die Tickets da sind.';

  @override
  String get infoHowBuy3 =>
      'Der Verkäufer schickt dir die Tickets; den Status siehst du unter „Käufe & Rechnungen“.';

  @override
  String get infoHowSellTitle => 'Verkaufen';

  @override
  String get infoSafetyIntro =>
      'Auf Stubswap kaufst du von anderen Fans – und wir sorgen dafür, dass alles klappt.';

  @override
  String get infoSafetyPaymentTitle => 'Geld bis zum Event gesichert';

  @override
  String get infoSafetyPaymentText =>
      'Du bezahlst über Stubswap, nie direkt an den Verkäufer. Der Verkäufer erhält das Geld erst nach dem Event.';

  @override
  String get infoSafetySellersTitle => 'Geprüfte Verkäufer';

  @override
  String get infoSafetySellersText =>
      'Verkäufer müssen ihre E-Mail-Adresse bestätigen, bevor sie ein Angebot veröffentlichen.';

  @override
  String get infoSafetySupportTitle => 'Hilfe, wenn du sie brauchst';

  @override
  String get infoSafetySupportText =>
      'Kommen die Tickets nicht an oder sind ungültig, melde dich beim Support – du bekommst dein Geld zurück.';

  @override
  String get eventStatusConfirmed => 'Bestätigt';

  @override
  String get eventStatusPending => 'Nicht bestätigt';

  @override
  String get eventStatusHidden => 'Ausgeblendet';

  @override
  String get eventStatusPendingInfo =>
      'Ein Nutzer hat dieses Event hinzugefügt, das Team hat es noch nicht geprüft. Du kannst trotzdem Tickets kaufen und verkaufen.';

  @override
  String get eventsUserNewTitle => 'Event hinzufügen';

  @override
  String get eventsUserInfoTitle => 'Das Team prüft das Event';

  @override
  String get eventsUserInfo =>
      'Bis zur Prüfung ist das Event als „Nicht bestätigt“ markiert. Tickets dafür kannst du sofort verkaufen.';

  @override
  String get eventsUserVerifyFirst =>
      'Bestätige deine E-Mail-Adresse, um Events hinzuzufügen.';

  @override
  String get eventsUserAdded => 'Event hinzugefügt – wird geprüft';

  @override
  String get eventsUserNotListed => 'Event nicht in der Liste?';

  @override
  String get eventsUserAddIt => 'Hinzufügen';

  @override
  String get eventsUserNoneToSellInfo =>
      'Noch keine kommenden Events. Füge dein Event hinzu und verkaufe gleich Tickets dafür.';

  @override
  String get eventsReviewEdit => 'Bearbeiten / prüfen';

  @override
  String get eventsReviewConfirm => 'Bestätigen';

  @override
  String get eventsReviewConfirmTitle => 'Event bestätigen?';

  @override
  String get eventsReviewConfirmInfo =>
      'Prüfe Name, Ort und Datum. Das Event wird allen als bestätigt angezeigt.';

  @override
  String get eventsReviewConfirmedToast => 'Event bestätigt';

  @override
  String eventsReviewTabPending(int count) {
    return 'Zu prüfen ($count)';
  }

  @override
  String get eventsReviewTabConfirmed => 'Bestätigt';

  @override
  String get eventsReviewTabHidden => 'Ausgeblendet';

  @override
  String get eventsReviewTabPast => 'Vergangen';

  @override
  String get eventsReviewEmptyPending => 'Keine Events zu prüfen';

  @override
  String get eventsReviewEmptyPendingInfo =>
      'Fügt ein Nutzer ein Event hinzu, erscheint es hier.';

  @override
  String get eventsReviewEmpty => 'Hier gibt es keine Events';

  @override
  String eventsReviewAddedBy(String who) {
    return 'Hinzugefügt von: $who';
  }

  @override
  String get eventsReviewAddedByYou => 'Dir';

  @override
  String get eventsReviewAddedByUser => 'Nutzer';

  @override
  String get eventsReviewQueue => 'Events zur Prüfung';

  @override
  String get eventsReviewNoAccessInfo =>
      'Diese Seite können nur Teammitglieder öffnen.';

  @override
  String get genreFootball => 'Fußball';

  @override
  String get genreBasketball => 'Basketball';

  @override
  String get genreHandball => 'Handball';

  @override
  String get genreTennis => 'Tennis';

  @override
  String get genreVolleyball => 'Volleyball';

  @override
  String get genreCombat => 'Kampfsport';

  @override
  String get genreMotorsport => 'Motorsport';

  @override
  String get genreOtherSport => 'Weiterer Sport';

  @override
  String get genreRock => 'Rock';

  @override
  String get genrePop => 'Pop';

  @override
  String get genreFolk => 'Volksmusik';

  @override
  String get genreJazz => 'Jazz';

  @override
  String get genreHiphop => 'Hip-Hop';

  @override
  String get genreElectronic => 'Elektronische Musik';

  @override
  String get genreClassical => 'Klassik';

  @override
  String get genreOtherMusic => 'Weitere Musik';

  @override
  String get genreDrama => 'Theater';

  @override
  String get genreOpera => 'Oper';

  @override
  String get genreBallet => 'Ballett';

  @override
  String get genreStandup => 'Stand-up-Comedy';

  @override
  String get genreMusical => 'Musical';

  @override
  String get genreExhibition => 'Ausstellungen';

  @override
  String get genreFilm => 'Film';

  @override
  String get genreMusicFestival => 'Musikfestivals';

  @override
  String get genreFilmFestival => 'Filmfestivals';

  @override
  String get genreFoodFestival => 'Food-Festivals';

  @override
  String get genreOtherFestival => 'Weitere Festivals';

  @override
  String get genreFamily => 'Für Familien';

  @override
  String get genreConference => 'Konferenzen';

  @override
  String get genreOtherEvent => 'Sonstiges';

  @override
  String get genreLabel => 'Unterkategorie';

  @override
  String get genreNone => 'Ohne Unterkategorie';

  @override
  String get supportUser => 'Nutzer';

  @override
  String get supportMyRequests => 'Meine Anfragen';

  @override
  String get supportNoRequests => 'Du hast noch keine Anfragen an den Support.';

  @override
  String get supportStatusOpen => 'Offen';

  @override
  String get supportStatusAnswered => 'Beantwortet';

  @override
  String get supportStatusClosed => 'Geschlossen';

  @override
  String get supportNewAnswer => 'Neue Antwort';

  @override
  String get supportRequestSent => 'Anfrage gesendet';

  @override
  String get supportMessageTooShort => 'Schreib mindestens 10 Zeichen';

  @override
  String get supportAnswerInApp =>
      'Wir antworten hier in der App, meist innerhalb von 24 Stunden. Du wirst benachrichtigt.';

  @override
  String get supportImages => 'Bilder';

  @override
  String supportImagesInfo(int count) {
    return 'Screenshots oder Fotos, höchstens $count';
  }

  @override
  String get supportAddImage => 'Bild hinzufügen';

  @override
  String get supportRemoveImage => 'Bild entfernen';

  @override
  String get supportImageError => 'Das Bild kann nicht gelesen werden';

  @override
  String get supportImage => 'Bild';

  @override
  String get supportTeamName => 'Stubswap-Support';

  @override
  String get supportYou => 'Du';

  @override
  String get supportTicket => 'Anfrage';

  @override
  String get supportCloseTicket => 'Anfrage schließen';

  @override
  String get supportResolveTicket => 'Problem gelöst – Anfrage schließen';

  @override
  String get supportCloseConfirm => 'Anfrage schließen?';

  @override
  String get supportCloseConfirmInfo =>
      'In eine geschlossene Anfrage kann nicht mehr geschrieben werden. Tritt das Problem wieder auf, eröffne eine neue Anfrage.';

  @override
  String get supportCloseConfirmStaff =>
      'Der Nutzer kann in diese Anfrage nicht mehr schreiben.';

  @override
  String get supportClosed => 'Die Anfrage ist geschlossen';

  @override
  String get supportClosedByUser => 'Vom Nutzer geschlossen.';

  @override
  String get supportClosedByYou => 'Auf deinen Wunsch geschlossen.';

  @override
  String get supportClosedByStaff => 'Vom Support geschlossen.';

  @override
  String get supportNewRequest => 'Neue Anfrage';

  @override
  String get supportWriteMessage => 'Nachricht schreiben…';

  @override
  String get supportNotFound => 'Anfrage nicht gefunden';

  @override
  String get supportNoAccess => 'Kein Zugriff';

  @override
  String get supportNoAccessInfo => 'Diese Seite ist nur für das Support-Team.';

  @override
  String get supportInbox => 'Support-Anfragen';

  @override
  String get supportFilterOpen => 'Offen';

  @override
  String get supportFilterAnswered => 'Beantwortet';

  @override
  String get supportFilterClosed => 'Geschlossen';

  @override
  String get supportFilterAll => 'Alle';

  @override
  String get supportInboxEmpty => 'Keine Anfragen';

  @override
  String get supportAppVersion => 'App-Version';

  @override
  String get supportEmail => 'E-Mail';

  @override
  String get supportAlertAnswered => 'Der Support hat geantwortet';

  @override
  String get supportAlertNew => 'Neue Support-Anfrage';

  @override
  String supportAlertNewMessage(String number) {
    return 'Neue Nachricht in Anfrage $number';
  }

  @override
  String get supportAlertOpen => 'Öffnen';

  @override
  String get supportAdministration => 'Verwaltung';

  @override
  String get adminTitle => 'Administration';

  @override
  String get adminTeamSection => 'Team';

  @override
  String get adminNoAccess => 'Kein Zugriff';

  @override
  String get adminNoAccessInfo => 'Diese Seite ist nur für Administratoren.';

  @override
  String get adminEvents => 'Events';

  @override
  String get adminEventsInfo => 'Events anlegen und bearbeiten';

  @override
  String get adminFeesTitle => 'Servicegebühr';

  @override
  String adminFeesSummary(int buyer, int seller) {
    return 'Käufer $buyer % · Verkäufer $seller %';
  }

  @override
  String get adminTeamTitle => 'Team und Support';

  @override
  String get adminTeamInfo => 'Support-Konten und Administratoren';

  @override
  String get adminSupportInbox => 'Supportanfragen';

  @override
  String get adminSupportInboxInfo => 'Anfragen der Nutzer beantworten';

  @override
  String get adminBuyerFee => 'Käufergebühr';

  @override
  String get adminBuyerFeeInfo =>
      'Zahlt der Käufer zusätzlich zum Ticketpreis.';

  @override
  String get adminSellerFee => 'Verkäufergebühr';

  @override
  String get adminSellerFeeInfo =>
      'Wird vom Ticketpreis des Verkäufers abgezogen.';

  @override
  String adminFeeRange(int max) {
    return 'Gib eine ganze Zahl von 0 bis $max ein';
  }

  @override
  String get adminFeeDecrease => 'Verringern';

  @override
  String get adminFeeIncrease => 'Erhöhen';

  @override
  String adminFeesCurrent(String summary) {
    return 'Aktuell: $summary';
  }

  @override
  String adminFeesExample(String price) {
    return 'Beispiel für ein Ticket zu $price';
  }

  @override
  String get adminTicketPrice => 'Ticketpreis';

  @override
  String get adminBuyerPays => 'Käufer zahlt';

  @override
  String get adminSellerReceives => 'Verkäufer erhält';

  @override
  String get adminPlatformEarns => 'Stubswap verdient';

  @override
  String get adminFeesNotice =>
      'Die neue Gebühr gilt nur für Angebote, die ab jetzt veröffentlicht werden. Bestehende Angebote und Bestellungen behalten ihre Gebühr.';

  @override
  String get adminFeesConfirmTitle => 'Gebühr ändern?';

  @override
  String get adminFeesSave => 'Gebühr speichern';

  @override
  String get adminFeesSaved => 'Gebühr gespeichert';

  @override
  String get adminRoleAdmin => 'Admin';

  @override
  String get adminRoleSupport => 'Support';

  @override
  String get adminTeamMembers => 'Teammitglieder';

  @override
  String adminGrantedAt(String date) {
    return 'Hinzugefügt am $date';
  }

  @override
  String get adminYou => 'Du';

  @override
  String get adminNoName => 'Ohne Namen';

  @override
  String get adminRemoveSupport => 'Aus dem Support entfernen';

  @override
  String get adminRemoveSupportTitle => 'Aus dem Support entfernen?';

  @override
  String adminRemoveSupportBody(String name) {
    return '$name sieht danach keine Supportanfragen mehr. Das Konto bleibt bestehen.';
  }

  @override
  String get adminRemove => 'Entfernen';

  @override
  String get adminSupportRemoved => 'Aus dem Support entfernt';

  @override
  String get adminAdminsInfo =>
      'Admins legst du nur in der Firebase-Konsole an (Firestore → roles → Dokument mit der ID des Nutzers, Feld role = admin).';

  @override
  String get adminAddSupport => 'Support-Konto hinzufügen';

  @override
  String get adminAddSupportInfo =>
      'Suche nach der genauen E-Mail-Adresse oder dem Benutzernamen. Die Person muss sich mindestens einmal bei Stubswap angemeldet haben.';

  @override
  String get adminFindUserLabel => 'E-Mail oder Benutzername';

  @override
  String get adminFindUser => 'Suchen';

  @override
  String get adminUserNotFound => 'Nutzer nicht gefunden';

  @override
  String get adminUserNotFoundInfo =>
      'Prüfe die Adresse oder den Benutzernamen. Die Person muss sich mindestens einmal angemeldet haben.';

  @override
  String get adminMakeSupport => 'Als Support hinzufügen';

  @override
  String get adminSupportAdded => 'Zum Support hinzugefügt';

  @override
  String adminAlreadyInTeam(String role) {
    return 'Bereits im Team als $role';
  }

  @override
  String get adminThatsYou => 'Das bist du';

  @override
  String eventsOffer(String price, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Tickets',
      one: '1 Ticket',
    );
    return 'ab $price · $_temp0';
  }

  @override
  String get eventsNoOffers => 'Noch keine Angebote';

  @override
  String get eventsNoOffersInfo =>
      'Verkaufe als Erste:r Tickets für dieses Event.';

  @override
  String get eventsSellForEvent => 'Tickets für dieses Event verkaufen';

  @override
  String get eventsOffers => 'Angebote';

  @override
  String get eventsNotFound => 'Event nicht gefunden';

  @override
  String get eventsNotFoundInfo =>
      'Es wurde vielleicht entfernt oder ist nicht mehr verfügbar.';

  @override
  String get eventsIsOver =>
      'Dieses Event ist vorbei. Dafür werden keine Tickets mehr verkauft.';

  @override
  String get eventsPick => 'Event auswählen';

  @override
  String get eventsPickRequired => 'Wähle ein Event aus';

  @override
  String get eventsChange => 'Ändern';

  @override
  String get eventsSearch => 'Events durchsuchen';

  @override
  String get eventsNoneToSell => 'Derzeit keine Events';

  @override
  String get eventsNoneToSellInfo =>
      'Events werden vom Stubswap-Team hinzugefügt. Sobald ein neues Event erscheint, kannst du hier Tickets dafür verkaufen.';

  @override
  String get eventsAllOffers => 'Alle Angebote für dieses Event';

  @override
  String get eventsAdminTitle => 'Events';

  @override
  String get eventsAdminNoAccess => 'Kein Zugriff';

  @override
  String get eventsAdminNoAccessInfo =>
      'Nur Administratoren können diese Seite öffnen.';

  @override
  String get eventsNew => 'Neues Event';

  @override
  String get eventsEdit => 'Event bearbeiten';

  @override
  String get eventsHiddenBadge => 'Ausgeblendet';

  @override
  String get eventsPastBadge => 'Vorbei';

  @override
  String get eventsUpcomingSection => 'Bevorstehend';

  @override
  String get eventsPastSection => 'Vergangen';

  @override
  String get eventsHide => 'Event ausblenden';

  @override
  String get eventsShow => 'Event einblenden';

  @override
  String get eventsHideConfirm =>
      'Das Event wird nicht mehr angezeigt und es können keine neuen Angebote dafür erstellt werden. Bestehende Angebote bleiben.';

  @override
  String get eventsShowConfirm =>
      'Das Event ist wieder für alle sichtbar und es können wieder Tickets dafür verkauft werden.';

  @override
  String get eventsHiddenToast => 'Event ausgeblendet';

  @override
  String get eventsShownToast => 'Event wieder sichtbar';

  @override
  String get eventsPicture => 'Bild';

  @override
  String get eventsPicturePick => 'Bild auswählen';

  @override
  String get eventsPictureReplace => 'Ersetzen';

  @override
  String get eventsPictureRemove => 'Entfernen';

  @override
  String get eventsPictureHint => 'Das Bild wird auf 16:9 zugeschnitten.';

  @override
  String get eventsPictureError => 'Dieses Bild kann nicht geladen werden';

  @override
  String get eventsCreated => 'Event erstellt';

  @override
  String get eventsListingsKeepData =>
      'Bestehende Angebote behalten die Eventdaten vom Zeitpunkt ihrer Veröffentlichung.';

  @override
  String get eventsNameTooShort => 'Mindestens 2 Zeichen';

  @override
  String get eventsNoneYet => 'Noch keine Events';

  @override
  String get eventsNoneYetInfo =>
      'Füge das erste Event hinzu, damit Verkäufer Angebote erstellen können.';

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
  String get passwordTooShort => 'Passwort muss mindestens 8 Zeichen haben';

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
  String get errorWeakPassword =>
      'Das Passwort ist zu schwach: mindestens 8 Zeichen';

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
  String get errorPopupBlocked =>
      'Der Browser hat das Google-Anmeldefenster blockiert. Erlaube Pop-ups für diese Seite und versuche es erneut';

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
  String get catTheater => 'Kultur';

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

  @override
  String get profileTitle => 'Profil';

  @override
  String get editProfile => 'Profil bearbeiten';

  @override
  String get changePhoto => 'Foto ändern';

  @override
  String get removePhoto => 'Foto entfernen';

  @override
  String get usernameLabel => 'Benutzername';

  @override
  String get usernameHint => '3–20 Zeichen: Kleinbuchstaben, Zahlen, _ und .';

  @override
  String get usernameInvalid => 'Ungültiger Benutzername';

  @override
  String get usernameTaken => 'Benutzername ist vergeben';

  @override
  String get save => 'Speichern';

  @override
  String get saved => 'Gespeichert';

  @override
  String get saveError => 'Speichern fehlgeschlagen';

  @override
  String get statListed => 'Eingestellt';

  @override
  String get statSold => 'Verkauft';

  @override
  String get statBought => 'Gekauft';

  @override
  String get statTickets => 'Tickets';

  @override
  String get profilePublic => 'Öffentliches Profil';

  @override
  String get profilePrivate => 'Privates Profil';

  @override
  String get personalization => 'Personalisierung';

  @override
  String get loadError => 'Laden fehlgeschlagen';

  @override
  String get loadErrorInfo =>
      'Prüfe deine Internetverbindung und versuche es erneut.';

  @override
  String get retry => 'Erneut versuchen';

  @override
  String get photoError => 'Foto konnte nicht geladen werden';

  @override
  String memberSince(String date) {
    return 'Mitglied seit $date';
  }

  @override
  String get privacySecurity => 'Datenschutz & Sicherheit';

  @override
  String get privacy => 'Datenschutz';

  @override
  String get profileVisibility => 'Profil-Sichtbarkeit';

  @override
  String get visibilityPublicInfo =>
      'Käufer sehen deinen Namen, Benutzernamen und dein Foto bei deinen Angeboten.';

  @override
  String get visibilityPrivateInfo =>
      'Käufer sehen nur, dass der Verkäufer verifiziert ist. Name und Foto bleiben verborgen.';

  @override
  String get security => 'Sicherheit';

  @override
  String get emailVerified => 'Bestätigt';

  @override
  String get emailNotVerified => 'Nicht bestätigt';

  @override
  String get verifyEmailInfo =>
      'Bestätige deine E-Mail-Adresse, bevor du Tickets verkaufst, damit Käufer dich erreichen können.';

  @override
  String get sendVerification => 'Bestätigungslink senden';

  @override
  String verificationSent(String email) {
    return 'Link wurde an $email gesendet';
  }

  @override
  String get checkVerification => 'Ich habe bestätigt';

  @override
  String get signInMethods => 'Anmeldemethoden';

  @override
  String get methodPassword => 'E-Mail und Passwort';

  @override
  String get changePassword => 'Passwort ändern';

  @override
  String get currentPassword => 'Aktuelles Passwort';

  @override
  String get newPassword => 'Neues Passwort';

  @override
  String get passwordChanged => 'Passwort wurde geändert';

  @override
  String get dangerZone => 'Gefahrenbereich';

  @override
  String get deleteAccount => 'Konto löschen';

  @override
  String get deleteAccountInfo =>
      'Dein Profil und deine aktiven Angebote werden dauerhaft entfernt. Bestellungen und Auszahlungen bewahren wir so lange auf, wie es gesetzlich nötig ist.';

  @override
  String get deleteAccountConfirm => 'Mit Passwort bestätigen';

  @override
  String get deleteAccountGoogle =>
      'Du bestätigst das Löschen mit deinem Google-Konto.';

  @override
  String get cancel => 'Abbrechen';

  @override
  String get notifications => 'Benachrichtigungen';

  @override
  String get channels => 'Kanäle';

  @override
  String get channelEmail => 'E-Mail';

  @override
  String channelEmailInfo(String email) {
    return 'Benachrichtigungen an $email';
  }

  @override
  String get channelPush => 'Push auf diesem Gerät';

  @override
  String get pushUnsupported =>
      'Dieser Browser unterstützt keine Benachrichtigungen. Auf dem iPhone füge Stubswap zum Home-Bildschirm hinzu.';

  @override
  String get pushDenied =>
      'Benachrichtigungen sind in den Browser-Einstellungen blockiert.';

  @override
  String get sendTestNotification => 'Test-Benachrichtigung senden';

  @override
  String get testNotificationTitle =>
      'Stubswap-Benachrichtigungen funktionieren';

  @override
  String get testNotificationBody =>
      'So erfährst du, wenn deine Tickets verkauft werden.';

  @override
  String get buying => 'Kaufen';

  @override
  String get selling => 'Verkaufen';

  @override
  String get other => 'Sonstiges';

  @override
  String get notifOrderUpdates => 'Bestellstatus';

  @override
  String get notifOrderUpdatesInfo => 'Zahlung, Ticketübergabe, Erstattungen';

  @override
  String get notifEventReminders => 'Event-Erinnerungen';

  @override
  String get notifEventRemindersInfo =>
      'Einen Tag vor Events, für die du Tickets hast';

  @override
  String get notifPriceAlerts => 'Preisalarme';

  @override
  String get notifPriceAlertsInfo =>
      'Wenn Preise für Events fallen, denen du folgst';

  @override
  String get notifSaleUpdates => 'Verkaufte Tickets';

  @override
  String get notifSaleUpdatesInfo =>
      'Wenn Tickets verkauft wurden und du sie senden musst';

  @override
  String get notifPayoutUpdates => 'Auszahlungen';

  @override
  String get notifPayoutUpdatesInfo =>
      'Geplante, gesendete oder fehlgeschlagene Auszahlungen';

  @override
  String get notifNewsletter => 'Neuigkeiten und Angebote';

  @override
  String get notifNewsletterInfo => 'Gelegentlich, zu neuen Events';

  @override
  String get sellTitle => 'Tickets verkaufen';

  @override
  String get event => 'Event';

  @override
  String get eventName => 'Name des Events';

  @override
  String get venue => 'Veranstaltungsort';

  @override
  String get city => 'Stadt';

  @override
  String get dateTime => 'Datum und Uhrzeit';

  @override
  String get pickDate => 'Datum wählen';

  @override
  String get category => 'Kategorie';

  @override
  String get tickets => 'Tickets';

  @override
  String get ticketType => 'Ticketart';

  @override
  String get ticketEticket => 'E-Ticket';

  @override
  String get ticketMobile => 'Mobil';

  @override
  String get ticketPaper => 'Papier';

  @override
  String get quantity => 'Anzahl';

  @override
  String get section => 'Block';

  @override
  String get row => 'Reihe';

  @override
  String get seats => 'Plätze';

  @override
  String get optional => 'optional';

  @override
  String get price => 'Preis';

  @override
  String get pricePerTicket => 'Preis pro Ticket';

  @override
  String buyerPays(String percent) {
    return 'Käufer zahlt (inkl. $percent % Gebühr)';
  }

  @override
  String youReceive(String percent) {
    return 'Du erhältst pro Ticket ($percent % Gebühr)';
  }

  @override
  String get totalPayout => 'Auszahlung gesamt';

  @override
  String get noteLabel => 'Hinweis für Käufer';

  @override
  String get publishListing => 'Angebot veröffentlichen';

  @override
  String get listingPublished => 'Angebot ist online';

  @override
  String get required => 'Pflichtfeld';

  @override
  String get dateInPast => 'Datum muss in der Zukunft liegen';

  @override
  String get priceInvalid => 'Bitte gültigen Preis eingeben';

  @override
  String get verifyBeforeSelling =>
      'Bestätige deine E-Mail-Adresse, damit Käufer deinen Angeboten vertrauen.';

  @override
  String get verifyNow => 'Bestätigen';

  @override
  String get myListings => 'Meine Angebote';

  @override
  String get filterAll => 'Alle';

  @override
  String get statusActive => 'Aktiv';

  @override
  String get statusReserved => 'Reserviert';

  @override
  String get statusSoldOut => 'Ausverkauft';

  @override
  String get statusExpired => 'Abgelaufen';

  @override
  String get statusWithdrawn => 'Zurückgezogen';

  @override
  String get ended => 'Beendet';

  @override
  String get noListings => 'Noch keine Angebote';

  @override
  String get noListingsInfo =>
      'Tickets übrig? Verkaufe sie in wenigen Minuten.';

  @override
  String ticketsLeft(String count, String total) {
    return '$count von $total verfügbar';
  }

  @override
  String ticketsCount(String count) {
    return '$count Stk.';
  }

  @override
  String get perTicket => 'pro Ticket';

  @override
  String get listingDetails => 'Angebotsdetails';

  @override
  String get editPrice => 'Preis ändern';

  @override
  String get withdrawListing => 'Angebot zurückziehen';

  @override
  String get withdrawConfirm =>
      'Das Angebot ist dann für Käufer nicht mehr sichtbar. Fortfahren?';

  @override
  String get listingWithdrawn => 'Angebot zurückgezogen';

  @override
  String get listingNotFound => 'Angebot nicht gefunden';

  @override
  String get yourListing => 'Dein Angebot';

  @override
  String get buyTickets => 'Tickets kaufen';

  @override
  String get total => 'Gesamt';

  @override
  String get serviceFee => 'Servicegebühr';

  @override
  String get checkoutSoonTitle => 'Bezahlung kommt bald';

  @override
  String get checkoutSoonInfo =>
      'Sichere Bezahlung mit Käuferschutz ist in Arbeit. Das Angebot kannst du dir schon ansehen.';

  @override
  String get buyerProtection =>
      'Käuferschutz: gültige Tickets rechtzeitig oder Geld zurück.';

  @override
  String get sellerVerified => 'Verifizierter Verkäufer';

  @override
  String searchNoResults(String query) {
    return 'Keine Ergebnisse für „$query“';
  }

  @override
  String get upcomingEvents => 'Kommende Events';

  @override
  String fromPrice(String price) {
    return 'ab $price';
  }

  @override
  String get ok => 'OK';

  @override
  String get orderPendingPayment => 'Zahlung ausstehend';

  @override
  String get orderPaid => 'Bezahlt';

  @override
  String get orderTicketsSent => 'Tickets übertragen';

  @override
  String get orderCompleted => 'Abgeschlossen';

  @override
  String get orderCancelled => 'Storniert';

  @override
  String get orderRefunded => 'Erstattet';

  @override
  String get orderDisputed => 'In Klärung';

  @override
  String get payoutPending => 'Wartet auf Event';

  @override
  String get payoutScheduled => 'Geplant';

  @override
  String get payoutProcessing => 'In Bearbeitung';

  @override
  String get payoutPaid => 'Ausgezahlt';

  @override
  String get payoutFailed => 'Fehlgeschlagen';

  @override
  String get buyerNextPendingPayment =>
      'Schließe die Zahlung ab, um die Tickets zu sichern.';

  @override
  String get buyerNextPaid =>
      'Der Verkäufer überträgt die Tickets. Du bekommst sie spätestens vor dem Event.';

  @override
  String get buyerNextTicketsSent =>
      'Deine Tickets wurden übertragen. Prüfe deine E-Mails oder die App des Veranstalters.';

  @override
  String get buyerNextCompleted => 'Viel Spaß beim Event!';

  @override
  String get buyerNextCancelled =>
      'Die Bestellung wurde storniert. Es wurde nichts berechnet.';

  @override
  String get buyerNextRefunded =>
      'Der Betrag wurde auf deine Zahlungsmethode erstattet.';

  @override
  String get buyerNextDisputed =>
      'Unser Team prüft die Bestellung und meldet sich bei dir.';

  @override
  String get sellerNextPendingPayment =>
      'Der Käufer bezahlt. Die Tickets sind reserviert.';

  @override
  String get sellerNextPaid =>
      'Übertrage die Tickets so bald wie möglich an den Käufer.';

  @override
  String get sellerNextTicketsSent => 'Die Auszahlung folgt nach dem Event.';

  @override
  String get sellerNextCompleted =>
      'Verkauf abgeschlossen. Sieh dir deine Auszahlungen an.';

  @override
  String get sellerNextCancelled =>
      'Bestellung storniert. Die Tickets sind wieder im Verkauf.';

  @override
  String get sellerNextRefunded =>
      'Der Käufer wurde erstattet. Für diesen Verkauf gibt es keine Auszahlung.';

  @override
  String get sellerNextDisputed =>
      'Der Käufer hat ein Problem gemeldet. Die Auszahlung wartet auf die Klärung.';

  @override
  String get payoutNextPending =>
      'Das Geld wird freigegeben, sobald das Event stattgefunden hat.';

  @override
  String get payoutNextScheduled =>
      'Die Auszahlung ist im nächsten Auszahlungslauf.';

  @override
  String get payoutNextProcessing =>
      'Die Bank bearbeitet die Überweisung, meist 1–3 Werktage.';

  @override
  String get payoutNextPaid => 'Das Geld ist auf deinem Konto.';

  @override
  String get payoutNextFailed =>
      'Prüfe deine Auszahlungsmethode. Nach einer Änderung versuchen wir es erneut.';

  @override
  String get invoice => 'Rechnung';

  @override
  String get orderNumber => 'Bestellnummer';

  @override
  String get orderDate => 'Bestelldatum';

  @override
  String get paymentMethod => 'Zahlungsmethode';

  @override
  String get saleAmount => 'Verkaufsbetrag';

  @override
  String get sellerFeeLabel => 'Verkäufergebühr';

  @override
  String get yourEarnings => 'Dein Erlös';

  @override
  String get copied => 'Kopiert';

  @override
  String get copy => 'Kopieren';

  @override
  String get whatsNext => 'Wie es weitergeht';

  @override
  String get statusHistory => 'Verlauf';

  @override
  String get orderDetails => 'Bestelldetails';

  @override
  String get saleDetails => 'Verkaufsdetails';

  @override
  String get payoutDetails => 'Auszahlungsdetails';

  @override
  String get purchases => 'Käufe & Rechnungen';

  @override
  String get sales => 'Verkäufe';

  @override
  String get payouts => 'Auszahlungen';

  @override
  String get payoutMethod => 'Auszahlungsmethode';

  @override
  String get noPurchases => 'Noch keine Käufe';

  @override
  String get noPurchasesInfo =>
      'Gekaufte Tickets und Rechnungen erscheinen hier.';

  @override
  String get noSales => 'Noch keine Verkäufe';

  @override
  String get noSalesInfo =>
      'Wenn jemand deine Tickets kauft, siehst du es hier.';

  @override
  String get noPayouts => 'Noch keine Auszahlungen';

  @override
  String get noPayoutsInfo =>
      'Geld aus Verkäufen kommt nach dem Event auf dein Konto.';

  @override
  String get filterInProgress => 'Laufend';

  @override
  String get filterCompleted => 'Abgeschlossen';

  @override
  String get filterCancelled => 'Storniert';

  @override
  String get payoutsUpcoming => 'Demnächst auf dem Konto';

  @override
  String get payoutsPaidTotal => 'Bisher ausgezahlt';

  @override
  String expectedOn(String date) {
    return 'Erwartet am $date';
  }

  @override
  String get payoutOrders => 'Enthaltene Bestellungen';

  @override
  String get failureReason => 'Grund';

  @override
  String get setUpPayout => 'Auszahlungsmethode hinzufügen';

  @override
  String get payoutMethodMissing =>
      'Füge ein Bankkonto hinzu, um Geld aus Verkäufen zu erhalten.';

  @override
  String get accountHolder => 'Kontoinhaber';

  @override
  String get iban => 'IBAN';

  @override
  String get ibanInvalid => 'Ungültige IBAN';

  @override
  String get payoutMethodInfo =>
      'Auszahlungen gehen 3–5 Werktage nach dem Event auf dieses Konto.';

  @override
  String get payoutMethodSaved => 'Auszahlungsmethode gespeichert';

  @override
  String get change => 'Ändern';

  @override
  String get buyer => 'Käufer';

  @override
  String get support => 'Support';

  @override
  String get helpCenter => 'Hilfe-Center';

  @override
  String get contactSupport => 'Support kontaktieren';

  @override
  String get about => 'Über die App';

  @override
  String get aboutText =>
      'Stubswap ist ein sicherer Marktplatz zum Kaufen und Verkaufen von Event-Tickets.';

  @override
  String get getHelpOrder => 'Hilfe zu dieser Bestellung';

  @override
  String get getHelpPayout => 'Hilfe zu dieser Auszahlung';

  @override
  String get topic => 'Thema';

  @override
  String get topicOrder => 'Kauf';

  @override
  String get topicSale => 'Verkauf';

  @override
  String get topicPayout => 'Auszahlung';

  @override
  String get topicAccount => 'Konto';

  @override
  String get topicOther => 'Sonstiges';

  @override
  String get reference => 'Bestell- oder Angebotsnummer';

  @override
  String get message => 'Nachricht';

  @override
  String get messageHint =>
      'Beschreibe, was passiert ist. Je mehr Details, desto schneller helfen wir.';

  @override
  String get messageTooShort => 'Bitte mindestens 20 Zeichen';

  @override
  String get send => 'Senden';

  @override
  String get requestSent => 'Anfrage gesendet';

  @override
  String requestSentInfo(String number, String email) {
    return 'Deine Anfragenummer ist $number. Wir antworten an $email, meist innerhalb von 24 Stunden.';
  }

  @override
  String get done => 'Fertig';

  @override
  String get stillNeedHelp => 'Keine Antwort gefunden?';

  @override
  String get faqBuySafeQ => 'Ist der Kauf bei Stubswap sicher?';

  @override
  String get faqBuySafeA =>
      'Ja. Wir halten das Geld zurück, bis du deine Tickets hast. Kommen sie nicht rechtzeitig oder sind ungültig, bekommst du dein Geld zurück.';

  @override
  String get faqWhenTicketsQ => 'Wann bekomme ich meine Tickets?';

  @override
  String get faqWhenTicketsA =>
      'Der Verkäufer überträgt sie nach der Zahlung, spätestens vor dem Event. Den Status siehst du unter Käufe & Rechnungen.';

  @override
  String get faqFeesQ => 'Welche Gebühren fallen an?';

  @override
  String faqFeesA(String buyer, String seller) {
    return 'Käufer zahlen $buyer % Servicegebühr auf den Ticketpreis. Von Verkäufern behalten wir $seller % des Verkaufspreises ein.';
  }

  @override
  String get faqPayoutWhenQ => 'Wann bekomme ich das Geld aus einem Verkauf?';

  @override
  String get faqPayoutWhenA =>
      'Nach dem Event wird die Auszahlung geplant und kommt in 3–5 Werktagen auf deine IBAN.';

  @override
  String get faqSendTicketsQ => 'Wie übertrage ich Tickets an den Käufer?';

  @override
  String get faqSendTicketsA =>
      'E-Tickets und mobile Tickets überträgst du über den Veranstalter an die E-Mail des Käufers. Papiertickets verschickst du per Einschreiben.';

  @override
  String get faqCancelQ => 'Was passiert, wenn ein Event abgesagt wird?';

  @override
  String get faqCancelA =>
      'Käufer bekommen den vollen Betrag zurück, Verkäufe werden ohne Gebühr für Verkäufer storniert.';

  @override
  String get checkout => 'Kasse';

  @override
  String payAmount(String amount) {
    return '$amount bezahlen';
  }

  @override
  String get testModeBadge => 'Testmodus · kein echtes Geld';

  @override
  String get stripeSimulator => 'Stripe-Simulator';

  @override
  String get simulatorInfo =>
      'Simulierte Zahlung. Wird später durch echtes Stripe ersetzt.';

  @override
  String get cardNumber => 'Kartennummer';

  @override
  String get cardExpiry => 'Ablaufdatum';

  @override
  String get cardCvc => 'CVC';

  @override
  String get simulateSuccess => 'Zahlung erfolgreich';

  @override
  String get simulateSuccessInfo =>
      'Ausschalten, um eine abgelehnte Karte zu simulieren.';

  @override
  String get declineReason => 'Ablehnungsgrund';

  @override
  String get failCardDeclined => 'Karte abgelehnt';

  @override
  String get failInsufficientFunds => 'Nicht genügend Guthaben';

  @override
  String get failExpiredCard => 'Karte abgelaufen';

  @override
  String get failProcessingError => 'Verarbeitungsfehler';

  @override
  String get failSoldOut => 'Die Tickets wurden inzwischen verkauft';

  @override
  String get processingPayment => 'Zahlung wird verarbeitet…';

  @override
  String get paymentSucceeded => 'Zahlung erfolgreich';

  @override
  String get paymentFailedTitle => 'Zahlung fehlgeschlagen';

  @override
  String paymentFailedInfo(String reason) {
    return '$reason. Es wurde nichts belastet. Versuche es erneut oder nutze eine andere Karte.';
  }

  @override
  String get tryAgain => 'Erneut versuchen';

  @override
  String get payNow => 'Jetzt bezahlen';

  @override
  String get markTicketsSent => 'Tickets als übertragen markieren';

  @override
  String get ticketsMarkedSent => 'Der Käufer wurde informiert';

  @override
  String get buyerEmail => 'Tickets gehen an';

  @override
  String get notAvailableAnymore => 'Dieses Angebot ist nicht mehr verfügbar';

  @override
  String get payoutRequiredTitle => 'Zuerst Auszahlungsmethode hinzufügen';

  @override
  String get payoutRequiredInfo =>
      'Damit wir dir das Geld aus Verkäufen auszahlen können, brauchen wir dein Bankkonto (IBAN). Danach kannst du sofort Tickets einstellen.';

  @override
  String get navEvents => 'Events';

  @override
  String get navMyTickets => 'Meine Tickets';

  @override
  String get openAccountMenu => 'Kontomenü öffnen';

  @override
  String get heroTitle => 'Tickets für Konzerte, Sport und Festivals';

  @override
  String get heroSubtitle =>
      'Kaufe sicher von Fans oder verkaufe Tickets, die du nicht nutzen kannst.';

  @override
  String get howSellingWorks => 'So funktioniert der Verkauf';

  @override
  String get sellStep1 => 'Angebot einstellen: Event, Plätze und Preis.';

  @override
  String get sellStep2 =>
      'Ein Käufer bezahlt. Wir halten das Geld, bis die Tickets ankommen.';

  @override
  String get sellStep3 =>
      'Übertrage die Tickets und markiere sie als übertragen.';

  @override
  String get sellStep4 => 'Nach dem Event kommt das Geld auf deine IBAN.';

  @override
  String get ibanBadFormat =>
      'Eine IBAN beginnt mit Ländercode und zwei Ziffern, z. B. BA39 …';

  @override
  String ibanWrongLength(String country, int expected, int actual) {
    return 'Eine IBAN für $country hat $expected Zeichen, eingegeben sind $actual.';
  }

  @override
  String get ibanBadChecksum =>
      'Die Prüfziffer passt nicht. Bitte prüfe die Ziffern der IBAN.';

  @override
  String get cancelSale => 'Verkauf stornieren';

  @override
  String get cancelSaleTitle => 'Verkauf stornieren?';

  @override
  String get cancelSaleInfo =>
      'Der Käufer bekommt das ganze Geld zurück, und die Tickets kommen zurück in dein Angebot. Für diesen Verkauf gibt es keine Auszahlung. Das lässt sich nicht rückgängig machen.';

  @override
  String get keepSale => 'Nein, behalten';

  @override
  String get saleCancelled =>
      'Verkauf storniert. Der Käufer hat sein Geld zurück.';

  @override
  String get buyerNextCancelledBySeller =>
      'Der Verkäufer hat den Verkauf storniert. Du bekommst dein Geld vollständig zurück.';

  @override
  String get sellerNextCancelledBySeller =>
      'Du hast den Verkauf storniert. Der Käufer hat sein Geld zurück, die Tickets sind wieder im Verkauf.';

  @override
  String get cannotBuyOwnListing =>
      'Das sind deine Tickets. Dein eigenes Angebot kannst du nicht kaufen.';

  @override
  String get openListing => 'Angebot öffnen';

  @override
  String alertSoldTitle(String event) {
    return 'Tickets verkauft: $event';
  }

  @override
  String alertSoldBody(String quantity, String amount) {
    return '$quantity Stk. · $amount. Sende die Tickets an den Käufer.';
  }

  @override
  String get alertTicketsSentTitle => 'Tickets verschickt';

  @override
  String alertTicketsSentBody(String event) {
    return '$event: Der Verkäufer hat deine Tickets geschickt.';
  }

  @override
  String get alertRefundTitle => 'Verkauf storniert';

  @override
  String alertRefundBody(String event) {
    return '$event: Der Verkäufer hat storniert, du bekommst dein Geld zurück.';
  }

  @override
  String get alertView => 'Ansehen';

  @override
  String get changeIban => 'IBAN ändern';

  @override
  String get keepCurrentIban => 'Gespeicherte IBAN behalten';

  @override
  String get ibanHint => 'z. B. BA39 1290 0794 0102 8494';

  @override
  String get deleteAccountOpenOrders =>
      'Du hast offene Verkäufe oder Käufe. Schließe sie ab oder storniere sie, bevor du dein Konto löschst.';

  @override
  String get newVersionTitle => 'Neue Version verfügbar';

  @override
  String get newVersionBody =>
      'Lade die Seite neu für die neueste Version von Stubswap.';

  @override
  String get reload => 'Neu laden';
}
