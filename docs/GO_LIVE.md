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

## 3. Fehlende Funktionen vor dem Go-Live (ohne Stripe)

### 🔴 Muss vor dem Start da sein

1. **Ticket-Übergabe** – das wichtigste fehlende Stück. Heute markiert der
   Verkäufer nur „Karten gesendet“. Nötig:
   - Upload der Tickets (PDF/QR/Bild) durch den Verkäufer in Firebase Storage,
     nur der Käufer kann sie nach der Zahlung herunterladen
   - für Mobile-Tickets: Übertragungsangaben (z. B. Ticketmaster-Transfer)
   - für Papier-Tickets: Versand mit Sendungsnummer
2. **Server-Logik (Cloud Functions)** – heute erledigt die App alles selbst,
   abgesichert durch Regeln. Für den Echtbetrieb braucht es einen Server für:
   - Bestellung nach dem Event automatisch „abgeschlossen“, Auszahlung freigeben
   - Angebote vergangener Events automatisch „abgelaufen“
   - unbezahlte Bestellungen nach X Minuten verfallen lassen
   - Tickets während des Bezahlens reservieren (gegen Überverkauf)
   - (wird für Stripe ohnehin gebraucht → Blaze-Tarif)
3. **Käuferschutz-Ablauf**: Käufer meldet „Ticket ungültig / nicht erhalten“,
   Auszahlung wird angehalten, Support entscheidet, Rückerstattung.
4. **Admin-Bereich**: Support-Anfragen und Streitfälle bearbeiten, Angebote
   entfernen, Nutzer sperren, Rückerstattungen auslösen.
5. **Rechtliches**: Impressum, AGB/Nutzungsbedingungen, Datenschutzerklärung
   (DSGVO + bosnisches ZZLP), Zustimmung bei der Registrierung, Gebühren- und
   Rückerstattungsregeln, Hinweis zu lokalem Speicher.
6. **E-Mails** zu Bestellung, Verkauf, Versand, Auszahlung (z. B. Firebase
   Extension „Trigger Email“).

### 🟠 Sollte vor dem Start kommen

7. **Push bei geschlossener App** (Firebase Cloud Messaging + Function).
   Live-Benachrichtigungen bei offener App gibt es schon.
8. **Verkäuferprofil & Vertrauen**: öffentliche Profilseite, Anzahl Verkäufe,
   Bewertungen, „verifizierter Verkäufer“ (kommt mit Stripe Connect / KYC).
9. **„Angebot melden“** (Betrug, Fake-Tickets).
10. **Event-Seiten**: Angebote pro Event bündeln, Suche nach Stadt/Datum,
    Sortierung nach Preis (wie viagogo).
11. **Fehler-Monitoring** (z. B. Sentry) und Analytics.
12. **Einstellungen ohne Funktion** entweder bauen oder ausblenden:
    Preisalarme, Event-Erinnerungen, Newsletter.

### 🟢 Kann nach dem Start kommen

13. Zwei-Faktor-Anmeldung, E-Mail-Adresse ändern
14. Originalpreis (Face Value) und Preisobergrenzen gegen Wucher
15. Wallet-Pässe, Währungsumrechnung, Wartelisten
16. Suchmaschinen-taugliche Event-Seiten (Flutter-Web wird schlecht indexiert)

---

## 4. Empfohlene Reihenfolge

1. Konsole-Schritte aus Abschnitt 2 (1–5) – eine Stunde Arbeit
2. Blaze-Tarif + Cloud Functions (Server-Logik, Reservierung, Ablauf)
3. Ticket-Übergabe mit Storage
4. Käuferschutz + Admin-Bereich
5. Rechtstexte, E-Mails, Push
6. Stripe (Zahlung + Connect-Auszahlungen), Testmodus-Regeln entfernen
7. Testdaten löschen → Go-Live
