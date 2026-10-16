# Stubswap – Design-Variablen

Wo das Aussehen der App festgelegt ist. Wer das Design ändern will, ändert
diese Stellen, nicht die einzelnen Seiten.

Grundregeln: Forui 0.27.5, mobile first, Farben nach 70/20/10, keine
Verläufe.

## Übersicht

| Was | Datei | Beispiel |
|---|---|---|
| Abstände (Skala auf Basis `Space.unit` = 4 px) | `lib/src/ui/tokens.dart` → `Space` | `SizedBox(height: Space.lg)` = 12 px |
| Seitenränder | `tokens.dart` → `Insets` | `padding: Insets.page` |
| Icon-Größen | `tokens.dart` → `IconSizes` | `Icon(…, size: IconSizes.sm)` |
| Animationen (Dauer, Kurven) | `tokens.dart` → `Motion` | `duration: Motion.normal` |
| Schriftgewichte | `tokens.dart` → `FontWeights` | `FontWeights.semibold` |
| Häufige Textstile | `tokens.dart` → `AppTextStyles` | `theme.mutedText`, `theme.titleText` |
| Feste Radien (Bottom Sheets) | `tokens.dart` → `Radii` | `Radii.sheetTop` |
| Seitenbreiten am PC, Umbruch Handy/PC | `tokens.dart` → `SiteWidth`, `wideLayoutBreakpoint` | 1200 px, ab 900 px Desktop |
| Feste Farben (Status, Staging-Band, Bildbetrachter, Google) | `tokens.dart` → `FixedColors` | `FixedColors.positive` |
| Markenfarben zur Auswahl | `lib/src/settings/settings_controller.dart` → `BrandColor` | violett, blau, … |
| Hell/Dunkel-Paletten für Forui | `lib/src/ui/forui_theme.dart` → `appColors` | |
| Material-Farben (für die wenigen Material-Widgets) | `lib/src/ui/theme.dart` | |
| Ecken von Karten, Buttons, Feldern (je nach „Stil“-Einstellung) | `lib/src/ui/app_style.dart`, `UiStyle` in `settings_controller.dart` | |
| Schriftart und Schriftgrößen | Forui-Typografie (`context.theme.typography`) | `typography.body.sm` |
| Logo und Schriftzug | `lib/src/brand/brand.dart` | |
| HTML-Splash vor dem Laden der App | `web/index.html`, `web/splash_theme.js` | |

## Beispiele für spätere Änderungen

- **Alles etwas luftiger:** `Space.unit` von 4 auf 4.5 setzen; alle Abstände
  wachsen mit.
- **Ruhigere Animationen:** Werte in `Motion` erhöhen. Kein Überschwingen
  (Apple: nur nach Gesten mit Schwung).
- **Andere Statusfarben:** `FixedColors.positive` / `waiting` ändern.
- **Breitere Seiten am PC:** `SiteWidth.wide` erhöhen (Kopfzeile und Inhalt
  wachsen zusammen).
- **Neue Hausfarbe:** `BrandColor` in `settings_controller.dart` ergänzen oder
  ändern; Forui und Material übernehmen sie.

## Barrierefreiheit

- Auf Touch-Geräten (< 900 px) hebt `forui_theme.dart` kleine Forui-Buttons
  und Tabs auf `TapTarget.min`. Eigene tippbare Flächen bekommen mindestens
  `BoxConstraints(minHeight: TapTarget.min)`.
- Icon-Buttons immer mit `semanticsLabel`; `FTooltip` in `MergeSemantics`.
- Statusfarben (`FixedColors`) nur für Punkte, Icons und Flächen, nicht für
  Fließtext; Kontraste prüft `test/accessibility_test.dart`.
- Formularfelder: `AutovalidateMode.onUserInteractionIfError` – Fehler
  erst beim Absenden, danach live bis zur Korrektur.
- Reduzierte Bewegung: `Motion.reducedDuration` statt der normalen Dauern,
  Seiten nur überblenden, keine Hero-Flüge (`HeroMode` in `app.dart`).
- Endlose Animationen nur, wenn `MediaQuery.disableAnimationsOf` false ist.
- Vorschläge aus dem Skill ui-ux-pro-max sind willkommen, die Regeln oben
  (Forui, 70/20/10, keine Verläufe, Tokens) gehen vor.

## Ausnahmen

Ein paar Feinwerte stehen bewusst noch als Zahl im Code, weil sie zu einem
einzelnen Bauteil gehören (z. B. 3 px Innenabstand in Badges, Pillenradien,
Avatar-Größen, die PDF-Rechnung in `invoice_pdf.dart`). Der Zahlungssimulator
hat seine Stripe-Farben in `test_payment_gateway.dart`; er fällt mit Stripe weg.
