import 'models/feierabend_result.dart';
import 'models/work_config.dart';

/// Kern-Logik der App: berechnet, **wann Feierabend ist**.
///
/// Bewusst rein (keine Flutter-Imports) und voll unit-getestet. Die UI hängt
/// nur an dieser Klasse — hier wird gerechnet, nirgends sonst.
///
/// Formel:
/// ```
/// feierabend = startzeit + arbeitszeit + pausenzeit
/// ```
/// Die Pause verlängert also die Anwesenheit (sie wird "draufgerechnet").
class FeierabendCalculator {
  const FeierabendCalculator();

  static const Duration _sixHours = Duration(hours: 6);
  static const Duration _nineHours = Duration(hours: 9);
  static const int _minutesPerDay = 24 * 60;

  /// Gesetzliche Mindestpause nach ArbZG §4, abhängig von der Arbeitszeit:
  /// - > 6 h Arbeit → mind. 30 min
  /// - > 9 h Arbeit → mind. 45 min
  /// - sonst → keine Pflichtpause
  static Duration legalMinimumBreak(Duration work) {
    if (work > _nineHours) return const Duration(minutes: 45);
    if (work > _sixHours) return const Duration(minutes: 30);
    return Duration.zero;
  }

  /// Effektive Pause. Im ArbZG-Auto-Modus wird die Pause **automatisch** auf das
  /// gesetzliche Minimum für die aktuelle Arbeitszeit gesetzt (die manuell
  /// eingestellte Pause wird dann ignoriert). Ohne Auto-Modus gilt die manuelle
  /// Pause.
  Duration effectiveBreak(WorkConfig config) {
    if (!config.arbzgAutoBreak) return config.breakTime;
    return legalMinimumBreak(config.work);
  }

  /// Gesamte Anwesenheit (Arbeit + effektive Pause).
  Duration presence(WorkConfig config) => config.work + effectiveBreak(config);

  /// Berechnet den Feierabend aus einer Startzeit.
  ///
  /// [start] ist die Uhrzeit als Dauer seit Mitternacht (z. B. 06:44 =
  /// `Duration(hours: 6, minutes: 44)`). Sekunden werden ignoriert (auf ganze
  /// Minuten gerundet). Mitternachts-Überlauf (Nachtschicht) wird über
  /// [FeierabendResult.dayOffset] abgebildet.
  FeierabendResult calculate({
    required Duration start,
    required WorkConfig config,
  }) {
    final breakUsed = effectiveBreak(config);
    final total = config.work + breakUsed;

    final endMinutes = start.inMinutes + total.inMinutes;
    final dayOffset = endMinutes ~/ _minutesPerDay;
    final clockMinutes = endMinutes % _minutesPerDay;

    return FeierabendResult(
      presence: total,
      breakUsed: breakUsed,
      endOfDay: Duration(minutes: clockMinutes),
      dayOffset: dayOffset,
    );
  }

  /// Convenience für Countdown/Benachrichtigungen: liefert den Feierabend als
  /// konkreten [DateTime] auf Basis von [start]. Sekunden/Millisekunden von
  /// [start] werden auf die Minute abgeschnitten.
  ///
  /// Hinweis: [DateTime.add] rechnet in absoluter Dauer. Über eine
  /// Sommer-/Winterzeit-Umstellung hinweg kann die angezeigte Wanduhrzeit
  /// daher um eine Stunde abweichen — bewusst simpel gehalten (TODO: echte
  /// Zeitzonen-Behandlung, siehe TODO.md Phase 2/7).
  DateTime feierabendFrom(DateTime start, WorkConfig config) {
    final rounded =
        DateTime(start.year, start.month, start.day, start.hour, start.minute);
    return rounded.add(presence(config));
  }
}
