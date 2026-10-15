# Changelog

Alle wichtigen Änderungen an Stubswap. Format nach
[Keep a Changelog](https://keepachangelog.com/de/1.1.0/), Versionen nach
[Semantic Versioning](https://semver.org/lang/de/): `MAJOR.MINOR.PATCH`.

Neue Einträge kommen unter **[Unreleased]**; `tool/release.sh` macht daraus
die nächste Version.

## [Unreleased]

### Geändert
- Am PC sitzt der Scrollbalken am Fensterrand statt neben dem Inhalt, und
  das Mausrad scrollt die Seite auch über den freien Rändern.

## [1.8.0] – 2026-10-14

### Neu
- Handy- und Papiertickets: Der Verkäufer gibt die Übergabe an (Übertragung
  an Name/E-Mail, Post/Kurier mit Sendungsnummer oder persönlich), der
  Käufer sieht die Angaben, bekommt sie per Mail und bestätigt den Erhalt.
- Datenauskunft: unter Privatsphäre & Sicherheit alle eigenen Daten als
  JSON-Datei herunterladen.

### Sicherheit
- Firebase App Check mit reCAPTCHA Enterprise (Fraud Defense):
  Anfragen an Firestore, Storage und Functions tragen einen Nachweis, dass
  sie aus der App kommen. Noch nicht erzwungen.

## [1.7.1] – 2026-10-12

- Moderation: open reports again
- Prod emails from the Gmail account for now; note prod is integration until go-live
- Emails: no upload reminder in the sale email when tickets are already there
- Staging emails: send from the Gmail test account

## [1.7.0] – 2026-10-12

### Neu
- Wiederverkaufsregeln: Admins legen fest, wie weit über dem Originalpreis
  Tickets verkauft werden dürfen (allgemein und je Event); Verkaufen und
  Preisänderungen zeigen und prüfen den Höchstpreis.
- Transaktionsmails (Bosnisch, Deutsch, Englisch): Kauf, Verkauf, Tickets
  da, Erstattung, Problem gemeldet, Auszahlung, Verschiebung, Erinnerung zum
  Hochladen, Support-Antwort, entferntes Angebot. Versand über eine eigene
  Function per SMTP (ohne Firebase-Erweiterung).
- Betrugsschutz: dieselbe Ticketdatei kann nicht zweimal verkauft werden
  (Kopie gesperrt, Team informiert); Limits für neue Verkäufer; Angebote
  melden.
- Moderation für Admins und Support: Meldungen, kopierte Tickets, Nutzer
  suchen, sperren/entsperren, Limits aufheben, Angebote entfernen,
  Bestellungen erstatten, Protokoll.
- Rechnungen der Plattform über die Servicegebühr (mit PDV) an Käufer und
  Verkäufer, Stornorechnungen, PDF-Download, Monatsübersicht mit CSV-Export
  und Firmendaten für Admins.

## [1.6.4] – 2026-10-12

- Account pages fill the page beside the sidebar, like the profile

## [1.6.3] – 2026-10-12

- Event editor: account sidebar on wide screens for the team

## [1.6.2] – 2026-10-12

- Web: let the app reach the Cloud Functions (CSP connect-src)
- Web: let the app reach the Cloud Functions (CSP connect-src)

## [1.6.1] – 2026-10-12

- Web: allow the Storage and Functions SDK loaders in the CSP
- Functions: delivered ticket copies get their own download token

## [1.6.0] – 2026-10-12

### Neu
- Tickets hochladen (PDF/Bild): beim Einstellen oder später; Käufer bekommen
  sie automatisch nach der Zahlung und können sie herunterladen; Warnung für
  Verkäufer, solange Karten fehlen
- Reservierung: Tickets sind beim Bezahlen 15 Minuten für den Käufer gehalten
- Fristen: unbezahlte Bestellungen verfallen; nicht gelieferte E-Tickets
  24 h vor dem Event werden erstattet; Abschluss 3 Tage nach dem Event,
  Auszahlung wird freigegeben; Angebote vergangener Events laufen ab
- Problem melden: Käufer meldet ein Problem, Auszahlung wird angehalten, das
  Team entscheidet (Erstattung oder weiter)
- Events absagen (alle Käufer bekommen ihr Geld zurück) oder verschieben
  (Karten bleiben gültig)
- Rechtliches: Impressum, AGB, Datenschutz, Cookies (mit Platzhaltern),
  Zustimmung bei der Registrierung
- Preise überall als Endpreis inkl. Servicegebühr; beim Einstellen
  Originalpreis pro Karte und sofortige Gewinnanzeige

### Technik
- Cloud Functions (`functions/`) und Firebase Storage, siehe docs/BACKEND.md

## [1.5.1] – 2026-10-11

### Geändert
- Team-Konten: Abschnitt „Tim“ (Support-Anfragen, Events zur Prüfung,
  Administration) steht in den Einstellungen ganz oben; keine Kauf-/
  Verkaufsstatistik im Profil

## [1.5.0] – 2026-10-11

### Geändert
- Admin- und Support-Konten kaufen und verkaufen nicht mehr: keine
  Verkaufen-/Kaufen-Knöpfe und Menüpunkte, Hinweis bei Angeboten, Seiten zum
  Kaufen/Verkaufen leiten zur Startseite; die Firestore-Regeln verbieten es

## [1.4.2] – 2026-10-11

- Retry Firestore listeners on transient errors; show error codes
- Showcase seed: read checks that work with the rules

## [1.4.1] – 2026-10-11

### Behoben
- „Laden fehlgeschlagen“ beim ersten Öffnen (z. B. Hilfe-Center): Abfragen,
  die genau beim An-/Abmelden starten oder kurz keine Verbindung haben,
  werden automatisch wiederholt; Fehlermeldungen zeigen den Fehlercode
- Team-Liste zeigt Name und E-Mail aus dem aktuellen Profil (auch für in der
  Konsole angelegte Admins) statt „Ohne Namen“

## [1.4.0] – 2026-10-11

### Neu
- Nutzer können Events anlegen; sie sind „nicht bestätigt“, bis Admin oder
  Support sie prüfen, anpassen und bestätigen. Karten können trotzdem sofort
  gekauft und verkauft werden; der Status ist überall sichtbar
- Unterkategorien (z. B. Fußball, Rock); „Theater“ heißt jetzt „Kultur“
- Startseite mit Filter (Stadt oder eigener Standort, Typ) und Sektionen:
  Zuletzt angesehen, Beliebte Veranstaltungen, Für Sie empfohlen, In der Nähe,
  beliebte Kategorien, alle Veranstaltungen
- Footer mit „Unser Unternehmen“ (Über uns, Presse, …) und Hilfe-Links

## [1.3.0] – 2026-10-11

### Neu
- Events werden vom Admin angelegt (mit Bild); die Startseite zeigt Events,
  die Angebote erscheinen auf der Event-Seite; Verkaufen = Event auswählen
- Admin-Bereich: Events, Servicegebühr, Team (Support-Konten vergeben),
  Support-Anfragen
- Servicegebühr einstellbar; gilt nur für neu eingestellte Angebote, alte
  Angebote und Bestellungen behalten ihre Gebühr
- Support in der App statt per E-Mail: Anfragen mit Bildern, Verlauf,
  Antworten des Teams, Anfrage schließen; Hinweis-Badge am Profilbild und
  Live-Benachrichtigung bei Antworten bzw. neuen Anfragen

### Sicherheit
- Regeln für Rollen, Events, Gebühren und Support-Tickets mit Angriffstests

## [1.2.2] – 2026-10-11

### Behoben
- Google-Anmeldung: Das Anmeldefenster wird sofort beim Tippen geöffnet, damit
  der Browser es nicht als unerwünschtes Pop-up blockiert
- Eigene Meldung, wenn der Browser das Google-Fenster trotzdem blockiert;
  unerwartete Fehler zeigen jetzt den Fehlercode (z. B. „internal-error“)

## [1.2.1] – 2026-10-11

### Behoben
- Passwort, das die Firebase-Passwortrichtlinie nicht erfüllt: verständliche
  Meldung statt „unbekannter Fehler“

## [1.2.0] – 2026-10-11

### Neu
- Prod-Umgebung mit eigenem Firebase-Projekt `stubswap-prod` (echte Nutzer,
  Zahlungssimulator bis Stripe); Staging bleibt unter `/flat/staging/`

## [1.1.1] – 2026-10-11

### Behoben
- Profilfoto hochladen: Die Sicherheitsrichtlinie (CSP) blockierte das Lesen
  der gewählten Datei („Bild konnte nicht geladen werden“)

## [1.1.0] – 2026-10-11

### Neu
- Versionierung: Version und Build in „Über“ und in Support-Anfragen,
  Release-Skript mit Changelog und Tags
- Hinweis „Neue Version verfügbar“ mit Neu-laden-Knopf (Web)
- Umgebungen Staging (Test) und Prod (echte Nutzer), Staging-Kennzeichen;
  beide mit Zahlungssimulator bis Stripe kommt

## [1.0.0] – 2026-10-11

Erste getaggte Version.

### Neu
- Marktplatz: Angebote einstellen, kaufen (Zahlungssimulator), verkaufen,
  Rechnungen, Auszahlungen, Support mit Hilfezentrum
- Konto: Profil mit Foto und Benutzername, Privatsphäre & Sicherheit,
  Benachrichtigungen, Aussehen (Farbe, Textgröße, Stil, Dark Mode)
- Sprachen Bosnisch, Deutsch, Englisch
- Design mit Forui, Desktop-Layout mit Konto-Seitenleiste
- Live-Benachrichtigungen bei Verkauf, Versand und Storno
- Verkäufer kann einen Verkauf stornieren (Käufer nicht)

### Sicherheit
- Gehärtete Firestore-Regeln mit Angriffstests
- Content-Security-Policy und Clickjacking-Schutz
- Verkaufen nur mit bestätigter E-Mail, Passwörter ab 8 Zeichen
