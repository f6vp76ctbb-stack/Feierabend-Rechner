/// An wie vielen verschiedenen Tagen die App benutzt wurde.
class UsageDays {
  const UsageDays({required this.count, this.lastDay});

  final int count;

  /// Letzter Nutzungstag als `JJJJ-MM-TT` (lokal).
  final String? lastDay;

  static String dayKey(DateTime t) =>
      '${t.year.toString().padLeft(4, '0')}-'
      '${t.month.toString().padLeft(2, '0')}-'
      '${t.day.toString().padLeft(2, '0')}';

  /// Zählt [now] mit – mehrere Starts am selben Tag zählen einmal.
  UsageDays record(DateTime now) {
    final today = dayKey(now);
    if (today == lastDay) return this;
    return UsageDays(count: count + 1, lastDay: today);
  }

  @override
  bool operator ==(Object other) =>
      other is UsageDays && other.count == count && other.lastDay == lastDay;

  @override
  int get hashCode => Object.hash(count, lastDay);
}

/// Wann die App einmalig um eine Bewertung bittet (Google-Play-Dialog).
///
/// Erst wenn sie sich bewährt hat (an mehreren Tagen genutzt) – nie beim
/// Kennenlernen, und nur ein einziges Mal (Google drosselt zusätzlich selbst).
abstract final class ReviewPolicy {
  static const minUsageDays = 4;

  static bool shouldAsk({required UsageDays usage, required bool alreadyAsked}) =>
      !alreadyAsked && usage.count >= minUsageDays;
}
