import 'package:feierabend_rechner/features/analytics/analytics_consent.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../test_helpers.dart';

Future<void> _openPaywall(WidgetTester tester) async {
  await tester.ensureVisible(find.text('Überstunden-Konto'));
  await tester.pumpAndSettle();
  await tester.tap(find.text('Überstunden-Konto'));
  await tester.pumpAndSettle();
}

void main() {
  setUp(() => AnalyticsConsentGate.delay = Duration.zero);

  testWidgets('Frage erscheint einmal; „Ja“ schaltet die Statistik ein', (
    tester,
  ) async {
    final analytics = FakeAnalyticsBackend();
    await tester.pumpWidget(
        await buildApp(pro: false, analytics: analytics));
    await tester.pumpAndSettle();

    expect(find.text('Darf die App mitzählen?'), findsOneWidget);
    await tester.tap(find.text('Ja, gern'));
    await tester.pumpAndSettle();

    expect(analytics.enabled, isTrue);
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getBool('analytics_consent'), isTrue);

    await _openPaywall(tester);
    expect(analytics.events, contains('paywall_view'));
  });

  testWidgets('„Nein“: nichts wird erfasst, Frage kommt nicht wieder', (
    tester,
  ) async {
    final analytics = FakeAnalyticsBackend();
    await tester.pumpWidget(
        await buildApp(pro: false, analytics: analytics));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Nein danke'));
    await tester.pumpAndSettle();

    await _openPaywall(tester);
    expect(analytics.enabled, isFalse);
    expect(analytics.events, isEmpty);
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getBool('analytics_consent'), isFalse);
  });

  testWidgets('Keine Frage direkt nach der Einführung', (tester) async {
    await tester.pumpWidget(await buildApp(
        onboarding: true, analytics: FakeAnalyticsBackend()));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Überspringen'));
    await tester.pumpAndSettle();

    expect(find.text('Darf die App mitzählen?'), findsNothing);
  });

  testWidgets('Einstellungen: Schalter ändert die Einwilligung', (
    tester,
  ) async {
    final analytics = FakeAnalyticsBackend();
    await tester.pumpWidget(await buildApp(
        analytics: analytics, initial: {'analytics_consent': false}));
    await tester.pumpAndSettle();
    expect(find.text('Darf die App mitzählen?'), findsNothing);

    await tester.tap(find.byIcon(Icons.settings_rounded));
    await tester.pumpAndSettle();
    final toggle = find.text('Nutzungsstatistik teilen');
    await tester.ensureVisible(toggle);
    await tester.pumpAndSettle();
    await tester.tap(toggle);
    await tester.pumpAndSettle();

    expect(analytics.enabled, isTrue);
  });

  testWidgets('Ohne Firebase-Konfiguration: keine Frage, kein Schalter', (
    tester,
  ) async {
    await tester.pumpWidget(await buildApp());
    await tester.pumpAndSettle();
    expect(find.text('Darf die App mitzählen?'), findsNothing);

    await tester.tap(find.byIcon(Icons.settings_rounded));
    await tester.pumpAndSettle();
    expect(find.text('Nutzungsstatistik teilen'), findsNothing);
  });
}
