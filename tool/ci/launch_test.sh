#!/usr/bin/env bash
# Start-Test im Emulator: installiert das Release-APK, startet die App zweimal,
# sammelt Logcat (Abstürze, Flutter-Fehler) und Screenshots.
# Aufruf (im android-emulator-runner): bash tool/ci/launch_test.sh <api> <apk>
set -u
API="$1"
APK="$2"
PKG=com.thinkube.feierabendrechner
OUT="launch-results/api$API"
mkdir -p "$OUT"

adb wait-for-device
adb shell getprop ro.build.version.release | tee "$OUT/android-version.txt"
adb install -r "$APK" 2>&1 | tee "$OUT/install.txt"

run() {
  local n="$1" wait="$2"
  adb logcat -c
  adb shell am start -W -n "$PKG/.MainActivity" 2>&1 | tee "$OUT/start-$n.txt"
  sleep "$wait"
  adb exec-out screencap -p > "$OUT/screen-$n.png"
  local pid
  pid=$(adb shell pidof "$PKG" | tr -d '\r')
  echo "run $n: pid after ${wait}s = '${pid}'" | tee -a "$OUT/status.txt"
  adb logcat -d -v threadtime > "$OUT/logcat-$n.txt"
  grep -E "AndroidRuntime|FATAL|F DEBUG|F libc|E flutter|I flutter|$PKG|Abort message|backtrace|#[0-9]{2} pc" \
    "$OUT/logcat-$n.txt" | tail -400 > "$OUT/relevant-$n.txt"
  echo "=================== API $API · Start $n · relevant logcat ==================="
  cat "$OUT/relevant-$n.txt"
  echo "=================== /API $API · Start $n ==================="
}

run 1 30
adb shell am force-stop "$PKG"
run 2 20
exit 0
