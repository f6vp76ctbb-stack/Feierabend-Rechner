/// Reine Formatierungs-Helfer (keine Flutter-Abhängigkeit, leicht testbar).
abstract final class Formatting {
  /// `15:29` — zweistellige Uhrzeit.
  static String clock(int hour, int minute) =>
      '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';

  /// Lange, menschliche Dauer: `6 Std 12 Min`, `45 Min`, `2 Std`.
  static String durationLong(Duration d) {
    final total = d.isNegative ? Duration.zero : d;
    final h = total.inHours;
    final m = total.inMinutes % 60;
    if (h > 0 && m > 0) return '$h Std $m Min';
    if (h > 0) return '$h Std';
    return '$m Min';
  }

  /// Kompakte Dauer für Chips/Zeilen: `8:45 h`, `0:45 h`.
  static String durationHm(Duration d) {
    final h = d.inHours;
    final m = d.inMinutes % 60;
    return '$h:${m.toString().padLeft(2, '0')} h';
  }

  /// Signierte Dauer aus Minuten: `+5 Std 30 Min`, `−1 Std 15 Min`, `±0 Min`.
  /// Nutzt das typografische Minus (−) für ein ruhigeres Schriftbild.
  static String signedDuration(int minutes) {
    if (minutes == 0) return '±0 Min';
    final sign = minutes < 0 ? '−' : '+';
    final abs = minutes.abs();
    final h = abs ~/ 60;
    final m = abs % 60;
    final body = h > 0 && m > 0
        ? '$h Std $m Min'
        : h > 0
            ? '$h Std'
            : '$m Min';
    return '$sign$body';
  }

  /// Countdown `06:12:03` (Std:Min:Sek), immer zweistellig.
  static String countdown(Duration d) {
    final total = d.isNegative ? Duration.zero : d;
    final h = total.inHours;
    final m = total.inMinutes % 60;
    final s = total.inSeconds % 60;
    return '${h.toString().padLeft(2, '0')}:'
        '${m.toString().padLeft(2, '0')}:'
        '${s.toString().padLeft(2, '0')}';
  }
}
