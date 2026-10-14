# Stubswap – Go-Live-Checkliste

Stand: 11.10.2026. Stripe (echte Zahlungen, Auszahlungen über Stripe Connect)
ist bewusst ausgeklammert und kommt als letzter Schritt.

Legende: ✅ erledigt · 🔴 blockiert den Go-Live · 🟠 sollte vor dem Go-Live
kommen · 🟢 kann nach dem Start kommen

---

## 1. Sicherheit – was im Code abgesichert ist ✅

Die App hat keinen eigenen Server: alles läuft über Firebase, also sind die
**Firestore-Regeln** die eigentliche Verteidigungslinie. Sie wurden komplett
gehärtet und mit 24 Emulator-Tests (inkl. Angriffsszenarien) geprüft
(`firestore_test/rules.test.mjs`).

| Angriff | Schutz |
|---|---|
| Eigene Felder einschleusen (z. B. `verified: true`, `role: admin`) | Jede Sammlung erlaubt nur die Felder, die die App schreibt |
| Riesige Daten / Spam (Speicher- und Kostenangriff) | Längenlimits für alle Texte, Profilfoto < 200 KB, Support-Nachricht ≤ 2000 Zeichen |
| Fantasiepreise, 1000 Tickets, Events in der Vergangenheit | Preis 0,01–10 000, max. 50 Tickets pro Angebot, max. 10 pro Bestellung, Event in der Zukunft (≤ 2 Jahre) |
| Verkaufen mit Wegwerf-Konto | Verkaufen nur mit bestätigter E-Mail (Regel + App) |
| Gefälschte Ticketdaten in Bestellungen | Event, Sitzplatz, Typ, Preis werden gegen das Angebot geprüft |
| Fremde E-Mail im Profil oder Support | E-Mail muss die des angemeldeten Kontos sein |
| Fremden Benutzernamen anzeigen / Namen horten | Benutzername muss reserviert sein, ein Name pro Konto |
| Fremde Profile, Bestellungen, Auszahlungen lesen/ändern | Nur Eigentümer bzw. Käufer/Verkäufer der Bestellung |
| Zahlung/Tickets/Auszahlung einzeln manipulieren | Nur zusammen in einer Transaktion, Beträge werden nachgerechnet |
| Storno ohne Rückgabe der Tickets | Regel prüft die Rückgabe (Lücke durch Test gefunden und geschlossen) |
| Eigene Tickets kaufen | Regel + App verweigern es |
| Konto löschen mit offenen Verkäufen | App verweigert es; aktive Angebote werden beim Löschen zurückgezogen |
| Fremde Skripte / Datenabfluss (XSS) | Content-Security-Policy: Skripte nur von der Seite, Google, Firebase |
| Einbetten in fremde Seiten (Clickjacking) | Frame-Schutz in der Seite; echte Header in `firebase.json` |
| Schwache Passwörter | Mindestens 8 Zeichen |
| Veraltetes „E-Mail bestätigt“ im Login-Token | Token wird nach Bestätigung erneuert |

Flutter zeichnet Text selbst (kein HTML), deshalb ist klassisches XSS über
Nutzereingaben ohnehin kaum möglich.

---

## 2. Sicherheit – Schritte in der Konsole (nur du kannst sie machen)

1. 🔴 **Firestore-Regeln veröffentlichen**: Inhalt von `firestore.rules` →
   Firebase-Konsole → Firestore → Regeln → Veröffentlichen.
   (Sonst gelten die alten, schwächeren Regeln und Stornieren funktioniert
   nicht.)
2. 🔴 **API-Schlüssel einschränken** (Google Cloud Console → APIs & Dienste →
   Anmeldedaten → Browser-Schlüssel):
   - Anwendungseinschränkung „Websites“: `https://durmexyt-dot.github.io/*`
     (später deine Domain), für Entwicklung `http://localhost:*`
   - API-Einschränkung: Identity Toolkit API, Token Service API, Cloud
     Firestore API, Firebase Installations API
3. 🔴 **Authentication → Einstellungen**:
   - „Schutz vor E-Mail-Aufzählung“ einschalten (verhindert, dass Angreifer
     herausfinden, welche E-Mails registriert sind)
   - Passwortrichtlinie: mindestens 8 Zeichen erzwingen
   - Autorisierte Domains: nur `durmexyt-dot.github.io` (bzw. deine Domain)
     und `localhost`; alles andere entfernen
4. 🔴 **App Check** (Schutz gegen Bots und Skripte, die die API direkt
   aufrufen): reCAPTCHA-Enterprise-Schlüssel anlegen, mir den Site-Key geben →
   ich binde `firebase_app_check` ein → danach in der Konsole für Firestore
   und Authentication „erzwingen“.
5. 🟠 **Budget-Warnung** in der Google Cloud (z. B. bei 10 €), damit ein
   Missbrauch nicht unbemerkt Kosten erzeugt.
6. 🟠 **Hosting auf Firebase Hosting + eigene Domain**: GitHub Pages kann
   keine Sicherheits-Header senden. `firebase.json` enthält sie schon
   (CSP mit `frame-ancestors`, HSTS, `nosniff`, Permissions-Policy).
7. 🟠 **Backups**: Firestore Point-in-Time-Recovery oder geplante Exporte
   (braucht den Blaze-Tarif).
8. 🔴 **Vor dem Start**: Testkonten und Testdaten löschen; den Testmodus
   (Zahlungssimulator) mit Stripe abschalten – solange er aktiv ist, kann
   jeder „bezahlen“, ohne zu zahlen.

---

## 3. Stand der Funktionen (ohne Stripe), Oktober 2026

### ✅ Erledigt (v1.7)

Ticket-Upload und automatische Auslieferung, Reservierung (15 Min),
Fristen/Abschluss/Ablauf per Cloud Function, Problem melden/Streitfall,
Absage/Verschiebung, Rechtstexte (Platzhalter), Endpreis, Originalpreis +
Gewinn, Wiederverkaufsregeln, Transaktionsmails (eigener SMTP-Versand),
Betrugsschutz (Doppel-Upload, Limits neuer Verkäufer, Angebot melden),
Moderation für Admin + Support, Rechnungen der Plattform mit CSV-Export.

### 🔴 Noch vor dem Start (Code)

1. **Mobile- und Papiertickets**: Übergabeangaben (Transfer an Name/E-Mail,
   Sendungsnummer) statt nur „gesendet“; Bestätigung durch den Käufer.
2. **App Check** einbauen (braucht den reCAPTCHA-Schlüssel, siehe 2.4).
3. **Einstellungen ohne Funktion** (Preisalarme, Event-Erinnerungen,
   Newsletter) bauen oder ausblenden.
4. **Datenauskunft (DSGVO/ZZLP)**: eigene Daten exportieren.
5. **Prod aufräumen**: Skript zum Löschen von Testdaten und -konten.

### 🟠 Sollte vor dem Start kommen

6. Push bei geschlossener App (FCM).
7. Fehler-Monitoring (Sentry/Crashlytics); Analytics nur mit Einwilligung.
8. Event-Seite: Filter (Anzahl, Preis, Sektor), Aufteilungsregeln,
   Angebot bearbeiten/pausieren.
9. Öffentliches Verkäuferprofil mit Bewertungen.
10. Admin-Seite „E-Mail“: Absender, Testmail, Versandstatus.

### 🟢 Nach dem Start

Zwei-Faktor-Anmeldung, E-Mail ändern, SEO-Seiten, Apps im Store, Wallet,
Merkliste/Preisalarm, „Ich suche Tickets“, mehr Währungen.

---

## 4. Vor dem Go-Live: nur der Inhaber

- Rechtstexte (Impressum, AGB, Datenschutz) ausfüllen und prüfen lassen.
- Firmendaten unter Administracija → Podaci o firmi; Rechnungsinhalt (PDV)
  von der Steuerberatung bestätigen lassen.
- Eigene Domain, Mails über einen Anbieter mit SPF/DKIM (statt Gmail),
  `MAIL_FROM` für Prod anpassen.
- Firebase Authentication: E-Mail-Vorlagen (Absender, Sprache), siehe 2.3.
- Konsole-Schritte aus Abschnitt 2 (API-Schlüssel, Auth-Einstellungen,
  App Check, Budget, Hosting mit Domain, Backups).
- Team-Konten auf Prod anlegen; Testdaten und -konten löschen.
- Stripe (Zahlung + Connect-Auszahlungen), danach Testmodus-Regeln entfernen.
