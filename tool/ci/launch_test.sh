#!/usr/bin/env bash
# Emulator-Test des Release-Builds (R8, echte AdMob-IDs) – zwei Durchgänge:
#   free:   Store-Version: Einführung → Hauptbildschirm (Werbung/Einwilligung) → Kaufseite
#           → Belohnungsvideo → Design-Kauf
#   tester: Tester-Version (TESTER_BUILD, wie im geschlossenen Test): Überstunden → Erinnerungen
#           → Widget ablegen → Design wählen → Neustart
# Sammelt Logcat + Screenshots. Exit 1, sobald die App irgendwo abstürzt.
# Aufruf: bash tool/ci/launch_test.sh <api> <free.apk> <tester.apk>
set -u
API="$1"
FREE_APK="$2"
TESTER_APK="$3"
PKG=com.thinkube.feierabendrechner
OUT="launch-results/api$API"
mkdir -p "$OUT"
CRASHED=0
SHOT=0

# adb mit Zeitlimit: ein hängender Aufruf darf den Test nicht stundenlang blockieren.
adbt() { timeout "${ADB_TIMEOUT:-60}" adb "$@"; }

ADB_TIMEOUT=300 adbt wait-for-device
adbt shell getprop ro.build.version.release | tee "$OUT/android-version.txt"
read -r W H <<<"$(adbt shell wm size | grep -o '[0-9]*x[0-9]*' | tail -1 | tr 'x' ' ')"
echo "Bildschirm: ${W}x${H}" | tee -a "$OUT/status.txt"

log() { echo "$*" | tee -a "$OUT/status.txt"; }

shot() {
  SHOT=$((SHOT + 1))
  adbt exec-out screencap -p > "$OUT/$(printf '%02d' $SHOT)-$1.png"
}

dump_ui() {
  for _ in 1 2 3; do
    if adbt shell uiautomator dump /sdcard/ui.xml 2>&1 | grep -q "dumped"; then
      adbt shell cat /sdcard/ui.xml > "$OUT/ui.xml" 2>/dev/null
      return 0
    fi
    sleep 2
  done
  : > "$OUT/ui.xml"
  return 1
}

# Tippt das erste Element an, dessen Text/Beschreibung einem der Muster entspricht
# (Muster = Regex für den Attributwert, z. B. 'Notifications[^"]*').
# Scrollt bei Bedarf bis zu 3× nach unten. Nicht gefunden ist kein Fehler.
tap() {
  local tries
  for tries in 1 2 3 4; do
    dump_ui
    local bounds=""
    for t in "$@"; do
      bounds=$(grep -o "<node[^>]*\(text\|content-desc\)=\"$t\"[^>]*>" "$OUT/ui.xml" \
        | grep -o 'bounds="\[[0-9]*,[0-9]*\]\[[0-9]*,[0-9]*\]"' | head -1)
      [ -n "$bounds" ] && break
    done
    if [ -n "$bounds" ]; then
      read -r x1 y1 x2 y2 <<<"$(echo "$bounds" | grep -o '[0-9]*' | tr '\n' ' ')"
      adbt shell input tap $(((x1 + x2) / 2)) $(((y1 + y2) / 2))
      log "tap '$1' bei $bounds"
      sleep 3
      return 0
    fi
    [ "$tries" -lt 4 ] && adbt shell input swipe $((W / 2)) $((H * 3 / 4)) $((W / 2)) $((H / 3)) 300 && sleep 1
  done
  log "tap '$1': nicht gefunden"
  return 1
}

back() { adbt shell input keyevent KEYCODE_BACK; sleep 2; }

# Ganz nach oben scrollen (Kopfzeile mit dem Einstellungs-Symbol sichtbar).
scroll_top() {
  for _ in 1 2 3 4; do
    adbt shell input swipe $((W / 2)) $((H / 3)) $((W / 2)) $((H * 3 / 4)) 200
  done
  sleep 1
}

check() {
  local n="$1"
  adbt logcat -d -v threadtime > "$OUT/logcat-$n.txt"
  grep -E "AndroidRuntime|FATAL|F DEBUG|F libc|E flutter|I flutter|$PKG|Abort message|backtrace|#[0-9]{2} pc" \
    "$OUT/logcat-$n.txt" | tail -400 > "$OUT/relevant-$n.txt"
  echo "=================== API $API · $n · relevant logcat ==================="
  cat "$OUT/relevant-$n.txt"
  echo "=================== /API $API · $n ==================="
  if grep -A1 "FATAL EXCEPTION" "$OUT/logcat-$n.txt" | grep -q "Process: $PKG" ||
     grep -q ">>> $PKG <<<" "$OUT/logcat-$n.txt"; then
    log "!!! API $API · $n: App ist abgestürzt"
    CRASHED=1
  else
    log "OK API $API · $n: kein Absturz"
  fi
  adbt logcat -c
}

start_app() {
  adbt shell am start -W -n "$PKG/.MainActivity" >/dev/null 2>&1
  sleep "${1:-20}"
}

# ---------------------------------------------------------------- free
timeout 300 adb install -r "$FREE_APK" 2>&1 | tee "$OUT/install-free.txt"
adbt logcat -c
start_app 25
shot "free-einfuehrung"
tap "Skip" "Überspringen"
sleep 20
shot "free-home-werbung"
check "1-free-start"

tap "Settings" "Einstellungen"
tap 'Unlock Pro[^"]*' 'Pro freischalten[^"]*'
shot "free-kaufseite"
tap 'Try free for 24 h[^"]*' '24 Std. gratis testen[^"]*'
sleep 15
shot "free-belohnungsvideo"
back; back; back
sleep 3
check "2-free-kaufseite-video"

start_app 10 # „Zurück“ nach dem Video kann die App schon verlassen haben
scroll_top
tap "Settings" "Einstellungen"
tap 'Browse designs[^"]*' 'Designs ansehen[^"]*'
tap '[^"]*Forest[^"]*' '[^"]*Wald[^"]*' # Karten-Label: „15:29\nForest\n…“
sleep 8
shot "free-design-kauf"
back; back; back
check "2b-free-design-kauf"

adbt shell am force-stop "$PKG"
start_app 20
shot "free-zweiter-start"
check "3-free-zweiter-start"

# ---------------------------------------------------------------- tester
adbt shell am force-stop "$PKG"
timeout 300 adb install -r "$TESTER_APK" 2>&1 | tee "$OUT/install-tester.txt"
adbt shell pm grant "$PKG" android.permission.POST_NOTIFICATIONS 2>/dev/null
adbt logcat -c
start_app 20
shot "tester-home"
tap 'Overtime account[^"]*' 'Überstunden-Konto[^"]*'
tap 'Book today[^"]*' 'Heute buchen[^"]*'
shot "tester-ueberstunden-gebucht"
back
scroll_top
check "4a-tester-ueberstunden"

tap "Settings" "Einstellungen"
dump_ui
grep -qE 'Tester version|Testversion' "$OUT/ui.xml" && log "Tester-Hinweis sichtbar" || log "Tester-Hinweis FEHLT"
tap 'Notifications[^"]*' 'Benachrichtigungen[^"]*'
tap '1 h' '1 Std'
tap 'At halftime[^"]*' 'Zur Halbzeit[^"]*'
shot "tester-erinnerungen"
adbt shell dumpsys alarm | grep -c "$PKG" | sed 's/^/Alarme der App: /' | tee -a "$OUT/status.txt"
check "4-tester-erinnerungen"

tap 'Add widget' 'Widget hinzufügen'
shot "tester-widget-dialog"
tap 'Add to home screen' 'ADD TO HOME SCREEN' 'Add automatically' 'ADD AUTOMATICALLY' \
  'Zum Startbildschirm hinzufügen' 'Automatisch hinzufügen' 'Add' 'ADD' 'Hinzufügen'
check "5-tester-widget"

tap 'Browse designs[^"]*' 'Designs ansehen[^"]*'
shot "tester-designs"
tap '[^"]*Forest[^"]*' '[^"]*Wald[^"]*'
sleep 5
shot "tester-design-gewaehlt"
back; back; back
check "6-tester-designs"

adbt shell input keyevent KEYCODE_HOME
sleep 5
shot "tester-startbildschirm-widget"
adbt shell am force-stop "$PKG"
start_app 20
shot "tester-neustart"
check "7-tester-neustart"

# Tester-Version darf keine Werbung laden (SDK startet gar nicht erst).
# Nur Zeilen aus App-Prozessen zählen (Play-Dienste loggen selbst unter „Ads“).
PIDS=$(cat "$OUT"/logcat-*-tester-*.txt 2>/dev/null |
  grep -oE "Start proc [0-9]+:$PKG" | grep -oE '[0-9]+' | sort -u | paste -sd'|')
ADS_LINES=0
[ -n "$PIDS" ] && ADS_LINES=$(cat "$OUT"/logcat-*-tester-*.txt |
  grep -E "^[0-9-]+ [0-9:.]+ +($PIDS) " |
  grep -cE " [VDIWE] (Ads|UserMessagingPlatform) *:|Ad failed to load|onAdLoaded")
log "Werbe-Logzeilen in der Tester-Version: $ADS_LINES"

log "Ergebnis API $API: $([ $CRASHED -eq 0 ] && echo 'KEIN ABSTURZ' || echo 'ABSTURZ')"
exit $CRASHED
