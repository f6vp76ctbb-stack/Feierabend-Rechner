# 🚀 Feierabend Rechner veröffentlichen – Schritt für Schritt

Alles ist vorbereitet. Du brauchst nur die Play Console (am besten am Computer oder Tablet).

## Das hast du bekommen

| Was | Wo |
|---|---|
| **Signiertes App-Bundle** | `feierabend-release-1.0.0-vc9.aab` (von mir geschickt, **echte Werbung**, mit Designs + einstellbaren Erinnerungen) |
| **Upload-Schlüssel + Passwort** | geschickt → sicher aufbewahren, siehe `SCHLUESSEL.md` |
| Store-Texte DE + EN | `STORE_EINTRAG.md` |
| Icon, Feature-Grafik, 8 Screenshots je Sprache | `graphics/` |
| Datenschutzerklärung (online) | https://f6vp76ctbb-stack.github.io/Feierabend-Rechner/privacy.html |
| Antworten für „App-Inhalte" & Datensicherheit | `APP_INHALTE.md` |
| In-App-Kauf & AdMob einrichten | `IN_APP_KAUF_UND_WERBUNG.md` |

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
2. **App-Bundle hochladen:** `feierabend-release-1.0.0-vc9.aab`
   – Warnung „keine Symbole zum Debuggen" ist harmlos (wegen der Dateigröße abgetrennt). Nachreichen: *Neueste Versionen und App-Bundles* → Version → *Details ansehen* → „Symbole zum Debuggen von nativem Code" → `native-debug-symbols-vc<N>.zip` (von mir geschickt, passt nur zum gleichen versionCode).
3. Release-Name: `1.0.0`
4. Versionshinweise DE + EN aus `STORE_EINTRAG.md`
5. **Weiter → Speichern → Release veröffentlichen**
6. Tab **Tester**: E-Mail-Liste anlegen (deine + Tester), speichern → **Link kopieren** → auf einem Android-Gerät öffnen und installieren.

> Interne Tests sind meist in Minuten verfügbar. Hier siehst du die Werbung als „Test Ad" – das ist so gewollt.

## Schritt 6 – In-App-Produkt „feierabend_pro" anlegen
Jetzt (nach dem Upload) geht es: siehe **`IN_APP_KAUF_UND_WERBUNG.md`, Teil A** – Produkt-ID exakt `feierabend_pro`, Preis 3,99 €, aktivieren. Deine Gmail unter **Lizenztests** eintragen → Kauf kostenlos testen.

## Schritt 7 – AdMob (echte Werbung)
Siehe **`IN_APP_KAUF_UND_WERBUNG.md`, Teil B** (~15 Minuten). Schick mir danach App-ID + 2 Anzeigenblock-IDs → ich baue dir **Version 1.0.0 (neuer versionCode) mit echten Anzeigen** und signiere sie.

## Schritt 8 – Produktion
- Zeigt das Dashboard „**Zugriff auf Produktion beantragen**" mit 12-Tester-Pflicht (neue private Konten): zuerst **Geschlossener Test** mit mind. 12 Testern über 14 Tage, dann beantragen.
- Sonst direkt: **Produktion → Neuen Release erstellen → „Aus Bibliothek hinzufügen"** (das AAB mit echten Anzeigen) → **Länder/Regionen** wählen (z. B. alle, mindestens DACH) → **Einführen**.
- Google-Prüfung: meist wenige Stunden bis ~3 Tage, bei neuen Apps manchmal bis 7 Tage.

---

## Checkliste vor dem Absenden
- [x] Kontakt-E-Mail in der Datenschutzerklärung eingetragen (thinkube@outlook.de)
- [ ] Datenschutz-URL öffnet sich im Browser
- [ ] App-Inhalte alle grün
- [ ] Store-Eintrag DE + EN inkl. Grafiken
- [ ] AAB im internen Test installiert & ausprobiert
- [ ] In-App-Produkt `feierabend_pro` aktiv, Testkauf klappt
- [ ] Für Produktion: AAB mit **echten** AdMob-IDs
- [ ] Upload-Schlüssel gesichert
