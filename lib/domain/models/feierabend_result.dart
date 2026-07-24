/// Ergebnis der Feierabend-Berechnung.
///
/// Reine Domain-Klasse — **keine** Flutter-Abhängigkeiten. Immutable.
class FeierabendResult {
  /// Gesamte Anwesenheit (Arbeit + effektive Pause).
  final Duration presence;

  /// Tatsächlich verwendete Pause (kann durch ArbZG-Auto-Modus angehoben sein).
  final Duration breakUsed;

  /// Feierabend als Wanduhrzeit, ausgedrückt als Dauer seit Mitternacht des
  /// Endtags (0 h ≤ endOfDay < 24 h).
  final Duration endOfDay;

  /// Wie viele Kalendertage nach dem Starttag der Feierabend liegt.
  /// `0` = selber Tag, `1` = am nächsten Tag (Nachtschicht) usw.
  final int dayOffset;

  const FeierabendResult({
    required this.presence,
    required this.breakUsed,
    required this.endOfDay,
    required this.dayOffset,
  });

  /// `true`, wenn der Feierabend erst am nächsten (oder einem späteren) Tag liegt.
  bool get crossesMidnight => dayOffset > 0;

  /// Stunde der Feierabend-Uhrzeit (0–23).
  int get endHour => endOfDay.inHours;

  /// Minute der Feierabend-Uhrzeit (0–59).
  int get endMinute => endOfDay.inMinutes % 60;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FeierabendResult &&
          other.presence == presence &&
          other.breakUsed == breakUsed &&
          other.endOfDay == endOfDay &&
          other.dayOffset == dayOffset;

  @override
  int get hashCode => Object.hash(presence, breakUsed, endOfDay, dayOffset);

  @override
  String toString() =>
      'FeierabendResult(end: ${endHour.toString().padLeft(2, '0')}:'
      '${endMinute.toString().padLeft(2, '0')}, dayOffset: $dayOffset, '
      'presence: $presence, breakUsed: $breakUsed)';
}
