import 'models/overtime_entry.dart';

/// Eine Woche im Überstunden-Konto (Montag–Sonntag) mit ihren Einträgen.
class OvertimeWeek {
  /// Montag dieser Woche (00:00).
  final DateTime weekStart;
  final List<OvertimeEntry> entries;

  const OvertimeWeek({required this.weekStart, required this.entries});

  DateTime get weekEnd => weekStart.add(const Duration(days: 6));

  int get balanceMinutes => OvertimeCalculator.totalBalance(entries);
}

/// Reine Rechen-Helfer fürs Überstunden-Konto (voll unit-getestet).
abstract final class OvertimeCalculator {
  /// Gesamtsaldo aller Einträge (Über- minus Unterstunden).
  static int totalBalance(List<OvertimeEntry> entries) =>
      entries.fold(0, (sum, e) => sum + e.overtimeMinutes);

  /// Montag der Woche, in der [date] liegt (auf den Tag normalisiert).
  static DateTime weekStart(DateTime date) {
    final day = DateTime(date.year, date.month, date.day);
    return day.subtract(Duration(days: day.weekday - DateTime.monday));
  }

  /// Saldo aller Einträge, die in derselben Woche wie [reference] liegen.
  static int balanceForWeekOf(List<OvertimeEntry> entries, DateTime reference) {
    final target = weekStart(reference);
    return totalBalance(
      entries.where((e) => weekStart(e.date) == target).toList(),
    );
  }

  /// Gruppiert Einträge nach Woche, absteigend (neueste Woche zuerst),
  /// Einträge innerhalb einer Woche absteigend nach Datum.
  static List<OvertimeWeek> groupByWeek(List<OvertimeEntry> entries) {
    final map = <DateTime, List<OvertimeEntry>>{};
    for (final e in entries) {
      map.putIfAbsent(weekStart(e.date), () => []).add(e);
    }
    final weeks = map.entries.map((entry) {
      final list = [...entry.value]
        ..sort((a, b) => b.date.compareTo(a.date));
      return OvertimeWeek(weekStart: entry.key, entries: list);
    }).toList()
      ..sort((a, b) => b.weekStart.compareTo(a.weekStart));
    return weeks;
  }
}
