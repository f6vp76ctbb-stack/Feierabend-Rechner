import 'package:feierabend_rechner/core/formatting.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('clock', () {
    test('führende Nullen', () {
      expect(Formatting.clock(6, 4), '06:04');
      expect(Formatting.clock(15, 29), '15:29');
      expect(Formatting.clock(0, 0), '00:00');
    });
  });

  group('durationLong', () {
    test('Stunden und Minuten', () {
      expect(Formatting.durationLong(const Duration(hours: 6, minutes: 12)),
          '6 Std 12 Min');
    });
    test('nur Minuten', () {
      expect(Formatting.durationLong(const Duration(minutes: 45)), '45 Min');
    });
    test('nur Stunden', () {
      expect(Formatting.durationLong(const Duration(hours: 2)), '2 Std');
    });
    test('negativ → 0 Min', () {
      expect(Formatting.durationLong(const Duration(minutes: -5)), '0 Min');
    });
  });

  group('durationHm', () {
    test('formatiert h:mm', () {
      expect(Formatting.durationHm(const Duration(hours: 8, minutes: 45)), '8:45 h');
      expect(Formatting.durationHm(const Duration(minutes: 45)), '0:45 h');
    });
  });

  group('countdown', () {
    test('hh:mm:ss', () {
      expect(
        Formatting.countdown(const Duration(hours: 6, minutes: 12, seconds: 3)),
        '06:12:03',
      );
    });
    test('negativ → 00:00:00', () {
      expect(Formatting.countdown(const Duration(seconds: -1)), '00:00:00');
    });
  });
}
