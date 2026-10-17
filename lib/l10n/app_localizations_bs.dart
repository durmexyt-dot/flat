// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Bosnian (`bs`).
class AppLocalizationsBs extends AppLocalizations {
  AppLocalizationsBs([String locale = 'bs']) : super(locale);

  @override
  String datesNearbyCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count događaja u tvojoj blizini',
      few: '$count događaja u tvojoj blizini',
      one: '1 događaj u tvojoj blizini',
    );
    return '$_temp0';
  }

  @override
  String get datesNoneNearby => 'Nema događaja u tvojoj blizini';

  @override
  String datesNoneNearbyInfo(String city) {
    return 'U gradu $city i okolini trenutno nema termina.';
  }

  @override
  String datesElsewhereCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count događaja na drugim mjestima',
      few: '$count događaja na drugim mjestima',
      one: '1 događaj na drugom mjestu',
    );
    return '$_temp0';
  }

  @override
  String datesAllCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count termina',
      few: '$count termina',
      one: '1 termin',
    );
    return '$_temp0';
  }

  @override
  String get datesPickCity => 'Odaberi grad da vidiš događaje u blizini';

  @override
  String datesNearCity(String city) {
    return 'U blizini: $city';
  }

  @override
  String get showTickets => 'Prikaži karte';

  @override
  String get noTicketsAvailable => 'Nema karata';

  @override
  String ticketsFrom(String price) {
    return 'od $price';
  }

  @override
  String get ticketsPageTitle => 'Karte';

  @override
  String get otherDates => 'Ostali termini';

  @override
  String get seatMapSoon => 'Plan sjedenja uskoro';

  @override
  String get seatMapSoonInfo =>
      'Za ovo mjesto još nemamo plan. Sektor i red vidiš na svakoj ponudi.';

  @override
  String get seatMapHint => 'Dodirni sektor da vidiš samo njegove ponude';

  @override
  String get seatMapStage => 'Bina';

  @override
  String seatMapSectionOffers(String name, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ponuda',
      few: '$count ponude',
      one: '1 ponuda',
      zero: 'nema ponuda',
    );
    return '$name: $_temp0';
  }

  @override
  String sectionFilter(String name) {
    return 'Sektor: $name';
  }

  @override
  String get filtersMore => 'Cijena i vrsta karte';

  @override
  String get filterPrice => 'Cijena po karti';

  @override
  String get filterTicketType => 'Vrsta karte';

  @override
  String get filterTogether => 'Sjedišta jedno do drugog';

  @override
  String get filterTogetherInfo =>
      'Samo ponude za koje prodavac navodi da su mjesta jedno do drugog';

  @override
  String get filtersReset => 'Poništi filtere';

  @override
  String get offersNoneForFilters => 'Nijedna ponuda ne odgovara filterima';

  @override
  String get offerTogether => 'Jedno do drugog';

  @override
  String get sellTogether => 'Mjesta su jedno do drugog';

  @override
  String get sellTogetherInfo =>
      'Kupci koji traže više mjesta zajedno lakše te pronađu.';

  @override
  String get sellSectionsOfVenue => 'Sektori ovog mjesta';

  @override
  String get eventPerformer => 'Izvođač / turneja (neobavezno)';

  @override
  String get eventPerformerInfo =>
      'Termini istog izvođača u drugim gradovima prikazuju se zajedno.';

  @override
  String get adminSeatMaps => 'Planovi sjedenja';

  @override
  String get adminSeatMapsInfo =>
      'Sektori mjesta, za kupce na stranici s kartama';

  @override
  String get seatMapNone => 'Nema plana';

  @override
  String seatMapSectionsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count sektora',
      few: '$count sektora',
      one: '1 sektor',
    );
    return '$_temp0';
  }

  @override
  String get seatMapTitle => 'Plan sjedenja';

  @override
  String get seatMapPicture => 'Slika plana (neobavezno)';

  @override
  String get seatMapPictureHint =>
      'Slika se ne obrezuje. Bez slike sektori se crtaju na praznoj podlozi.';

  @override
  String get seatMapDrawHint =>
      'Povuci prstom ili mišem da nacrtaš sektor. Dodirni sektor da ga preimenuješ ili obrišeš.';

  @override
  String get seatMapDrawSection => 'Sektor';

  @override
  String get seatMapSectionName => 'Naziv sektora';

  @override
  String seatMapSectionDefault(int n) {
    return 'Sektor $n';
  }

  @override
  String get seatMapDeleteSection => 'Obriši sektor';

  @override
  String get seatMapRemoveStage => 'Ukloni binu';

  @override
  String get seatMapDelete => 'Obriši plan';

  @override
  String get seatMapDeleteInfo => 'Kupci više neće vidjeti plan za ovo mjesto.';

  @override
  String seatMapUnmatched(String names) {
    return 'Sektori iz ponuda koji nisu na planu: $names';
  }

  @override
  String get seatMapDuplicate => 'Dva sektora imaju isti naziv';

  @override
  String get seatMapVenues => 'Mjesta iz događaja';

  @override
  String get quantityDecrease => 'Jedna karta manje';

  @override
  String get quantityIncrease => 'Jedna karta više';

  @override
  String get offersHowMany => 'Koliko karata trebaš zajedno?';

  @override
  String get navInbox => 'Upiti';

  @override
  String get navSell => 'Prodaj';

  @override
  String get accountGroupHelp => 'Pomoć';

  @override
  String get accountGroupTeam => 'Tim';

  @override
  String get profileAndSettings => 'Profil i postavke';

  @override
  String get offerAmountAtCheckout => 'Broj karata biraš u sljedećem koraku.';

  @override
  String get offerAvailable => 'dostupno';

  @override
  String get offerPerTicket => 'po karti';

  @override
  String get offerNoSeats => 'Bez označenih mjesta';

  @override
  String eventsOffersCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ponuda',
      few: '$count ponude',
      one: '1 ponuda',
    );
    return '$_temp0';
  }

  @override
  String get offersAnyAmount => 'Sve';

  @override
  String offersAmount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'karata',
      few: 'karte',
      one: 'karta',
    );
    return '$count $_temp0';
  }

  @override
  String offersAmountOrMore(int count) {
    return '$count+';
  }

  @override
  String offersNoneForAmount(int count) {
    return 'Nema ponude za $count karte zajedno';
  }

  @override
  String get offersNoneForAmountInfo =>
      'Probaj manji broj ili pogledaj kasnije.';

  @override
  String get eventsHaveTickets => 'Imaš karte za ovaj događaj?';

  @override
  String get eventsHaveTicketsInfo =>
      'Prodaj ih sigurno fanovima kojima trebaju.';

  @override
  String get signInToContinue => 'Prijavi se ili napravi račun da nastaviš.';

  @override
  String get handoverSection => 'Predaja karata';

  @override
  String get handoverTitle => 'Kako si predao karte?';

  @override
  String get handoverSubmit => 'Karte predane';

  @override
  String get handoverInfoMobile =>
      'Prenesi karte u aplikaciji organizatora (npr. Eventim, Ticketmaster) na račun kupca i upiši kome si ih prenio. Ovi podaci pomažu ako dođe do problema.';

  @override
  String get handoverInfoPaper =>
      'Pošalji karte poštom ili kurirom (s brojem pošiljke ako ga imaš) ili ih predaj lično. Ovi podaci pomažu ako dođe do problema.';

  @override
  String get handoverAppTransfer => 'Prenos u aplikaciji';

  @override
  String get handoverPost => 'Pošta';

  @override
  String get handoverCourier => 'Kurir';

  @override
  String get handoverInPerson => 'Lično';

  @override
  String get handoverRecipient => 'Prenijeto na';

  @override
  String get handoverRecipientInfo =>
      'Ime ili e-mail računa kupca u aplikaciji organizatora';

  @override
  String get handoverRecipientMissing => 'Upiši kome si prenio karte';

  @override
  String get handoverTracking => 'Broj pošiljke';

  @override
  String get handoverTrackingInfo => 'Neobavezno, ali preporučeno';

  @override
  String get handoverNote => 'Napomena';

  @override
  String get handoverNoteInPerson => 'Gdje i kada ste se sreli';

  @override
  String get handoverSentAt => 'Predano';

  @override
  String get handoverConfirm => 'Potvrdi prijem';

  @override
  String get handoverConfirmInfo =>
      'Kad karte budu kod tebe, potvrdi prijem. Ako ne stignu, prijavi problem.';

  @override
  String get handoverConfirmed => 'Hvala! Prijem je potvrđen.';

  @override
  String handoverConfirmedAt(String date) {
    return 'Kupac je potvrdio prijem $date';
  }

  @override
  String get handoverWaiting => 'Kupac još nije potvrdio prijem.';

  @override
  String get dataExportSection => 'Tvoji podaci';

  @override
  String get dataExport => 'Preuzmi moje podatke';

  @override
  String get dataExportInfo =>
      'Sve što Stubswap čuva o tvom računu (profil, ponude, narudžbe, isplate, upiti, računi) kao JSON datoteka.';

  @override
  String get dataExportDone => 'Podaci su preuzeti.';

  @override
  String get invoicesTitle => 'Računi';

  @override
  String get invoicesInfo =>
      'Računi Stubswapa za servisnu naknadu tvojih kupovina i prodaja.';

  @override
  String get invoicesEmpty => 'Još nema računa';

  @override
  String get invoicesPlatform => 'Računi Stubswapa';

  @override
  String get invoiceTitle => 'Račun';

  @override
  String get invoiceCreditNote => 'Storno račun';

  @override
  String get invoiceNotFound => 'Račun nije pronađen';

  @override
  String get invoiceRecipient => 'Primalac';

  @override
  String get invoiceTaxId => 'JIB';

  @override
  String get invoiceVatNumber => 'PDV broj';

  @override
  String get invoiceFeeBuyer => 'Servisna naknada za kupovinu karata';

  @override
  String get invoiceFeeSeller => 'Naknada za prodaju karata';

  @override
  String get invoiceOrder => 'Narudžba';

  @override
  String invoiceBase(int percent, String amount) {
    return '$percent % od cijene karata $amount';
  }

  @override
  String get invoiceNet => 'Iznos bez PDV-a';

  @override
  String invoiceVat(int percent) {
    return 'PDV $percent %';
  }

  @override
  String get invoiceVatTotal => 'PDV';

  @override
  String get invoiceNoVat => 'Bez PDV-a';

  @override
  String get invoiceGross => 'Ukupno';

  @override
  String invoiceCreditFor(String number) {
    return 'Stornira račun $number.';
  }

  @override
  String get invoicePaidBuyer => 'Plaćeno uz kupovinu karata.';

  @override
  String get invoicePaidSeller => 'Odbijeno od isplate za prodaju.';

  @override
  String get invoiceFooter =>
      'Račun je izdat elektronski i važi bez potpisa i pečata.';

  @override
  String get invoiceDownload => 'Preuzmi PDF';

  @override
  String get invoiceDownloadUnavailable => 'Preuzimanje ovdje još nije moguće.';

  @override
  String get adminInvoicesTitle => 'Računi platforme';

  @override
  String get adminInvoicesInfo =>
      'Svi računi po mjesecima, ukupni iznosi i izvoz za knjigovodstvo';

  @override
  String get invoicesPrevMonth => 'Prethodni mjesec';

  @override
  String get invoicesNextMonth => 'Sljedeći mjesec';

  @override
  String invoicesCount(int count) {
    return '$count računa';
  }

  @override
  String get invoicesExport => 'Izvoz CSV (Excel)';

  @override
  String get invoicesNoneInMonth => 'U ovom mjesecu nema računa.';

  @override
  String get moderationTitle => 'Moderacija';

  @override
  String get moderationInfo => 'Prijave, kopirane karte, blokiranje korisnika';

  @override
  String get moderationOpen => 'Otvoreno';

  @override
  String get moderationHandled => 'Riješeno';

  @override
  String get moderationUsers => 'Korisnici';

  @override
  String get moderationNoOpen => 'Nema otvorenih prijava';

  @override
  String get moderationNoHandled => 'Još nema riješenih prijava';

  @override
  String get moderationDuplicate => 'Kopirana karta';

  @override
  String get moderationDuplicateInfo =>
      'Ista datoteka karte je već učitana za drugu ponudu. Kopija je blokirana i neće biti isporučena. Provjeri prodavca.';

  @override
  String get moderationReport => 'Prijava ponude';

  @override
  String get moderationNote => 'Bilješka tima';

  @override
  String get moderationOpenSeller => 'Prodavac';

  @override
  String get moderationRemoveListing => 'Ukloni ponudu';

  @override
  String get moderationRemoveListingInfo =>
      'Ponuda se odmah skida s prodaje. Prodavac dobija e-mail s razlogom. Postojeće kupovine ostaju.';

  @override
  String get moderationListingRemoved => 'Ponuda uklonjena';

  @override
  String get moderationResolve => 'Riješeno';

  @override
  String get moderationDismiss => 'Odbaci';

  @override
  String get moderationReason => 'Razlog';

  @override
  String get moderationReasonInfo =>
      'Neobavezno; vidi se u dnevniku i u e-mailu korisniku.';

  @override
  String get moderationFindUser => 'Pronađi korisnika';

  @override
  String get moderationFindUserInfo =>
      'Tačna e-mail adresa ili korisničko ime.';

  @override
  String get moderationSearch => 'Traži';

  @override
  String get moderationUserNotFound => 'Korisnik nije pronađen.';

  @override
  String get moderationUser => 'Korisnik';

  @override
  String get moderationBlock => 'Blokiraj';

  @override
  String get moderationUnblock => 'Deblokiraj';

  @override
  String get moderationBlockInfo =>
      'Korisnik više ne može prodavati, kupovati ni dodavati događaje. Njegove aktivne ponude se uklanjaju.';

  @override
  String get moderationUnblockInfo =>
      'Korisnik ponovo može prodavati i kupovati. Uklonjene ponude ostaju uklonjene.';

  @override
  String get moderationBlocked => 'Korisnik blokiran';

  @override
  String get moderationUnblocked => 'Korisnik deblokiran';

  @override
  String get moderationIsBlocked => 'Blokiran';

  @override
  String get moderationNewSeller => 'Novi prodavac (limiti)';

  @override
  String get moderationTrustedSeller => 'Bez limita';

  @override
  String moderationStats(int listings, int sales) {
    return '$listings aktivnih ponuda · $sales završenih prodaja';
  }

  @override
  String get moderationTrust => 'Ukloni limite';

  @override
  String get moderationUntrust => 'Vrati limite';

  @override
  String get moderationListings => 'Ponude';

  @override
  String get moderationOrders => 'Narudžbe';

  @override
  String get moderationAsBuyer => 'Kupac';

  @override
  String get moderationAsSeller => 'Prodavac';

  @override
  String get moderationLog => 'Dnevnik tima';

  @override
  String get moderationNone => 'Nema.';

  @override
  String get moderationRefund => 'Vrati novac';

  @override
  String moderationRefundInfo(String number) {
    return 'Kupac dobija puni iznos za $number, prodavac nema isplatu. Ovo se ne može poništiti.';
  }

  @override
  String get moderationRefunded => 'Novac vraćen';

  @override
  String get reportReasonFake => 'Lažne ili nevažeće karte';

  @override
  String get reportReasonPrice => 'Previsoka cijena';

  @override
  String get reportReasonWrongEvent => 'Pogrešan događaj ili podaci';

  @override
  String get reportReasonSpam => 'Spam ili prevara';

  @override
  String get reportReasonOther => 'Ostalo';

  @override
  String get reportListing => 'Prijavi ponudu';

  @override
  String get reportListingInfo =>
      'Nešto nije u redu s ovom ponudom? Tim Stubswap će je provjeriti.';

  @override
  String get reportDetails => 'Detalji (neobavezno)';

  @override
  String get reportSend => 'Pošalji prijavu';

  @override
  String get reportSent => 'Hvala! Tim će provjeriti ponudu.';

  @override
  String get reportAlready => 'Već si prijavio ovu ponudu.';

  @override
  String get accountBlocked => 'Tvoj račun je blokiran';

  @override
  String get accountBlockedInfo =>
      'Ne možeš prodavati ni kupovati. Za pitanja kontaktiraj podršku.';

  @override
  String get sellNewSeller => 'Novi prodavac';

  @override
  String get sellLimitReached => 'Dostignut limit za nove prodavce';

  @override
  String sellLimitInfo(int listings, int tickets, int sales) {
    return 'Kao novi prodavac možeš imati do $listings aktivnih ponuda s najviše $tickets karata po ponudi. Nakon $sales završenih prodaja limiti nestaju.';
  }

  @override
  String resaleLimitHint(int percent) {
    return 'Najviše $percent % iznad originalne cijene';
  }

  @override
  String resaleMaxPrice(String price, int percent) {
    return 'Najviše $price ($percent % iznad originalne cijene)';
  }

  @override
  String resaleTooHigh(String price) {
    return 'Najviša dozvoljena cijena je $price';
  }

  @override
  String get resaleNeedsFaceValue =>
      'Ova ponuda nema originalnu cijenu. Povuci je i objavi ponovo s originalnom cijenom.';

  @override
  String get statusRemoved => 'Uklonjena';

  @override
  String numberBetween(int min, int max) {
    return 'Unesi broj od $min do $max';
  }

  @override
  String get resaleTitle => 'Pravila preprodaje';

  @override
  String get resaleIntro =>
      'Odredi koliko iznad originalne cijene se karte smiju preprodavati. Pojedini događaji mogu imati vlastito ograničenje.';

  @override
  String get resaleRules => 'Pravila';

  @override
  String get resaleLimitPrice => 'Ograniči cijenu';

  @override
  String get resaleLimitPriceInfo =>
      'Cijena po karti smije biti najviše određeni postotak iznad originalne cijene.';

  @override
  String get resaleRequireFace => 'Originalna cijena obavezna';

  @override
  String get resaleRequireFaceInfo =>
      'Prodavci moraju unijeti cijenu odštampanu na karti. Uz ograničenje cijene uvijek je obavezna.';

  @override
  String get resaleMarkup => 'Najviše iznad originalne cijene';

  @override
  String get resaleMarkupInfo => '0 % znači: najviše originalna cijena.';

  @override
  String resaleExample(String face, String max) {
    return 'Primjer: karta od $face smije koštati najviše $max.';
  }

  @override
  String get resaleNotice =>
      'Važi za nove ponude i promjene cijene. Postojeće ponude ostaju dok ih prodavac ne promijeni.';

  @override
  String get resaleEventMarkup => 'Vlastito ograničenje za ovaj događaj';

  @override
  String get resaleEventMarkupInfo =>
      'Najviše % iznad originalne cijene. Prazno: opće pravilo.';

  @override
  String get limitsTitle => 'Limiti za nove prodavce';

  @override
  String get limitsIntro =>
      'Novi prodavci mogu prodavati samo malo karata dok ne završe nekoliko prodaja. To štiti kupce od prevara s lažnim kartama.';

  @override
  String get limitsListings => 'Aktivnih ponuda najviše';

  @override
  String get limitsListingsInfo =>
      'Koliko ponuda novi prodavac može imati istovremeno.';

  @override
  String get limitsTickets => 'Karata po ponudi najviše';

  @override
  String get limitsTicketsInfo => 'Koliko karata smije biti u jednoj ponudi.';

  @override
  String get limitsTrusted => 'Bez limita nakon prodaja';

  @override
  String get limitsTrustedInfo =>
      'Nakon koliko završenih prodaja limiti nestaju. Tim može i ručno ukloniti limite prodavcu.';

  @override
  String get limitsNotice =>
      'Važi odmah za nove ponude. Postojeće ponude ostaju.';

  @override
  String get companyTitle => 'Podaci o firmi';

  @override
  String get companyIntro =>
      'Ovi podaci stoje na računima za servisnu naknadu. Važe za nove račune.';

  @override
  String get companyName => 'Naziv firme';

  @override
  String get companyAddress => 'Adresa';

  @override
  String get companyTaxId => 'Identifikacioni broj (JIB)';

  @override
  String get companyVatNumber => 'PDV broj';

  @override
  String get companyVat => 'PDV';

  @override
  String get companyVatInfo =>
      'Uključen u servisnu naknadu (u BiH 17 %; 0 ako firma nije u sistemu PDV-a).';

  @override
  String get companyEmail => 'E-mail za račune';

  @override
  String get companyPrefix => 'Prefiks računa';

  @override
  String get companyPrefixInfo => '2–6 slova, npr. SSW → SSW-2026-00001';

  @override
  String get companyPrefixInvalid => '2 do 6 slova bez razmaka';

  @override
  String get companyNotice =>
      'Brojevi računa idu redom po godini, bez praznina. Za poreska pitanja pitaj računovođu.';

  @override
  String get disputeOpenOrder => 'Otvori narudžbu';

  @override
  String get deliveryPageTitle => 'Karte za ponudu';

  @override
  String get deliveryFilesSection => 'Učitane karte';

  @override
  String deliveryProgress(int done, int total) {
    return '$done od $total karata učitano';
  }

  @override
  String get deliveryAddFile => 'Dodaj karte';

  @override
  String get deliveryAllUploaded => 'Sve karte su učitane.';

  @override
  String get deliveryInfoTitle => 'Kako funkcioniše';

  @override
  String get deliveryInfo =>
      'Karte se automatski šalju kupcu odmah nakon plaćanja. Učitaj ih najkasnije 24 sata prije događaja – inače kupci automatski dobijaju povrat novca.';

  @override
  String get deliveryFileTypes =>
      'PDF, PNG, JPG ili WebP, najviše 10 MB po fajlu.';

  @override
  String get deliveryManualTitle => 'Mobilne i papirne karte';

  @override
  String get deliveryManualInfo =>
      'Ove karte predaješ kupcu direktno (npr. prenosom u aplikaciji organizatora ili lično). Nakon predaje potvrdi slanje u prodaji.';

  @override
  String get deliveryNoFiles => 'Još nema učitanih karata.';

  @override
  String get deliveryWaiting => 'Čeka kupca';

  @override
  String deliverySentTo(String order) {
    return 'Poslano kupcu $order';
  }

  @override
  String deliveryFileTickets(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count karata',
      few: '$count karte',
      one: '$count karta',
    );
    return '$_temp0';
  }

  @override
  String get deliveryHowManyTitle => 'Koliko karata je u fajlu?';

  @override
  String get deliveryHowManyInfo =>
      'Jedan PDF može sadržavati više karata. Kupac dobija cijeli fajl.';

  @override
  String get deliveryUpload => 'Učitaj';

  @override
  String get deliveryUploaded => 'Karte učitane';

  @override
  String get deliveryUploading => 'Učitavam…';

  @override
  String get deliveryWrongType =>
      'Ova vrsta fajla nije podržana. Koristi PDF, PNG, JPG ili WebP.';

  @override
  String get deliveryTooBig => 'Fajl je veći od 10 MB.';

  @override
  String get deliveryUploadError => 'Učitavanje nije uspjelo. Pokušaj ponovo.';

  @override
  String get deliveryPickUnsupported =>
      'Učitavanje fajlova je za sada moguć samo u web pregledniku.';

  @override
  String get deliveryDeleteTitle => 'Obrisati fajl?';

  @override
  String get deliveryDeleteInfo =>
      'Fajl još nije poslan kupcu i bit će uklonjen.';

  @override
  String get deliveryDelete => 'Obriši';

  @override
  String get deliveryDeleted => 'Fajl obrisan';

  @override
  String get deliveryNoAccessTitle => 'Nemaš pristup';

  @override
  String get deliveryNoAccess =>
      'Samo prodavac može učitati karte za ovu ponudu.';

  @override
  String get deliveryMissingBadge => 'Karte nisu učitane';

  @override
  String get deliveryUploadAction => 'Učitaj karte';

  @override
  String deliverySalesWarning(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Imaš $count prodanih karata koje još nisu učitane',
      few: 'Imaš $count prodane karte koje još nisu učitane',
      one: 'Imaš $count prodanu kartu koja još nije učitana',
    );
    return '$_temp0';
  }

  @override
  String deliveryDeadline(String date) {
    return 'Rok: $date';
  }

  @override
  String get deliverySellerMissingTitle => 'Karte još nisu učitane';

  @override
  String deliverySellerMissingInfo(String date) {
    return 'Učitaj ih do $date. Ako ne stignu na vrijeme, kupac automatski dobija povrat novca.';
  }

  @override
  String get deliveryBuyerSection => 'Tvoje karte';

  @override
  String get deliveryDownload => 'Preuzmi';

  @override
  String deliveryBuyerWaiting(String date) {
    return 'Prodavac još nije poslao karte. Rok: $date. Ako ih ne pošalje, automatski dobijaš povrat novca.';
  }

  @override
  String get deliveryDownloadError => 'Preuzimanje nije uspjelo.';

  @override
  String get deliveryCancelSeller => 'Prodavac je otkazao';

  @override
  String get deliveryCancelExpired =>
      'Plaćanje nije završeno u roku od 15 minuta';

  @override
  String get deliveryCancelDeadline =>
      'Karte nisu poslane na vrijeme – novac vraćen';

  @override
  String get deliveryCancelEvent => 'Događaj je otkazan – novac vraćen';

  @override
  String get deliveryCancelSupport => 'Riješeno preko podrške – novac vraćen';

  @override
  String get deliveryAlertArrivedTitle => 'Karte su stigle';

  @override
  String deliveryAlertArrivedBody(String event) {
    return '$event: preuzmi karte u narudžbi.';
  }

  @override
  String get deliveryAlertRefundTitle => 'Povrat novca';

  @override
  String deliveryAlertRefundBody(String event, String reason) {
    return '$event: $reason';
  }

  @override
  String get deliveryAlertDeadlineTitle =>
      'Prodaja otkazana – karte nisu učitane';

  @override
  String deliveryAlertDeadlineBody(String event) {
    return '$event: kupcu je vraćen novac.';
  }

  @override
  String reservationHeld(String time) {
    return 'Karte su rezervisane za tebe još $time';
  }

  @override
  String get reservationHint =>
      'Kada pokreneš plaćanje, karte su 15 minuta rezervisane samo za tebe.';

  @override
  String get reservationExpiredTitle => 'Rezervacija je istekla';

  @override
  String get reservationExpiredInfo =>
      'Plaćanje nije završeno u roku od 15 minuta, pa su karte ponovo u prodaji. Ništa nije naplaćeno.';

  @override
  String get reservationBackToListing => 'Nazad na ponudu';

  @override
  String get disputeReport => 'Prijavi problem';

  @override
  String get disputeSheetTitle => 'Prijavi problem s narudžbom';

  @override
  String get disputeSheetInfo =>
      'Naš tim provjerava prijavu. Do odluke je narudžba zadržana i prodavac ne dobija isplatu.';

  @override
  String get disputeReasonLabel => 'Šta nije u redu?';

  @override
  String get disputeReasonNotReceived => 'Karte nisu stigle';

  @override
  String get disputeReasonInvalid => 'Karta ne važi';

  @override
  String get disputeReasonWrongTickets => 'Pogrešne karte';

  @override
  String get disputeReasonEventChanged => 'Događaj promijenjen';

  @override
  String get disputeReasonOther => 'Drugo';

  @override
  String get disputeTextLabel => 'Opiši problem';

  @override
  String get disputeTextHint =>
      'Šta se desilo? Npr. karta je odbijena na ulazu.';

  @override
  String get disputeTextTooShort => 'Napiši barem 10 znakova.';

  @override
  String get disputeSubmit => 'Pošalji prijavu';

  @override
  String get disputeSent => 'Prijava poslana. Javit ćemo ti se.';

  @override
  String get disputeBoxTitle => 'Prijavljeni problem';

  @override
  String get disputeStatusLine => 'Problem prijavljen – čeka odluku podrške';

  @override
  String get disputeStatusOpen => 'Čeka odluku';

  @override
  String get disputeStatusRefund => 'Odluka: novac vraćen kupcu';

  @override
  String get disputeStatusReject => 'Odluka: prijava odbijena';

  @override
  String disputeNote(String note) {
    return 'Napomena tima: $note';
  }

  @override
  String get disputeOpenRequest => 'Otvori zahtjev za podršku';

  @override
  String get disputeErrorTooLate => 'Ova narudžba se više ne može prijaviti.';

  @override
  String get disputeErrorPermission => 'Nemaš pravo na ovu radnju.';

  @override
  String get disputeErrorInvalid => 'Provjeri unos i pokušaj ponovo.';

  @override
  String get disputeErrorNotFound => 'Nije pronađeno.';

  @override
  String get disputeStaffTitle => 'Odluka tima';

  @override
  String get disputeStaffBuyer => 'Kupac (ID)';

  @override
  String get disputeStaffSeller => 'Prodavac (ID)';

  @override
  String get disputeRefund => 'Vrati novac kupcu';

  @override
  String get disputeReject => 'Odbij prijavu';

  @override
  String get disputeRefundConfirm =>
      'Kupac dobija puni povrat novca, a prodavac ne dobija isplatu.';

  @override
  String get disputeRejectConfirm => 'Narudžba se nastavlja kao prije prijave.';

  @override
  String get disputeNoteLabel => 'Napomena (vidi je kupac)';

  @override
  String get disputeDecided => 'Odluka sačuvana';

  @override
  String disputeStaffHint(String order) {
    return 'Ovo je prijava problema s narudžbom $order. Odluku donosiš u detaljima narudžbe.';
  }

  @override
  String get disputeAlertOpenedTitle => 'Kupac je prijavio problem';

  @override
  String disputeAlertOpenedBody(String event) {
    return '$event: isplata čeka odluku podrške.';
  }

  @override
  String get disputeAlertRejectedTitle => 'Odluka o prijavljenom problemu';

  @override
  String disputeAlertRejectedBody(String event) {
    return '$event: prijava je odbijena, narudžba se nastavlja.';
  }

  @override
  String get eventChangeSection => 'Otkazivanje i pomjeranje';

  @override
  String get eventChangeCancel => 'Otkaži događaj';

  @override
  String get eventChangeCancelInfo =>
      'Svi kupci automatski dobijaju povrat novca, a sve ponude se povlače. Ovo se ne može poništiti.';

  @override
  String get eventChangeReason => 'Razlog otkazivanja';

  @override
  String get eventChangeReasonHint => 'Npr. izvođač je otkazao nastup.';

  @override
  String eventChangeCancelled(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Događaj otkazan, $count kupaca dobija povrat novca',
      few: 'Događaj otkazan, $count kupca dobijaju povrat novca',
      one: 'Događaj otkazan, $count kupac dobija povrat novca',
    );
    return '$_temp0';
  }

  @override
  String get eventChangePostpone => 'Pomjeri događaj';

  @override
  String get eventChangePostponeInfo =>
      'Kupljene karte ostaju važeće za novi termin. Kupci vide obavijest na stranici događaja.';

  @override
  String get eventChangeNewDate => 'Novi termin';

  @override
  String get eventChangePickDate => 'Odaberi novi termin';

  @override
  String get eventChangePostponed => 'Događaj pomjeren';

  @override
  String get eventChangeCancelledBanner =>
      'Ovaj događaj je otkazan i više se ne može mijenjati.';

  @override
  String eventChangeCancelReason(String reason) {
    return 'Razlog: $reason';
  }

  @override
  String eventChangePostponedFrom(String date) {
    return 'Pomjeren, prvobitni termin: $date';
  }

  @override
  String get eventChangeFilterCancelled => 'Otkazani';

  @override
  String get sellerUploadNow => 'Učitaj';

  @override
  String get sellerTicketsMissing => 'Karte još nisu učitane';

  @override
  String sellerTicketsMissingInfo(int done, int total) {
    return '$done od $total karata učitano. Učitaj ih sada – kupci ih dobiju odmah nakon plaćanja. Rok je 24 sata prije događaja, inače kupci dobijaju povrat novca.';
  }

  @override
  String get sellerTicketsButton => 'Karte (učitavanje)';

  @override
  String get sellerUploadNowHint =>
      'Ponuda je objavljena. Učitaj karte sada – kupci ih dobiju odmah nakon plaćanja. Možeš i kasnije.';

  @override
  String get eventPageCancelled => 'Događaj je otkazan';

  @override
  String get eventPageCancelledInfo =>
      'Svi kupci automatski dobijaju povrat novca. Karte se više ne prodaju.';

  @override
  String get eventPagePostponed => 'Događaj je pomjeren';

  @override
  String eventPagePostponedInfo(String date) {
    return 'Prvobitni termin: $date. Kupljene karte ostaju važeće za novi termin.';
  }

  @override
  String get eventStatusCancelled => 'Otkazan';

  @override
  String get eventStatusPostponed => 'Pomjeren';

  @override
  String get legalImprintTitle => 'Impresum';

  @override
  String get legalTermsTitle => 'Uslovi korištenja';

  @override
  String get legalPrivacyTitle => 'Politika privatnosti';

  @override
  String get legalCookiesTitle => 'Kolačići';

  @override
  String get legalFooterTitle => 'Pravne informacije';

  @override
  String get legalTermsLink => 'uslove korištenja';

  @override
  String get legalPrivacyLink => 'politiku privatnosti';

  @override
  String legalAcceptTerms(String terms, String privacy) {
    return 'Prihvatam $terms i $privacy';
  }

  @override
  String get legalAcceptRequired =>
      'Za registraciju prihvati uslove korištenja i politiku privatnosti.';

  @override
  String legalContinueAccept(String terms, String privacy) {
    return 'Nastavkom prihvataš $terms i $privacy.';
  }

  @override
  String priceInclFee(String percent) {
    return 'uključena naknada za uslugu $percent%';
  }

  @override
  String get priceFaceValue => 'Originalna cijena po karti';

  @override
  String get priceFaceValueInfo => 'Cijena odštampana na karti, bez naknada';

  @override
  String get priceFaceValueShort => 'Originalna cijena';

  @override
  String get priceFaceValueInvalid => 'Unesi originalnu cijenu karte';

  @override
  String get priceSalePrice => 'Cijena prodaje';

  @override
  String priceSellerFee(String percent) {
    return 'Naknada prodavca ($percent%)';
  }

  @override
  String get priceYouReceive => 'Dobijaš po karti';

  @override
  String get priceProfit => 'Zarada po karti';

  @override
  String get priceTotalProfit => 'Ukupna zarada';

  @override
  String priceForQuantity(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count karata',
      few: '$count karte',
      one: '$count kartu',
    );
    return 'Za $_temp0';
  }

  @override
  String get priceBelowFaceValue =>
      'Nakon naknade dobijaš manje od originalne cijene karte.';

  @override
  String get staffNoMarketTitle => 'Timski računi ne kupuju i ne prodaju';

  @override
  String get staffNoMarketInfo =>
      'Admin i podrška rade samo na zadacima tima. Za kupovinu i prodaju koristi običan račun.';

  @override
  String get eventsUserDateTooFar =>
      'Datum može biti najviše dvije godine unaprijed';

  @override
  String get homeCityPick => 'Odaberi grad';

  @override
  String get homeCitySearch => 'Pretraži gradove';

  @override
  String homeCityUseTyped(String city) {
    return 'Koristi „$city”';
  }

  @override
  String get homeCityUseLocation => 'Koristi moju lokaciju';

  @override
  String get homeCityLocationUnavailable =>
      'Lokacija nije dostupna. Odaberi grad ručno.';

  @override
  String get homeCityClear => 'Ukloni';

  @override
  String get homeCityFromLocation => 'Prema tvojoj lokaciji';

  @override
  String get homeCityMostEvents => 'Grad s najviše događaja';

  @override
  String get homeAllTypes => 'Svi tipovi';

  @override
  String get homeRecentlyViewed => 'Nedavno pregledano';

  @override
  String get homePopular => 'Popularni događaji';

  @override
  String get homeRecommended => 'Preporučeno za vas';

  @override
  String homeNearby(String city) {
    return 'Aktuelno u blizini: $city';
  }

  @override
  String get homeNearbyChange => 'Promijeni';

  @override
  String get homePopularCategories => 'Popularne kategorije';

  @override
  String get homeAllEvents => 'Svi događaji';

  @override
  String homeAllEventsOfType(String type) {
    return 'Svi događaji: $type';
  }

  @override
  String get homeSearchResults => 'Rezultati pretrage';

  @override
  String get homeAddEvent => 'Dodaj događaj';

  @override
  String get homeScrollBack => 'Prethodni';

  @override
  String get homeScrollForward => 'Sljedeći';

  @override
  String get footerClaim => 'Sigurna preprodaja karata – od fanova za fanove.';

  @override
  String get footerCompany => 'Naša kompanija';

  @override
  String get footerQuestions => 'Imate pitanja?';

  @override
  String footerCopyright(int year) {
    return '© $year Stubswap';
  }

  @override
  String footerVersion(String version) {
    return 'Verzija $version';
  }

  @override
  String get infoAboutTitle => 'O nama';

  @override
  String get infoPressTitle => 'Press';

  @override
  String get infoHowTitle => 'Kako funkcioniše';

  @override
  String get infoSafetyTitle => 'Sigurnost kupovine';

  @override
  String get infoNotFound => 'Stranica nije pronađena';

  @override
  String get infoNotFoundInfo => 'Ova stranica ne postoji ili je premještena.';

  @override
  String get infoAboutIntro =>
      'Stubswap je tržište na kojem fanovi u Bosni i Hercegovini i regionu sigurno preprodaju karte za koncerte, sport, kulturu i festivale.';

  @override
  String get infoAboutFansTitle => 'Od fanova za fanove';

  @override
  String get infoAboutFansText =>
      'Ne možeš na događaj? Ponudi kartu nekome ko želi ići, umjesto da propadne. Rasprodano? Možda neko upravo prodaje svoju.';

  @override
  String get infoAboutTrustTitle => 'Sigurnost na prvom mjestu';

  @override
  String get infoAboutTrustText =>
      'Plaćanje ide preko Stubswapa: prodavac dobija novac tek nakon događaja, a naša podrška pomaže ako nešto nije u redu.';

  @override
  String get infoPressIntro =>
      'Pišete o Stubswapu? Rado odgovaramo na pitanja medija.';

  @override
  String get infoPressFactsTitle => 'Ukratko';

  @override
  String get infoPressFact1 =>
      'Online tržište za preprodaju karata između fanova.';

  @override
  String get infoPressFact2 => 'Fokus na Bosnu i Hercegovinu i region.';

  @override
  String get infoPressFact3 =>
      'Dostupno na webu i mobilnim uređajima, na bosanskom, njemačkom i engleskom jeziku.';

  @override
  String get infoPressContactTitle => 'Kontakt za medije';

  @override
  String get infoPressContactText =>
      'Upite medija pošaljite preko centra za pomoć. Javit ćemo vam se što prije.';

  @override
  String get infoHowBuyTitle => 'Kupovina';

  @override
  String get infoHowBuy1 => 'Pronađi događaj i uporedi ponude fanova.';

  @override
  String get infoHowBuy2 => 'Plati sigurno – novac čuvamo dok karte ne stignu.';

  @override
  String get infoHowBuy3 =>
      'Prodavac ti šalje karte, a status pratiš u Kupovine i računi.';

  @override
  String get infoHowSellTitle => 'Prodaja';

  @override
  String get infoSafetyIntro =>
      'Na Stubswapu kupuješ od drugih fanova – a mi pazimo da sve prođe kako treba.';

  @override
  String get infoSafetyPaymentTitle => 'Novac čuvamo do događaja';

  @override
  String get infoSafetyPaymentText =>
      'Plaćaš preko Stubswapa, nikad direktno prodavcu. Prodavac dobija novac tek nakon događaja.';

  @override
  String get infoSafetySellersTitle => 'Provjereni prodavci';

  @override
  String get infoSafetySellersText =>
      'Prodavci moraju potvrditi svoju e-mail adresu prije nego što objave ponudu.';

  @override
  String get infoSafetySupportTitle => 'Podrška kad zatreba';

  @override
  String get infoSafetySupportText =>
      'Ako karte ne stignu ili nisu važeće, javi se podršci – vraćamo ti novac.';

  @override
  String get eventStatusConfirmed => 'Potvrđen';

  @override
  String get eventStatusPending => 'Nije potvrđen';

  @override
  String get eventStatusHidden => 'Skriven';

  @override
  String get eventStatusPendingInfo =>
      'Ovaj događaj je dodao korisnik i tim ga još nije provjerio. Karte možeš kupiti i prodati.';

  @override
  String get eventsUserNewTitle => 'Dodaj događaj';

  @override
  String get eventsUserInfoTitle => 'Tim će provjeriti događaj';

  @override
  String get eventsUserInfo =>
      'Dok ga ne provjerimo, događaj je označen kao „Nije potvrđen“. Karte za njega možeš prodavati odmah.';

  @override
  String get eventsUserVerifyFirst =>
      'Potvrdi e-mail adresu da bi mogao dodavati događaje.';

  @override
  String get eventsUserAdded => 'Događaj dodan – čeka provjeru';

  @override
  String get eventsUserNotListed => 'Događaj nije na listi?';

  @override
  String get eventsUserAddIt => 'Dodaj ga';

  @override
  String get eventsUserNoneToSellInfo =>
      'Još nema nadolazećih događaja. Dodaj svoj događaj i odmah prodaj karte za njega.';

  @override
  String get eventsReviewEdit => 'Uredi / provjeri';

  @override
  String get eventsReviewConfirm => 'Potvrdi';

  @override
  String get eventsReviewConfirmTitle => 'Potvrditi događaj?';

  @override
  String get eventsReviewConfirmInfo =>
      'Provjeri naziv, mjesto i datum. Događaj će svima biti prikazan kao potvrđen.';

  @override
  String get eventsReviewConfirmedToast => 'Događaj je potvrđen';

  @override
  String eventsReviewTabPending(int count) {
    return 'Na provjeri ($count)';
  }

  @override
  String get eventsReviewTabConfirmed => 'Potvrđeni';

  @override
  String get eventsReviewTabHidden => 'Skriveni';

  @override
  String get eventsReviewTabPast => 'Prošli';

  @override
  String get eventsReviewEmptyPending => 'Nema događaja na provjeri';

  @override
  String get eventsReviewEmptyPendingInfo =>
      'Kad korisnik doda događaj, pojavit će se ovdje.';

  @override
  String get eventsReviewEmpty => 'Ovdje nema događaja';

  @override
  String eventsReviewAddedBy(String who) {
    return 'Dodao: $who';
  }

  @override
  String get eventsReviewAddedByYou => 'Ti';

  @override
  String get eventsReviewAddedByUser => 'Korisnik';

  @override
  String get eventsReviewQueue => 'Događaji na provjeri';

  @override
  String get eventsReviewNoAccessInfo =>
      'Ovu stranicu mogu otvoriti samo članovi tima.';

  @override
  String get genreFootball => 'Fudbal';

  @override
  String get genreBasketball => 'Košarka';

  @override
  String get genreHandball => 'Rukomet';

  @override
  String get genreTennis => 'Tenis';

  @override
  String get genreVolleyball => 'Odbojka';

  @override
  String get genreCombat => 'Borilački sportovi';

  @override
  String get genreMotorsport => 'Moto sport';

  @override
  String get genreOtherSport => 'Ostali sportovi';

  @override
  String get genreRock => 'Rock';

  @override
  String get genrePop => 'Pop';

  @override
  String get genreFolk => 'Narodna muzika';

  @override
  String get genreJazz => 'Jazz';

  @override
  String get genreHiphop => 'Hip-hop';

  @override
  String get genreElectronic => 'Elektronska muzika';

  @override
  String get genreClassical => 'Klasična muzika';

  @override
  String get genreOtherMusic => 'Ostala muzika';

  @override
  String get genreDrama => 'Pozorište';

  @override
  String get genreOpera => 'Opera';

  @override
  String get genreBallet => 'Balet';

  @override
  String get genreStandup => 'Stand-up komedija';

  @override
  String get genreMusical => 'Mjuzikl';

  @override
  String get genreExhibition => 'Izložbe';

  @override
  String get genreFilm => 'Film';

  @override
  String get genreMusicFestival => 'Muzički festivali';

  @override
  String get genreFilmFestival => 'Filmski festivali';

  @override
  String get genreFoodFestival => 'Gastro festivali';

  @override
  String get genreOtherFestival => 'Ostali festivali';

  @override
  String get genreFamily => 'Za porodicu';

  @override
  String get genreConference => 'Konferencije';

  @override
  String get genreOtherEvent => 'Ostalo';

  @override
  String get genreLabel => 'Podkategorija';

  @override
  String get genreNone => 'Bez podkategorije';

  @override
  String get supportUser => 'Korisnik';

  @override
  String get supportMyRequests => 'Moji upiti';

  @override
  String get supportNoRequests => 'Još nemaš upita podršci.';

  @override
  String get supportStatusOpen => 'Otvoren';

  @override
  String get supportStatusAnswered => 'Odgovoreno';

  @override
  String get supportStatusClosed => 'Zatvoren';

  @override
  String get supportNewAnswer => 'Novi odgovor';

  @override
  String get supportRequestSent => 'Upit poslan';

  @override
  String get supportMessageTooShort => 'Napiši barem 10 znakova';

  @override
  String get supportAnswerInApp =>
      'Odgovaramo ovdje u aplikaciji, obično u roku od 24 sata. Dobit ćeš obavijest.';

  @override
  String get supportImages => 'Slike';

  @override
  String supportImagesInfo(int count) {
    return 'Snimci ekrana ili fotografije, najviše $count';
  }

  @override
  String get supportAddImage => 'Dodaj sliku';

  @override
  String get supportRemoveImage => 'Ukloni sliku';

  @override
  String get supportImageError => 'Slika se ne može učitati';

  @override
  String get supportImage => 'Slika';

  @override
  String get supportTeamName => 'Podrška Stubswap';

  @override
  String get supportYou => 'Ti';

  @override
  String get supportTicket => 'Upit';

  @override
  String get supportCloseTicket => 'Zatvori upit';

  @override
  String get supportResolveTicket => 'Problem riješen – zatvori upit';

  @override
  String get supportCloseConfirm => 'Zatvoriti upit?';

  @override
  String get supportCloseConfirmInfo =>
      'U zatvoreni upit se više ne može pisati. Ako se problem ponovo pojavi, otvori novi upit.';

  @override
  String get supportCloseConfirmStaff =>
      'Korisnik više neće moći pisati u ovaj upit.';

  @override
  String get supportClosed => 'Upit je zatvoren';

  @override
  String get supportClosedByUser => 'Zatvorio ga je korisnik.';

  @override
  String get supportClosedByYou => 'Zatvoren na tvoj zahtjev.';

  @override
  String get supportClosedByStaff => 'Zatvorila ga je podrška.';

  @override
  String get supportNewRequest => 'Novi upit';

  @override
  String get supportWriteMessage => 'Napiši poruku…';

  @override
  String get supportNotFound => 'Upit nije pronađen';

  @override
  String get supportNoAccess => 'Nemaš pristup';

  @override
  String get supportNoAccessInfo => 'Ova stranica je samo za tim podrške.';

  @override
  String get supportInbox => 'Upiti podrške';

  @override
  String get supportFilterOpen => 'Otvoreni';

  @override
  String get supportFilterAnswered => 'Odgovoreni';

  @override
  String get supportFilterClosed => 'Zatvoreni';

  @override
  String get supportFilterAll => 'Svi';

  @override
  String get supportInboxEmpty => 'Nema upita';

  @override
  String get supportAppVersion => 'Verzija aplikacije';

  @override
  String get supportEmail => 'E-mail';

  @override
  String get supportAlertAnswered => 'Podrška je odgovorila';

  @override
  String get supportAlertNew => 'Novi upit za podršku';

  @override
  String supportAlertNewMessage(String number) {
    return 'Nova poruka u upitu $number';
  }

  @override
  String get supportAlertOpen => 'Otvori';

  @override
  String get supportAdministration => 'Administracija';

  @override
  String get adminTitle => 'Administracija';

  @override
  String get adminTeamSection => 'Tim';

  @override
  String get adminNoAccess => 'Nemaš pristup';

  @override
  String get adminNoAccessInfo => 'Ova stranica je samo za administratore.';

  @override
  String get adminEvents => 'Događaji';

  @override
  String get adminEventsInfo => 'Dodaj i uredi događaje';

  @override
  String get adminFeesTitle => 'Servisna naknada';

  @override
  String adminFeesSummary(int buyer, int seller) {
    return 'Kupac $buyer % · Prodavac $seller %';
  }

  @override
  String get adminTeamTitle => 'Tim i podrška';

  @override
  String get adminTeamInfo => 'Računi podrške i administratori';

  @override
  String get adminSupportInbox => 'Upiti podrške';

  @override
  String get adminSupportInboxInfo => 'Odgovori na upite korisnika';

  @override
  String get adminBuyerFee => 'Naknada kupca';

  @override
  String get adminBuyerFeeInfo => 'Kupac je plaća povrh cijene karte.';

  @override
  String get adminSellerFee => 'Naknada prodavca';

  @override
  String get adminSellerFeeInfo =>
      'Oduzima se od cijene karte koju prodavac dobija.';

  @override
  String adminFeeRange(int max) {
    return 'Unesi cijeli broj od 0 do $max';
  }

  @override
  String get adminFeeDecrease => 'Smanji';

  @override
  String get adminFeeIncrease => 'Povećaj';

  @override
  String adminFeesCurrent(String summary) {
    return 'Trenutno: $summary';
  }

  @override
  String adminFeesExample(String price) {
    return 'Primjer za kartu od $price';
  }

  @override
  String get adminTicketPrice => 'Cijena karte';

  @override
  String get adminBuyerPays => 'Kupac plaća';

  @override
  String get adminSellerReceives => 'Prodavac dobija';

  @override
  String get adminPlatformEarns => 'Stubswap zarađuje';

  @override
  String get adminFeesNotice =>
      'Nova naknada vrijedi samo za ponude objavljene od sada. Postojeće ponude i narudžbe zadržavaju svoju naknadu.';

  @override
  String get adminFeesConfirmTitle => 'Promijeniti naknadu?';

  @override
  String get adminFeesSave => 'Sačuvaj naknadu';

  @override
  String get adminFeesSaved => 'Naknada je sačuvana';

  @override
  String get adminRoleAdmin => 'Admin';

  @override
  String get adminRoleSupport => 'Podrška';

  @override
  String get adminTeamMembers => 'Članovi tima';

  @override
  String adminGrantedAt(String date) {
    return 'Dodano $date';
  }

  @override
  String get adminYou => 'Ti';

  @override
  String get adminNoName => 'Bez imena';

  @override
  String get adminRemoveSupport => 'Ukloni iz podrške';

  @override
  String get adminRemoveSupportTitle => 'Ukloniti iz podrške?';

  @override
  String adminRemoveSupportBody(String name) {
    return '$name više neće vidjeti upite podrške. Korisnički račun ostaje.';
  }

  @override
  String get adminRemove => 'Ukloni';

  @override
  String get adminSupportRemoved => 'Uklonjeno iz podrške';

  @override
  String get adminAdminsInfo =>
      'Admine dodaješ samo u Firebase konzoli (Firestore → roles → dokument s ID-em korisnika, polje role = admin).';

  @override
  String get adminAddSupport => 'Dodaj račun podrške';

  @override
  String get adminAddSupportInfo =>
      'Traži po tačnoj e-mail adresi ili korisničkom imenu. Korisnik se mora barem jednom prijaviti u Stubswap.';

  @override
  String get adminFindUserLabel => 'E-mail ili korisničko ime';

  @override
  String get adminFindUser => 'Traži';

  @override
  String get adminUserNotFound => 'Korisnik nije pronađen';

  @override
  String get adminUserNotFoundInfo =>
      'Provjeri adresu ili korisničko ime. Korisnik se mora barem jednom prijaviti.';

  @override
  String get adminMakeSupport => 'Dodaj kao podršku';

  @override
  String get adminSupportAdded => 'Dodano u podršku';

  @override
  String adminAlreadyInTeam(String role) {
    return 'Već je u timu kao $role';
  }

  @override
  String get adminThatsYou => 'To si ti';

  @override
  String eventsOffer(String price, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count karata',
      few: '$count karte',
      one: '$count karta',
    );
    return 'od $price · $_temp0';
  }

  @override
  String get eventsNoOffers => 'Još nema ponuda';

  @override
  String get eventsNoOffersInfo =>
      'Budite prvi koji prodaje karte za ovaj događaj.';

  @override
  String get eventsSellForEvent => 'Prodaj karte za ovaj događaj';

  @override
  String get eventsOffers => 'Ponude';

  @override
  String get eventsNotFound => 'Događaj nije pronađen';

  @override
  String get eventsNotFoundInfo => 'Možda je uklonjen ili više nije dostupan.';

  @override
  String get eventsIsOver =>
      'Ovaj događaj je prošao. Karte za njega se više ne prodaju.';

  @override
  String get eventsPick => 'Odaberi događaj';

  @override
  String get eventsPickRequired => 'Odaberite događaj';

  @override
  String get eventsChange => 'Promijeni';

  @override
  String get eventsSearch => 'Pretraži događaje';

  @override
  String get eventsNoneToSell => 'Trenutno nema događaja';

  @override
  String get eventsNoneToSellInfo =>
      'Događaje dodaje Stubswap tim. Čim se pojavi novi događaj, ovdje možete prodati karte za njega.';

  @override
  String get eventsAllOffers => 'Sve ponude za ovaj događaj';

  @override
  String get eventsAdminTitle => 'Događaji';

  @override
  String get eventsAdminNoAccess => 'Nemate pristup';

  @override
  String get eventsAdminNoAccessInfo =>
      'Ovu stranicu mogu otvoriti samo administratori.';

  @override
  String get eventsNew => 'Novi događaj';

  @override
  String get eventsEdit => 'Uredi događaj';

  @override
  String get eventsHiddenBadge => 'Skriven';

  @override
  String get eventsPastBadge => 'Prošao';

  @override
  String get eventsUpcomingSection => 'Nadolazeći';

  @override
  String get eventsPastSection => 'Prošli';

  @override
  String get eventsHide => 'Sakrij događaj';

  @override
  String get eventsShow => 'Prikaži događaj';

  @override
  String get eventsHideConfirm =>
      'Događaj se više neće prikazivati i za njega se neće moći objavljivati nove ponude. Postojeće ponude ostaju.';

  @override
  String get eventsShowConfirm =>
      'Događaj će ponovo biti vidljiv svima i za njega će se moći prodavati karte.';

  @override
  String get eventsHiddenToast => 'Događaj je sakriven';

  @override
  String get eventsShownToast => 'Događaj je ponovo vidljiv';

  @override
  String get eventsPicture => 'Slika';

  @override
  String get eventsPicturePick => 'Odaberi sliku';

  @override
  String get eventsPictureReplace => 'Zamijeni';

  @override
  String get eventsPictureRemove => 'Ukloni';

  @override
  String get eventsPictureHint => 'Slika se izrezuje na format 16:9.';

  @override
  String get eventsPictureError => 'Ova slika se ne može učitati';

  @override
  String get eventsCreated => 'Događaj je kreiran';

  @override
  String get eventsListingsKeepData =>
      'Postojeće ponude zadržavaju podatke o događaju iz trenutka kada su objavljene.';

  @override
  String get eventsNameTooShort => 'Najmanje 2 znaka';

  @override
  String get eventsNoneYet => 'Još nema događaja';

  @override
  String get eventsNoneYetInfo =>
      'Dodajte prvi događaj da bi prodavci mogli objavljivati ponude.';

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
  String get continueAsGuest => 'Nastavi bez prijave';

  @override
  String get signupTitle => 'Kreirajte svoj račun';

  @override
  String get nameLabel => 'Ime';

  @override
  String get nameRequired => 'Unesite ime';

  @override
  String get confirmPasswordLabel => 'Potvrdite lozinku';

  @override
  String get passwordTooShort => 'Lozinka mora imati najmanje 8 znakova';

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
  String get errorWeakPassword => 'Lozinka je preslaba: najmanje 8 znakova';

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
  String get errorPopupBlocked =>
      'Preglednik je blokirao prozor za Google prijavu. Dozvolite skočne prozore za ovu stranicu i pokušajte ponovo';

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
  String get catTheater => 'Kultura';

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
  String get testNotificationSent =>
      'Probno obavještenje je poslano. Ako ga ne vidiš, provjeri obavještenja za preglednik u postavkama uređaja.';

  @override
  String get testNotificationFailed => 'Preglednik nije prikazao obavještenje.';

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
  String get purchases => 'Moje karte';

  @override
  String get sales => 'Prodane karte';

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
  String get markTicketsSent => 'Unesi predaju karata';

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

  @override
  String get navEvents => 'Događaji';

  @override
  String get navMyTickets => 'Moje karte';

  @override
  String get openAccountMenu => 'Otvori meni računa';

  @override
  String get heroTitle => 'Karte za koncerte, sport i festivale';

  @override
  String get heroSubtitle =>
      'Kupi sigurno od fanova ili prodaj karte koje ne možeš iskoristiti.';

  @override
  String get howSellingWorks => 'Kako funkcioniše prodaja';

  @override
  String get sellStep1 => 'Objavi ponudu: događaj, sjedišta i cijenu.';

  @override
  String get sellStep2 => 'Kupac plaća. Novac čuvamo dok karte ne stignu.';

  @override
  String get sellStep3 => 'Pošalji karte kupcu i označi ih kao poslane.';

  @override
  String get sellStep4 => 'Nakon događaja novac stiže na tvoj IBAN.';

  @override
  String get ibanBadFormat =>
      'IBAN počinje oznakom zemlje i dvije cifre, npr. BA39 …';

  @override
  String ibanWrongLength(String country, int expected, int actual) {
    return 'IBAN za $country ima $expected znakova, uneseno je $actual.';
  }

  @override
  String get ibanBadChecksum =>
      'Kontrolni broj ne odgovara. Provjeri cifre IBAN-a.';

  @override
  String get cancelSale => 'Otkaži prodaju';

  @override
  String get cancelSaleTitle => 'Otkazati prodaju?';

  @override
  String get cancelSaleInfo =>
      'Kupac dobija sav novac nazad, a karte se vraćaju u tvoju ponudu. Za ovu prodaju nema isplate. Ovo se ne može poništiti.';

  @override
  String get keepSale => 'Ne, zadrži';

  @override
  String get saleCancelled => 'Prodaja je otkazana. Kupcu je vraćen novac.';

  @override
  String get buyerNextCancelledBySeller =>
      'Prodavac je otkazao prodaju. Novac ti je vraćen u cijelosti.';

  @override
  String get sellerNextCancelledBySeller =>
      'Otkazao/la si prodaju. Kupcu je vraćen novac, a karte su ponovo u prodaji.';

  @override
  String get cannotBuyOwnListing =>
      'Ovo su tvoje karte. Svoju ponudu ne možeš kupiti.';

  @override
  String get openListing => 'Otvori ponudu';

  @override
  String alertSoldTitle(String event) {
    return 'Prodane karte: $event';
  }

  @override
  String alertSoldBody(String quantity, String amount) {
    return '$quantity kom. · $amount. Pošalji karte kupcu.';
  }

  @override
  String get alertTicketsSentTitle => 'Karte su poslane';

  @override
  String alertTicketsSentBody(String event) {
    return '$event: prodavac je poslao tvoje karte.';
  }

  @override
  String get alertRefundTitle => 'Prodaja otkazana';

  @override
  String alertRefundBody(String event) {
    return '$event: prodavac je otkazao prodaju, novac ti je vraćen.';
  }

  @override
  String get alertView => 'Pogledaj';

  @override
  String get changeIban => 'Promijeni IBAN';

  @override
  String get keepCurrentIban => 'Zadrži sačuvani IBAN';

  @override
  String get ibanHint => 'npr. BA39 1290 0794 0102 8494';

  @override
  String get deleteAccountOpenOrders =>
      'Imaš otvorene prodaje ili kupovine. Završi ih ili otkaži prije brisanja računa.';

  @override
  String get newVersionTitle => 'Nova verzija je dostupna';

  @override
  String get newVersionBody =>
      'Osvježi stranicu za najnoviju verziju Stubswapa.';

  @override
  String get reload => 'Osvježi';
}
