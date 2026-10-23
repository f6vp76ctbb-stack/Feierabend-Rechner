import 'dart:io';

import 'package:feierabend_rechner/config/app_info.dart';
import 'package:feierabend_rechner/features/legal/licenses.dart';
import 'package:feierabend_rechner/features/startup/startup_prompts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../test_helpers.dart';

Future<void> _openSettingsTile(WidgetTester tester, String title) async {
  await tester.tap(find.byIcon(Icons.settings_rounded));
  await tester.pumpAndSettle();
  await tester.ensureVisible(find.text(title));
  await tester.pumpAndSettle();
  await tester.tap(find.text(title));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('Impressum in der App: Anbieter, Anschrift, Kontakt, Streitschlichtung',
      (tester) async {
    await tester.pumpWidget(await buildApp());
    await tester.pumpAndSettle();
    await _openSettingsTile(tester, 'Impressum');

    expect(find.text('Angaben gemäß § 5 DDG'), findsOneWidget);
    // Einzelunternehmen: voller Name Pflicht, „Thinkube“ nur Geschäftsbezeichnung.
    expect(
      find.text('Sam Däubler\nThinkube\nMähderweg 5\n88451 Dettingen\nDeutschland'),
      findsOneWidget,
    );
    expect(find.text('Sam Däubler, Anschrift wie oben.'), findsOneWidget);
    expect(find.text('thinkube@outlook.de'), findsOneWidget);
    expect(find.textContaining('nicht bereit, an einem Streitbeilegungsverfahren'),
        findsOneWidget);
    // Kein Link auf die abgeschaltete EU-OS-Plattform (seit 20.07.2025 abmahnfähig).
    expect(find.textContaining('ec.europa.eu/consumers/odr'), findsNothing);
  });

  testWidgets('Impressum auf Englisch', (tester) async {
    await tester.pumpWidget(await buildApp(locale: const Locale('en')));
    await tester.pumpAndSettle();
    await _openSettingsTile(tester, 'Legal notice');
    expect(find.text('Information pursuant to § 5 DDG (Germany)'), findsOneWidget);
    expect(
      find.text('Sam Däubler\nThinkube\nMähderweg 5\n88451 Dettingen\nGermany'),
      findsOneWidget,
    );
  });

  test('Web-Impressum und Datenschutzerklärung nennen dieselben Anbieterdaten', () {
    for (final page in ['web/impressum.html', 'web/privacy.html']) {
      final html = File(page).readAsStringSync();
      for (final value in [
        AppInfo.providerName,
        AppInfo.businessName,
        AppInfo.providerStreet,
        AppInfo.providerCity,
        AppInfo.contactEmail,
      ]) {
        expect(html, contains(value), reason: '$page: $value');
      }
    }
  });

  testWidgets('Open-Source-Lizenzen enthalten die Schrift Inter (OFL)', (
    tester,
  ) async {
    registerExtraLicenses();
    await tester.pumpWidget(await buildApp());
    await tester.pumpAndSettle();
    await _openSettingsTile(tester, 'Open-Source-Lizenzen');
    // Die Lizenzliste wird asynchron (Asset) geladen.
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 300)));
    await tester.pumpAndSettle();
    expect(find.text('Inter (font)'), findsOneWidget);
  });

  testWidgets('Statistik-Frage nennt Anbieter, USA-Übermittlung und Datenschutz',
      (tester) async {
    StartupPrompts.consentDelay = Duration.zero;
    await tester.pumpWidget(await buildApp(analytics: FakeAnalyticsBackend()));
    await tester.pumpAndSettle();

    expect(find.text('Darf die App mitzählen?'), findsOneWidget);
    expect(find.textContaining('Google Ireland'), findsOneWidget);
    expect(find.textContaining('USA'), findsOneWidget);
    expect(find.text('Datenschutzerklärung'), findsOneWidget);
  });
}
