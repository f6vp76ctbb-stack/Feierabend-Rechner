#!/usr/bin/env bash
# Start-Test im Emulator: installiert das Release-APK, startet die App, klickt durch
# die Einführung (dann starten Werbung + Einwilligung), startet ein zweites Mal und
# sammelt Logcat + Screenshots. Exit 1, sobald die App abstürzt.
# Aufruf (im android-emulator-runner): bash tool/ci/launch_test.sh <api> <apk>
set -u
API="$1"
APK="$2"
PKG=com.thinkube.feierabendrechner
OUT="launch-results/api$API"
mkdir -p "$OUT"
CRASHED=0

adb wait-for-device
adb shell getprop ro.build.version.release | tee "$OUT/android-version.txt"
adb install -r "$APK" 2>&1 | tee "$OUT/install.txt"

# Sucht ein Element per Text/Beschreibung (Flutter-Semantik) und tippt es an.
tap_text() {
  adb shell uiautomator dump /sdcard/ui.xml >/dev/null 2>&1
  adb shell cat /sdcard/ui.xml > "$OUT/ui.xml" 2>/dev/null
  local bounds=""
  for t in "$@"; do
    bounds=$(grep -o "<node[^>]*\(text\|content-desc\)=\"$t\"[^>]*>" "$OUT/ui.xml" \
      | grep -o 'bounds="\[[0-9]*,[0-9]*\]\[[0-9]*,[0-9]*\]"' | head -1)
    [ -n "$bounds" ] && break
  done
  if [ -z "$bounds" ]; then
    echo "tap_text: '$*' nicht gefunden"
    return 1
  fi
  read -r x1 y1 x2 y2 <<<"$(echo "$bounds" | grep -o '[0-9]*' | tr '\n' ' ')"
  adb shell input tap $(((x1 + x2) / 2)) $(((y1 + y2) / 2))
  echo "tap_text: '$*' bei $bounds"
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
    echo "!!! API $API · $n: App ist abgestürzt" | tee -a "$OUT/status.txt"
    CRASHED=1
  else
    echo "OK API $API · $n: kein Absturz" | tee -a "$OUT/status.txt"
  fi
}

# 1) Erster Start → Einführung
adb logcat -c
adb shell am start -W -n "$PKG/.MainActivity" 2>&1 | tee "$OUT/start-1.txt"
sleep 25
adb exec-out screencap -p > "$OUT/1-start.png"

# 2) Einführung überspringen → Hauptbildschirm, Werbung/Einwilligung starten
tap_text "Skip" "Überspringen" | tee -a "$OUT/status.txt"
sleep 25
adb exec-out screencap -p > "$OUT/2-home.png"
check "1-erster-start"

# 3) Zweiter Start (gespeicherte Daten, Einführung erledigt)
adb shell am force-stop "$PKG"
adb logcat -c
adb shell am start -W -n "$PKG/.MainActivity" 2>&1 | tee "$OUT/start-2.txt"
sleep 25
adb exec-out screencap -p > "$OUT/3-zweiter-start.png"
check "2-zweiter-start"

exit $CRASHED
