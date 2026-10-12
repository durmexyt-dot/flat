import 'package:flutter/widgets.dart';

/// The version of the terms of use a user accepts when signing up. Raise it
/// when the terms change materially.
const termsVersion = '2026-10';

/// The legal pages under /info/: imprint, terms, privacy and cookies.
const legalTopics = ['imprint', 'terms', 'privacy', 'cookies'];

/// A part of a legal page: a heading and its text.
typedef LegalSection = ({String title, String text});

/// A legal page's text: a short intro and its sections.
typedef LegalDoc = ({String intro, List<LegalSection> sections});

// The operator's details are placeholders in square brackets until the
// owner fills them in. They stay visible on purpose.
const _operator = '[BETREIBER / FIRMA]';
const _address = '[ADRESA]';
const _email = '[E-MAIL]';
const _registry = '[ID-BROJ / REGISTARSKI BROJ]';
const _date = '[DATUM]';

/// The legal text of [topic] (one of [legalTopics]) in the app's language;
/// Bosnian for any other language. Null for other topics.
LegalDoc? legalDoc(String topic, Locale locale) {
  final docs = switch (locale.languageCode) {
    'de' => _de,
    'en' => _en,
    _ => _bs,
  };
  return docs[topic];
}

/// "Valid from …, version …" in the app's language.
String legalValidFrom(Locale locale) => switch (locale.languageCode) {
  'de' => 'Stand: $_date · Version $termsVersion',
  'en' => 'Effective: $_date · Version $termsVersion',
  _ => 'Važi od: $_date · Verzija $termsVersion',
};

// ---------------------------------------------------------------------------
// Bosanski
// ---------------------------------------------------------------------------

const Map<String, LegalDoc> _bs = {
  'imprint': (
    intro:
        'Podaci o operateru platforme Stubswap u skladu s propisima o '
        'informacijama na web stranicama i u aplikacijama.',
    sections: [
      (
        title: 'Operater',
        text:
            '$_operator\n$_address\n'
            'ID-broj / registarski broj: $_registry',
      ),
      (
        title: 'Kontakt',
        text:
            'E-mail: $_email\n'
            'Najbrže nas dosegneš preko centra za pomoć u aplikaciji.',
      ),
      (title: 'Odgovorna osoba za sadržaj', text: '$_operator, $_address'),
      (
        title: 'Uloga platforme',
        text:
            'Stubswap je online tržnica na kojoj privatne osobe prodaju i '
            'kupuju ulaznice za događaje. Stubswap nije organizator '
            'događaja niti izdavač ulaznica i ne prodaje ulaznice u svoje '
            'ime.',
      ),
      (
        title: 'Sadržaj korisnika',
        text:
            'Za ponude, opise i slike koje objavljuju korisnici odgovorni su '
            'sami korisnici. Nezakonit sadržaj uklanjamo čim saznamo za '
            'njega – prijavi ga preko centra za pomoć.',
      ),
    ],
  ),
  'terms': (
    intro:
        'Ovi uslovi korištenja uređuju korištenje platforme Stubswap '
        '(web stranica i aplikacija) između tebe i operatera $_operator. '
        'Registracijom ih prihvataš.',
    sections: [
      (
        title: '1. Operater i uloga platforme',
        text:
            'Platformu vodi $_operator, $_address ($_registry). Stubswap je '
            'posrednik između privatnih prodavaca i kupaca ulaznica. Ugovor '
            'o kupoprodaji ulaznice nastaje direktno između prodavca i '
            'kupca. Stubswap nije organizator događaja i ne odgovara za '
            'održavanje, sadržaj ili kvalitet događaja.',
      ),
      (
        title: '2. Korisnički račun',
        text:
            'Za kupovinu i prodaju potreban je račun. Moraš imati najmanje '
            '18 godina ili saglasnost roditelja, navesti tačne podatke i '
            'čuvati svoju lozinku. Jedna osoba smije imati samo jedan račun. '
            'Prodavati mogu samo računi s potvrđenom e-mail adresom i '
            'unesenim načinom isplate. Račun možeš u svakom trenutku '
            'izbrisati u postavkama (Privatnost i sigurnost).',
      ),
      (
        title: '3. Ponude',
        text:
            'Prodavac smije ponuditi samo originalne, važeće ulaznice koje '
            'posjeduje ili će sigurno posjedovati do roka dostave. Podaci o '
            'događaju, vrsti ulaznice, sektoru, redu, sjedištima i '
            'originalnoj cijeni moraju biti tačni. Prodavac sam određuje '
            'prodajnu cijenu i odgovoran je za poštivanje uslova '
            'organizatora i propisa o preprodaji. Netačne ili sumnjive '
            'ponude možemo ukloniti.',
      ),
      (
        title: '4. Naknade',
        text:
            'Kupac plaća naknadu za uslugu na cijenu karte; prodavcu se od '
            'prodajne cijene zadržava naknada prodavca. Visinu obje naknade '
            'u procentima određuje platforma. Kupcu se ukupna cijena s '
            'naknadom prikazuje prije kupovine, a prodavcu iznos koji dobija '
            'prije objave ponude. Naknade važeće u trenutku objave ponude '
            'ostaju na snazi za tu ponudu.',
      ),
      (
        title: '5. Plaćanje i isplata',
        text:
            'Kupac plaća preko platforme. Novac zadržavamo do završetka '
            'događaja i isplaćujemo ga prodavcu tek nakon događaja, ako nije '
            'prijavljen problem. Tako je kupac zaštićen ako ulaznica ne '
            'stigne ili ne važi.',
      ),
      (
        title: '6. Dostava ulaznica',
        text:
            'Prodavac učitava ulaznice (npr. PDF ili sliku) u narudžbu '
            'najkasnije 24 sata prije početka događaja. Ako ih do tada ne '
            'učita, narudžba se automatski otkazuje i kupac dobija puni '
            'povrat novca, uključujući naknadu za uslugu.',
      ),
      (
        title: '7. Zaštita kupca i prijava problema',
        text:
            'Ako ulaznica ne stigne, ne važi ili ne odgovara opisu, kupac to '
            'prijavljuje preko narudžbe ili centra za pomoć, najkasnije do '
            'kraja događaja. Slučaj provjeravamo, po potrebi tražimo dokaze '
            'od obje strane i, ako je prijava opravdana, kupac dobija povrat '
            'novca, a prodavac ne dobija isplatu.',
      ),
      (
        title: '8. Otkazivanje i odgađanje događaja',
        text:
            'Ako organizator otkaže događaj, kupac dobija povrat plaćenog '
            'iznosa, a prodavac ne dobija isplatu. Ako se događaj odgodi ili '
            'premjesti, ulaznice u pravilu ostaju važeće za novi termin i '
            'narudžba ostaje na snazi; isplata slijedi nakon novog termina. '
            'Ako organizator za odgođeni događaj nudi povrat, važe njegovi '
            'uslovi.',
      ),
      (
        title: '9. Zabranjeno ponašanje',
        text:
            'Zabranjeno je: prodavati lažne, kopirane, već iskorištene ili '
            'nevažeće ulaznice; istu ulaznicu prodati više puta; navoditi '
            'netačne podatke; dogovarati plaćanje izvan platforme; '
            'zloupotrebljavati račune drugih; ometati rad platforme. Kršenja '
            'mogu dovesti do uklanjanja ponuda, zadržavanja isplate, '
            'blokade računa i prijave nadležnim organima.',
      ),
      (
        title: '10. Odgovornost',
        text:
            'Stubswap odgovara za namjeru i krajnju nepažnju te u skladu s '
            'obaveznim propisima. Za ulaznice, njihove podatke i uslove '
            'ulaska odgovoran je prodavac, odnosno organizator. Ne '
            'garantujemo neprekidnu dostupnost platforme.',
      ),
      (
        title: '11. Izmjene uslova',
        text:
            'Uslove možemo izmijeniti. O bitnim izmjenama obavještavamo '
            'unaprijed; za već sklopljene narudžbe važe uslovi u trenutku '
            'narudžbe.',
      ),
      (
        title: '12. Kontakt i mjerodavno pravo',
        text:
            'Pitanja šalji na $_email ili preko centra za pomoć. Primjenjuje '
            'se pravo države sjedišta operatera, uz obavezna prava zaštite '
            'potrošača u tvojoj zemlji.',
      ),
    ],
  ),
  'privacy': (
    intro:
        'Ovdje objašnjavamo koje lične podatke obrađujemo kada koristiš '
        'Stubswap, zašto i koja prava imaš.',
    sections: [
      (title: 'Odgovorni', text: '$_operator, $_address\nE-mail: $_email'),
      (
        title: 'Koje podatke obrađujemo',
        text:
            '• Podaci računa: ime, e-mail, korisničko ime, profilna slika, '
            'postavke i datum prihvatanja uslova.\n'
            '• Ponude i narudžbe: događaj, ulaznice, cijene, kupljene '
            'količine, status plaćanja i isplate, podaci za isplatu (npr. '
            'IBAN).\n'
            '• Datoteke: ulaznice koje prodavci učitaju i slike događaja.\n'
            '• Podrška: poruke i prilozi koje šalješ timu podrške.\n'
            '• Tehnički podaci: podaci o prijavi i uređaju potrebni za '
            'sigurnost.',
      ),
      (
        title: 'Svrhe i pravni osnov',
        text:
            'Podatke koristimo za vođenje računa, posredovanje između '
            'kupaca i prodavaca, plaćanje i isplatu, dostavu ulaznica, '
            'podršku i sprječavanje prevara. Osnov je izvršenje ugovora, '
            'zakonske obaveze (npr. računovodstvo) i naš legitimni interes '
            'za sigurnu platformu; za opcionalna obavještenja tvoja '
            'saglasnost.',
      ),
      (
        title: 'Ko dobija podatke',
        text:
            'Kupac i prodavac vide podatke potrebne za narudžbu (npr. '
            'javni profil, ulaznice). Platformu tehnički pokreće Google '
            'Firebase (Google Ireland Ltd. / Google LLC) kao obrađivač: '
            'prijava, baza podataka, pohrana datoteka i hosting. Pri tome '
            'podaci mogu biti preneseni u SAD na osnovu standardnih '
            'ugovornih klauzula. Pružaoci plaćanja dobijaju podatke '
            'potrebne za plaćanje. Podatke ne prodajemo.',
      ),
      (
        title: 'Koliko dugo čuvamo podatke',
        text:
            'Podatke računa čuvamo dok postoji račun. Narudžbe i podatke o '
            'plaćanjima čuvamo onoliko koliko to zahtijevaju zakonski '
            'rokovi. Ulaznice i poruke podrške brišemo kada više nisu '
            'potrebne, najkasnije nakon isteka rokova za prigovore.',
      ),
      (
        title: 'Tvoja prava',
        text:
            'Imaš pravo na pristup, ispravku, brisanje, ograničenje obrade, '
            'prenosivost podataka i prigovor, kao i pravo na žalbu '
            'nadležnom organu za zaštitu podataka. Profil uređuješ u '
            'postavkama, a račun sa svim podacima brišeš u postavkama pod '
            'Privatnost i sigurnost. Za ostale zahtjeve piši na $_email.',
      ),
      (
        title: 'Sigurnost',
        text:
            'Podaci se prenose šifrovano. Pristup je ograničen na tebe i, '
            'gdje je potrebno, na tim podrške.',
      ),
    ],
  ),
  'cookies': (
    intro:
        'Stubswap ne koristi kolačiće za praćenje ni oglašavanje. Koristimo '
        'samo pohranu koja je nužna za rad aplikacije.',
    sections: [
      (
        title: 'Lokalna pohrana u pregledniku',
        text:
            'Aplikacija u tvom pregledniku ili na uređaju pamti postavke '
            '(jezik, valuta, izgled, grad) i nedavno pregledane događaje. '
            'Ovi podaci ostaju na tvom uređaju.',
      ),
      (
        title: 'Prijava (Firebase)',
        text:
            'Da bi ostao prijavljen, Google Firebase Authentication u '
            'pregledniku sprema podatke o prijavi (lokalna pohrana / '
            'IndexedDB). Ako ne izabereš „Ostani prijavljen”, prijava traje '
            'samo do zatvaranja preglednika.',
      ),
      (
        title: 'Bez praćenja',
        text:
            'Trenutno ne koristimo analitiku, alate za praćenje ni kolačiće '
            'trećih strana za oglase. Ako se to promijeni, prethodno ćemo '
            'tražiti tvoju saglasnost i ažurirati ovu stranicu.',
      ),
      (
        title: 'Brisanje',
        text:
            'Pohranjene podatke možeš izbrisati u postavkama preglednika. '
            'Nakon toga se moraš ponovo prijaviti, a postavke se vraćaju na '
            'početne.',
      ),
    ],
  ),
};

// ---------------------------------------------------------------------------
// Deutsch
// ---------------------------------------------------------------------------

const Map<String, LegalDoc> _de = {
  'imprint': (
    intro: 'Angaben zum Betreiber der Plattform Stubswap.',
    sections: [
      (
        title: 'Betreiber',
        text:
            '$_operator\n$_address\n'
            'ID-/Registernummer: $_registry',
      ),
      (
        title: 'Kontakt',
        text:
            'E-Mail: $_email\n'
            'Am schnellsten erreichst du uns über das Hilfe-Center in der App.',
      ),
      (title: 'Verantwortlich für den Inhalt', text: '$_operator, $_address'),
      (
        title: 'Rolle der Plattform',
        text:
            'Stubswap ist ein Online-Marktplatz, auf dem Privatpersonen '
            'Tickets für Veranstaltungen verkaufen und kaufen. Stubswap ist '
            'weder Veranstalter noch Ticketaussteller und verkauft keine '
            'Tickets im eigenen Namen.',
      ),
      (
        title: 'Inhalte von Nutzern',
        text:
            'Für Angebote, Beschreibungen und Bilder der Nutzer sind diese '
            'selbst verantwortlich. Rechtswidrige Inhalte entfernen wir, '
            'sobald wir davon erfahren – melde sie über das Hilfe-Center.',
      ),
    ],
  ),
  'terms': (
    intro:
        'Diese Allgemeinen Geschäftsbedingungen (AGB) regeln die Nutzung '
        'der Plattform Stubswap (Website und App) zwischen dir und '
        '$_operator. Mit der Registrierung akzeptierst du sie.',
    sections: [
      (
        title: '1. Betreiber und Rolle der Plattform',
        text:
            'Betreiber ist $_operator, $_address ($_registry). Stubswap '
            'vermittelt zwischen privaten Verkäufern und Käufern von '
            'Tickets. Der Kaufvertrag über ein Ticket kommt direkt zwischen '
            'Verkäufer und Käufer zustande. Stubswap ist nicht Veranstalter '
            'und haftet nicht für Durchführung, Inhalt oder Qualität von '
            'Veranstaltungen.',
      ),
      (
        title: '2. Konto',
        text:
            'Zum Kaufen und Verkaufen brauchst du ein Konto. Du musst '
            'mindestens 18 Jahre alt sein oder die Zustimmung deiner Eltern '
            'haben, wahre Angaben machen und dein Passwort geheim halten. '
            'Pro Person ist ein Konto erlaubt. Verkaufen können nur Konten '
            'mit bestätigter E-Mail-Adresse und hinterlegter '
            'Auszahlungsmethode. Du kannst dein Konto jederzeit in den '
            'Einstellungen (Datenschutz & Sicherheit) löschen.',
      ),
      (
        title: '3. Angebote',
        text:
            'Verkäufer dürfen nur echte, gültige Tickets anbieten, die sie '
            'besitzen oder bis zur Lieferfrist sicher besitzen werden. '
            'Angaben zu Veranstaltung, Ticketart, Block, Reihe, Plätzen und '
            'Originalpreis müssen stimmen. Der Verkäufer legt den Preis '
            'selbst fest und ist für die Einhaltung der Bedingungen des '
            'Veranstalters und der Vorschriften zum Weiterverkauf '
            'verantwortlich. Falsche oder verdächtige Angebote können wir '
            'entfernen.',
      ),
      (
        title: '4. Gebühren',
        text:
            'Käufer zahlen eine Servicegebühr auf den Ticketpreis; vom '
            'Verkaufspreis behalten wir eine Verkäufergebühr ein. Die Höhe '
            'beider Gebühren in Prozent legt die Plattform fest. Käufer '
            'sehen den Gesamtpreis inklusive Gebühr vor dem Kauf, Verkäufer '
            'ihren Erlös vor dem Veröffentlichen. Für ein Angebot gelten die '
            'Gebühren zum Zeitpunkt seiner Veröffentlichung.',
      ),
      (
        title: '5. Zahlung und Auszahlung',
        text:
            'Käufer bezahlen über die Plattform. Wir halten das Geld bis '
            'nach der Veranstaltung zurück und zahlen es erst danach an den '
            'Verkäufer aus, sofern kein Problem gemeldet wurde. So ist der '
            'Käufer geschützt, falls ein Ticket nicht ankommt oder ungültig '
            'ist.',
      ),
      (
        title: '6. Lieferung der Tickets',
        text:
            'Der Verkäufer lädt die Tickets (z. B. PDF oder Bild) spätestens '
            '24 Stunden vor Beginn der Veranstaltung in die Bestellung hoch. '
            'Tut er das nicht, wird die Bestellung automatisch storniert und '
            'der Käufer erhält den vollen Betrag einschließlich '
            'Servicegebühr zurück.',
      ),
      (
        title: '7. Käuferschutz und Meldung von Problemen',
        text:
            'Kommt ein Ticket nicht an, ist es ungültig oder entspricht es '
            'nicht der Beschreibung, meldet der Käufer das über die '
            'Bestellung oder das Hilfe-Center, spätestens bis zum Ende der '
            'Veranstaltung. Wir prüfen den Fall, fordern bei Bedarf Belege '
            'von beiden Seiten an und erstatten dem Käufer bei berechtigter '
            'Meldung den Betrag; der Verkäufer erhält dann keine Auszahlung.',
      ),
      (
        title: '8. Absage und Verschiebung',
        text:
            'Sagt der Veranstalter eine Veranstaltung ab, erhält der Käufer '
            'den bezahlten Betrag zurück und der Verkäufer keine Auszahlung. '
            'Wird sie verschoben oder verlegt, bleiben die Tickets in der '
            'Regel für den neuen Termin gültig und die Bestellung bleibt '
            'bestehen; ausgezahlt wird nach dem neuen Termin. Bietet der '
            'Veranstalter bei einer Verschiebung eine Rückerstattung an, '
            'gelten seine Bedingungen.',
      ),
      (
        title: '9. Verbotenes Verhalten',
        text:
            'Verboten ist: gefälschte, kopierte, bereits benutzte oder '
            'ungültige Tickets zu verkaufen; dasselbe Ticket mehrfach zu '
            'verkaufen; falsche Angaben zu machen; Zahlungen außerhalb der '
            'Plattform zu vereinbaren; fremde Konten zu missbrauchen; den '
            'Betrieb der Plattform zu stören. Verstöße können zur Entfernung '
            'von Angeboten, zum Einbehalt von Auszahlungen, zur Sperrung des '
            'Kontos und zur Anzeige bei Behörden führen.',
      ),
      (
        title: '10. Haftung',
        text:
            'Stubswap haftet bei Vorsatz und grober Fahrlässigkeit sowie '
            'nach zwingenden gesetzlichen Vorschriften. Für Tickets, ihre '
            'Angaben und Einlassbedingungen sind Verkäufer bzw. '
            'Veranstalter verantwortlich. Eine ununterbrochene '
            'Verfügbarkeit der Plattform können wir nicht garantieren.',
      ),
      (
        title: '11. Änderungen',
        text:
            'Wir können diese AGB ändern. Über wesentliche Änderungen '
            'informieren wir vorab; für bestehende Bestellungen gelten die '
            'AGB zum Zeitpunkt der Bestellung.',
      ),
      (
        title: '12. Kontakt und anwendbares Recht',
        text:
            'Fragen an $_email oder über das Hilfe-Center. Es gilt das Recht '
            'des Landes, in dem der Betreiber seinen Sitz hat; zwingende '
            'Verbraucherschutzrechte deines Landes bleiben unberührt.',
      ),
    ],
  ),
  'privacy': (
    intro:
        'Hier erklären wir, welche personenbezogenen Daten wir verarbeiten, '
        'wenn du Stubswap nutzt, wozu und welche Rechte du hast.',
    sections: [
      (
        title: 'Verantwortlicher',
        text: '$_operator, $_address\nE-Mail: $_email',
      ),
      (
        title: 'Welche Daten wir verarbeiten',
        text:
            '• Kontodaten: Name, E-Mail, Benutzername, Profilbild, '
            'Einstellungen und Datum der Zustimmung zu den AGB.\n'
            '• Angebote und Bestellungen: Veranstaltung, Tickets, Preise, '
            'Mengen, Zahlungs- und Auszahlungsstatus, Auszahlungsdaten '
            '(z. B. IBAN).\n'
            '• Dateien: von Verkäufern hochgeladene Tickets und '
            'Veranstaltungsbilder.\n'
            '• Support: Nachrichten und Anhänge an das Support-Team.\n'
            '• Technische Daten: Anmelde- und Gerätedaten, die für die '
            'Sicherheit nötig sind.',
      ),
      (
        title: 'Zwecke und Rechtsgrundlagen',
        text:
            'Wir nutzen die Daten, um dein Konto zu führen, zwischen Käufern '
            'und Verkäufern zu vermitteln, Zahlungen und Auszahlungen '
            'abzuwickeln, Tickets zu liefern, Support zu leisten und Betrug '
            'zu verhindern. Rechtsgrundlagen sind die Vertragserfüllung '
            '(Art. 6 Abs. 1 lit. b DSGVO), gesetzliche Pflichten (lit. c, '
            'z. B. Buchhaltung) und unser berechtigtes Interesse an einer '
            'sicheren Plattform (lit. f); für optionale Benachrichtigungen '
            'deine Einwilligung (lit. a).',
      ),
      (
        title: 'Empfänger',
        text:
            'Käufer und Verkäufer sehen die für eine Bestellung nötigen '
            'Daten (z. B. öffentliches Profil, Tickets). Technisch läuft die '
            'Plattform auf Google Firebase (Google Ireland Ltd. / Google LLC) '
            'als Auftragsverarbeiter: Anmeldung, Datenbank, Dateispeicher '
            'und Hosting. Dabei können Daten auf Grundlage von '
            'Standardvertragsklauseln in die USA übermittelt werden. '
            'Zahlungsdienstleister erhalten die für die Zahlung nötigen '
            'Daten. Wir verkaufen keine Daten.',
      ),
      (
        title: 'Speicherdauer',
        text:
            'Kontodaten speichern wir, solange das Konto besteht. '
            'Bestellungen und Zahlungsdaten bewahren wir so lange auf, wie '
            'gesetzliche Aufbewahrungsfristen es verlangen. Tickets und '
            'Support-Nachrichten löschen wir, wenn sie nicht mehr nötig '
            'sind, spätestens nach Ablauf der Reklamationsfristen.',
      ),
      (
        title: 'Deine Rechte',
        text:
            'Du hast das Recht auf Auskunft, Berichtigung, Löschung, '
            'Einschränkung der Verarbeitung, Datenübertragbarkeit und '
            'Widerspruch sowie auf Beschwerde bei einer '
            'Datenschutzaufsichtsbehörde. Dein Profil bearbeitest du in den '
            'Einstellungen; dein Konto samt Daten löschst du unter '
            'Einstellungen › Datenschutz & Sicherheit. Für alles andere '
            'schreib an $_email.',
      ),
      (
        title: 'Sicherheit',
        text:
            'Daten werden verschlüsselt übertragen. Zugriff haben nur du '
            'und, wo nötig, das Support-Team.',
      ),
    ],
  ),
  'cookies': (
    intro:
        'Stubswap verwendet keine Cookies für Tracking oder Werbung. Wir '
        'nutzen nur Speicher, der für den Betrieb der App nötig ist.',
    sections: [
      (
        title: 'Lokaler Speicher im Browser',
        text:
            'Die App speichert in deinem Browser bzw. auf deinem Gerät '
            'Einstellungen (Sprache, Währung, Darstellung, Stadt) und '
            'zuletzt angesehene Veranstaltungen. Diese Daten bleiben auf '
            'deinem Gerät.',
      ),
      (
        title: 'Anmeldung (Firebase)',
        text:
            'Damit du angemeldet bleibst, speichert Google Firebase '
            'Authentication Anmeldedaten im Browser (Local Storage / '
            'IndexedDB). Ohne „Angemeldet bleiben” gilt die Anmeldung nur '
            'bis zum Schließen des Browsers.',
      ),
      (
        title: 'Kein Tracking',
        text:
            'Derzeit nutzen wir keine Analyse, keine Tracking-Tools und '
            'keine Werbe-Cookies von Dritten. Ändert sich das, fragen wir '
            'vorher nach deiner Einwilligung und passen diese Seite an.',
      ),
      (
        title: 'Löschen',
        text:
            'Gespeicherte Daten kannst du in den Browser-Einstellungen '
            'löschen. Danach musst du dich neu anmelden und die '
            'Einstellungen sind zurückgesetzt.',
      ),
    ],
  ),
};

// ---------------------------------------------------------------------------
// English
// ---------------------------------------------------------------------------

const Map<String, LegalDoc> _en = {
  'imprint': (
    intro: 'Information about the operator of the Stubswap platform.',
    sections: [
      (
        title: 'Operator',
        text:
            '$_operator\n$_address\n'
            'ID / registration number: $_registry',
      ),
      (
        title: 'Contact',
        text:
            'Email: $_email\n'
            'The quickest way to reach us is the help center in the app.',
      ),
      (title: 'Responsible for content', text: '$_operator, $_address'),
      (
        title: 'Role of the platform',
        text:
            'Stubswap is an online marketplace where private individuals '
            'sell and buy tickets for events. Stubswap is neither an event '
            'organizer nor a ticket issuer and does not sell tickets in its '
            'own name.',
      ),
      (
        title: 'User content',
        text:
            'Users are responsible for the listings, descriptions and '
            'pictures they publish. We remove unlawful content as soon as '
            'we learn of it – report it through the help center.',
      ),
    ],
  ),
  'terms': (
    intro:
        'These terms of use govern the use of the Stubswap platform '
        '(website and app) between you and $_operator. By signing up you '
        'accept them.',
    sections: [
      (
        title: '1. Operator and role of the platform',
        text:
            'The platform is run by $_operator, $_address ($_registry). '
            'Stubswap is an intermediary between private sellers and buyers '
            'of tickets. The purchase contract for a ticket is concluded '
            'directly between seller and buyer. Stubswap is not the event '
            'organizer and is not responsible for whether, how or how well '
            'an event takes place.',
      ),
      (
        title: '2. Account',
        text:
            'You need an account to buy and sell. You must be at least 18 '
            'or have your parents\' consent, give true details and keep your '
            'password secret. One account per person. Only accounts with a '
            'confirmed email address and a payout method can sell. You can '
            'delete your account at any time in the settings (Privacy & '
            'security).',
      ),
      (
        title: '3. Listings',
        text:
            'Sellers may only offer genuine, valid tickets they own or will '
            'certainly own by the delivery deadline. Event, ticket type, '
            'section, row, seats and face value must be stated correctly. '
            'The seller sets the price and is responsible for complying '
            'with the organizer\'s terms and resale laws. We may remove '
            'incorrect or suspicious listings.',
      ),
      (
        title: '4. Fees',
        text:
            'Buyers pay a service fee on the ticket price; sellers pay a '
            'seller fee deducted from the sale price. The platform sets both '
            'percentages. Buyers see the total including the fee before '
            'they buy, sellers see what they receive before they publish. '
            'A listing keeps the fees in force when it was published.',
      ),
      (
        title: '5. Payment and payout',
        text:
            'Buyers pay through the platform. We hold the money until after '
            'the event and only then pay it out to the seller, unless a '
            'problem was reported. This protects the buyer if a ticket does '
            'not arrive or is invalid.',
      ),
      (
        title: '6. Ticket delivery',
        text:
            'The seller uploads the tickets (e.g. PDF or picture) to the '
            'order no later than 24 hours before the event starts. If not, '
            'the order is cancelled automatically and the buyer gets a full '
            'refund including the service fee.',
      ),
      (
        title: '7. Buyer protection and reporting problems',
        text:
            'If a ticket does not arrive, is invalid or does not match the '
            'description, the buyer reports it through the order or the '
            'help center, at the latest by the end of the event. We review '
            'the case, ask both sides for evidence if needed and, if the '
            'report is justified, refund the buyer; the seller then '
            'receives no payout.',
      ),
      (
        title: '8. Cancelled and postponed events',
        text:
            'If the organizer cancels an event, the buyer is refunded and '
            'the seller receives no payout. If it is postponed or moved, '
            'tickets usually stay valid for the new date and the order '
            'stands; the payout follows the new date. If the organizer '
            'offers refunds for a postponed event, their terms apply.',
      ),
      (
        title: '9. Prohibited conduct',
        text:
            'It is prohibited to sell fake, copied, already used or invalid '
            'tickets; to sell the same ticket more than once; to give false '
            'details; to arrange payment outside the platform; to misuse '
            'other people\'s accounts; or to disrupt the platform. '
            'Violations may lead to removed listings, withheld payouts, a '
            'blocked account and reports to the authorities.',
      ),
      (
        title: '10. Liability',
        text:
            'Stubswap is liable for intent and gross negligence and as '
            'required by mandatory law. Sellers and organizers are '
            'responsible for tickets, their details and entry conditions. '
            'We cannot guarantee that the platform is always available.',
      ),
      (
        title: '11. Changes',
        text:
            'We may change these terms. We announce material changes in '
            'advance; existing orders keep the terms in force when they '
            'were placed.',
      ),
      (
        title: '12. Contact and governing law',
        text:
            'Questions to $_email or through the help center. The law of '
            'the operator\'s country of registration applies, without '
            'limiting the mandatory consumer rights of your country.',
      ),
    ],
  ),
  'privacy': (
    intro:
        'This explains which personal data we process when you use '
        'Stubswap, why, and what your rights are.',
    sections: [
      (title: 'Controller', text: '$_operator, $_address\nEmail: $_email'),
      (
        title: 'Data we process',
        text:
            '• Account data: name, email, username, profile picture, '
            'settings and when you accepted the terms.\n'
            '• Listings and orders: event, tickets, prices, quantities, '
            'payment and payout status, payout details (e.g. IBAN).\n'
            '• Files: tickets uploaded by sellers and event pictures.\n'
            '• Support: messages and attachments you send to the support '
            'team.\n'
            '• Technical data: sign-in and device data needed for security.',
      ),
      (
        title: 'Purposes and legal bases',
        text:
            'We use the data to run your account, connect buyers and '
            'sellers, process payments and payouts, deliver tickets, '
            'provide support and prevent fraud. The legal bases are '
            'performance of the contract, legal obligations (e.g. '
            'accounting) and our legitimate interest in a safe platform; '
            'for optional notifications, your consent.',
      ),
      (
        title: 'Recipients',
        text:
            'Buyers and sellers see the data an order needs (e.g. public '
            'profile, tickets). The platform runs on Google Firebase (Google '
            'Ireland Ltd. / Google LLC) as processor: sign-in, database, '
            'file storage and hosting. Data may be transferred to the USA '
            'under standard contractual clauses. Payment providers receive '
            'the data a payment needs. We do not sell data.',
      ),
      (
        title: 'Retention',
        text:
            'We keep account data as long as the account exists. Orders and '
            'payment records are kept as long as statutory retention '
            'periods require. Tickets and support messages are deleted when '
            'no longer needed, at the latest after complaint periods end.',
      ),
      (
        title: 'Your rights',
        text:
            'You have the right of access, rectification, erasure, '
            'restriction, data portability and objection, and the right to '
            'complain to a data protection authority. You edit your profile '
            'in the settings and delete your account with all its data '
            'under Settings › Privacy & security. For anything else, write '
            'to $_email.',
      ),
      (
        title: 'Security',
        text:
            'Data is transmitted encrypted. Only you and, where needed, the '
            'support team have access.',
      ),
    ],
  ),
  'cookies': (
    intro:
        'Stubswap does not use cookies for tracking or advertising. We only '
        'use the storage the app needs to work.',
    sections: [
      (
        title: 'Local storage in the browser',
        text:
            'The app remembers your settings (language, currency, '
            'appearance, city) and recently viewed events in your browser or '
            'on your device. This data stays on your device.',
      ),
      (
        title: 'Sign-in (Firebase)',
        text:
            'To keep you signed in, Google Firebase Authentication stores '
            'sign-in data in the browser (local storage / IndexedDB). '
            'Without “Keep me signed in”, the sign-in lasts until the '
            'browser is closed.',
      ),
      (
        title: 'No tracking',
        text:
            'We currently use no analytics, no tracking tools and no '
            'third-party advertising cookies. If that changes, we will ask '
            'for your consent first and update this page.',
      ),
      (
        title: 'Deleting',
        text:
            'You can delete stored data in your browser settings. You will '
            'then have to sign in again and your settings are reset.',
      ),
    ],
  ),
};
