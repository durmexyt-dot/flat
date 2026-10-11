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

  @override
  String get sellTitle => 'Prodaj karte';

  @override
  String get event => 'Događaj';

  @override
  String get eventName => 'Naziv događaja';

  @override
  String get venue => 'Mjesto održavanja';

  @override
  String get city => 'Grad';

  @override
  String get dateTime => 'Datum i vrijeme';

  @override
  String get pickDate => 'Odaberi datum';

  @override
  String get category => 'Kategorija';

  @override
  String get tickets => 'Karte';

  @override
  String get ticketType => 'Vrsta karte';

  @override
  String get ticketEticket => 'E-karta';

  @override
  String get ticketMobile => 'Mobilna';

  @override
  String get ticketPaper => 'Papirna';

  @override
  String get quantity => 'Količina';

  @override
  String get section => 'Sektor';

  @override
  String get row => 'Red';

  @override
  String get seats => 'Sjedišta';

  @override
  String get optional => 'neobavezno';

  @override
  String get price => 'Cijena';

  @override
  String get pricePerTicket => 'Cijena po karti';

  @override
  String buyerPays(String percent) {
    return 'Kupac plaća (s naknadom $percent%)';
  }

  @override
  String youReceive(String percent) {
    return 'Dobijaš po karti (naknada $percent%)';
  }

  @override
  String get totalPayout => 'Ukupna isplata';

  @override
  String get noteLabel => 'Napomena za kupca';

  @override
  String get publishListing => 'Objavi ponudu';

  @override
  String get listingPublished => 'Ponuda je objavljena';

  @override
  String get required => 'Obavezno polje';

  @override
  String get dateInPast => 'Datum mora biti u budućnosti';

  @override
  String get priceInvalid => 'Unesite ispravnu cijenu';

  @override
  String get verifyBeforeSelling =>
      'Potvrdi e-mail adresu da bi kupci mogli vjerovati tvojim ponudama.';

  @override
  String get verifyNow => 'Potvrdi';

  @override
  String get myListings => 'Moje ponude';

  @override
  String get filterAll => 'Sve';

  @override
  String get statusActive => 'Aktivna';

  @override
  String get statusReserved => 'Rezervisana';

  @override
  String get statusSoldOut => 'Rasprodana';

  @override
  String get statusExpired => 'Istekla';

  @override
  String get statusWithdrawn => 'Povučena';

  @override
  String get ended => 'Završene';

  @override
  String get noListings => 'Još nemaš ponuda';

  @override
  String get noListingsInfo =>
      'Imaš karte koje ne trebaš? Prodaj ih za nekoliko minuta.';

  @override
  String ticketsLeft(String count, String total) {
    return '$count od $total dostupno';
  }

  @override
  String ticketsCount(String count) {
    return '$count kom.';
  }

  @override
  String get perTicket => 'po karti';

  @override
  String get listingDetails => 'Detalji ponude';

  @override
  String get editPrice => 'Promijeni cijenu';

  @override
  String get withdrawListing => 'Povuci ponudu';

  @override
  String get withdrawConfirm =>
      'Ponuda više neće biti vidljiva kupcima. Nastaviti?';

  @override
  String get listingWithdrawn => 'Ponuda je povučena';

  @override
  String get listingNotFound => 'Ponuda nije pronađena';

  @override
  String get yourListing => 'Tvoja ponuda';

  @override
  String get buyTickets => 'Kupi karte';

  @override
  String get total => 'Ukupno';

  @override
  String get serviceFee => 'Naknada za uslugu';

  @override
  String get checkoutSoonTitle => 'Plaćanje uskoro';

  @override
  String get checkoutSoonInfo =>
      'Sigurno plaćanje s garancijom za kupce je u izradi. Ponudu možeš već pregledati.';

  @override
  String get buyerProtection =>
      'Garancija za kupce: dobijaš važeće karte na vrijeme ili povrat novca.';

  @override
  String get sellerVerified => 'Verifikovani prodavac';

  @override
  String searchNoResults(String query) {
    return 'Nema rezultata za „$query”';
  }

  @override
  String get upcomingEvents => 'Nadolazeći događaji';

  @override
  String fromPrice(String price) {
    return 'od $price';
  }

  @override
  String get ok => 'U redu';

  @override
  String get orderPendingPayment => 'Čeka plaćanje';

  @override
  String get orderPaid => 'Plaćeno';

  @override
  String get orderTicketsSent => 'Karte poslane';

  @override
  String get orderCompleted => 'Završeno';

  @override
  String get orderCancelled => 'Otkazano';

  @override
  String get orderRefunded => 'Novac vraćen';

  @override
  String get orderDisputed => 'U rješavanju';

  @override
  String get payoutPending => 'Čeka događaj';

  @override
  String get payoutScheduled => 'Zakazano';

  @override
  String get payoutProcessing => 'U obradi';

  @override
  String get payoutPaid => 'Isplaćeno';

  @override
  String get payoutFailed => 'Neuspjelo';

  @override
  String get buyerNextPendingPayment => 'Završi plaćanje da rezervišeš karte.';

  @override
  String get buyerNextPaid =>
      'Prodavac šalje karte. Dobit ćeš ih najkasnije prije događaja.';

  @override
  String get buyerNextTicketsSent =>
      'Karte su ti poslane. Provjeri e-mail ili aplikaciju organizatora.';

  @override
  String get buyerNextCompleted => 'Uživaj u događaju!';

  @override
  String get buyerNextCancelled =>
      'Narudžba je otkazana. Ništa nije naplaćeno.';

  @override
  String get buyerNextRefunded => 'Iznos je vraćen na tvoj način plaćanja.';

  @override
  String get buyerNextDisputed =>
      'Naš tim provjerava narudžbu i javit će ti se.';

  @override
  String get sellerNextPendingPayment => 'Kupac plaća. Karte su rezervisane.';

  @override
  String get sellerNextPaid => 'Pošalji karte kupcu što prije.';

  @override
  String get sellerNextTicketsSent => 'Isplata slijedi nakon događaja.';

  @override
  String get sellerNextCompleted => 'Prodaja je završena. Pogledaj isplate.';

  @override
  String get sellerNextCancelled =>
      'Narudžba je otkazana. Karte su ponovo u prodaji.';

  @override
  String get sellerNextRefunded =>
      'Kupcu je vraćen novac. Za ovu prodaju nema isplate.';

  @override
  String get sellerNextDisputed =>
      'Kupac je prijavio problem. Isplata čeka rješenje.';

  @override
  String get payoutNextPending => 'Novac se oslobađa nakon održanog događaja.';

  @override
  String get payoutNextScheduled => 'Isplata je u sljedećem krugu isplata.';

  @override
  String get payoutNextProcessing =>
      'Banka obrađuje uplatu, obično 1–3 radna dana.';

  @override
  String get payoutNextPaid => 'Novac je na tvom računu.';

  @override
  String get payoutNextFailed =>
      'Provjeri način isplate. Pokušat ćemo ponovo nakon izmjene.';

  @override
  String get invoice => 'Račun';

  @override
  String get orderNumber => 'Broj narudžbe';

  @override
  String get orderDate => 'Datum narudžbe';

  @override
  String get paymentMethod => 'Način plaćanja';

  @override
  String get saleAmount => 'Iznos prodaje';

  @override
  String get sellerFeeLabel => 'Naknada prodavca';

  @override
  String get yourEarnings => 'Tvoja zarada';

  @override
  String get copied => 'Kopirano';

  @override
  String get copy => 'Kopiraj';

  @override
  String get whatsNext => 'Šta slijedi';

  @override
  String get statusHistory => 'Tok statusa';

  @override
  String get orderDetails => 'Detalji narudžbe';

  @override
  String get saleDetails => 'Detalji prodaje';

  @override
  String get payoutDetails => 'Detalji isplate';

  @override
  String get purchases => 'Kupovine i računi';

  @override
  String get sales => 'Prodaje';

  @override
  String get payouts => 'Isplate';

  @override
  String get payoutMethod => 'Način isplate';

  @override
  String get noPurchases => 'Još nemaš kupovina';

  @override
  String get noPurchasesInfo => 'Kupljene karte i računi pojavit će se ovdje.';

  @override
  String get noSales => 'Još nemaš prodaja';

  @override
  String get noSalesInfo => 'Kada neko kupi tvoje karte, vidjet ćeš to ovdje.';

  @override
  String get noPayouts => 'Još nema isplata';

  @override
  String get noPayoutsInfo =>
      'Novac od prodaje stiže na tvoj račun nakon događaja.';

  @override
  String get filterInProgress => 'U toku';

  @override
  String get filterCompleted => 'Završene';

  @override
  String get filterCancelled => 'Otkazane';

  @override
  String get payoutsUpcoming => 'Uskoro na računu';

  @override
  String get payoutsPaidTotal => 'Isplaćeno ukupno';

  @override
  String expectedOn(String date) {
    return 'Očekivano $date';
  }

  @override
  String get payoutOrders => 'Narudžbe u isplati';

  @override
  String get failureReason => 'Razlog';

  @override
  String get setUpPayout => 'Dodaj način isplate';

  @override
  String get payoutMethodMissing =>
      'Dodaj bankovni račun da bi primio novac od prodaje.';

  @override
  String get accountHolder => 'Vlasnik računa';

  @override
  String get iban => 'IBAN';

  @override
  String get ibanInvalid => 'Neispravan IBAN';

  @override
  String get payoutMethodInfo =>
      'Isplate stižu na ovaj račun 3–5 radnih dana nakon događaja.';

  @override
  String get payoutMethodSaved => 'Način isplate je sačuvan';

  @override
  String get change => 'Promijeni';

  @override
  String get buyer => 'Kupac';

  @override
  String get support => 'Podrška';

  @override
  String get helpCenter => 'Centar za pomoć';

  @override
  String get contactSupport => 'Kontaktiraj podršku';

  @override
  String get about => 'O aplikaciji';

  @override
  String get aboutText =>
      'Stubswap je sigurno tržište za kupovinu i prodaju karata za događaje.';

  @override
  String get getHelpOrder => 'Pomoć oko ove narudžbe';

  @override
  String get getHelpPayout => 'Pomoć oko ove isplate';

  @override
  String get topic => 'Tema';

  @override
  String get topicOrder => 'Kupovina';

  @override
  String get topicSale => 'Prodaja';

  @override
  String get topicPayout => 'Isplata';

  @override
  String get topicAccount => 'Račun';

  @override
  String get topicOther => 'Ostalo';

  @override
  String get reference => 'Broj narudžbe ili ponude';

  @override
  String get message => 'Poruka';

  @override
  String get messageHint =>
      'Opiši šta se desilo. Što više detalja, brže pomažemo.';

  @override
  String get messageTooShort => 'Napiši barem 20 znakova';

  @override
  String get send => 'Pošalji';

  @override
  String get requestSent => 'Zahtjev je poslan';

  @override
  String requestSentInfo(String number, String email) {
    return 'Broj tvog zahtjeva je $number. Odgovorit ćemo na $email, obično u roku od 24 sata.';
  }

  @override
  String get done => 'Gotovo';

  @override
  String get stillNeedHelp => 'Nisi pronašao odgovor?';

  @override
  String get faqBuySafeQ => 'Da li je kupovina na Stubswapu sigurna?';

  @override
  String get faqBuySafeA =>
      'Da. Novac zadržavamo dok ne dobiješ karte. Ako karte ne stignu na vrijeme ili nisu važeće, vraćamo ti novac.';

  @override
  String get faqWhenTicketsQ => 'Kada ću dobiti karte?';

  @override
  String get faqWhenTicketsA =>
      'Prodavac ih šalje nakon plaćanja, najkasnije prije događaja. Status vidiš u Kupovine i računi.';

  @override
  String get faqFeesQ => 'Koje su naknade?';

  @override
  String faqFeesA(String buyer, String seller) {
    return 'Kupac plaća naknadu za uslugu od $buyer% na cijenu karte. Prodavcu zadržavamo $seller% od prodajne cijene.';
  }

  @override
  String get faqPayoutWhenQ => 'Kada dobijam novac od prodaje?';

  @override
  String get faqPayoutWhenA =>
      'Nakon održanog događaja isplata se zakazuje i stiže na tvoj IBAN za 3–5 radnih dana.';

  @override
  String get faqSendTicketsQ => 'Kako da pošaljem karte kupcu?';

  @override
  String get faqSendTicketsA =>
      'E-karte i mobilne karte prenosiš preko organizatora na e-mail kupca. Papirne karte šalješ preporučeno. Status ažuriraj odmah nakon slanja.';

  @override
  String get faqCancelQ => 'Šta ako je događaj otkazan?';

  @override
  String get faqCancelA =>
      'Kupci dobijaju puni povrat novca, a prodaje se poništavaju bez naknade za prodavca.';

  @override
  String get checkout => 'Plaćanje';

  @override
  String payAmount(String amount) {
    return 'Plati $amount';
  }

  @override
  String get testModeBadge => 'Testni način · bez pravog novca';

  @override
  String get stripeSimulator => 'Stripe simulator';

  @override
  String get simulatorInfo =>
      'Simulacija plaćanja. Kasnije je zamjenjuje pravi Stripe.';

  @override
  String get cardNumber => 'Broj kartice';

  @override
  String get cardExpiry => 'Datum isteka';

  @override
  String get cardCvc => 'CVC';

  @override
  String get simulateSuccess => 'Plaćanje uspješno';

  @override
  String get simulateSuccessInfo => 'Isključi da simuliraš odbijenu karticu.';

  @override
  String get declineReason => 'Razlog odbijanja';

  @override
  String get failCardDeclined => 'Kartica odbijena';

  @override
  String get failInsufficientFunds => 'Nedovoljno sredstava';

  @override
  String get failExpiredCard => 'Kartica je istekla';

  @override
  String get failProcessingError => 'Greška pri obradi';

  @override
  String get failSoldOut => 'Karte su u međuvremenu prodane';

  @override
  String get processingPayment => 'Obrada plaćanja…';

  @override
  String get paymentSucceeded => 'Plaćanje uspješno';

  @override
  String get paymentFailedTitle => 'Plaćanje nije uspjelo';

  @override
  String paymentFailedInfo(String reason) {
    return '$reason. Ništa nije naplaćeno. Pokušaj ponovo ili koristi drugu karticu.';
  }

  @override
  String get tryAgain => 'Pokušaj ponovo';

  @override
  String get payNow => 'Plati sada';

  @override
  String get markTicketsSent => 'Označi karte kao poslane';

  @override
  String get ticketsMarkedSent => 'Kupac je obaviješten';

  @override
  String get buyerEmail => 'Karte stižu na';

  @override
  String get notAvailableAnymore => 'Ova ponuda više nije dostupna';

  @override
  String get payoutRequiredTitle => 'Prvo dodaj način isplate';

  @override
  String get payoutRequiredInfo =>
      'Da bismo ti mogli isplatiti novac od prodaje, potreban nam je tvoj bankovni račun (IBAN). Nakon toga možeš odmah objaviti karte.';
}
