import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../test_helpers.dart';

void main() {
  testWidgets('Erster Start zeigt die Einführung, Überspringen führt zur App', (
    tester,
  ) async {
    await tester.pumpWidget(await buildApp(onboarding: true));
    await tester.pumpAndSettle();

    expect(find.text('Wann ist Feierabend?'), findsOneWidget);
    expect(find.text('FEIERABEND UM'), findsNothing);

    await tester.tap(find.text('Überspringen'));
    await tester.pumpAndSettle();

    expect(find.text('Wann ist Feierabend?'), findsNothing);
    expect(find.text('FEIERABEND UM'), findsOneWidget);
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getBool('onboarding_done'), isTrue);
  });

  testWidgets('Durchklicken: Arbeitszeit und Pause werden übernommen', (
    tester,
  ) async {
    await tester.pumpWidget(await buildApp(onboarding: true));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Weiter'));
    await tester.pumpAndSettle();
    expect(find.text('Dein Arbeitstag'), findsOneWidget);

    await tester.tap(find.text('7 Std'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('30 Min'));
    await tester.tap(find.text('30 Min'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Weiter'));
    await tester.pumpAndSettle();
    expect(find.text('Noch mehr mit Pro'), findsOneWidget);
    final skip = tester.widget<TextButton>(find.ancestor(
      of: find.text('Überspringen'),
      matching: find.byType(TextButton),
    ));
    expect(skip.onPressed, isNull); // letzte Seite: nur noch „Los geht's"

    await tester.tap(find.text("Los geht's"));
    await tester.pumpAndSettle();

    expect(find.text('FEIERABEND UM'), findsOneWidget);
    final prefs = await SharedPreferences.getInstance();
    final profiles = jsonDecode(prefs.getString('profiles_v1')!) as Map;
    final config = (profiles['profiles'] as List).first['config'] as Map;
    expect(config['work'], 420);
    expect(config['break'], 30);
    expect(prefs.getInt('daily_target_minutes'), 420);
  });

  testWidgets('Free: „Pro ansehen" öffnet die Paywall', (tester) async {
    await tester.pumpWidget(await buildApp(onboarding: true, pro: false));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Weiter'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Weiter'));
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('Pro ansehen'));
    await tester.tap(find.text('Pro ansehen'));
    await tester.pumpAndSettle();
    expect(find.text('Einmal zahlen. Für immer frei.'), findsOneWidget);
  });

  testWidgets('Pro: statt Kauf-Hinweis „alles freigeschaltet"', (tester) async {
    await tester.pumpWidget(await buildApp(onboarding: true));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Weiter'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Weiter'));
    await tester.pumpAndSettle();

    expect(find.text('Pro ist aktiv – alles freigeschaltet.'), findsOneWidget);
    expect(find.text('Pro ansehen'), findsNothing);
  });
}
