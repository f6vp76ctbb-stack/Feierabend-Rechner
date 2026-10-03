import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/l10n_ext.dart';
import '../onboarding/onboarding_screen.dart';
import 'analytics_providers.dart';

/// Einmalige Frage nach der Nutzungsstatistik. „Ja“ und „Nein“ gleichwertig;
/// Wegwischen zählt als „Nein“ (später in den Einstellungen änderbar).
class AnalyticsConsentSheet extends ConsumerWidget {
  const AnalyticsConsentSheet({super.key});

  static Future<void> show(BuildContext context, WidgetRef ref) async {
    final ctrl = ref.read(analyticsConsentProvider.notifier);
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) => const AnalyticsConsentSheet(),
    );
    ctrl.dismissed();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l = context.l10n;

    void answer(bool yes) {
      HapticFeedback.selectionClick();
      ref.read(analyticsConsentProvider.notifier).set(yes);
      Navigator.of(context).pop();
    }

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Icon(Icons.insights_rounded,
                size: 40, color: theme.colorScheme.primary),
            const SizedBox(height: 12),
            Text(l.analyticsAskTitle, style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(l.analyticsAskBody, style: theme.textTheme.bodyMedium),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => answer(false),
                    child: Text(l.analyticsNo),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    onPressed: () => answer(true),
                    child: Text(l.analyticsYes),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Fragt beim ersten Start NACH der Einführung (nicht in derselben Sitzung –
/// dort kommt ggf. schon die Werbe-Einwilligung) einmal nach der Statistik.
class AnalyticsConsentGate extends ConsumerStatefulWidget {
  const AnalyticsConsentGate({super.key, required this.child});

  final Widget child;

  /// Wartezeit, damit die App erst sichtbar ist (Tests setzen sie auf null).
  static Duration delay = const Duration(seconds: 3);

  @override
  ConsumerState<AnalyticsConsentGate> createState() =>
      _AnalyticsConsentGateState();
}

class _AnalyticsConsentGateState extends ConsumerState<AnalyticsConsentGate> {
  @override
  void initState() {
    super.initState();
    final ask = ref.read(analyticsBackendProvider).isSupported &&
        ref.read(analyticsConsentProvider) == null &&
        !ref.read(onboardingDoneProvider.notifier).finishedThisSession;
    if (ask) {
      Future.delayed(AnalyticsConsentGate.delay, () {
        if (!mounted || ref.read(analyticsConsentProvider) != null) return;
        AnalyticsConsentSheet.show(context, ref);
      });
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
