# CLAUDE.md — Feierabend Rechner

Diese Datei ist die **zentrale Wahrheitsquelle** für die Entwicklung. Jede KI-Session
(und jeder Mensch) liest sie zuerst. Kurz, präzise, immer aktuell halten.

---

## 1. Was ist die App?

**Feierabend Rechner** — eine extrem einfache App, die berechnet, **wann Feierabend ist**.

Kernfall:
- Nutzer gibt Startzeit ein (z. B. `06:44`).
- Standard: 8 Std. Arbeitszeit + 45 Min. Pause (wird automatisch dazugerechnet/abgezogen).
- App zeigt sofort die **Feierabend-Uhrzeit** und einen **Live-Countdown**.

Alles ist individuell einstellbar (Arbeitszeit, Pausen, Profile). Design: **minimalistisch,
übersichtlich, modern**, angenehme Farben, sanfte Overlays/Animationen.

Ziel: **Play-Store-Release** (später optional App Store). Bezahlmodell, das zum Kauf anregt.

---

## 2. Design-Prinzipien (nicht verhandelbar)

1. **Ein-Blick-Klarheit**: Der Hauptbildschirm beantwortet EINE Frage — „Wann habe ich frei?"
   Alles andere ist sekundär und ausgeblendet, bis man es braucht.
2. **Maximal 2 Taps** bis zum Ergebnis. Startzeit ist beim Öffnen vorausgewählt (jetzt/letzte).
3. **Ruhige, moderne Ästhetik**: viel Weißraum, große Zahlen, weiche Ecken, dezente Schatten.
4. **Angenehme Farben**: warme, entspannende Palette (siehe Design-Tokens unten). Kein grelles Rot.
5. **Sanfte Overlays** statt harter Seitenwechsel: Bottom-Sheets, Fade/Slide, Haptik-Feedback.
6. **Dark Mode** von Tag 1 an gleichwertig.
7. **Offline-first**: Alles funktioniert ohne Internet. Keine Anmeldung nötig.

---

## 3. Tech-Stack (Entscheidung)

| Bereich            | Wahl                          | Warum |
|--------------------|-------------------------------|-------|
| Framework          | **Flutter (Dart)**            | Ein Codebase, native Performance, top UI, Play + App Store |
| Min. Android SDK   | 24 (Android 7.0)              | ~99 % Geräteabdeckung |
| State Management   | **Riverpod**                  | Einfach, testbar, wenig Boilerplate |
| Lokale Daten       | **shared_preferences** (JSON-Blobs) | Offline, reicht für Settings/Profile/Überstunden |
| Monetarisierung    | **in_app_purchase** (direkt, Produkt `feierabend_pro`) + **google_mobile_ads** (AdMob, UMP) | Kein Fremdkonto nötig |
| Benachrichtigungen | **flutter_local_notifications** | Countdown/„Feierabend erreicht" ohne Server |
| Home-Widget        | **nativ** (RemoteViews + Chronometer, MethodChannel) | Kein Glance/Compose-Ballast; Countdown tickt ohne App |
| Design-System      | **Material 3** + eigenes Theme | Modern, anpassbar |
| Analytics/Crashes  | **keine eigenen** (Play-Console-Statistik reicht) | Datenschutz, schlanke Data-Safety-Angaben |
| Übersetzung        | **gen-l10n** (`lib/l10n/*.arb`, DE + EN) | Offizieller Flutter-Weg |

> Wenn ein Paket Probleme macht: erst in TODO.md dokumentieren, dann Alternative wählen.
> Nichts Serverseitiges bauen, solange nicht zwingend nötig — die App bleibt offline-first.

---

## 4. Kern-Logik (Feierabend-Berechnung)

```
feierabend = startzeit + arbeitszeit + pausenzeit  (Pause verlängert Anwesenheit)
```

- `arbeitszeit`: Netto-Sollarbeitszeit (Default 8 h).
- `pausenzeit`: wird zur Anwesenheit addiert (Default 45 min). D. h. bei Start 06:44,
  8 h Arbeit + 45 min Pause → Feierabend **15:29**.
- **Deutsches Arbeitszeitgesetz (ArbZG) als optionaler Auto-Modus**:
  - > 6 h Arbeit → mind. 30 min Pause
  - > 9 h Arbeit → mind. 45 min Pause
  - App kann Pause automatisch nach Gesetz vorschlagen (Toggle in Settings).
- Edge Cases sauber behandeln: Mitternachts-Überlauf (Nachtschicht), Zeitumstellung,
  0-Pause, Teilzeit, Sekunden ignorieren (auf Minute runden).

Diese Logik lebt **isoliert und voll unit-getestet** in `lib/domain/` — UI hängt nur dran.

---

## 5. Feature-Umfang (Free vs. Pro)

**Free (Köder, muss für sich schon nützlich sein):**
- Feierabend-Berechnung mit Startzeit, Arbeitszeit, Pause, Schnellwahl
- Live-Countdown, Sprüche (alle Berufsgruppen), Dark Mode
- 1 Profil
- dezentes AdMob-Banner unten; 24 Std. Pro per Belohnungsvideo

**Pro (einmaliger Kauf `feierabend_pro`, 3,99 €) — umgesetzt:**
- Keine Werbung
- Mehrere Profile (z. B. Mo–Do / Fr, Schichten)
- Überstunden-Konto / Wochenübersicht
- ArbZG-Auto-Pausenmodus
- Erinnerungen, frei einstellbar: mehrere Vorwarnungen (z. B. 2 Std/1 Std/15 Min + eigene), Halbzeit, „Feierabend!", optional mit Spruch
- Live-Countdown im Android-Home-Screen-Widget (die Uhrzeit darin ist gratis → Werbehebel)

**Designs (einzeln kaufbar, nicht in Pro):** Standard gratis; `design_supporter` (Herzen, teuerstes),
`design_midnight`, `design_sunset`, `design_ocean`, `design_forest`. Katalog `lib/design/app_designs.dart`,
Kauf/Auswahl `lib/features/designs/` (`designsProvider`, `activeDesignProvider`), Farben per
`ThemeExtension` `DesignColors` (`context.design`). Web-Vorschau: alle frei.

Gating über `isProProvider` (`lib/features/pro/pro_providers.dart`); Web-Vorschau = immer Pro.

Details & Begründung in `MARKETING.md`.

---

## 6. Projekt-Struktur (Ziel)

```
lib/
  main.dart
  app.dart                 # MaterialApp, Theme, Routing
  domain/                  # Reine Logik, KEINE Flutter-Imports
    feierabend_calculator.dart
    models/
  data/                    # Hive-Repos, Persistenz
  features/
    home/                  # Hauptbildschirm
    settings/
    profiles/
    overtime/
    paywall/
  design/                  # Theme, Farben, Typografie, Widgets
  services/                # Notifications, Widget, Purchases, Analytics
test/                      # Unit- + Widget-Tests (domain/ = 100 % Ziel)
```

---

## 7. Design-Tokens (Startwerte, in `lib/design/` verankern)

- **Primär**: warmes Indigo/Violett `#6C5CE7` (Fokus, Buttons)
- **Akzent/Erfolg**: sanftes Grün `#00B894` („frei!")
- **Hintergrund hell**: `#F7F7FB`  ·  **dunkel**: `#15151E`
- **Fläche/Karten**: weiche Ecken (20–24 px), dezenter Schatten, Glas-/Blur-Overlays
- **Typografie**: eine moderne Sans (z. B. Inter). Uhrzeit sehr groß & fett.
- **Motion**: 200–300 ms, ease-out; Haptik bei wichtigen Aktionen.

---

## 8. Arbeitsweise für Claude

1. **Immer** aktueller Branch: `claude/feierabend-rechner-app-joa1y4`.
2. Vor Code: passenden Punkt in `TODO.md` checken, Phasen der Reihe nach abarbeiten.
3. **Domain-Logik zuerst + Tests**, dann UI.
4. Kleine, thematische Commits mit klarer Message (Deutsch oder Englisch, konsistent).
5. Nach sinnvollen Einheiten committen & pushen (`git push -u origin <branch>`).
6. Kein PR ohne ausdrückliche Aufforderung.
7. Nach jedem größeren Schritt: `TODO.md` abhaken, `CLAUDE.md` bei Architektur-Änderungen aktualisieren.
8. `flutter analyze` + `flutter test` müssen grün sein, bevor etwas als „fertig" gilt.

---

## 9. Aktueller Stand

**Release-Kandidat 1.0.0 (Android)** — Paket `com.thinkube.feierabendrechner`, Entwickler „Thinkube".

- **Fertig:** Phasen 0–6 + Store-Vorbereitung (Phase 8). Kern-Logik (`lib/domain/`), Home mit
  Countdown-Ring, Startzeit-Pfeile, Schnellwahl „6 Std ohne Pause", Profile, Überstunden-Konto
  („Heute buchen", Soll pro Tag), Sprüche nach Berufsgruppe (DE+EN, keine Direktwiederholung),
  Einstellungen (Theme, Soll, Pro, Rechtliches), Persistenz (`SettingsRepository`).
- **Monetarisierung:** `lib/config/monetization_config.dart` (IDs), `lib/services/purchase_backend.dart`
  + `ads_backend.dart` (abstrahiert, in Tests/Screenshots per Override ersetzt),
  `lib/features/pro/` (ProController, Paywall, Banner). AdMob-Anzeigenblöcke per
  `--dart-define=ADMOB_BANNER_ANDROID/ADMOB_REWARDED_ANDROID`, App-ID per Env `ADMOB_APP_ID`
  (Default im Code: Google-Test-IDs; CI-Release-Builds setzen die echten IDs aus `android-bundle.yml` → `RELEASE_ADMOB_*`).
- **Erinnerungen:** `lib/domain/reminder_planner.dart` (`ReminderOptions` + Planer, rein, getestet) →
  `lib/features/reminders/` (Optionen persistiert, `reminderScheduleProvider` nur mit Pro,
  `buildReminderNotifications` formuliert Texte + Spruch) → Sync in `app.dart` via `NotificationBackend`
  (`flutter_local_notifications`, `inexactAllowWhileIdle`, UTC; IDs: Ende 1002, Halbzeit 1003, Vorwarnung 1100+Min).
  Android: Desugaring + Boot-Receiver im Manifest.
- **Home-Widget (Android):** `lib/features/widget/` + `lib/services/widget_backend.dart` schicken einen
  `WidgetSnapshot` (Start/Ende/Label/Pro-Ablauf) über den Channel `com.thinkube.feierabendrechner/widget`
  an `android/.../FeierabendWidget.kt` (Provider + `setWindow`-Alarm zum Umschalten auf „erreicht").
  Texte in `res/values(-de)/strings.xml`. Kotlin lässt sich nur in CI bauen.
- **Onboarding:** `lib/features/onboarding/onboarding_screen.dart` (`onboardingDoneProvider`, Key
  `onboarding_done`; Bestandsnutzer mit gespeicherten Eingaben überspringen es). `_Root` in `app.dart`
  blendet zum Home über; Werbe-Einwilligung/SDK startet erst danach. Tests: `buildApp(onboarding: true)`.
- **Übersetzung:** `lib/l10n/app_{de,en}.arb` → `flutter gen-l10n`; `context.l10n`, `context.units`.
- **Store-Assets:** `flutter test tool/store_assets_test.dart` rendert Icon-Quellen (`assets/icon/`),
  Screenshots/Feature-Grafik (`store/graphics/`); danach `dart run flutter_launcher_icons`.
- **Android-Build:** `.github/workflows/android-bundle.yml` baut **unsigniert** (dl.google.com ist in der
  Claude-Sandbox gesperrt) und legt das AAB im Branch `aab-build` ab; Signatur lokal per `jarsigner`
  mit dem Upload-Schlüssel (**nie ins Repo**, siehe `store/SCHLUESSEL.md`). versionCode = run_number.
- **Web-Vorschau:** `deploy.yml` → `gh-pages` (Pages: „Deploy from a branch"); `web/privacy.html` ist
  die Datenschutz-URL.
- **Store-Doku für den Nutzer:** `store/ANLEITUNG.md` (Start hier), `STORE_EINTRAG.md`,
  `APP_INHALTE.md`, `IN_APP_KAUF_UND_WERBUNG.md`, `SCHLUESSEL.md`.
- **Name:** DE „Feierabend Rechner“ (Icon: „Feierabend“), EN „Clock-Out Calculator“ (Icon: „Clock-Out“, Pro: „Clock-Out Pro“);
  Android-Label über `res/values(-de)/strings.xml` `app_name`.
- **Kontakt:** thinkube@outlook.de (Datenschutzerklärung, Store-Eintrag, IARC).
- **Offen:**
  Zeitzonen-/DST-Behandlung, iOS-Widget.
