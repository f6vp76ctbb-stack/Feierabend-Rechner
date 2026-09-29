/// Alles, was das Home-Screen-Widget zum Anzeigen braucht – ohne App-Prozess.
///
/// Das Widget rechnet selbst weiter (Countdown, „erreicht", Pro-Ablauf),
/// deshalb werden absolute Zeitpunkte übergeben.
class WidgetSnapshot {
  /// Arbeitsbeginn heute.
  final DateTime start;

  /// Feierabend (kann am Folgetag liegen).
  final DateTime end;

  /// Pro dauerhaft gekauft.
  final bool proForever;

  /// Ende eines befristeten Pro-Tests (null = kein Test).
  final DateTime? proUntil;

  const WidgetSnapshot({
    required this.start,
    required this.end,
    this.proForever = false,
    this.proUntil,
  });

  /// Uhrzeit wie in der App, z. B. „15:29" bzw. „06:15 +1" bei Nachtschicht.
  String get endLabel {
    String two(int v) => v.toString().padLeft(2, '0');
    final label = '${two(end.hour)}:${two(end.minute)}';
    final days = DateTime(end.year, end.month, end.day)
        .difference(DateTime(start.year, start.month, start.day))
        .inDays;
    return days > 0 ? '$label +$days' : label;
  }

  /// Pro-Status als ein Zahlwert für die native Seite:
  /// -1 = dauerhaft, 0 = kein Pro, sonst Ablauf in Epoch-Millisekunden.
  int get proUntilMillis {
    if (proForever) return -1;
    return proUntil?.millisecondsSinceEpoch ?? 0;
  }

  Map<String, Object> toMap() => {
        'startMillis': start.millisecondsSinceEpoch,
        'endMillis': end.millisecondsSinceEpoch,
        'endLabel': endLabel,
        'proUntilMillis': proUntilMillis,
      };

  @override
  bool operator ==(Object other) =>
      other is WidgetSnapshot &&
      other.start == start &&
      other.end == end &&
      other.proForever == proForever &&
      other.proUntil == proUntil;

  @override
  int get hashCode => Object.hash(start, end, proForever, proUntil);
}
