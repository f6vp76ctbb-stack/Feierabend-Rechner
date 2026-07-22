# MASTERPLAN — Feierabend Rechner

Der strategische Fahrplan vom leeren Repo bis zum profitablen Play-Store-Release.
Für Details zur Umsetzung siehe `TODO.md`, für Technik `CLAUDE.md`, für Vermarktung `MARKETING.md`.

---

## Vision

Die **einfachste und schönste** App, um zu sehen, wann Feierabend ist. Ein deutsches
Kultwort („Feierabend") als Produkt: emotional, alltagsnah, teilbar. Kostenlos zum
Einstieg, mit einem eleganten Pro-Upgrade, das man gern kauft, weil die App den Tag
jeden Arbeitstag ein kleines bisschen besser macht.

**Nordstern-Metrik:** tägliche Öffnungen pro Nutzer (Habit) → treibt Retention → treibt Kauf.

---

## Positionierung

- **Für wen?** Angestellte mit gleitender/fester Arbeitszeit, Schichtarbeiter, Azubis,
  alle die „Wann kann ich gehen?" im Kopf ausrechnen.
- **Warum wir?** Andere Zeiterfassungs-Apps sind überladen (Firmen-Tools, Stundenzettel).
  Wir machen **eine** Sache perfekt und schön.
- **Ton:** freundlich, entspannt, leicht augenzwinkernd („Endlich frei.").

---

## Geschäftsmodell

**Freemium mit einmaligem Pro-Kauf** (kein nerviges Abo als Standard).

- Free ist echt nützlich → gute Bewertungen, organisches Wachstum.
- Pro (~**3,99 €** einmalig) schaltet Komfort- & Power-Features frei (siehe `CLAUDE.md` §5).
- **Kauf-Anreiz** ohne Nerven:
  - Kontextuelle Paywall (erscheint, wenn man ein Pro-Feature antippt — nicht beim Start).
  - Elegantes Paywall-Overlay mit klarem Nutzen + „Einmal zahlen, für immer nutzen".
  - Optional 7-Tage-Pro-Trial zum Ausprobieren.
  - Dezenter, hübscher „Pro"-Hinweis, nie aufdringliche Vollbild-Ads.
- Später testbar: Abo-Variante (Cloud-Sync/Teams) als zusätzliche Option, nicht als Zwang.

Preis-Feintuning per RevenueCat-A/B-Test nach Launch (2,99 / 3,99 / 4,99 €).

---

## Phasen-Übersicht

### Phase 0 — Fundament (Planung) ✅
Doku (CLAUDE.md, MASTERPLAN.md, TODO.md, MARKETING.md), Tech-Entscheidung, Namens-/Store-Check.

### Phase 1 — Gerüst
Flutter-Projekt, Ordnerstruktur, Theme/Design-System, Riverpod, CI (analyze + test).

### Phase 2 — Kern-Logik (MVP-Herz)
`FeierabendCalculator` + Modelle, **voll unit-getestet**, inkl. Edge Cases & ArbZG-Regeln.

### Phase 3 — Hauptbildschirm (MVP-UI)
Startzeit-Picker, Arbeitszeit/Pause, großes Ergebnis, Live-Countdown, Dark Mode.
→ **Ab hier ist die App für sich schon benutzbar.**

### Phase 4 — Persistenz & Settings
Hive-Speicherung, Einstellungen (Defaults), letzte Eingaben merken.

### Phase 5 — Pro-Features
Profile, Überstunden-Konto/Wochenübersicht, Widget, Notifications, Premium-Themes.

### Phase 6 — Monetarisierung
RevenueCat, Paywall-Overlay, Trial, Feature-Gating, Kauf-Wiederherstellung.

### Phase 7 — Politur & Store-Reife
Onboarding, Animationen/Haptik, Icon & Splash, Barrierefreiheit, Lokalisierung (DE zuerst, EN vorbereitet).

### Phase 8 — Release-Vorbereitung
Datenschutzerklärung, Play Data Safety, Signierung, Store-Listing (Text, Screenshots, Grafik),
Crashlytics, internes Testing → geschlossenes Testing → Produktion.

### Phase 9 — Launch & Wachstum
Soft-Launch, ASO, Content-/Social-Marketing (siehe `MARKETING.md`), Bewertungen einsammeln,
iterieren nach Nutzerfeedback & Conversion-Daten.

### Phase 10 — Danach
iOS-Port, Cloud-Sync/Teams (Abo-Option), Kalender-Integration, weitere Länder/Sprachen.

---

## Definition of Done je Phase

Eine Phase gilt als fertig, wenn:
- alle zugehörigen TODO-Punkte abgehakt sind,
- `flutter analyze` **und** `flutter test` grün sind,
- die App auf einem echten/emuliertem Gerät ohne Absturz läuft,
- `CLAUDE.md` / `TODO.md` den neuen Stand widerspiegeln.

---

## Risiken & Gegenmaßnahmen

| Risiko | Gegenmaßnahme |
|--------|---------------|
| „Zu simpel, keiner zahlt" | Free bleibt top; Pro löst echte Wiederhol-Schmerzen (Widget, Überstunden) |
| Store-Ablehnung (Data Safety) | Offline-first, minimale Daten, saubere Datenschutzerklärung von Anfang an |
| Zeitzonen/DST-Bugs | Zentrale, getestete Domain-Logik; keine UI-Rechnerei |
| Marketing verpufft | Widget + Teilbarkeit als organischer Motor, Nischen-Communities (r/de) |
| Namens-/Markenkonflikt | „Feierabend Rechner" vor Phase 1 im Store & Markenregister prüfen |

---

## Meilensteine (grob, anpassbar)

1. **M1 — Benutzbarer MVP** (Phasen 1–4): rechnet & sieht schön aus, lokal gespeichert.
2. **M2 — Verkaufsfertig** (Phasen 5–6): Pro-Features + Paywall funktionieren.
3. **M3 — Store-Ready** (Phasen 7–8): poliert, getestet, Listing steht.
4. **M4 — Live & wachsend** (Phasen 9–10): veröffentlicht, Marketing läuft, iteriert.
