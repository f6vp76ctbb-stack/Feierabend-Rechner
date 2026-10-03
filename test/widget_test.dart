import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'test_helpers.dart';

void main() {
  testWidgets('Home zeigt Feierabend-Überschrift und Eingaben', (tester) async {
    await tester.pumpWidget(await buildApp());
    await tester.pump();

    expect(find.text('Feierabend'), findsOneWidget);
    expect(find.text('FEIERABEND UM'), findsOneWidget);
    expect(find.text('Start'), findsOneWidget);
    expect(find.text('Arbeitszeit'), findsOneWidget);
    expect(find.text('Pause'), findsOneWidget);
  });

  testWidgets('Englische Oberfläche', (tester) async {
    await tester.pumpWidget(await buildApp(locale: const Locale('en')));
    await tester.pump();

    expect(find.text('CLOCK-OUT AT'), findsOneWidget);
    expect(find.text('Work time'), findsOneWidget);
    expect(find.text('Break'), findsOneWidget);
    expect(find.text('General'), findsOneWidget); // Berufsgruppe übersetzt
  });

  testWidgets('Pause-Zeile öffnet das Einstell-Overlay', (tester) async {
    await tester.pumpWidget(await buildApp());
    await tester.pump();

    await tester.ensureVisible(find.text('Pause'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Pause'));
    await tester.pumpAndSettle();

    expect(find.text('Übernehmen'), findsOneWidget);
  });

  testWidgets('Startzeit-Overlay zeigt ▲▼-Stepper und „Jetzt"', (tester) async {
    await tester.pumpWidget(await buildApp());
    await tester.pump();

    await tester.ensureVisible(find.text('Start'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Start'));
    await tester.pumpAndSettle();

    expect(find.text('Stunde'), findsOneWidget);
    expect(find.text('Minute'), findsOneWidget);
    expect(find.text('Jetzt'), findsOneWidget);
    expect(find.byIcon(Icons.keyboard_arrow_up_rounded), findsNWidgets(2));
    expect(find.byIcon(Icons.keyboard_arrow_down_rounded), findsNWidgets(2));
  });

  testWidgets('Sprüche-Karte zeigt Berufsgruppe „Allgemein"', (tester) async {
    await tester.pumpWidget(await buildApp());
    await tester.pump();

    expect(find.text('Allgemein'), findsOneWidget);
    expect(find.text('neuer Spruch'), findsOneWidget);
  });

  testWidgets('Gespeicherte Berufsgruppe wird beim Start geladen', (tester) async {
    await tester.pumpWidget(await buildApp(initial: {'berufsgruppe': 'IT'}));
    await tester.pump();

    expect(find.text('IT'), findsOneWidget);
  });

  testWidgets('Profil-Leiste zeigt „Standard" und öffnet die Verwaltung',
      (tester) async {
    await tester.pumpWidget(await buildApp());
    await tester.pump();

    expect(find.text('Standard'), findsOneWidget);

    await tester.tap(find.text('Profile'));
    await tester.pumpAndSettle();

    expect(find.text('Neues Profil'), findsOneWidget);
  });

  testWidgets('Pro: Überstunden-Karte öffnet das Konto', (tester) async {
    await tester.pumpWidget(await buildApp());
    await tester.pump();

    await tester.ensureVisible(find.text('Überstunden-Konto'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Überstunden-Konto'));
    await tester.pumpAndSettle();

    expect(find.text('GESAMTSALDO'), findsOneWidget);
    expect(find.text('Noch keine Einträge'), findsOneWidget);
  });

  testWidgets('Free: Überstunden-Karte öffnet die Paywall', (tester) async {
    await tester.pumpWidget(await buildApp(pro: false));
    await tester.pump();

    await tester.ensureVisible(find.text('Überstunden-Konto'));
    await tester.pumpAndSettle();
    expect(find.text('PRO'), findsWidgets);
    await tester.tap(find.text('Überstunden-Konto'));
    await tester.pumpAndSettle();

    expect(find.text('Einmal zahlen. Für immer frei.'), findsOneWidget);
    expect(find.text('GESAMTSALDO'), findsNothing);
  });

  testWidgets('Free: Auto-Pause-Schalter öffnet die Paywall statt einzuschalten',
      (tester) async {
    await tester.pumpWidget(await buildApp(pro: false));
    await tester.pump();

    final toggle = find.byType(SwitchListTile);
    await tester.ensureVisible(toggle);
    await tester.pumpAndSettle();
    await tester.tap(toggle);
    await tester.pumpAndSettle();

    expect(find.text('Feierabend Pro'), findsOneWidget);
    expect(find.text('automatisch angepasst'), findsNothing);
  });

  testWidgets('Auto-Pause: ⓘ erklärt die Regeln, ohne umzuschalten', (tester) async {
    await tester.pumpWidget(await buildApp());
    await tester.pump();

    expect(find.text('Pause automatisch'), findsOneWidget);
    final info = find.byTooltip('Mehr Infos');
    await tester.ensureVisible(info);
    await tester.pumpAndSettle();
    await tester.tap(info);
    await tester.pumpAndSettle();

    expect(find.text('So funktioniert die automatische Pause'), findsOneWidget);
    expect(find.text('Bis 6 Std Arbeit'), findsOneWidget);
    expect(find.text('keine Pause'), findsOneWidget);
    expect(find.text('30 Min'), findsOneWidget);
    expect(find.text('45 Min'), findsOneWidget);
    // Schalter unverändert aus.
    final toggle =
        tester.widget<SwitchListTile>(find.byType(SwitchListTile).first);
    expect(toggle.value, isFalse);
  });

  testWidgets('Paywall zeigt Store-Preis und startet den Kauf', (tester) async {
    final store = FakePurchaseBackend();
    await tester.pumpWidget(await buildApp(pro: false, purchases: store));
    await tester.pump();

    await tester.ensureVisible(find.text('Überstunden-Konto'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Überstunden-Konto'));
    await tester.pumpAndSettle();

    final buy = find.text('Pro freischalten – 3,99 €');
    expect(buy, findsOneWidget);
    await tester.ensureVisible(buy);
    await tester.pumpAndSettle();
    await tester.tap(buy);
    await tester.pumpAndSettle();
    expect(store.buyCalls, 1);
  });

  testWidgets('Einstellungen-Overlay bietet Theme-Wahl', (tester) async {
    await tester.pumpWidget(await buildApp());
    await tester.pump();

    await tester.tap(find.byIcon(Icons.settings_rounded));
    await tester.pumpAndSettle();

    expect(find.text('Einstellungen'), findsOneWidget);
    expect(find.text('System'), findsOneWidget);
    expect(find.text('Hell'), findsOneWidget);
    expect(find.text('Dunkel'), findsOneWidget);
  });
}
