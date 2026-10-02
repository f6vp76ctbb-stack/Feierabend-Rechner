import 'package:feierabend_rechner/domain/reminder_planner.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../test_helpers.dart';

/// Startzeit = jetzt → Feierabend liegt sicher in der Zukunft.
Map<String, Object> _startNow() {
  final n = DateTime.now();
  return {'start_minutes': n.hour * 60 + n.minute};
}

void main() {
  testWidgets('Pro + eingeschaltet: Vorwarnung und Feierabend werden geplant', (
    tester,
  ) async {
    final notif = FakeNotificationBackend();
    await tester.pumpWidget(
      await buildApp(
        notifications: notif,
        initial: {
          ..._startNow(),
          'reminders_enabled': true,
          'reminder_lead_minutes': 30,
        },
      ),
    );
    await tester.pump();

    expect(notif.current.map((r) => r.kind), [
      ReminderKind.before,
      ReminderKind.end,
    ]);
    expect(notif.lastTexts!.beforeBody, 'Noch 30 Min – dann bist du frei.');
    expect(notif.lastTexts!.endTitle, 'Feierabend! 🎉');
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

  testWidgets('Einstellungen: Pro schaltet ein (mit Berechtigung)', (
    tester,
  ) async {
    final notif = FakeNotificationBackend();
    await tester.pumpWidget(
      await buildApp(notifications: notif, initial: _startNow()),
    );
    await tester.pump();
    expect(notif.current, isEmpty);

    await tester.tap(find.byIcon(Icons.settings_rounded));
    await tester.pumpAndSettle();
    expect(find.text('Erinnerungen'), findsOneWidget);

    await tester.tap(find.text('Benachrichtigungen'));
    await tester.pumpAndSettle();

    expect(notif.permissionRequests, 1);
    expect(notif.current, isNotEmpty);
    expect(find.text('Vorwarnung'), findsOneWidget);
  });

  testWidgets('Einstellungen: verweigerte Berechtigung lässt es aus', (
    tester,
  ) async {
    final notif = FakeNotificationBackend(grant: false);
    await tester.pumpWidget(
      await buildApp(notifications: notif, initial: _startNow()),
    );
    await tester.pump();

    await tester.tap(find.byIcon(Icons.settings_rounded));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Benachrichtigungen'));
    await tester.pumpAndSettle();

    expect(notif.current, isEmpty);
    expect(
      find.text(
        'Benachrichtigungen sind in den Systemeinstellungen blockiert.',
      ),
      findsOneWidget,
    );
  });

  testWidgets('Einstellungen: Free öffnet die Paywall', (tester) async {
    final notif = FakeNotificationBackend();
    await tester.pumpWidget(await buildApp(pro: false, notifications: notif));
    await tester.pump();

    await tester.tap(find.byIcon(Icons.settings_rounded));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Benachrichtigungen'));
    await tester.pumpAndSettle();

    expect(notif.permissionRequests, 0);
    expect(find.text('Einmal zahlen. Für immer frei.'), findsOneWidget);
  });
}
