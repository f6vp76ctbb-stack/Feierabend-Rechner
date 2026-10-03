import 'package:feierabend_rechner/data/sprueche.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../test_helpers.dart';

/// Startzeit = jetzt → Feierabend (8 Std + 45 Min) liegt sicher in der Zukunft.
Map<String, Object> _startNow() {
  final n = DateTime.now();
  return {'start_minutes': n.hour * 60 + n.minute};
}

String _feierabendLabel() {
  final n = DateTime.now();
  final end = DateTime(n.year, n.month, n.day, n.hour, n.minute)
      .add(const Duration(hours: 8, minutes: 45));
  String two(int v) => v.toString().padLeft(2, '0');
  return '${two(end.hour)}:${two(end.minute)}';
}

Future<void> _openSettings(WidgetTester tester) async {
  await tester.tap(find.byIcon(Icons.settings_rounded));
  await tester.pumpAndSettle();
}

Future<void> _tapVisible(WidgetTester tester, Finder f) async {
  await tester.ensureVisible(f);
  await tester.pumpAndSettle();
  await tester.tap(f);
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('Mehrere Vorwarnungen, Halbzeit und Feierabend – mit Spruch', (
    tester,
  ) async {
    final notif = FakeNotificationBackend();
    await tester.pumpWidget(
      await buildApp(
        notifications: notif,
        initial: {
          ..._startNow(),
          'reminders_enabled': true,
          'reminder_leads': '60,15',
          'reminder_half': true,
        },
      ),
    );
    await tester.pump();

    expect(notif.current.map((n) => n.title), [
      'Halbzeit! ☕',
      'Noch 1 Std bis Feierabend',
      'Noch 15 Min bis Feierabend',
      'Feierabend! 🎉',
    ]);
    final lead = notif.current[1];
    final lines = lead.body.split('\n');
    expect(lines.first, 'Feierabend um ${_feierabendLabel()}.');
    expect(Sprueche.forGruppe(Sprueche.defaultGruppe), contains(lines.last));
    // Kein Spruch doppelt in einem Plan.
    final quotes = notif.current.map((n) => n.body.split('\n').last).toSet();
    expect(quotes.length, notif.current.length);
  });

  testWidgets('Ohne Spruch: nur der Hinweis', (tester) async {
    final notif = FakeNotificationBackend();
    await tester.pumpWidget(
      await buildApp(
        notifications: notif,
        initial: {
          ..._startNow(),
          'reminders_enabled': true,
          'reminder_leads': '60',
          'reminder_quote': false,
        },
      ),
    );
    await tester.pump();

    expect(notif.current.first.body, 'Feierabend um ${_feierabendLabel()}.');
    expect(notif.current.last.body, 'Geschafft. Ab nach Hause!');
  });

  testWidgets('Englisch: eigene Texte', (tester) async {
    final notif = FakeNotificationBackend();
    await tester.pumpWidget(
      await buildApp(
        locale: const Locale('en'),
        notifications: notif,
        initial: {
          ..._startNow(),
          'reminders_enabled': true,
          'reminder_leads': '120',
          'reminder_quote': false,
        },
      ),
    );
    await tester.pump();

    expect(notif.current.first.title, '2 h until clock-out');
    expect(notif.current.first.body, 'Clock-out at ${_feierabendLabel()}.');
  });

  testWidgets('Free: trotz eingeschaltet wird nichts geplant', (tester) async {
    final notif = FakeNotificationBackend();
    await tester.pumpWidget(
      await buildApp(
        pro: false,
        notifications: notif,
        initial: {..._startNow(), 'reminders_enabled': true},
      ),
    );
    await tester.pump();

    expect(notif.applied, isNotEmpty); // alte Planungen werden abgeräumt
    expect(notif.current, isEmpty);
  });

  testWidgets('Einstellungen: einschalten, Vorwarnung dazu, Halbzeit an', (
    tester,
  ) async {
    final notif = FakeNotificationBackend();
    await tester.pumpWidget(
      await buildApp(notifications: notif, initial: _startNow()),
    );
    await tester.pump();
    expect(notif.current, isEmpty);

    await _openSettings(tester);
    expect(find.text('Erinnerungen'), findsOneWidget);
    await _tapVisible(tester, find.text('Benachrichtigungen'));

    expect(notif.permissionRequests, 1);
    expect(notif.current.map((n) => n.title),
        ['Noch 30 Min bis Feierabend', 'Feierabend! 🎉']);
    expect(find.text('Vorwarnungen'), findsOneWidget);

    await _tapVisible(tester, find.widgetWithText(FilterChip, '1 Std'));
    expect(notif.current.map((n) => n.title), [
      'Noch 1 Std bis Feierabend',
      'Noch 30 Min bis Feierabend',
      'Feierabend! 🎉',
    ]);

    await _tapVisible(tester, find.text('Zur Halbzeit'));
    expect(notif.current.first.title, 'Halbzeit! ☕');

    await _tapVisible(tester, find.text('Pünktlich zum Feierabend'));
    expect(notif.current.map((n) => n.title), isNot(contains('Feierabend! 🎉')));
  });

  testWidgets('Einstellungen: verweigerte Berechtigung lässt es aus', (
    tester,
  ) async {
    final notif = FakeNotificationBackend(grant: false);
    await tester.pumpWidget(
      await buildApp(notifications: notif, initial: _startNow()),
    );
    await tester.pump();

    await _openSettings(tester);
    await _tapVisible(tester, find.text('Benachrichtigungen'));

    expect(notif.current, isEmpty);
    expect(
      find.text('Benachrichtigungen sind in den Systemeinstellungen blockiert.'),
      findsOneWidget,
    );
  });

  testWidgets('Einstellungen: Free öffnet die Paywall', (tester) async {
    final notif = FakeNotificationBackend();
    await tester.pumpWidget(await buildApp(pro: false, notifications: notif));
    await tester.pump();

    await _openSettings(tester);
    await _tapVisible(tester, find.text('Benachrichtigungen'));

    expect(notif.permissionRequests, 0);
    expect(find.text('Einmal zahlen. Für immer frei.'), findsOneWidget);
  });
}
