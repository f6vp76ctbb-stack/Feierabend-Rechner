/// Art einer Feierabend-Erinnerung.
enum ReminderKind { before, half, end }

/// Was der Nutzer an Erinnerungen eingestellt hat (reine Domain).
class ReminderOptions {
  /// Erinnerungen insgesamt an/aus.
  final bool enabled;

  /// Vorwarnungen vor Feierabend, absteigend sortiert, ohne Doppelte.
  final List<Duration> leads;

  /// Hinweis zur Halbzeit der Anwesenheit.
  final bool halfTime;

  /// „Feierabend!" pünktlich zum Feierabend.
  final bool atEnd;

  /// Spruch aus der gewählten Berufsgruppe anhängen.
  final bool withQuote;

  static const presetLeads = [
    Duration(minutes: 5),
    Duration(minutes: 15),
    Duration(minutes: 30),
    Duration(hours: 1),
    Duration(hours: 2),
  ];
  static const maxLeads = 6;
  static const maxLead = Duration(hours: 12);

  ReminderOptions({
    this.enabled = false,
    List<Duration> leads = const [Duration(minutes: 30)],
    this.halfTime = false,
    this.atEnd = true,
    this.withQuote = true,
  }) : leads = normalize(leads);

  /// Gültige Vorwarnungen: > 0, ≤ 12 Std, ohne Doppelte, größte zuerst, max. 6.
  static List<Duration> normalize(Iterable<Duration> leads) {
    final set = {
      for (final l in leads)
        if (l > Duration.zero && l <= maxLead) Duration(minutes: l.inMinutes),
    }.toList()
      ..sort((a, b) => b.compareTo(a));
    return List.unmodifiable(set.take(maxLeads));
  }

  bool hasLead(Duration lead) => leads.contains(lead);

  /// Vorwarnung an- bzw. abschalten (bei vollem Kontingent bleibt alles, wie es ist).
  ReminderOptions toggleLead(Duration lead) => copyWith(
        leads: hasLead(lead)
            ? leads.where((l) => l != lead).toList()
            : leads.length >= maxLeads
                ? leads
                : [...leads, lead],
      );

  ReminderOptions copyWith({
    bool? enabled,
    List<Duration>? leads,
    bool? halfTime,
    bool? atEnd,
    bool? withQuote,
  }) =>
      ReminderOptions(
        enabled: enabled ?? this.enabled,
        leads: leads ?? this.leads,
        halfTime: halfTime ?? this.halfTime,
        atEnd: atEnd ?? this.atEnd,
        withQuote: withQuote ?? this.withQuote,
      );

  @override
  bool operator ==(Object other) =>
      other is ReminderOptions &&
      other.enabled == enabled &&
      _sameLeads(other.leads, leads) &&
      other.halfTime == halfTime &&
      other.atEnd == atEnd &&
      other.withQuote == withQuote;

  @override
  int get hashCode =>
      Object.hash(enabled, Object.hashAll(leads), halfTime, atEnd, withQuote);

  static bool _sameLeads(List<Duration> a, List<Duration> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}

/// Eine geplante Erinnerung (reine Domain, keine Flutter-Abhängigkeit).
class PlannedReminder {
  final int id;
  final ReminderKind kind;
  final DateTime at;

  /// Nur bei [ReminderKind.before]: wie lange es dann noch bis Feierabend ist.
  final Duration? lead;

  const PlannedReminder({
    required this.id,
    required this.kind,
    required this.at,
    this.lead,
  });

  @override
  bool operator ==(Object other) =>
      other is PlannedReminder &&
      other.id == id &&
      other.kind == kind &&
      other.at == at &&
      other.lead == lead;

  @override
  int get hashCode => Object.hash(id, kind, at, lead);

  @override
  String toString() => 'PlannedReminder($kind${lead == null ? '' : ' $lead'} @ $at)';
}

/// Plant Vorwarnungen, Halbzeit und „Feierabend!" – nur Zeitpunkte in der
/// Zukunft und nach Arbeitsbeginn, zeitlich sortiert. Voll unit-getestet.
abstract final class ReminderPlanner {
  static const endId = 1002;
  static const halfId = 1003;

  /// Vorwarnungen: 1100 + Minuten → je Vorwarnzeit eine feste ID.
  static int beforeId(Duration lead) => 1100 + lead.inMinutes;

  /// Gehört diese Benachrichtigungs-ID zu uns? (1001 = Vorwarnung aus v1.0)
  static bool isOwnId(int id) =>
      id == 1001 || id == endId || id == halfId || (id > 1100 && id <= 1100 + 12 * 60);

  static List<PlannedReminder> plan({
    required DateTime start,
    required DateTime feierabend,
    required DateTime now,
    required ReminderOptions options,
  }) {
    if (!options.enabled) return const [];
    bool usable(DateTime at) => at.isAfter(now) && at.isAfter(start);

    final result = <PlannedReminder>[
      for (final lead in options.leads)
        if (usable(feierabend.subtract(lead)))
          PlannedReminder(
            id: beforeId(lead),
            kind: ReminderKind.before,
            at: feierabend.subtract(lead),
            lead: lead,
          ),
    ];
    final half = start.add(feierabend.difference(start) ~/ 2);
    if (options.halfTime && usable(half)) {
      result.add(PlannedReminder(id: halfId, kind: ReminderKind.half, at: half));
    }
    if (options.atEnd && feierabend.isAfter(now)) {
      result.add(PlannedReminder(id: endId, kind: ReminderKind.end, at: feierabend));
    }
    result.sort((a, b) => a.at.compareTo(b.at));
    return result;
  }
}
