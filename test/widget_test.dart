import 'package:feierabend_rechner/app.dart';
import 'package:feierabend_rechner/features/home/state/home_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Baut die App mit gemockter Persistenz (leere Voreinstellungen).
Future<Widget> buildApp([Map<String, Object> initial = const {}]) async {
  SharedPreferences.setMockInitialValues(initial);
  final prefs = await SharedPreferences.getInstance();
  return ProviderScope(
    overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
    child: const FeierabendApp(),
  );
}

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
    await tester.pumpWidget(await buildApp({'berufsgruppe': 'IT'}));
    await tester.pump();

    expect(find.text('IT'), findsOneWidget);
  });

  testWidgets('Einstellungen-Overlay bietet Theme-Wahl', (tester) async {
    await tester.pumpWidget(await buildApp());
    await tester.pump();

    await tester.tap(find.byIcon(Icons.tune_rounded));
    await tester.pumpAndSettle();

    expect(find.text('Einstellungen'), findsOneWidget);
    expect(find.text('System'), findsOneWidget);
    expect(find.text('Hell'), findsOneWidget);
    expect(find.text('Dunkel'), findsOneWidget);
  });
}
