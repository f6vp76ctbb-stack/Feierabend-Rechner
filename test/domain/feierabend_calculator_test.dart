import 'package:feierabend_rechner/domain/feierabend_calculator.dart';
import 'package:feierabend_rechner/domain/models/work_config.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const calc = FeierabendCalculator();

  Duration atTime(int h, int m) => Duration(hours: h, minutes: m);

  group('Standardfall', () {
    test('06:44 + 8h Arbeit + 45min Pause → 15:29', () {
      final r = calc.calculate(
        start: atTime(6, 44),
        config: const WorkConfig(),
      );
      expect(r.endHour, 15);
      expect(r.endMinute, 29);
      expect(r.crossesMidnight, isFalse);
      expect(r.dayOffset, 0);
      expect(r.presence, atTime(8, 45));
      expect(r.breakUsed, const Duration(minutes: 45));
    });

    test('08:00 + 8h + 0 Pause → 16:00', () {
      final r = calc.calculate(
        start: atTime(8, 0),
        config: const WorkConfig(breakTime: Duration.zero),
      );
      expect(r.endHour, 16);
      expect(r.endMinute, 0);
    });
  });

  group('Teilzeit', () {
    test('09:00 + 4h + 0 Pause → 13:00', () {
      final r = calc.calculate(
        start: atTime(9, 0),
        config: const WorkConfig(
          work: Duration(hours: 4),
          breakTime: Duration.zero,
        ),
      );
      expect(r.endHour, 13);
      expect(r.endMinute, 0);
      expect(r.crossesMidnight, isFalse);
    });
  });

  group('Mitternachts-Überlauf (Nachtschicht)', () {
    test('22:00 + 8h + 30min → 06:30 am Folgetag', () {
      final r = calc.calculate(
        start: atTime(22, 0),
        config: const WorkConfig(
          work: Duration(hours: 8),
          breakTime: Duration(minutes: 30),
        ),
      );
      expect(r.endHour, 6);
      expect(r.endMinute, 30);
      expect(r.crossesMidnight, isTrue);
      expect(r.dayOffset, 1);
    });

    test('Exakt Mitternacht: 16:00 + 8h + 0 → 00:00 Folgetag', () {
      final r = calc.calculate(
        start: atTime(16, 0),
        config: const WorkConfig(
          work: Duration(hours: 8),
          breakTime: Duration.zero,
        ),
      );
      expect(r.endHour, 0);
      expect(r.endMinute, 0);
      expect(r.dayOffset, 1);
      expect(r.crossesMidnight, isTrue);
    });
  });

  group('ArbZG legalMinimumBreak (Grenzen)', () {
    test('≤ 6h → keine Pflichtpause', () {
      expect(FeierabendCalculator.legalMinimumBreak(atTime(6, 0)), Duration.zero);
    });
    test('> 6h → 30min', () {
      expect(
        FeierabendCalculator.legalMinimumBreak(atTime(6, 1)),
        const Duration(minutes: 30),
      );
    });
    test('exakt 9h → weiterhin 30min', () {
      expect(
        FeierabendCalculator.legalMinimumBreak(atTime(9, 0)),
        const Duration(minutes: 30),
      );
    });
    test('> 9h → 45min', () {
      expect(
        FeierabendCalculator.legalMinimumBreak(atTime(9, 1)),
        const Duration(minutes: 45),
      );
    });
  });

  group('ArbZG-Auto-Modus', () {
    test('7h Arbeit, 0 Pause eingestellt → auf 30min angehoben', () {
      final r = calc.calculate(
        start: atTime(8, 0),
        config: const WorkConfig(
          work: Duration(hours: 7),
          breakTime: Duration.zero,
          arbzgAutoBreak: true,
        ),
      );
      expect(r.breakUsed, const Duration(minutes: 30));
      expect(r.presence, atTime(7, 30));
      expect(r.endHour, 15);
      expect(r.endMinute, 30);
    });

    test('10h Arbeit → auf 45min angehoben', () {
      final r = calc.calculate(
        start: atTime(6, 0),
        config: const WorkConfig(
          work: Duration(hours: 10),
          breakTime: Duration.zero,
          arbzgAutoBreak: true,
        ),
      );
      expect(r.breakUsed, const Duration(minutes: 45));
    });

    test('Eingestellte Pause über Minimum bleibt erhalten (60 > 30)', () {
      final r = calc.calculate(
        start: atTime(8, 0),
        config: const WorkConfig(
          work: Duration(hours: 8),
          breakTime: Duration(minutes: 60),
          arbzgAutoBreak: true,
        ),
      );
      expect(r.breakUsed, const Duration(minutes: 60));
    });

    test('Ohne Auto-Modus wird nichts angehoben (10h, 0 Pause bleibt 0)', () {
      final r = calc.calculate(
        start: atTime(6, 0),
        config: const WorkConfig(
          work: Duration(hours: 10),
          breakTime: Duration.zero,
        ),
      );
      expect(r.breakUsed, Duration.zero);
      expect(r.presence, atTime(10, 0));
    });
  });

  group('feierabendFrom (DateTime)', () {
    test('Standardfall am selben Tag', () {
      final start = DateTime(2026, 7, 24, 6, 44);
      final end = calc.feierabendFrom(start, const WorkConfig());
      expect(end, DateTime(2026, 7, 24, 15, 29));
    });

    test('Sekunden werden auf die Minute abgeschnitten', () {
      final start = DateTime(2026, 7, 24, 6, 44, 59);
      final end = calc.feierabendFrom(start, const WorkConfig());
      expect(end, DateTime(2026, 7, 24, 15, 29, 0));
    });

    test('Nachtschicht rollt auf den Folgetag', () {
      final start = DateTime(2026, 7, 24, 22, 0);
      final end = calc.feierabendFrom(
        start,
        const WorkConfig(
          work: Duration(hours: 8),
          breakTime: Duration(minutes: 30),
        ),
      );
      expect(end, DateTime(2026, 7, 25, 6, 30));
    });
  });

  group('presence & effectiveBreak', () {
    test('presence = Arbeit + Pause', () {
      expect(calc.presence(const WorkConfig()), atTime(8, 45));
    });
    test('effectiveBreak ohne Auto = eingestellte Pause', () {
      expect(
        calc.effectiveBreak(const WorkConfig(breakTime: Duration(minutes: 15))),
        const Duration(minutes: 15),
      );
    });
  });
}
