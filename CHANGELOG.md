# Changelog

Alle wichtigen Änderungen an Stubswap. Format nach
[Keep a Changelog](https://keepachangelog.com/de/1.1.0/), Versionen nach
[Semantic Versioning](https://semver.org/lang/de/): `MAJOR.MINOR.PATCH`.

Neue Einträge kommen unter **[Unreleased]**; `tool/release.sh` macht daraus
die nächste Version.

## [Unreleased]

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
