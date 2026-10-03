import 'package:feierabend_rechner/domain/reminder_planner.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final start = DateTime(2026, 9, 29, 6, 44);
  final end = DateTime(2026, 9, 29, 15, 29);
  const h1 = Duration(hours: 1);
  const m15 = Duration(minutes: 15);
  const m30 = Duration(minutes: 30);

  List<PlannedReminder> plan(DateTime now, ReminderOptions options) =>
      ReminderPlanner.plan(start: start, feierabend: end, now: now, options: options);

  ReminderOptions on({
    List<Duration> leads = const [m30],
    bool half = false,
    bool atEnd = true,
  }) =>
      ReminderOptions(enabled: true, leads: leads, halfTime: half, atEnd: atEnd);

  group('ReminderPlanner', () {
    test('mehrere Vorwarnungen + Feierabend, zeitlich sortiert', () {
      final r = plan(DateTime(2026, 9, 29, 8, 0), on(leads: [m15, h1]));
      expect(r.map((e) => e.at), [
        DateTime(2026, 9, 29, 14, 29),
        DateTime(2026, 9, 29, 15, 14),
        end,
      ]);
      expect(r.map((e) => e.lead), [h1, m15, null]);
      expect(r.last.kind, ReminderKind.end);
    });

    test('Halbzeit liegt mittig zwischen Start und Feierabend', () {
      final r = plan(DateTime(2026, 9, 29, 7, 0), on(leads: [], half: true));
      final half = r.firstWhere((e) => e.kind == ReminderKind.half);
      expect(half.at, DateTime(2026, 9, 29, 11, 6, 30));
    });

    test('vergangene Zeitpunkte fallen weg', () {
      final r = plan(DateTime(2026, 9, 29, 15, 0), on(leads: [m15, h1], half: true));
      expect(r.map((e) => e.kind), [ReminderKind.before, ReminderKind.end]);
      expect(r.first.lead, m15);
    });

    test('Vorwarnung vor Arbeitsbeginn fällt weg', () {
      final r = plan(
        DateTime(2026, 9, 29, 5, 0),
        on(leads: [const Duration(hours: 10)]),
      );
      expect(r.map((e) => e.kind), [ReminderKind.end]);
    });

    test('„Feierabend!" lässt sich abschalten', () {
      final r = plan(DateTime(2026, 9, 29, 8, 0), on(atEnd: false));
      expect(r.map((e) => e.kind), [ReminderKind.before]);
    });

    test('nach Feierabend: nichts mehr', () {
      expect(plan(DateTime(2026, 9, 29, 16, 0), on(half: true)), isEmpty);
    });

    test('ausgeschaltet: nichts', () {
      expect(plan(DateTime(2026, 9, 29, 8, 0), ReminderOptions()), isEmpty);
    });

    test('IDs sind stabil und gehören zur App', () {
      final r = plan(DateTime(2026, 9, 29, 7, 0), on(leads: [m15, h1], half: true));
      expect(r.map((e) => e.id).toSet(), {
        ReminderPlanner.beforeId(h1),
        ReminderPlanner.beforeId(m15),
        ReminderPlanner.halfId,
        ReminderPlanner.endId,
      });
      expect(r.every((e) => ReminderPlanner.isOwnId(e.id)), isTrue);
      expect(ReminderPlanner.isOwnId(1001), isTrue); // alte Vorwarnung aus 1.0
      expect(ReminderPlanner.isOwnId(42), isFalse);
    });
  });

  group('ReminderOptions', () {
    test('Vorwarnungen: sortiert, ohne Doppelte, ohne 0 und > 12 Std', () {
      final o = ReminderOptions(leads: [
        m15,
        h1,
        m15,
        Duration.zero,
        const Duration(hours: 13),
      ]);
      expect(o.leads, [h1, m15]);
    });

    test('höchstens 6 Vorwarnungen', () {
      var o = ReminderOptions(leads: []);
      for (var m = 5; m <= 40; m += 5) {
        o = o.toggleLead(Duration(minutes: m));
      }
      expect(o.leads.length, ReminderOptions.maxLeads);
    });

    test('toggleLead schaltet an und wieder aus', () {
      final o = ReminderOptions(leads: [m30]).toggleLead(h1);
      expect(o.leads, [h1, m30]);
      expect(o.toggleLead(m30).leads, [h1]);
    });

    test('Gleichheit nach Inhalt', () {
      expect(ReminderOptions(leads: [m15, h1]), ReminderOptions(leads: [h1, m15]));
      expect(ReminderOptions() == ReminderOptions(withQuote: false), isFalse);
    });
  });
}
