import 'package:feierabend_rechner/domain/models/overtime_entry.dart';
import 'package:feierabend_rechner/domain/overtime_calculator.dart';
import 'package:flutter_test/flutter_test.dart';

OvertimeEntry entry(DateTime date, int worked, int target) =>
    OvertimeEntry(date: date, workedMinutes: worked, targetMinutes: target);

void main() {
  group('OvertimeEntry', () {
    test('overtimeMinutes = worked - target', () {
      expect(entry(DateTime(2024, 1, 3), 510, 480).overtimeMinutes, 30);
      expect(entry(DateTime(2024, 1, 3), 450, 480).overtimeMinutes, -30);
    });

    test('date wird auf den Kalendertag normalisiert', () {
      final e = OvertimeEntry(
        date: DateTime(2024, 1, 3, 17, 42),
        workedMinutes: 480,
        targetMinutes: 480,
      );
      expect(e.date, DateTime(2024, 1, 3));
    });

    test('JSON Round-Trip', () {
      final e = entry(DateTime(2024, 1, 3), 510, 480);
      expect(OvertimeEntry.fromJson(e.toJson()), e);
    });
  });

  group('weekStart (Montag)', () {
    // 2024-01-01 war ein Montag.
    test('Montag bleibt Montag', () {
      expect(OvertimeCalculator.weekStart(DateTime(2024, 1, 1)),
          DateTime(2024, 1, 1));
    });
    test('Mittwoch → Montag derselben Woche', () {
      expect(OvertimeCalculator.weekStart(DateTime(2024, 1, 3)),
          DateTime(2024, 1, 1));
    });
    test('Sonntag → Montag derselben Woche', () {
      expect(OvertimeCalculator.weekStart(DateTime(2024, 1, 7)),
          DateTime(2024, 1, 1));
    });
    test('nächster Montag → neue Woche', () {
      expect(OvertimeCalculator.weekStart(DateTime(2024, 1, 8)),
          DateTime(2024, 1, 8));
    });
  });

  group('totalBalance & balanceForWeekOf', () {
    final entries = [
      entry(DateTime(2024, 1, 2), 510, 480), // +30 (Woche 1)
      entry(DateTime(2024, 1, 4), 450, 480), // -30 (Woche 1)
      entry(DateTime(2024, 1, 9), 540, 480), // +60 (Woche 2)
    ];

    test('Gesamtsaldo summiert alle Tage', () {
      expect(OvertimeCalculator.totalBalance(entries), 60);
    });

    test('Wochensaldo filtert korrekt', () {
      expect(
        OvertimeCalculator.balanceForWeekOf(entries, DateTime(2024, 1, 3)),
        0, // +30 -30
      );
      expect(
        OvertimeCalculator.balanceForWeekOf(entries, DateTime(2024, 1, 9)),
        60,
      );
    });

    test('leere Liste → 0', () {
      expect(OvertimeCalculator.totalBalance(const []), 0);
    });
  });

  group('groupByWeek', () {
    test('gruppiert und sortiert absteigend', () {
      final entries = [
        entry(DateTime(2024, 1, 2), 480, 480),
        entry(DateTime(2024, 1, 9), 480, 480),
        entry(DateTime(2024, 1, 4), 480, 480),
      ];
      final weeks = OvertimeCalculator.groupByWeek(entries);
      expect(weeks, hasLength(2));
      // Neueste Woche zuerst.
      expect(weeks.first.weekStart, DateTime(2024, 1, 8));
      expect(weeks.last.weekStart, DateTime(2024, 1, 1));
      // Innerhalb der Woche absteigend nach Datum.
      expect(weeks.last.entries.first.date, DateTime(2024, 1, 4));
      expect(weeks.last.entries.last.date, DateTime(2024, 1, 2));
      expect(weeks.first.weekEnd, DateTime(2024, 1, 14));
    });
  });
}
