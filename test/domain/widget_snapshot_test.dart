import 'package:feierabend_rechner/domain/models/widget_snapshot.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final start = DateTime(2026, 9, 29, 6, 44);

  test('endLabel: Uhrzeit wie in der App', () {
    final s = WidgetSnapshot(start: start, end: DateTime(2026, 9, 29, 15, 29));
    expect(s.endLabel, '15:29');
  });

  test('endLabel: Nachtschicht über Mitternacht bekommt +1', () {
    final s = WidgetSnapshot(
      start: DateTime(2026, 9, 29, 22, 0),
      end: DateTime(2026, 9, 30, 6, 45),
    );
    expect(s.endLabel, '06:45 +1');
  });

  test('proUntilMillis: dauerhaft, Test, kein Pro', () {
    final end = DateTime(2026, 9, 29, 15, 29);
    final trial = DateTime(2026, 9, 30, 12, 0);
    expect(
      WidgetSnapshot(start: start, end: end, proForever: true).proUntilMillis,
      -1,
    );
    expect(
      WidgetSnapshot(start: start, end: end, proUntil: trial).proUntilMillis,
      trial.millisecondsSinceEpoch,
    );
    expect(WidgetSnapshot(start: start, end: end).proUntilMillis, 0);
  });

  test('toMap enthält alle Felder für die native Seite', () {
    final end = DateTime(2026, 9, 29, 15, 29);
    final map = WidgetSnapshot(start: start, end: end, proForever: true).toMap();
    expect(map, {
      'startMillis': start.millisecondsSinceEpoch,
      'endMillis': end.millisecondsSinceEpoch,
      'endLabel': '15:29',
      'proUntilMillis': -1,
    });
  });

  test('Gleichheit nach Inhalt', () {
    final end = DateTime(2026, 9, 29, 15, 29);
    expect(
      WidgetSnapshot(start: start, end: end),
      WidgetSnapshot(start: start, end: end),
    );
    expect(
      WidgetSnapshot(start: start, end: end) ==
          WidgetSnapshot(start: start, end: end, proForever: true),
      isFalse,
    );
  });
}
