import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../test_helpers.dart';

void main() {
  testWidgets('Pro: Widget bekommt Feierabend-Zeit und Pro-Status', (
    tester,
  ) async {
    final widgets = FakeWidgetBackend();
    await tester.pumpWidget(
      await buildApp(widgets: widgets, initial: {'start_minutes': 6 * 60 + 44}),
    );
    await tester.pump();

    expect(widgets.updates, isNotEmpty);
    final s = widgets.updates.last;
    expect(s.endLabel, '15:29');
    expect(s.start.hour, 6);
    expect(s.start.minute, 44);
    expect(s.proUntilMillis, -1);
  });

  testWidgets('Free: Widget zeigt Zeit, aber ohne Pro', (tester) async {
    final widgets = FakeWidgetBackend();
    await tester.pumpWidget(await buildApp(pro: false, widgets: widgets));
    await tester.pump();

    expect(widgets.updates.last.proUntilMillis, 0);
  });

  testWidgets('Einstellungen: „Widget hinzufügen" fragt den Launcher', (
    tester,
  ) async {
    final widgets = FakeWidgetBackend();
    await tester.pumpWidget(await buildApp(widgets: widgets));
    await tester.pump();

    await tester.tap(find.byIcon(Icons.settings_rounded));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Widget hinzufügen'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Widget hinzufügen'));
    await tester.pumpAndSettle();

    expect(widgets.pinRequests, 1);
    expect(find.textContaining('Lange auf den Startbildschirm'), findsNothing);
  });

  testWidgets('Einstellungen: ohne Anheften-Dialog kommt eine Anleitung', (
    tester,
  ) async {
    final widgets = FakeWidgetBackend(pinSupported: false);
    await tester.pumpWidget(await buildApp(widgets: widgets));
    await tester.pump();

    await tester.tap(find.byIcon(Icons.settings_rounded));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Widget hinzufügen'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Widget hinzufügen'));
    await tester.pumpAndSettle();

    expect(find.textContaining('Lange auf den Startbildschirm'), findsOneWidget);
  });

  testWidgets('Ohne Widget-Unterstützung kein Eintrag in den Einstellungen', (
    tester,
  ) async {
    await tester.pumpWidget(
      await buildApp(widgets: FakeWidgetBackend(supported: false)),
    );
    await tester.pump();

    await tester.tap(find.byIcon(Icons.settings_rounded));
    await tester.pumpAndSettle();
    expect(find.text('Widget hinzufügen'), findsNothing);
  });
}
