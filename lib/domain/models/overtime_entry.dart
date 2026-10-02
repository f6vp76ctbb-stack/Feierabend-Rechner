/// Ein Arbeitstag im Überstunden-Konto: tatsächlich gearbeitet vs. Soll.
///
/// Reine Domain-Klasse. Ein Eintrag pro Kalendertag ([date] ist der Schlüssel).
class OvertimeEntry {
  /// Auf den Kalendertag normalisiert (00:00 Uhr).
  final DateTime date;

  /// Tatsächlich gearbeitete Minuten (netto).
  final int workedMinutes;

  /// Soll-Minuten für diesen Tag.
  final int targetMinutes;

  OvertimeEntry({
    required DateTime date,
    required this.workedMinutes,
    required this.targetMinutes,
  }) : date = DateTime(date.year, date.month, date.day);

  /// Über-/Unterstunden dieses Tages (kann negativ sein).
  int get overtimeMinutes => workedMinutes - targetMinutes;

  OvertimeEntry copyWith({int? workedMinutes, int? targetMinutes}) => OvertimeEntry(
        date: date,
        workedMinutes: workedMinutes ?? this.workedMinutes,
        targetMinutes: targetMinutes ?? this.targetMinutes,
      );

  static String _iso(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-'
      '${d.month.toString().padLeft(2, '0')}-'
      '${d.day.toString().padLeft(2, '0')}';

  Map<String, dynamic> toJson() => {
        'date': _iso(date),
        'worked': workedMinutes,
        'target': targetMinutes,
      };

  factory OvertimeEntry.fromJson(Map<String, dynamic> json) => OvertimeEntry(
        date: DateTime.parse(json['date'] as String),
        workedMinutes: (json['worked'] as num).toInt(),
        targetMinutes: (json['target'] as num).toInt(),
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OvertimeEntry &&
          other.date == date &&
          other.workedMinutes == workedMinutes &&
          other.targetMinutes == targetMinutes;

  @override
  int get hashCode => Object.hash(date, workedMinutes, targetMinutes);

  @override
  String toString() =>
      'OvertimeEntry(${_iso(date)}, worked: $workedMinutes, target: $targetMinutes)';
}
