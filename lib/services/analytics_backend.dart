import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

import '../config/firebase_config.dart';

/// Nutzungsstatistik. Ohne Einwilligung wird nichts erfasst – Firebase wird dann
/// nicht einmal gestartet. In Tests/Web per Override bzw. Noop ersetzt.
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
      await Firebase.initializeApp(options: FirebaseConfig.options);
      return FirebaseAnalytics.instance;
    } catch (e) {
      debugPrint('Analytics nicht verfügbar: $e');
      return null;
    }
  }

  @override
  Future<void> setEnabled(bool enabled) async {
    _enabled = enabled;
    // Ohne Einwilligung Firebase gar nicht erst starten. War es schon an,
    // schaltet das die (vom SDK gemerkte) Erfassung wieder ab.
    if (!enabled && _instance == null) return;
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
