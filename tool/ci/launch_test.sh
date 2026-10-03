#!/usr/bin/env bash
# Emulator-Test des Release-Builds (R8, echte AdMob-IDs) – zwei Durchgänge:
#   free: Einführung → Hauptbildschirm (Werbung/Einwilligung) → Kaufseite → Belohnungsvideo
#   pro:  Erinnerungen planen → Widget ablegen → Design-Shop/Kauf → Überstunden → Neustart
# Sammelt Logcat + Screenshots. Exit 1, sobald die App irgendwo abstürzt.
# Aufruf: bash tool/ci/launch_test.sh <api> <free.apk> <pro.apk>
set -u
API="$1"
FREE_APK="$2"
PRO_APK="$3"
PKG=com.thinkube.feierabendrechner
OUT="launch-results/api$API"
mkdir -p "$OUT"
CRASHED=0
SHOT=0

adb wait-for-device
adb shell getprop ro.build.version.release | tee "$OUT/android-version.txt"
read -r W H <<<"$(adb shell wm size | grep -o '[0-9]*x[0-9]*' | tail -1 | tr 'x' ' ')"
echo "Bildschirm: ${W}x${H}" | tee -a "$OUT/status.txt"

log() { echo "$*" | tee -a "$OUT/status.txt"; }

shot() {
  SHOT=$((SHOT + 1))
  adb exec-out screencap -p > "$OUT/$(printf '%02d' $SHOT)-$1.png"
}

dump_ui() {
  for _ in 1 2 3; do
    if adb shell uiautomator dump /sdcard/ui.xml 2>&1 | grep -q "dumped"; then
      adb shell cat /sdcard/ui.xml > "$OUT/ui.xml" 2>/dev/null
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
      adb shell input tap $(((x1 + x2) / 2)) $(((y1 + y2) / 2))
      log "tap '$1' bei $bounds"
      sleep 3
      return 0
    fi
    [ "$tries" -lt 4 ] && adb shell input swipe $((W / 2)) $((H * 3 / 4)) $((W / 2)) $((H / 3)) 300 && sleep 1
  done
  log "tap '$1': nicht gefunden"
  return 1
}

back() { adb shell input keyevent KEYCODE_BACK; sleep 2; }

# Ganz nach oben scrollen (Kopfzeile mit dem Einstellungs-Symbol sichtbar).
scroll_top() {
  for _ in 1 2 3 4; do
    adb shell input swipe $((W / 2)) $((H / 3)) $((W / 2)) $((H * 3 / 4)) 200
  done
  sleep 1
}

check() {
  local n="$1"
  adb logcat -d -v threadtime > "$OUT/logcat-$n.txt"
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
  adb logcat -c
}

start_app() {
  adb shell am start -W -n "$PKG/.MainActivity" >/dev/null 2>&1
  sleep "${1:-20}"
}

# ---------------------------------------------------------------- free
adb install -r "$FREE_APK" 2>&1 | tee "$OUT/install-free.txt"
adb logcat -c
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

adb shell am force-stop "$PKG"
start_app 20
shot "free-zweiter-start"
check "3-free-zweiter-start"

# ---------------------------------------------------------------- pro
adb shell am force-stop "$PKG"
adb install -r "$PRO_APK" 2>&1 | tee "$OUT/install-pro.txt"
adb shell pm grant "$PKG" android.permission.POST_NOTIFICATIONS 2>/dev/null
adb logcat -c
start_app 20
shot "pro-home"
tap 'Overtime account[^"]*' 'Überstunden-Konto[^"]*'
tap 'Book today[^"]*' 'Heute buchen[^"]*'
shot "pro-ueberstunden-gebucht"
back
scroll_top
check "4a-pro-ueberstunden"

tap "Settings" "Einstellungen"
tap 'Notifications[^"]*' 'Benachrichtigungen[^"]*'
tap '1 h' '1 Std'
tap 'At halftime[^"]*' 'Zur Halbzeit[^"]*'
shot "pro-erinnerungen"
adb shell dumpsys alarm | grep -c "$PKG" | sed 's/^/Alarme der App: /' | tee -a "$OUT/status.txt"
check "4-pro-erinnerungen"

tap 'Add widget' 'Widget hinzufügen'
shot "pro-widget-dialog"
tap 'Add to home screen' 'ADD TO HOME SCREEN' 'Add automatically' 'ADD AUTOMATICALLY' \
  'Zum Startbildschirm hinzufügen' 'Automatisch hinzufügen' 'Add' 'ADD' 'Hinzufügen'
check "5-pro-widget"

tap 'Browse designs[^"]*' 'Designs ansehen[^"]*'
shot "pro-designs"
tap 'Forest[^"]*' 'Wald[^"]*'
sleep 5
shot "pro-design-kauf"
back; back; back
check "6-pro-designs"

adb shell input keyevent KEYCODE_HOME
sleep 5
shot "pro-startbildschirm-widget"
adb shell am force-stop "$PKG"
start_app 20
shot "pro-neustart"
check "7-pro-neustart"

log "Ergebnis API $API: $([ $CRASHED -eq 0 ] && echo 'KEIN ABSTURZ' || echo 'ABSTURZ')"
exit $CRASHED
