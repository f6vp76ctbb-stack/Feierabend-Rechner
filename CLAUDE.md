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
| Lokale Daten       | **Hive** (+ shared_preferences für Settings) | Schnell, offline, kein SQL nötig |
| Monetarisierung    | **RevenueCat** (über in_app_purchase) | Vereinfacht IAP/Abos, Analytics, A/B-Paywall |
| Benachrichtigungen | **flutter_local_notifications** | Countdown/„Feierabend erreicht" ohne Server |
| Home-Widget        | **home_widget**               | Android-Widget mit Countdown (starker Marketing-Hebel) |
| Design-System      | **Material 3** + eigenes Theme | Modern, anpassbar |
| Analytics          | Firebase Analytics (anonym) + RevenueCat | Conversion messen |
| Crash-Reporting    | Firebase Crashlytics          | Stabilität vor Release |

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
- Feierabend-Berechnung mit Startzeit, Arbeitszeit, Pause
- Live-Countdown
- Dark Mode
- 1 Profil

**Pro (einmaliger Kauf, ~3,99 €):**
- Mehrere Profile (z. B. Mo–Do / Fr, Schichten)
- Überstunden-Konto / Wochenübersicht
- Home-Screen-Widget
- Benachrichtigungen („Noch 30 Min", „Feierabend!")
- ArbZG-Auto-Pausenmodus
- Premium-Themes / Farbwelten
- Keine (sehr dezenten) Hinweise

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

- Phase 0 (Planung): Dokumente angelegt. Flutter-Projekt noch **nicht** initialisiert.
- Nächster Schritt: siehe `TODO.md` → Phase 1.
