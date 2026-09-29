# In-App-Kauf & Werbung – Schritt für Schritt

Das Geschäftsmodell der App:

| | Free | Pro (einmalig) |
|---|---|---|
| Feierabend-Rechner, Countdown, Schnellwahl, Sprüche, Dark Mode | ✅ | ✅ |
| Werbung | kleines Banner unten | **keine** |
| Mehrere Profile | nur 1 | unbegrenzt |
| Überstunden-Konto + „Heute buchen" | – | ✅ |
| Pause nach Arbeitszeitgesetz (Automatik) | – | ✅ |
| Erinnerungen („Gleich Feierabend", „Feierabend!") | – | ✅ |
| 24 Std. Pro gratis per Belohnungsvideo | ✅ | – |

---

## Teil A – In-App-Kauf „Feierabend Pro"

### A1. Voraussetzung: Zahlungsprofil
Play Console → **Einstellungen → Zahlungsprofil**: Händlerkonto einrichten (Name, Adresse, Bankkonto, Steuerangaben).
Ohne Zahlungsprofil kannst du keine kostenpflichtigen Produkte anlegen.

### A2. Wichtig: Reihenfolge
Google lässt In-App-Produkte **erst anlegen, nachdem ein AAB mit Abrechnungs-Berechtigung hochgeladen wurde**.
Das mitgelieferte AAB enthält sie bereits → **zuerst AAB in „Interner Test" hochladen** (siehe `ANLEITUNG.md`, Schritt 5), dann weiter hier.

### A3. Produkt anlegen
Play Console → deine App → **Monetarisieren → Produkte → In-App-Produkte → Produkt erstellen**

| Feld | Eintrag |
|---|---|
| **Produkt-ID** | `feierabend_pro` ← **exakt so**, sonst findet die App das Produkt nicht (nicht mehr änderbar!) |
| Name | Feierabend Pro |
| Beschreibung | Einmal zahlen, für immer frei: keine Werbung, unbegrenzt Profile, Überstunden-Konto und Pause nach Arbeitszeitgesetz. |
| Preis | **3,99 €** → „Preis festlegen" → Google rechnet andere Länder automatisch um |

→ **Speichern** → **Aktivieren**.

Englische Übersetzung des Produkts (optional, empfohlen):
- Name: `Feierabend Pro`
- Beschreibung: `Pay once, free forever: no ads, unlimited profiles, overtime account and automatic legal breaks.`

> Typ: Das ist ein **einmaliges, nicht verbrauchbares** Produkt (kein Abo). Die App bestätigt den Kauf automatisch (sonst würde Google ihn nach 3 Tagen erstatten).

### A4. Kostenlos testen (Lizenztester)
Play Console → **Einstellungen (links unten, Konto-Ebene) → Lizenztests** → deine Gmail-Adresse (und die deiner Tester) eintragen → Speichern.
Diese Konten sehen beim Kauf „Testbestellung – es wird nichts berechnet".

### A5. Was die App automatisch macht
- zeigt den **echten Preis** aus dem Store an („Pro freischalten – 3,99 €")
- schaltet Pro nach dem Kauf sofort frei und merkt es sich (auch offline)
- prüft beim Start still, ob schon gekauft wurde (z. B. nach Neuinstallation)
- **„Käufe wiederherstellen"** in Einstellungen und im Kauf-Fenster

---

## Teil B – Werbung mit Google AdMob

Das mitgelieferte AAB nutzt **Googles offizielle Test-Anzeigen** („Test Ad"). Das ist für den internen Test genau richtig.
Für echtes Geld brauchst du eigene IDs – das dauert ca. 15 Minuten:

### B1. AdMob-Konto
<https://admob.google.com> → mit demselben Google-Konto anmelden → Land, Zeitzone, Zahlungswährung (EUR) wählen.

### B2. App hinzufügen
**Apps → App hinzufügen** → Plattform **Android** → „Ist die App in einem unterstützten App-Shop veröffentlicht?" → vorerst **Nein** → Name `Feierabend Rechner` → Nutzermesswerte an → **App hinzufügen**.
Später (wenn live) unter **App-Einstellungen → App-Shop-Details** mit Google Play verknüpfen.

→ Notiere die **App-ID**: `ca-app-pub-XXXXXXXXXXXXXXXX~YYYYYYYYYY` (mit **~**)

### B3. Anzeigenblöcke anlegen
In der App: **Anzeigenblöcke → Anzeigenblock hinzufügen**

1. **Banner** → Name `Home Banner` → Erstellen
   → ID notieren: `ca-app-pub-…/…` (mit **/**)
2. **Mit Prämie** (Rewarded) → Name `Pro 24h Test`
   - Prämienmenge: `1`, Prämienartikel: `Pro-Tag`
   - Server-Side-Verification: aus
   → ID notieren: `ca-app-pub-…/…`

### B4. Einwilligungs-Dialog (DSGVO) aktivieren – Pflicht für EU
**Datenschutz & Mitteilungen → Europäische Vorschriften (DSGVO) → Mitteilung erstellen**
- App auswählen: Feierabend Rechner
- Sprachen: Deutsch + Englisch
- Datenschutzerklärung-URL: `https://f6vp76ctbb-stack.github.io/Feierabend-Rechner/privacy.html`
- Optionen: „Einwilligung" + „Verwalten" (Standard) → **Veröffentlichen**

Die App zeigt diesen Dialog dann automatisch beim Start (nur in der EU/UK) und bietet in den Einstellungen „Datenschutz-Einstellungen (Werbung)" an – das verlangt Google.

### B5. IDs an mich geben → echtes AAB
Schick mir die **3 Werte** (App-ID, Banner-ID, Rewarded-ID) – ich baue dir das AAB damit neu und signiere es.
Alternativ selbst: GitHub → Actions → **„Android App Bundle (AAB)" → Run workflow** → IDs eintragen → danach muss das Ergebnis noch mit deinem Upload-Schlüssel signiert werden (siehe `SCHLUESSEL.md`).

### B6. Regeln, die du kennen musst
- **Nie auf eigene echte Anzeigen klicken** – AdMob sperrt sonst dein Konto. Für eigene Tests dein Gerät als Testgerät eintragen: **AdMob → Einstellungen → Testgeräte**.
- Neue Konten/Anzeigenblöcke brauchen oft einige Stunden bis Tage, bis echte Anzeigen ausgeliefert werden.
- Auszahlung ab 70 € Guthaben (AdMob-Standard) nach Steuer- und Zahlungsangaben.
- `app-ads.txt` ist optional und braucht eine eigene Website-Domain – kann später ergänzt werden.
