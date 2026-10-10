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
  String get demoMode => 'Demo-Daten';

  @override
  String get demoModeInfo =>
      'Zeigt Beispiel-Bestellungen, -Verkäufe und -Auszahlungen. Nichts wird gespeichert.';

  @override
  String get demoBanner => 'Demo – Beispieldaten';

  @override
  String get buyer => 'Käufer';

  @override
  String get tools => 'Werkzeuge';
}
