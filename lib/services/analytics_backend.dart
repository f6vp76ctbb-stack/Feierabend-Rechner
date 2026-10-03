import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

import '../config/firebase_config.dart';

/// Nutzungsstatistik. Ohne Einwilligung wird nichts erfasst oder gesendet (Erfassung
/// per Manifest aus, die App schaltet sie erst nach „Ja“ ein). In Tests/Web: Noop/Fake.
abstract class AnalyticsBackend {
  /// Gibt es überhaupt eine Statistik (Firebase konfiguriert, mobile App)?
  bool get isSupported;

  /// Erfassung an/aus (folgt der Einwilligung).
  Future<void> setEnabled(bool enabled);

  /// Ereignis protokollieren – nur wirksam, wenn eingeschaltet.
  Future<void> log(String name, [Map<String, Object>? params]);
}

class NoopAnalyticsBackend implements AnalyticsBackend {
  @override
  bool get isSupported => false;
  @override
  Future<void> setEnabled(bool enabled) async {}
  @override
  Future<void> log(String name, [Map<String, Object>? params]) async {}
}

class FirebaseAnalyticsBackend implements AnalyticsBackend {
  Future<FirebaseAnalytics?>? _instance;
  bool _enabled = false;

  @override
  bool get isSupported => true;

  Future<FirebaseAnalytics?> _get() => _instance ??= _start();

  Future<FirebaseAnalytics?> _start() async {
    try {
      try {
        await Firebase.initializeApp(options: FirebaseConfig.options);
      } on FirebaseException catch (e) {
        // Android startet die Standard-App schon selbst (Ressourcen im Build).
        if (e.code != 'duplicate-app') rethrow;
      }
      return FirebaseAnalytics.instance;
    } catch (e) {
      debugPrint('Analytics nicht verfügbar: $e');
      return null;
    }
  }

  @override
  Future<void> setEnabled(bool enabled) async {
    _enabled = enabled;
    // Immer ans SDK weitergeben – es merkt sich die Einstellung über Neustarts
    // hinweg, ein „Aus“ muss es also auch in einer späteren Sitzung erreichen.
    try {
      await (await _get())?.setAnalyticsCollectionEnabled(enabled);
    } catch (e) {
      debugPrint('Analytics: $e');
    }
  }

  @override
  Future<void> log(String name, [Map<String, Object>? params]) async {
    if (!_enabled) return;
    try {
      await (await _get())?.logEvent(name: name, parameters: params);
    } catch (e) {
      debugPrint('Analytics: $e');
    }
  }
}
