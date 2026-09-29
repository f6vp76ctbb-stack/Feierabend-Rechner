import 'package:feierabend_rechner/domain/reminder_planner.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final end = DateTime(2026, 9, 29, 15, 29);

  List<PlannedReminder> plan(DateTime now,
          {Duration lead = const Duration(minutes: 30), bool enabled = true}) =>
      ReminderPlanner.plan(feierabend: end, now: now, lead: lead, enabled: enabled);

  test('vormittags: Vorwarnung + Feierabend', () {
    final r = plan(DateTime(2026, 9, 29, 12, 17));
    expect(r.map((e) => e.kind), [ReminderKind.before, ReminderKind.end]);
    expect(r.first.at, DateTime(2026, 9, 29, 14, 59));
    expect(r.last.at, end);
  });

  test('innerhalb der Vorwarnzeit: nur noch Feierabend', () {
    final r = plan(DateTime(2026, 9, 29, 15, 10));
    expect(r.map((e) => e.kind), [ReminderKind.end]);
  });

  test('nach Feierabend: nichts mehr', () {
    expect(plan(DateTime(2026, 9, 29, 16, 0)), isEmpty);
  });

  test('ausgeschaltet: nichts', () {
    expect(plan(DateTime(2026, 9, 29, 8, 0), enabled: false), isEmpty);
  });

  test('Vorwarnung 0: nur Feierabend', () {
    final r = plan(DateTime(2026, 9, 29, 8, 0), lead: Duration.zero);
    expect(r.map((e) => e.kind), [ReminderKind.end]);
  });

  test('IDs sind stabil (Überschreiben statt Duplikate)', () {
    final r = plan(DateTime(2026, 9, 29, 8, 0));
    expect(r.map((e) => e.id), ReminderPlanner.allIds);
  });
}
