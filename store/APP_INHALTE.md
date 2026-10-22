# App-Inhalte – alle Antworten für die Play Console

Play Console → deine App → **Richtlinien → App-Inhalte** (oder Dashboard → „App einrichten").
Die Antworten passen genau zu dem, was die App tut (lokale Speicherung, AdMob, Google Play Billing).

---

## Datenschutzerklärung
```
https://f6vp76ctbb-stack.github.io/Feierabend-Rechner/privacy.html
```
> Verantwortlicher in der Erklärung: Thinkube, Mähderweg 5, 88451 Dettingen · thinkube@outlook.de
> Impressum: `https://f6vp76ctbb-stack.github.io/Feierabend-Rechner/impressum.html` (zusätzlich in der App: Einstellungen → Impressum)

## App-Zugriff
**„Alle Funktionen sind ohne besondere Zugriffsrechte verfügbar."**
(Kein Login. Pro-Funktionen sind per Kauf erhältlich – dafür braucht Google keine Zugangsdaten.)

## Anzeigen
**„Ja, meine App enthält Anzeigen."**

## Einstufung des Inhalts (IARC-Fragebogen)
- E-Mail angeben, Kategorie: **„Alle anderen App-Typen"** (nicht Spiel, nicht Social)
- Gewalt, Angst, Sexualität, Glücksspiel, grobe Sprache, Drogen/Alkohol/Tabak: **Nein**
- Nutzerinteraktion / Inhalte teilen / Standort teilen: **Nein**
- Digitale Käufe: **Ja** (In-App-Käufe)
- Erwartetes Ergebnis: USK 0 / PEGI 3 / „Alle"

## Zielgruppe und Inhalte
- Altersgruppen: **16–17** und **18 und älter**
- „Könnte die App ungewollt Kinder ansprechen?" → **Nein**
- Store-Präsenz spricht keine Kinder an → bestätigen

## Nachrichten-App
**Nein**

## Werbe-ID (Advertising ID)
- „Verwendet deine App eine Werbe-ID?" → **Ja**
- Zwecke: **Werbung oder Marketing**, **Analysen**, **Betrugsprävention, Sicherheit und Compliance**

## Behörden-App / Finanzfunktionen / Gesundheit
- Behörden-App: **Nein**
- Finanzfunktionen: **„Meine App bietet keine der aufgeführten Finanzfunktionen"**
- Gesundheits-App: **Nein** (keine Gesundheitsfunktionen)

---

## Datensicherheit (Data safety)

### Übersicht
| Frage | Antwort |
|---|---|
| Erfasst oder teilt deine App erforderliche Nutzerdatentypen? | **Ja** |
| Werden alle Daten bei der Übertragung verschlüsselt? | **Ja** |
| Können Nutzer das Löschen ihrer Daten beantragen? | **Nein** (kein Konto; lokale Daten werden mit der App gelöscht) |

> Die Arbeitszeiten, Profile und Überstunden verlassen das Gerät **nie** – sie gelten laut Google **nicht** als „erfasst".
> Anzugeben ist nur, was das **Google Mobile Ads SDK (AdMob)** überträgt. Quelle: Googles offizielle Anleitung „Google Mobile Ads SDK – Play Data Disclosure".
> **Google Analytics for Firebase** (nur nach Einwilligung, ohne Werbe-ID) überträgt dieselben Datentypen wie unten (App-Interaktionen, Diagnosedaten, Geräte-IDs, ungefährer Standort) zum Zweck **Analysen** – plus **Kaufverlauf** (Firebase protokolliert In-App-Käufe automatisch). Dafür gibt es die zweite Tabelle unten.

### Datentypen (jeweils **erfasst ✔** und **geteilt ✔**, **nicht** vorübergehend, **erforderlich**)

| Kategorie → Datentyp | Zwecke |
|---|---|
| **Standort → Ungefährer Standort** | Werbung oder Marketing · Analysen · Betrugsprävention, Sicherheit und Compliance |
| **App-Aktivitäten → App-Interaktionen** | Werbung oder Marketing · Analysen |
| **App-Informationen und -Leistung → Absturzprotokolle** | Analysen · Betrugsprävention, Sicherheit und Compliance |
| **App-Informationen und -Leistung → Diagnosedaten** | Analysen · Betrugsprävention, Sicherheit und Compliance |
| **App-Informationen und -Leistung → Andere Leistungsdaten** | Analysen |
| **Geräte- oder andere IDs → Geräte- oder andere IDs** | Werbung oder Marketing · Analysen · Betrugsprävention, Sicherheit und Compliance |

### Zusätzlich (nur Nutzungsstatistik): **erfasst ✔**, **nicht geteilt** (Google ist Auftragsverarbeiter), **optional**

| Kategorie → Datentyp | Zwecke |
|---|---|
| **Finanzinfos → Kaufverlauf** | Analysen |

Nicht ankreuzen: Persönliche Infos, übrige Finanzinfos (Zahlungsdaten laufen nur über Google Play), Gesundheit, Nachrichten, Fotos, Audio, Dateien, Kalender, Kontakte, Web-Browsing.

---

## Berechtigungen im AAB (zur Info, geprüft am fertigen Bundle)
`INTERNET`, `ACCESS_NETWORK_STATE`, `com.google.android.gms.permission.AD_ID` + `ACCESS_ADSERVICES_AD_ID/ATTRIBUTION/TOPICS`
(Werbung, aus dem AdMob-SDK), `com.android.vending.BILLING` (Kauf), `BIND_GET_INSTALL_REFERRER_SERVICE` (Installationsquelle, Firebase),
`POST_NOTIFICATIONS` + `RECEIVE_BOOT_COMPLETED` + `VIBRATE` + `WAKE_LOCK` (Feierabend-Erinnerungen, rein lokal – keine Datensicherheits-Angabe nötig),
`FOREGROUND_SERVICE` (aus WorkManager, **ohne** Dienst-Typ → keine Erklärung „Dienste im Vordergrund“ nötig).
Das Home-Screen-Widget braucht keine Berechtigung (Aktualisierung per nicht-exaktem `setWindow`-Alarm).
Keine exakten Alarme (`SCHEDULE_EXACT_ALARM`/`USE_EXACT_ALARM`) → keine Sonder-Erklärung.
Keine Standort-, Kamera-, Kontakt- oder Speicher-Berechtigungen.
