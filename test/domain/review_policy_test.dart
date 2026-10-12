import 'package:feierabend_rechner/domain/review_policy.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('UsageDays', () {
    test('zählt jeden Tag einmal', () {
      var u = const UsageDays(count: 0);
      u = u.record(DateTime(2026, 10, 12, 7));
      u = u.record(DateTime(2026, 10, 12, 16)); // gleicher Tag
      expect(u, const UsageDays(count: 1, lastDay: '2026-10-12'));
      u = u.record(DateTime(2026, 10, 13, 0, 5));
      expect(u.count, 2);
      expect(u.lastDay, '2026-10-13');
    });

    test('Tagesschlüssel mit führenden Nullen', () {
      expect(UsageDays.dayKey(DateTime(2027, 1, 5)), '2027-01-05');
    });
  });

  group('ReviewPolicy', () {
    test('erst ab dem 4. Nutzungstag', () {
      expect(
          ReviewPolicy.shouldAsk(
              usage: const UsageDays(count: 3), alreadyAsked: false),
          isFalse);
      expect(
          ReviewPolicy.shouldAsk(
              usage: const UsageDays(count: 4), alreadyAsked: false),
          isTrue);
    });

    test('nur einmal', () {
      expect(
          ReviewPolicy.shouldAsk(
              usage: const UsageDays(count: 10), alreadyAsked: true),
          isFalse);
    });
  });
}
