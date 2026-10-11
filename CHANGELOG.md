# Changelog

Alle wichtigen Änderungen an Stubswap. Format nach
[Keep a Changelog](https://keepachangelog.com/de/1.1.0/), Versionen nach
[Semantic Versioning](https://semver.org/lang/de/): `MAJOR.MINOR.PATCH`.

Neue Einträge kommen unter **[Unreleased]**; `tool/release.sh` macht daraus
die nächste Version.

## [Unreleased]

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
