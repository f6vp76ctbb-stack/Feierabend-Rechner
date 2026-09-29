# App-Inhalte – alle Antworten für die Play Console

Play Console → deine App → **Richtlinien → App-Inhalte** (oder Dashboard → „App einrichten").
Die Antworten passen genau zu dem, was die App tut (lokale Speicherung, AdMob, Google Play Billing).

---

## Datenschutzerklärung
```
https://f6vp76ctbb-stack.github.io/Feierabend-Rechner/privacy.html
```
> Vorher die Kontakt-E-Mail in der Erklärung eintragen lassen (Platzhalter ist gelb markiert).

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

### Datentypen (jeweils **erfasst ✔** und **geteilt ✔**, **nicht** vorübergehend, **erforderlich**)

| Kategorie → Datentyp | Zwecke |
|---|---|
| **Standort → Ungefährer Standort** | Werbung oder Marketing · Analysen · Betrugsprävention, Sicherheit und Compliance |
| **App-Aktivitäten → App-Interaktionen** | Werbung oder Marketing · Analysen |
| **App-Informationen und -Leistung → Absturzprotokolle** | Analysen · Betrugsprävention, Sicherheit und Compliance |
| **App-Informationen und -Leistung → Diagnosedaten** | Analysen · Betrugsprävention, Sicherheit und Compliance |
| **App-Informationen und -Leistung → Andere Leistungsdaten** | Analysen |
| **Geräte- oder andere IDs → Geräte- oder andere IDs** | Werbung oder Marketing · Analysen · Betrugsprävention, Sicherheit und Compliance |

Nicht ankreuzen: Persönliche Infos, Finanzinfos (Käufe laufen über Google Play, die App erfasst keine Zahlungsdaten), Gesundheit, Nachrichten, Fotos, Audio, Dateien, Kalender, Kontakte, Web-Browsing.

---

## Berechtigungen im AAB (zur Info)
`INTERNET`, `ACCESS_NETWORK_STATE`, `com.google.android.gms.permission.AD_ID` (Werbung), `com.android.vending.BILLING` (Kauf),
`POST_NOTIFICATIONS` + `RECEIVE_BOOT_COMPLETED` (Feierabend-Erinnerungen, rein lokal – keine Datensicherheits-Angabe nötig).
Keine exakten Alarme (`SCHEDULE_EXACT_ALARM`/`USE_EXACT_ALARM`) → keine Sonder-Erklärung.
Keine Standort-, Kamera-, Kontakt- oder Speicher-Berechtigungen.
