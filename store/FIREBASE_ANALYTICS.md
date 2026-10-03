# Google Analytics (GA4 über Firebase) einrichten

**Eingerichtet** mit dem Firebase-Projekt `feierabendrechner` (Werte aus `google-services.json` stehen
als `FIREBASE_*` in `android-bundle.yml` und `launch-test.yml`). Fehlen sie, bleibt die Statistik komplett aus.

## Was die App macht
- Beim **zweiten Start** (nicht direkt nach der Einführung) fragt sie einmal: „Darf die App mitzählen?"
  → „Ja, gern" / „Nein danke". Ohne „Ja" bleibt die Erfassung aus – nichts wird erfasst oder gesendet (DSGVO/TDDDG: Einwilligung nötig).
- Jederzeit änderbar: **Einstellungen → Nutzungsstatistik teilen**.
- Keine Werbe-ID über Analytics, keine Personalisierungssignale, keine Arbeitszeiten/Profile.
- Automatisch erfasst Firebase u. a. `first_open`, `session_start`, `app_update`, `in_app_purchase`.
- Eigene Ereignisse:

| Ereignis | Wann | Parameter |
|---|---|---|
| `paywall_view` | Kaufseite für Pro geöffnet | – |
| `purchase_start` | Kauf angetippt | `item` = `pro` oder `design_<name>` |
| `trial_reward` | 24 Std. Pro per Video verdient | – |
| `design_shop_view` | Design-Shop geöffnet | – |
| `design_select` | gekauftes Design gewählt | `design` |
| `reminders_on` | Erinnerungen eingeschaltet | – |
| `widget_pin` | „Widget hinzufügen" | `ok` = 1/0 |
| `overtime_book` | „Heute buchen" | – |
| `profile_add` | Profil angelegt | – |
| `auto_break` | „Pause automatisch" umgeschaltet | `on` = 1/0 |

## Deine Schritte (~10 Minuten)

1. <https://console.firebase.google.com> → **Projekt hinzufügen** (oder dein vorhandenes Projekt öffnen,
   falls du für GA4 schon einen App-Datenstream hast – der hängt immer an einem Firebase-Projekt).
   - Name z. B. `Feierabend Rechner`, **Google Analytics aktivieren** → deine GA4-Property/Konto wählen.
2. Projektübersicht → **Android-Symbol** („App hinzufügen"):
   - Android-Paketname: **`com.thinkube.feierabendrechner`** (exakt so)
   - App-Alias: `Feierabend Rechner` · SHA-1: leer lassen
   - **App registrieren** → **`google-services.json` herunterladen**.
   - Die weiteren Schritte („Firebase SDK hinzufügen") **überspringen** – das ist erledigt.
3. **Schick mir die `google-services.json`** (Datei oder Inhalt). Die Werte darin sind nicht geheim,
   sie stehen in jeder App. Ich trage sie in die Builds ein und baue dir ein neues App-Bundle.
4. In Google Analytics (<https://analytics.google.com>) → **Verwaltung → Datenerfassung und -änderung →
   Datenaufbewahrung** → **14 Monate** → speichern. **Google Signale** ausgeschaltet lassen.

Danach siehst du die Daten in Firebase (**Analytics → Dashboard / Ereignisse**) und in GA4.
Neue Ereignisse brauchen bis zu 24 Std., bis sie in den Berichten auftauchen; live siehst du sie unter
**Echtzeit**.

## Play Console
- **Datensicherheit:** nichts Neues ankreuzen – die dort schon angegebenen Datentypen (App-Interaktionen,
  Diagnosedaten, Geräte-IDs, ungefährer Standort, Zweck „Analysen") decken Analytics ab (siehe `APP_INHALTE.md`).
- **Datenschutzerklärung:** ist schon aktualisiert (Abschnitt 7).
