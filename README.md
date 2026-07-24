# Feierabend Rechner

Eine extrem einfache, schöne App, die berechnet, **wann Feierabend ist**.
Startzeit eingeben → App zeigt sofort die Feierabend-Uhrzeit und einen Live-Countdown.
Alles individuell einstellbar (Arbeitszeit, Pause, Profile). Offline-first, ohne Anmeldung.

Geplant für den **Google Play Store** (Freemium mit einmaligem Pro-Kauf).

## Dokumentation
- **[CLAUDE.md](CLAUDE.md)** — Kerninformationen, Tech-Stack, Architektur, Arbeitsweise
- **[MASTERPLAN.md](MASTERPLAN.md)** — Strategie & Phasen vom Repo bis zum Release
- **[TODO.md](TODO.md)** — Aufgabenplan für dich & Claude
- **[MARKETING.md](MARKETING.md)** — Vermarktung, ASO & Kauf-Anreize

## Status
Phasen 0–3 stehen: Flutter-Projekt, getestete Kern-Logik und ein funktionierender,
schöner Hauptbildschirm (Countdown, Dark Mode, Overlays). `flutter analyze` + `flutter test`
sind grün (25 Tests).

## Testen auf dem iPhone (GitHub Pages)
Jeder Push baut die App und veröffentlicht sie automatisch als Web-App.
**Einmalig aktivieren:** Repo → *Settings* → *Pages* → *Source* = **GitHub Actions**.
Danach erreichbar unter:

    https://f6vp76ctbb-stack.github.io/Feierabend-Rechner/

Auf dem iPhone in Safari öffnen → Teilen → **Zum Home-Bildschirm** → startet wie eine echte App.

## Lokal entwickeln
```bash
flutter pub get
flutter test        # Tests
flutter run -d chrome   # oder ein Gerät/Emulator
```
