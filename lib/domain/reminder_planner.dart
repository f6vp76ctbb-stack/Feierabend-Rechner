/// Art einer Feierabend-Erinnerung.
enum ReminderKind { before, end }

/// Eine geplante Erinnerung (reine Domain, keine Flutter-Abhängigkeit).
class PlannedReminder {
  final int id;
  final ReminderKind kind;
  final DateTime at;

  const PlannedReminder({required this.id, required this.kind, required this.at});

  @override
  bool operator ==(Object other) =>
      other is PlannedReminder &&
      other.id == id &&
      other.kind == kind &&
      other.at == at;

  @override
  int get hashCode => Object.hash(id, kind, at);

  @override
  String toString() => 'PlannedReminder($kind @ $at)';
}

/// Plant „Gleich Feierabend" (Vorwarnung) und „Feierabend!" – nur Zeitpunkte
/// in der Zukunft. Voll unit-getestet.
abstract final class ReminderPlanner {
  static const beforeId = 1001;
  static const endId = 1002;

  /// Alle IDs, die die App je vergibt (zum sauberen Abbestellen).
  static const allIds = [beforeId, endId];

  static List<PlannedReminder> plan({
    required DateTime feierabend,
    required DateTime now,
    required Duration lead,
    required bool enabled,
  }) {
    if (!enabled) return const [];
    final before = feierabend.subtract(lead);
    return [
      if (lead > Duration.zero && before.isAfter(now))
        PlannedReminder(id: beforeId, kind: ReminderKind.before, at: before),
      if (feierabend.isAfter(now))
        PlannedReminder(id: endId, kind: ReminderKind.end, at: feierabend),
    ];
  }
}
