# Upload-Schlüssel – bitte sicher aufbewahren

Du hast von mir zwei **geheime** Dateien bekommen (sie liegen **nicht** im öffentlichen Repo):

| Datei | Inhalt |
|---|---|
| `upload-keystore.jks` | dein Upload-Schlüssel (Alias `upload`) |
| `SCHLUESSEL_PASSWORT.txt` | das Passwort dazu |

**Sofort erledigen:** beide Dateien in deinen Passwort-Manager / einen sicheren Cloud-Ordner legen und aus Downloads/Chats löschen.

## Wofür ist der Schlüssel?
Google Play nutzt **Play App-Signatur**: Google signiert die App für die Nutzer mit einem eigenen, sicher verwahrten Schlüssel. Du signierst nur deine **Uploads** mit diesem Upload-Schlüssel, damit Google weiß, dass sie von dir kommen.
Jedes künftige Update muss mit **demselben** Upload-Schlüssel signiert sein.

Fingerabdruck (SHA-256) deines Upload-Zertifikats – zum Abgleich in der Play Console unter *Test und Release → Einrichtung → App-Integrität*:
```
5B:96:4D:92:59:DA:79:97:BB:AF:A4:E2:B5:07:D2:15:75:72:44:0C:7B:D1:F7:14:2E:D2:5A:48:A1:67:73:B8
```
Gültig bis 14.02.2054.

## Schlüssel verloren?
Kein Weltuntergang dank Play App-Signatur: Play Console → *App-Integrität → Upload-Schlüssel zurücksetzen* beantragen. Das dauert aber einige Tage – also lieber gut sichern.

## Neue Version bauen (Updates)
Einfachster Weg: **sag mir Bescheid** – ich baue und signiere.

Selbst (braucht einen Computer mit Java):
1. GitHub → Actions → **„Android App Bundle (AAB)" → Run workflow** (optional AdMob-IDs eintragen).
   Die Versionsnummer (`versionCode`) zählt automatisch hoch.
2. Das unsignierte AAB liegt danach im Branch `aab-build` (`feierabend-unsigned.aab`).
3. Signieren:
   ```bash
   jarsigner -keystore upload-keystore.jks -sigalg SHA256withRSA -digestalg SHA-256 \
     feierabend-unsigned.aab upload
   mv feierabend-unsigned.aab feierabend-release.aab
   ```
4. `feierabend-release.aab` in der Play Console hochladen.

Die Versionsbezeichnung (`1.0.0`) stellst du in `pubspec.yaml` unter `version:` hoch (z. B. `1.0.1`).
