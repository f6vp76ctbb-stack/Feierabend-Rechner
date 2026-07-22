# TODO — Feierabend Rechner

Gemeinsame Aufgabenliste für **dich (Mensch)** und **Claude (KI)**.
Legende: `[ ]` offen · `[x]` erledigt · 👤 = du · 🤖 = Claude · 🤝 = zusammen

> Reihenfolge einhalten. Erst wenn eine Phase „Definition of Done" (siehe MASTERPLAN.md)
> erfüllt ist, zur nächsten. Claude hakt ab und aktualisiert diese Datei.

---

## Phase 0 — Fundament ✅
- [x] 🤖 CLAUDE.md, MASTERPLAN.md, TODO.md, MARKETING.md anlegen
- [ ] 👤 App-Name & Verfügbarkeit prüfen (Play Store Suche + ggf. Markenrecherche DPMA)
- [ ] 👤 Google-Play-Entwicklerkonto anlegen (einmalig 25 $) — kann parallel laufen
- [ ] 👤 Entscheiden: finaler Preis-Startwert (Empfehlung: 3,99 € einmalig)

## Phase 1 — Gerüst 🤖
- [ ] 🤖 `flutter create` mit Package-ID (z. B. `de.deinname.feierabendrechner`)
- [ ] 🤖 Ordnerstruktur laut CLAUDE.md §6 anlegen
- [ ] 🤖 Riverpod einbinden, App-Skelett + Routing
- [ ] 🤖 Design-System: Theme (hell/dunkel), Farben, Typografie, Basis-Widgets
- [ ] 🤖 `.gitignore`, README-Update, GitHub-Actions-CI (`flutter analyze` + `flutter test`)
- [ ] 👤 Flutter lokal installieren (falls du selbst bauen/testen willst) — optional

## Phase 2 — Kern-Logik 🤖
- [ ] 🤖 Modelle: `Startzeit`, `Arbeitszeit`, `Pause`, `Feierabend-Ergebnis`
- [ ] 🤖 `FeierabendCalculator` implementieren (start + arbeit + pause)
- [ ] 🤖 ArbZG-Auto-Pausenlogik (>6 h→30, >9 h→45) als optionalen Modus
- [ ] 🤖 Edge Cases: Mitternachts-Überlauf, 0-Pause, Teilzeit, Rundung auf Minute
- [ ] 🤖 Unit-Tests für alle Fälle (Ziel: 100 % der Domain)

## Phase 3 — Hauptbildschirm (MVP-UI) 🤖
- [ ] 🤖 Startzeit-Picker (schön, groß, „jetzt" als Default)
- [ ] 🤖 Arbeitszeit- & Pausen-Eingabe (Stepper/Slider, Default 8 h / 45 min)
- [ ] 🤖 Großes Ergebnis: „Feierabend um **15:29**"
- [ ] 🤖 Live-Countdown („noch 6 Std 12 Min")
- [ ] 🤖 Dark Mode gleichwertig
- [ ] 🤖 Sanfte Overlays/Animationen + Haptik
- [ ] 👤 Erstes Feedback: Fühlt sich „ein-Blick-klar" an? Farben angenehm?

## Phase 4 — Persistenz & Settings 🤖
- [ ] 🤖 Hive einrichten, letzte Eingaben & Defaults speichern
- [ ] 🤖 Settings-Screen (Standard-Arbeitszeit/Pause, ArbZG-Toggle, Theme)
- [ ] 🤖 App merkt sich Zustand über Neustarts

## Phase 5 — Pro-Features 🤖
- [ ] 🤖 Mehrere Profile (Mo–Do/Fr, Schichten) + Umschalter
- [ ] 🤖 Überstunden-Konto + Wochenübersicht
- [ ] 🤖 Home-Screen-Widget (Countdown) via `home_widget`
- [ ] 🤖 Lokale Benachrichtigungen („noch 30 Min", „Feierabend!")
- [ ] 🤖 Premium-Themes / Farbwelten

## Phase 6 — Monetarisierung 🤝
- [ ] 👤 RevenueCat-Konto anlegen, Produkte in Play Console anlegen (Pro-Kauf)
- [ ] 👤 In-App-Produkt-ID(s) & Preise in Play Console eintragen
- [ ] 🤖 RevenueCat integrieren, Kaufstatus verwalten
- [ ] 🤖 Feature-Gating (Free/Pro) einbauen
- [ ] 🤖 Paywall-Overlay (kontextuell, elegant) + „Kauf wiederherstellen"
- [ ] 🤖 Optionaler 7-Tage-Trial

## Phase 7 — Politur & Store-Reife 🤝
- [ ] 🤖 Onboarding (2–3 Screens, überspringbar)
- [ ] 🤖 App-Icon & Splash (👤 liefert Idee/Freigabe)
- [ ] 🤖 Feinschliff Animationen, Leerzustände, Fehlerfälle
- [ ] 🤖 Barrierefreiheit (Kontraste, Screenreader-Labels, große Schrift)
- [ ] 🤖 Lokalisierung: Deutsch fertig, Englisch vorbereitet
- [ ] 👤 App auf eigenem Gerät testen, Bugs melden

## Phase 8 — Release-Vorbereitung 🤝
- [ ] 🤖 Datenschutzerklärung erstellen (offline-first, minimale Daten)
- [ ] 👤 Datenschutzerklärung hosten (z. B. GitHub Pages) + Link
- [ ] 👤 Play Console: „Data Safety"-Formular ausfüllen
- [ ] 🤖 Crashlytics + anonyme Analytics einbauen
- [ ] 🤖 Release-Signierung (Keystore) einrichten (👤 verwahrt Keystore sicher!)
- [ ] 🤝 Store-Listing: Titel, Kurz-/Langbeschreibung (ASO-optimiert, siehe MARKETING.md)
- [ ] 🤝 Screenshots + Feature-Grafik erstellen
- [ ] 👤 App-Bundle (`.aab`) bauen & in internes Testing hochladen
- [ ] 👤 Geschlossenes Testing mit 5–20 Testern (Play verlangt das oft vor Produktion)

## Phase 9 — Launch & Wachstum 🤝
- [ ] 👤 Produktions-Release beantragen
- [ ] 🤝 ASO: Keywords & Listing nach Daten optimieren
- [ ] 👤 Marketing-Aktionen starten (siehe MARKETING.md)
- [ ] 🤝 Bewertungen einsammeln (In-App-Review-Prompt zur richtigen Zeit)
- [ ] 🤝 Conversion/Retention auswerten, Preis-A/B-Test

## Phase 10 — Danach 🤝
- [ ] iOS-Port (App Store)
- [ ] Cloud-Sync / Teams (optionales Abo)
- [ ] Kalender-Integration, weitere Sprachen/Länder

---

## Was NUR du (👤) tun kannst — Sammelübersicht
1. Play-Entwicklerkonto (25 $) anlegen
2. RevenueCat-Konto + In-App-Produkte in Play Console anlegen
3. Keystore sicher verwahren
4. Datenschutzerklärung hosten
5. Data-Safety-Formular ausfüllen
6. App auf echtem Gerät testen & Feedback geben
7. Tester für geschlossenes Testing organisieren
8. Marketing-Kanäle bespielen (oder Claude Texte/Ideen liefern lassen)

## Was Claude (🤖) übernimmt
Der komplette Code, Tests, Architektur, Store-Texte, Datenschutz-Entwurf, Icon-Konzept,
Marketing-Content-Vorlagen — alles Digitale bis zur Abgabe an dich.
