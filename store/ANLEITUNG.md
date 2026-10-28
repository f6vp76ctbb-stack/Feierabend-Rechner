# 🚀 Feierabend Rechner – Produktions-Release 1.0.0

Stand 26.10.2026: geschlossener Test bestanden, **Produktionszugang freigegeben**, Store-Bundle **vc50**.
App anlegen, App-Inhalte, Store-Eintrag, Händlerstatus, interner und geschlossener Test sind erledigt
(Details zu den einzelnen Formularen: `APP_INHALTE.md`, `STORE_EINTRAG.md`, `IN_APP_KAUF_UND_WERBUNG.md`).

## Das brauchst du

| Was | Wo |
|---|---|
| **Store-App-Bundle** (Produktion) | `feierabend-release-1.0.0-vc50.aab` – [Download](https://github.com/f6vp76ctbb-stack/Feierabend-Rechner/raw/signed-aab/feierabend-release-1.0.0-vc50.aab) (~62 MB). Werbung (AdMob), Pro + 5 Designs kaufbar, Nutzungsstatistik nur nach Einwilligung, Impressum mit vollem Namen, inkl. Debug-Symbolen + Offenlegungsdatei. **Ersetzt vc48** |
| Tester-App-Bundle | nur für den geschlossenen Test (ungerade versionCode) – **nie in Produktion** |
| Upload-Schlüssel + Passwort | bei dir gesichert (`SCHLUESSEL.md`) – für **jedes** Update nötig |
| Datenschutzerklärung | https://f6vp76ctbb-stack.github.io/Feierabend-Rechner/privacy.html |
| Impressum | https://f6vp76ctbb-stack.github.io/Feierabend-Rechner/impressum.html (auch in der App: Einstellungen → Impressum) |

> **vc48 schon hochgeladen?** Kein Problem: vc50 einfach als neuen Release hinterher (im internen Test bzw. in der
> Produktion) – er ersetzt vc48. In vc48 fehlte im Impressum der App noch der volle Name.

**Eckdaten:** Paketname `com.thinkube.feierabendrechner` · Version 1.0.0 · Android 7.0+ · Ziel-API 36 · Deutsch + Englisch.

---

## A. Einmal prüfen, bevor du veröffentlichst (~15 Minuten)

1. **In-App-Produkte aktiv** – Play Console → *Monetarisieren → Produkte → In-App-Produkte*:
   `feierabend_pro` (3,99 €), `design_supporter`, `design_midnight`, `design_sunset`, `design_ocean`, `design_forest`
   → alle Status **„Aktiv“**. Fehlt eines, zeigt die App beim Kaufen „Store nicht erreichbar“.
   Am schnellsten mit der KI der Play Console: fertiger Prompt in `IN_APP_KAUF_UND_WERBUNG.md`, Teil A3.
2. **AdMob-Einwilligungsdialog veröffentlicht** – AdMob → *Datenschutz & Mitteilungen → Europäische Vorschriften*:
   Die Mitteilung für „Feierabend Rechner“ muss **„Veröffentlicht“** sein (siehe `IN_APP_KAUF_UND_WERBUNG.md`, Teil B).
   Ohne sie werden Nutzer im EWR nicht gefragt – das verstößt gegen Googles Einwilligungsrichtlinie, und es gibt kaum Werbung.
3. **AdMob-Anzeigeninhalte** – AdMob → *Apps → Feierabend Rechner → App-Einstellungen*: maximale Anzeigeninhalts-Einstufung
   **„T“ (Jugendliche)** – passt zur Zielgruppe ab 16.
4. **Google Analytics / Firebase** (für die Nutzungsstatistik):
   - Datenverarbeitungsbedingungen annehmen: Firebase-Konsole → *Projekteinstellungen* → Datenschutz-Bereich, und
     Google Analytics → *Verwaltung → Kontoeinstellungen* → „Änderung zur Datenverarbeitung“ / „Datenverarbeitungsbedingungen“.
     (Die Datenschutzerklärung nennt Google als Auftragsverarbeiter – das stimmt erst damit.)
   - *Datenerfassung und -änderung → Datenaufbewahrung* → **14 Monate**; **Google Signale aus** lassen.
5. **Datensicherheit ergänzen** – Play Console → *Richtlinien → App-Inhalte → Datensicherheit* → zusätzlich
   **Finanzinfos → Kaufverlauf**: erfasst, **nicht** geteilt, **optional**, Zweck **Analysen** (siehe `APP_INHALTE.md`).
6. **Store-Eintrag** aktuell? Texte aus `STORE_EINTRAG.md` (DE + EN) und Screenshots aus `graphics/` (01 → 08).
   Unter *Store-Präsenz → Store-Einstellungen* bei **Website** das Impressum eintragen
   (`https://f6vp76ctbb-stack.github.io/Feierabend-Rechner/impressum.html`) – so ist es auch im Store verlinkt.

## B. Kauf selbst ausprobieren (empfohlen, ~20 Minuten)

1. *Einstellungen (Konto-Ebene) → Lizenztests*: deine Gmail eintragen → Käufe kosten dich nichts (Testkarte).
2. *Test und Release → Testen → **Interner Test** → Neuen Release erstellen* → **Store-App-Bundle vc50** hochladen
   → Release-Name `1.0.0` → Versionshinweise (unten) → **Veröffentlichen**.
3. Über den Link des internen Tests installieren (die Tester-Version wird dabei ersetzt) und prüfen:
   - Einführung → Tipps → Werbung erscheint unten (**nie auf eigene Anzeigen tippen!**)
   - *Pro freischalten* → Testkarte „Immer genehmigen“ → Pro aktiv, Werbung weg
   - *Designs ansehen* → ein Design kaufen → es ist sofort aktiv
   - *Käufe wiederherstellen* → Pro bleibt aktiv
4. Passt alles: beim Release im internen Test **„Release übernehmen“ → Produktion** – das ist dasselbe Store-Bundle,
   kein neuer Upload nötig. (Den Release aus dem **geschlossenen** Test nie übernehmen: das ist die Tester-Version.)

## C. Produktion veröffentlichen

*Test und Release → **Produktion** → Neuen Release erstellen* (bzw. den übernommenen Release öffnen)
1. App-Bundle: **vc50** (Store-Bundle; aus der Bibliothek oder per Download-Link hochladen)
2. Release-Name: `1.0.0`
3. Versionshinweise:
   ```
   <de-DE>
   Wann ist Feierabend? Startzeit tippen – fertig. Mit Live-Countdown, Schnellwahl, Pause automatisch, Überstunden-Konto, Profilen, Erinnerungen, Home-Screen-Widget, lustigen Sprüchen und 5 Designs.
   </de-DE>
   <en-US>
   When can you clock out? Tap your start time – done. With live countdown, quick picks, automatic break, overtime account, profiles, reminders, home screen widget, fun quotes and 5 designs.
   </en-US>
   ```
4. **Länder/Regionen:** alle (mindestens Deutschland, Österreich, Schweiz).
5. **Einführung:** 100 % (es gibt noch keine Bestandsnutzer – ein gestaffelter Rollout bringt nichts).
6. **Zur Überprüfung senden.** Google prüft meist in Stunden bis wenigen Tagen.

> Warnungen beim Hochladen: Zu Debug-Symbolen/Offenlegungsdatei kommen keine mehr. Erscheint eine andere
> (z. B. „Geräte werden nicht mehr unterstützt“) → nicht veröffentlichen, mir Bescheid geben.

## D. Nach dem Start

1. **AdMob mit dem Store verknüpfen:** AdMob → *Apps → Feierabend Rechner → App-Einstellungen → App-Store-Details
   hinzufügen* → Google Play → App auswählen. Danach prüft AdMob die App („App-Bereitschaft“); bis dahin kann es
   weniger Werbung geben.
2. **Geschlossener Test** darf weiterlaufen: Tester bekommen automatisch die Produktionsversion (höhere Nummer) –
   Pro ist dann nicht mehr gratis. Wer mag, pausiert den Track.
3. **Firebase → Analytics → Echtzeit:** dort siehst du die ersten Nutzer, die der Statistik zugestimmt haben.
4. **Updates:** sag mir Bescheid – ich baue, teste im Emulator und schicke dir den Download-Link.

---

## Rechtliches – geprüft am 22.10.2026, Name ergänzt am 23.10.2026

Erledigt in App und Webseite:
- **Impressum** in der App (Einstellungen → Impressum, auch offline) und online – wie bei Qubble, mit vollem
  Namen (Sam Däubler, Geschäftsbezeichnung „Thinkube“)
- **Datenschutzerklärung** vollständig: Verantwortlicher mit Anschrift, alle Datenflüsse (AdMob, Google Play,
  Nutzungsstatistik, Feedback-E-Mail), Rechtsgrundlagen, Speicherdauer, USA-Übermittlung, Rechte, Aufsichtsbehörde
- **Einwilligungen:** Werbung über Googles zertifizierten Dialog (UMP/TCF), Statistik nur nach „Ja“ (gleichwertige
  Knöpfe, Anbieter + USA genannt, jederzeit abschaltbar); ohne Einwilligung wird nichts erfasst
- **Open-Source-Lizenzen** in der App (inkl. Schrift Inter, SIL OFL)
- **Kein** Link zur abgeschalteten EU-Streitschlichtungsplattform (wäre seit 20.07.2025 abmahnfähig); Hinweis zur
  Verbraucherschlichtung vorhanden
- Käufe laufen komplett über Google Play (Preise inkl. MwSt., Bezahlung, Erstattung, Widerruf) – keine eigenen AGB nötig
- Keine Haftungsausschluss-Klauseln, keine Markennamen, keine fremden Texte/Bilder; Zielgruppe ab 16

**Offen – nur du kannst das klären:**
1. **Steuern** (Gewerbe ist angemeldet ✓):
   - **Fragebogen zur steuerlichen Erfassung** über *Mein ELSTER* abschicken, falls noch nicht geschehen – innerhalb
     eines Monats nach Beginn, nicht auf Post vom Finanzamt warten. Danach kommt die **Steuernummer** per Brief.
   - Im Fragebogen entscheidest du über die **Kleinunternehmerregelung** – im Zweifel kurz Steuerberatung oder die
     kostenlose Gründungsberatung deiner IHK fragen. Die Umsatzsteuer für Play-Käufe in der EU führt Google ab.
   - **Ins Impressum gehört keine Steuernummer** (und auch nicht deine persönliche Steuer-ID). Pflicht wird erst
     eine **USt-IdNr.** oder die **Wirtschafts-IdNr.** (kommt automatisch vom Bundeszentralamt für Steuern über
     ELSTER) – sobald du eine davon hast, schick sie mir, dann kommt sie ins Impressum.
2. **Letzte Sicherheit:** Ich habe sorgfältig geprüft, bin aber kein Anwalt. Wer ganz sicher gehen will, lässt
   Impressum und Datenschutzerklärung von einem Rechtstexte-Dienst oder einer IT-Kanzlei gegenlesen.

## Checkliste vor dem Absenden
- [ ] In-App-Produkte (6) aktiv
- [ ] AdMob-Einwilligungsdialog veröffentlicht, Anzeigeninhalte „T“
- [ ] Firebase/GA: Datenverarbeitungsbedingungen angenommen, Aufbewahrung 14 Monate
- [ ] Datensicherheit um „Kaufverlauf“ ergänzt
- [ ] Kauf im internen Test ausprobiert (Pro + ein Design + Wiederherstellen)
- [ ] Produktion: **Store**-Bundle vc50 (nie das Tester-Bundle), Länder gewählt, 100 %
- [ ] Upload-Schlüssel gesichert
