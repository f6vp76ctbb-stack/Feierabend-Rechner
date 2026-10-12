import 'package:feierabend_rechner/domain/review_policy.dart';
import 'package:feierabend_rechner/features/startup/startup_prompts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../test_helpers.dart';

Future<void> _openSettings(WidgetTester tester) async {
  await tester.tap(find.byIcon(Icons.settings_rounded));
  await tester.pumpAndSettle();
}

Future<void> _tapInSettings(WidgetTester tester, String text) async {
  await tester.ensureVisible(find.text(text));
  await tester.pumpAndSettle();
  await tester.tap(find.text(text));
  await tester.pumpAndSettle();
}

String _yesterday() =>
    UsageDays.dayKey(DateTime.now().subtract(const Duration(days: 1)));

void main() {
  setUp(() {
    StartupPrompts.consentDelay = Duration.zero;
    StartupPrompts.reviewDelay = Duration.zero;
  });

  group('Tipps', () {
    testWidgets('nach der Einführung: 4 Schritte durchtippen', (tester) async {
      await tester.pumpWidget(await buildApp(onboarding: true));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Überspringen')); // Einführung
      await tester.pumpAndSettle();

      expect(find.text('Dein Feierabend auf einen Blick'), findsOneWidget);
      expect(find.text('1 von 4'), findsOneWidget);
      for (final (n, title) in [
        (2, 'Alles anpassbar'),
        (3, 'Ein Tipp für typische Tage – z. B. „6 Std ohne Pause“.'),
        (4, 'Noch mehr drin'),
      ]) {
        await tester.tap(find.text('Weiter'));
        await tester.pumpAndSettle();
        expect(find.text('$n von 4'), findsOneWidget);
        expect(find.text(title), findsOneWidget);
      }
      expect(find.text('Überspringen'), findsNothing); // letzter Schritt
      await tester.tap(find.text('Alles klar'));
      await tester.pumpAndSettle();

      expect(find.text('Noch mehr drin'), findsNothing);
      // Danach wieder oben: Kopfzeile mit Einstellungen sichtbar.
      expect(tester.getTopLeft(find.byIcon(Icons.settings_rounded)).dy,
          lessThan(100));
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool('tips_done'), isTrue);
    });

    testWidgets('überspringen beendet sofort', (tester) async {
      final analytics = FakeAnalyticsBackend()..enabled = true;
      await tester.pumpWidget(await buildApp(tips: true, analytics: analytics));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Weiter'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Überspringen'));
      await tester.pumpAndSettle();
      expect(find.text('Alles anpassbar'), findsNothing);
      expect(tester.getTopLeft(find.byIcon(Icons.settings_rounded)).dy,
          lessThan(100));
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool('tips_done'), isTrue);
    });

    testWidgets('„Tipps erneut zeigen“ in den Einstellungen', (tester) async {
      await tester.pumpWidget(await buildApp());
      await tester.pumpAndSettle();
      expect(find.text('Dein Feierabend auf einen Blick'), findsNothing);

      await _openSettings(tester);
      await _tapInSettings(tester, 'Tipps erneut zeigen');
      expect(find.text('Dein Feierabend auf einen Blick'), findsOneWidget);
    });

    testWidgets('während der Tipps keine Statistik-Frage', (tester) async {
      await tester.pumpWidget(await buildApp(
          tips: true, analytics: FakeAnalyticsBackend()));
      await tester.pumpAndSettle();
      expect(find.text('Dein Feierabend auf einen Blick'), findsOneWidget);
      expect(find.text('Darf die App mitzählen?'), findsNothing);
    });
  });

  group('Feedback & Weiterempfehlen', () {
    testWidgets('bewerten, teilen, Feedback per E-Mail', (tester) async {
      final feedback = FakeFeedbackBackend();
      await tester.pumpWidget(await buildApp(feedback: feedback));
      await tester.pumpAndSettle();

      await _openSettings(tester);
      await _tapInSettings(tester, 'App bewerten');
      expect(feedback.storeOpens, 1);

      await _tapInSettings(tester, 'App weiterempfehlen');
      expect(feedback.shared.single,
          contains('play.google.com/store/apps/details?id=com.thinkube.feierabendrechner'));

      await _tapInSettings(tester, 'Feedback senden');
      expect(feedback.mails.single, startsWith('Feedback zu Feierabend Rechner'));
      expect(feedback.mails.single, contains('App-Version: 1.0.0'));
    });

    testWidgets('ohne E-Mail-App: Adresse als Hinweis', (tester) async {
      await tester.pumpWidget(
          await buildApp(feedback: FakeFeedbackBackend(mailApp: false)));
      await tester.pumpAndSettle();

      await _openSettings(tester);
      await _tapInSettings(tester, 'Feedback senden');
      expect(find.textContaining('thinkube@outlook.de'), findsOneWidget);
    });
  });

  group('Bewertungs-Bitte', () {
    testWidgets('am 4. Nutzungstag einmal', (tester) async {
      final feedback = FakeFeedbackBackend();
      await tester.pumpWidget(await buildApp(feedback: feedback, initial: {
        'usage_days': 3,
        'usage_last_day': _yesterday(),
      }));
      await tester.pumpAndSettle();

      expect(feedback.reviewRequests, 1);
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getInt('usage_days'), 4);
      expect(prefs.getBool('review_asked'), isTrue);
    });

    testWidgets('nicht vor dem 4. Tag und nicht ein zweites Mal', (
      tester,
    ) async {
      final feedback = FakeFeedbackBackend();
      await tester.pumpWidget(await buildApp(feedback: feedback, initial: {
        'usage_days': 2,
        'usage_last_day': _yesterday(),
      }));
      await tester.pumpAndSettle();
      expect(feedback.reviewRequests, 0);

      final again = FakeFeedbackBackend();
      await tester.pumpWidget(await buildApp(feedback: again, initial: {
        'usage_days': 9,
        'usage_last_day': _yesterday(),
        'review_asked': true,
      }));
      await tester.pumpAndSettle();
      expect(again.reviewRequests, 0);
    });

    testWidgets('offene Statistik-Frage hat Vorrang', (tester) async {
      final feedback = FakeFeedbackBackend();
      await tester.pumpWidget(await buildApp(
        feedback: feedback,
        analytics: FakeAnalyticsBackend(),
        initial: {'usage_days': 5, 'usage_last_day': _yesterday()},
      ));
      await tester.pumpAndSettle();

      expect(find.text('Darf die App mitzählen?'), findsOneWidget);
      expect(feedback.reviewRequests, 0);
    });
  });
}
