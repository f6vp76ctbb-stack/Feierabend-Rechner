import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/review_policy.dart';
import '../analytics/analytics_consent.dart';
import '../analytics/analytics_providers.dart';
import '../feedback/feedback_section.dart';
import '../home/state/home_providers.dart';
import '../onboarding/onboarding_screen.dart';
import '../tips/tips.dart';

/// Alles, was die App von sich aus zeigt – höchstens eins pro Start, in dieser
/// Reihenfolge, damit sich nichts stapelt:
/// 1. Tipps auf dem Hauptbildschirm (nach der Einführung bzw. auf Wunsch),
/// 2. Frage nach der Nutzungsstatistik (frühestens in der nächsten Sitzung),
/// 3. Bitte um eine Bewertung (einmal, ab dem 4. Nutzungstag).
/// Die Werbe-Einwilligung kommt erst nach den Tipps (siehe `app.dart`).
class StartupPrompts extends ConsumerStatefulWidget {
  const StartupPrompts({super.key, required this.child});

  final Widget child;

  /// Wartezeiten, damit die App erst sichtbar ist (Tests setzen sie auf null).
  static Duration consentDelay = const Duration(seconds: 3);
  static Duration reviewDelay = const Duration(seconds: 5);

  @override
  ConsumerState<StartupPrompts> createState() => _StartupPromptsState();
}

class _StartupPromptsState extends ConsumerState<StartupPrompts> {
  bool _tipsShowing = false;

  @override
  void initState() {
    super.initState();
    final repo = ref.read(settingsRepositoryProvider);
    final usage = repo.loadUsageDays().record(DateTime.now());
    repo.saveUsageDays(usage);

    if (!ref.read(tipsDoneProvider)) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _showTips());
      return; // Rest frühestens beim nächsten Start
    }
    final firstSession =
        ref.read(onboardingDoneProvider.notifier).finishedThisSession;
    if (firstSession) return;

    final consentOpen = ref.read(analyticsBackendProvider).isSupported &&
        ref.read(analyticsConsentProvider) == null;
    if (consentOpen) {
      Future.delayed(StartupPrompts.consentDelay, () {
        if (!mounted || ref.read(analyticsConsentProvider) != null) return;
        AnalyticsConsentSheet.show(context, ref);
      });
    } else if (ReviewPolicy.shouldAsk(
        usage: usage, alreadyAsked: repo.loadReviewAsked())) {
      Future.delayed(StartupPrompts.reviewDelay, () {
        if (!mounted) return;
        repo.saveReviewAsked();
        ref.read(analyticsProvider).log('review_prompt');
        ref.read(feedbackBackendProvider).requestReview();
      });
    }
  }

  Future<void> _showTips() async {
    if (!mounted || _tipsShowing || ref.read(tipsDoneProvider)) return;
    _tipsShowing = true;
    await showTips(context, ref);
    _tipsShowing = false;
  }

  @override
  Widget build(BuildContext context) {
    // „Tipps erneut zeigen“ aus den Einstellungen.
    ref.listen<bool>(tipsDoneProvider, (_, done) {
      if (!done) {
        WidgetsBinding.instance.addPostFrameCallback((_) => _showTips());
      }
    });
    return widget.child;
  }
}
