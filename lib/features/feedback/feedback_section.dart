import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../config/app_info.dart';
import '../../config/monetization_config.dart';
import '../../l10n/l10n_ext.dart';
import '../../services/feedback_backend.dart';
import '../analytics/analytics_providers.dart';
import '../tips/tips.dart';

/// Bewerten/Teilen/E-Mail. In Tests per Override ersetzbar.
final feedbackBackendProvider = Provider<FeedbackBackend>(
  (ref) => MonetizationConfig.isMobile
      ? DeviceFeedbackBackend()
      : NoopFeedbackBackend(),
);

/// Einstellungen: App bewerten, weiterempfehlen, Feedback senden, Tipps.
class FeedbackSection extends ConsumerWidget {
  const FeedbackSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l = context.l10n;
    final backend = ref.watch(feedbackBackendProvider);
    final analytics = ref.read(analyticsProvider);

    Widget tile(IconData icon, String title, String? hint, VoidCallback onTap) =>
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: Icon(icon),
          title: Text(title),
          subtitle: hint == null ? null : Text(hint),
          onTap: () {
            HapticFeedback.selectionClick();
            onTap();
          },
        );

    Future<void> mail() async {
      analytics.log('feedback_click');
      final messenger = ScaffoldMessenger.of(context);
      final sent = await backend.email(
        subject: l.feedbackSubject,
        body: l.feedbackBody(AppInfo.versionLabel),
      );
      if (!sent) {
        messenger.showSnackBar(SnackBar(
            content: Text(l.feedbackNoMail(AppInfo.contactEmail))));
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(l.feedbackSection, style: theme.textTheme.labelLarge),
        if (backend.isSupported) ...[
          tile(Icons.star_rounded, l.rateApp, l.rateAppHint, () {
            analytics.log('rate_click');
            backend.openStoreListing();
          }),
          tile(Icons.share_rounded, l.shareApp, l.shareAppHint, () {
            analytics.log('share_click');
            backend.share(l.shareText(AppInfo.playStoreUrl),
                subject: l.appTitle);
          }),
          tile(Icons.mail_outline_rounded, l.sendFeedback, l.sendFeedbackHint,
              mail),
        ],
        tile(Icons.lightbulb_outline_rounded, l.tipsReplay, null, () {
          // Einstellungen schließen – die Tipps erscheinen auf dem Hauptbildschirm.
          Navigator.of(context).pop();
          ref.read(tipsDoneProvider.notifier).replay();
        }),
      ],
    );
  }
}
