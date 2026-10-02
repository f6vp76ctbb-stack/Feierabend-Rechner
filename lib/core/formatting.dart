/// Einheiten-Bezeichner für Dauern (sprachabhängig, z. B. „Std/Min" oder „h/min").
class Units {
  final String hour;
  final String minute;

  const Units({required this.hour, required this.minute});

  static const de = Units(hour: 'Std', minute: 'Min');
  static const en = Units(hour: 'h', minute: 'min');
}

/// Reine Formatierungs-Helfer (keine Flutter-Abhängigkeit, leicht testbar).
abstract final class Formatting {
  /// `15:29` — zweistellige Uhrzeit.
  static String clock(int hour, int minute) =>
      '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';

  static String _hm(int h, int m, Units u) {
    if (h > 0 && m > 0) return '$h ${u.hour} $m ${u.minute}';
    if (h > 0) return '$h ${u.hour}';
    return '$m ${u.minute}';
  }

  /// Lange, menschliche Dauer: `6 Std 12 Min`, `45 Min`, `2 Std`.
  static String durationLong(Duration d, [Units u = Units.de]) {
    final total = d.isNegative ? Duration.zero : d;
    return _hm(total.inHours, total.inMinutes % 60, u);
  }

  /// Kompakte Dauer für Chips/Zeilen: `8:45 h`, `0:45 h`.
  static String durationHm(Duration d) {
    final h = d.inHours;
    final m = d.inMinutes % 60;
    return '$h:${m.toString().padLeft(2, '0')} h';
  }

  /// Signierte Dauer aus Minuten: `+5 Std 30 Min`, `−1 Std 15 Min`, `±0 Min`.
  /// Nutzt das typografische Minus (−) für ein ruhigeres Schriftbild.
  static String signedDuration(int minutes, [Units u = Units.de]) {
    if (minutes == 0) return '±0 ${u.minute}';
    final sign = minutes < 0 ? '−' : '+';
    final abs = minutes.abs();
    return '$sign${_hm(abs ~/ 60, abs % 60, u)}';
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
