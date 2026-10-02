/// Konfiguration eines Arbeitstags.
///
/// Reine Domain-Klasse — **keine** Flutter-Abhängigkeiten. Immutable.
class WorkConfig {
  /// Netto-Sollarbeitszeit (Default 8 h).
  final Duration work;

  /// Pausenzeit, die die Anwesenheit verlängert (Default 45 min).
  final Duration breakTime;

  /// Wenn `true`, wird die Pause mindestens auf das gesetzliche Minimum
  /// nach dem Arbeitszeitgesetz (ArbZG) angehoben.
  final bool arbzgAutoBreak;

  const WorkConfig({
    this.work = const Duration(hours: 8),
    this.breakTime = const Duration(minutes: 45),
    this.arbzgAutoBreak = false,
  });

  WorkConfig copyWith({
    Duration? work,
    Duration? breakTime,
    bool? arbzgAutoBreak,
  }) {
    return WorkConfig(
      work: work ?? this.work,
      breakTime: breakTime ?? this.breakTime,
      arbzgAutoBreak: arbzgAutoBreak ?? this.arbzgAutoBreak,
    );
  }

  Map<String, dynamic> toJson() => {
        'work': work.inMinutes,
        'break': breakTime.inMinutes,
        'arbzg': arbzgAutoBreak,
      };

  factory WorkConfig.fromJson(Map<String, dynamic> json) => WorkConfig(
        work: Duration(minutes: (json['work'] as num?)?.toInt() ?? 480),
        breakTime: Duration(minutes: (json['break'] as num?)?.toInt() ?? 45),
        arbzgAutoBreak: json['arbzg'] as bool? ?? false,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WorkConfig &&
          other.work == work &&
          other.breakTime == breakTime &&
          other.arbzgAutoBreak == arbzgAutoBreak;

  @override
  int get hashCode => Object.hash(work, breakTime, arbzgAutoBreak);

  @override
  String toString() =>
      'WorkConfig(work: $work, breakTime: $breakTime, arbzgAutoBreak: $arbzgAutoBreak)';
}
