import 'package:flutter/foundation.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../config/app_info.dart';

/// Bewerten, Weiterempfehlen, Feedback – alles über Apps des Geräts
/// (Google Play, Teilen-Dialog, E-Mail). In Tests/Web per Noop ersetzt.
abstract class FeedbackBackend {
  bool get isSupported;

  /// Googles In-App-Bewertungsdialog (Google entscheidet, ob er erscheint).
  Future<void> requestReview();

  /// Store-Seite der App öffnen (für den „App bewerten“-Knopf).
  Future<void> openStoreListing();

  /// System-Teilen-Dialog mit Text (inkl. Link).
  Future<void> share(String text, {String? subject});

  /// E-Mail-App öffnen. `false`, wenn keine vorhanden ist.
  Future<bool> email({required String subject, required String body});
}

class NoopFeedbackBackend implements FeedbackBackend {
  @override
  bool get isSupported => false;
  @override
  Future<void> requestReview() async {}
  @override
  Future<void> openStoreListing() async {}
  @override
  Future<void> share(String text, {String? subject}) async {}
  @override
  Future<bool> email({required String subject, required String body}) async =>
      false;
}

class DeviceFeedbackBackend implements FeedbackBackend {
  final _review = InAppReview.instance;

  @override
  bool get isSupported => true;

  @override
  Future<void> requestReview() async {
    try {
      if (await _review.isAvailable()) await _review.requestReview();
    } catch (e) {
      debugPrint('Bewertung nicht möglich: $e');
    }
  }

  @override
  Future<void> openStoreListing() async {
    try {
      await _review.openStoreListing();
    } catch (_) {
      // Ohne Play-Store-App: die Store-Seite im Browser.
      await launchUrl(Uri.parse(AppInfo.playStoreUrl),
          mode: LaunchMode.externalApplication);
    }
  }

  @override
  Future<void> share(String text, {String? subject}) async {
    try {
      await SharePlus.instance.share(ShareParams(text: text, subject: subject));
    } catch (e) {
      debugPrint('Teilen nicht möglich: $e');
    }
  }

  @override
  Future<bool> email({required String subject, required String body}) async {
    final uri = Uri(
      scheme: 'mailto',
      path: AppInfo.contactEmail,
      // queryParameters würde Leerzeichen als „+“ kodieren – Mail-Apps zeigen das so an.
      query: 'subject=${Uri.encodeComponent(subject)}'
          '&body=${Uri.encodeComponent(body)}',
    );
    try {
      return await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      return false;
    }
  }
}
