import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../config/firebase_config.dart';
import '../../config/monetization_config.dart';
import '../../services/analytics_backend.dart';
import '../home/state/home_providers.dart';

/// Statistik-Anbindung. Nur in der mobilen App und mit Firebase-Konfiguration.
final analyticsBackendProvider = Provider<AnalyticsBackend>(
  (ref) => MonetizationConfig.isMobile && FirebaseConfig.isConfigured
      ? FirebaseAnalyticsBackend()
      : NoopAnalyticsBackend(),
);

/// Einwilligung in die Nutzungsstatistik: `null` = noch nicht gefragt.
class AnalyticsConsentController extends Notifier<bool?> {
  @override
  bool? build() {
    final consent = ref.read(settingsRepositoryProvider).loadAnalyticsConsent();
    if (consent == true) {
      unawaited(ref.read(analyticsBackendProvider).setEnabled(true));
    }
    return consent;
  }

  void set(bool value) {
    state = value;
    ref.read(settingsRepositoryProvider).saveAnalyticsConsent(value);
    unawaited(ref.read(analyticsBackendProvider).setEnabled(value));
  }

  /// Frage weggewischt, ohne zu antworten → „Nein“ (nicht erneut nerven).
  void dismissed() {
    if (state == null) set(false);
  }
}

final analyticsConsentProvider =
    NotifierProvider<AnalyticsConsentController, bool?>(
        AnalyticsConsentController.new);

/// Ereignisse protokollieren – wirkt nur mit Einwilligung.
class Analytics {
  const Analytics(this._backend);

  final AnalyticsBackend _backend;

  void log(String name, [Map<String, Object>? params]) =>
      unawaited(_backend.log(name, params));
}

final analyticsProvider = Provider<Analytics>((ref) {
  ref.watch(analyticsConsentProvider); // lädt die Einwilligung → Backend an/aus
  return Analytics(ref.watch(analyticsBackendProvider));
});

/// Kurzform für Stellen ohne `ref` (z. B. statische `show`-Methoden).
void track(BuildContext context, String name, [Map<String, Object>? params]) =>
    ProviderScope.containerOf(context, listen: false)
        .read(analyticsProvider)
        .log(name, params);
