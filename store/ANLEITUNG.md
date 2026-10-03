# 🚀 Feierabend Rechner veröffentlichen – Schritt für Schritt

Alles ist vorbereitet. Du brauchst nur die Play Console (am besten am Computer oder Tablet).

## Das hast du bekommen

| Was | Wo |
|---|---|
| **Tester-App-Bundle** (geschlossener Test) | `feierabend-TESTER-1.0.0-vc27.aab` – Pro + alle Designs frei, **keine Werbung**. Nur für den Test-Track, **nie in Produktion!** |
| **Store-App-Bundle** (Produktion, später) | `feierabend-release-1.0.0-vc<N>.aab` (gerade Nummer) – so wie Kunden die App bekommen: Werbung, Pro/Designs kaufbar. Schicke ich dir, sobald der Produktionszugang da ist. |
| **Upload-Schlüssel + Passwort** | geschickt → sicher aufbewahren, siehe `SCHLUESSEL.md` |
| Store-Texte DE + EN | `STORE_EINTRAG.md` |
| Icon, Feature-Grafik, 8 Screenshots je Sprache | `graphics/` |
| Datenschutzerklärung (online) | https://f6vp76ctbb-stack.github.io/Feierabend-Rechner/privacy.html |
| Antworten für „App-Inhalte" & Datensicherheit | `APP_INHALTE.md` |
| In-App-Kauf & AdMob einrichten | `IN_APP_KAUF_UND_WERBUNG.md` |
| Google Analytics (Firebase) einrichten | `FIREBASE_ANALYTICS.md` |

**Eckdaten:** Paketname `com.thinkube.feierabendrechner` · Version 1.0.0 (versionCode siehe Dateiname/Nachricht) · Android 7.0+ · Ziel-API 36 · Deutsch + Englisch.

---

## Schritt 1 – App anlegen (falls noch nicht geschehen)
Play Console → **Alle Apps → App erstellen**
- App-Name: `Feierabend Rechner`
- Standardsprache: **Deutsch – de-DE**
- App oder Spiel: **App**
- Kostenlos oder kostenpflichtig: **Kostenlos** (Geld kommt über In-App-Kauf + Werbung; „kostenlos" lässt sich später nicht mehr ändern – so ist es richtig)
- Erklärungen bestätigen → **App erstellen**

## Schritt 2 – Händlerstatus & Zahlungsprofil
- **Einstellungen → Zahlungsprofil**: Händlerkonto (für In-App-Käufe) einrichten, falls noch nicht vorhanden.
- Weil die App Geld verdient, fragt Google nach dem **Händlerstatus (EU Digital Services Act)** → „Händler" angeben. Deine Kontaktdaten werden dann im Store angezeigt.

## Schritt 3 – App-Inhalte ausfüllen
Dashboard → **„App einrichten"** → jede Aufgabe mit den Antworten aus **`APP_INHALTE.md`** ausfüllen:
Datenschutzerklärung · App-Zugriff · Anzeigen · Einstufung · Zielgruppe · Nachrichten-App · Werbe-ID · Behörden/Finanzen/Gesundheit · **Datensicherheit**.

## Schritt 4 – Store-Eintrag
**Store-Präsenz → Haupteintrag im Store** → Texte aus **`STORE_EINTRAG.md`** (Deutsch) einfügen, Grafiken hochladen:
- App-Symbol: `graphics/icon-512.png`
- Vorstellungsgrafik: `graphics/de/feature-graphic.png`
- Smartphone-Screenshots: alle 8 aus `graphics/de/screenshots/` (in Reihenfolge 01 → 08)

Dann **Übersetzungen verwalten → Eigene Übersetzung hinzufügen → Englisch (Vereinigte Staaten) – en-US** → englische Texte + `graphics/en/…` hochladen.

**Store-Einstellungen:** Kategorie **Effizienz**, Tags Arbeit · Effizienz · Rechner · Uhr, Wecker & Timer · Humor, Kontakt-E-Mail `thinkube@outlook.de`.

## Schritt 5 – AAB hochladen (Interner Test)
**Test und Release → Testen → Interner Test → Neuen Release erstellen**
1. Play App-Signatur: **„Google Play generiert und verwaltet"** bestätigen (Standard)
2. **App-Bundle hochladen:** Store-App-Bundle (`feierabend-release-…`) – nur für dich zum Kauf-Test; die Tester bekommen das Tester-Bundle (Schritt 8)
   – Warnung „keine Symbole zum Debuggen" ist harmlos → einfach ignorieren.
3. Release-Name: `1.0.0`
4. Versionshinweise DE + EN aus `STORE_EINTRAG.md`
5. **Weiter → Speichern → Release veröffentlichen**
6. Tab **Tester**: E-Mail-Liste anlegen (deine + Tester), speichern → **Link kopieren** → auf einem Android-Gerät öffnen und installieren.

> Interne Tests sind meist in Minuten verfügbar. **Nie auf die eigenen (echten) Anzeigen tippen** – das verbietet AdMob.

## Schritt 6 – In-App-Produkt „feierabend_pro" anlegen
Jetzt (nach dem Upload) geht es: siehe **`IN_APP_KAUF_UND_WERBUNG.md`, Teil A** – Produkt-ID exakt `feierabend_pro`, Preis 3,99 €, aktivieren. Deine Gmail unter **Lizenztests** eintragen → Kauf kostenlos testen.

## Schritt 7 – AdMob (echte Werbung)
Siehe **`IN_APP_KAUF_UND_WERBUNG.md`, Teil B** (~15 Minuten). Schick mir danach App-ID + 2 Anzeigenblock-IDs → ich baue dir **Version 1.0.0 (neuer versionCode) mit echten Anzeigen** und signiere sie.

## Schritt 8 – Geschlossener Test (12 Tester, 14 Tage)
- **Test und Release → Testen → Geschlossener Test → Neuen Release erstellen** → **Tester-App-Bundle** hochladen (`feierabend-TESTER-…`, ungerade versionCode).
- Darin ist **alles freigeschaltet** (Pro, alle 5 Designs) und es gibt **keine Werbung**: Tester probieren jede Funktion aus, und niemand klickt im Test auf echte Anzeigen (schützt dein AdMob-Konto).
- In den Einstellungen steht „Testversion: Pro und alle Designs sind freigeschaltet“ – so wissen die Tester Bescheid.
- Kauf selbst testen: deine Gmail unter **Einstellungen → Lizenztests** eintragen und das **Store-App-Bundle** im **internen Test** installieren → Kauf läuft mit Testkarte, kostet nichts.

## Schritt 9 – Produktion
- Nach den 14 Tagen: Dashboard → „**Zugriff auf Produktion beantragen**".
- **Produktion → Neuen Release erstellen** → das **Store-App-Bundle** (`feierabend-release-…`, gerade versionCode) hochladen → **Länder/Regionen** wählen (z. B. alle, mindestens DACH) → **Einführen**.
- ⚠️ **Nicht** den Release aus dem geschlossenen Test in die Produktion übernehmen („Release übernehmen/hochstufen") – sonst bekäme jeder Pro gratis und es gäbe keine Werbung.
- Google-Prüfung: meist wenige Stunden bis ~3 Tage, bei neuen Apps manchmal bis 7 Tage.

---

## Checkliste vor dem Absenden
- [x] Kontakt-E-Mail in der Datenschutzerklärung eingetragen (thinkube@outlook.de)
- [ ] Datenschutz-URL öffnet sich im Browser
- [ ] App-Inhalte alle grün
- [ ] Store-Eintrag DE + EN inkl. Grafiken
- [ ] AAB im internen Test installiert & ausprobiert
- [ ] In-App-Produkt `feierabend_pro` aktiv, Testkauf klappt
- [ ] Geschlossener Test: **Tester**-AAB · Produktion: **Store**-AAB (nie vertauschen)
- [ ] Upload-Schlüssel gesichert
