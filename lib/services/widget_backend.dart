import 'package:flutter/services.dart';

import '../domain/models/widget_snapshot.dart';

/// Abstraktion über das Home-Screen-Widget (Tests/Web/iOS: Noop).
abstract class WidgetBackend {
  bool get isSupported;

  /// Überträgt den aktuellen Stand ans Widget und zeichnet es neu.
  Future<void> update(WidgetSnapshot snapshot);

  /// Bittet den Launcher, das Widget auf dem Startbildschirm abzulegen.
  /// `false`, wenn der Launcher das nicht unterstützt.
  Future<bool> requestPin();
}

class NoopWidgetBackend implements WidgetBackend {
  @override
  bool get isSupported => false;
  @override
  Future<void> update(WidgetSnapshot snapshot) async {}
  @override
  Future<bool> requestPin() async => false;
}

/// Natives Android-Widget (`FeierabendWidgetProvider.kt`) über einen MethodChannel.
///
/// Bewusst ohne Zusatz-Paket: RemoteViews + Chronometer tickt den Countdown
/// selbst, die App liefert nur Zeitpunkte.
class AndroidWidgetBackend implements WidgetBackend {
  static const _channel =
      MethodChannel('com.thinkube.feierabendrechner/widget');

  @override
  bool get isSupported => true;

  @override
  Future<void> update(WidgetSnapshot snapshot) async {
    try {
      await _channel.invokeMethod<bool>('update', snapshot.toMap());
    } catch (_) {
      // Widget ist ein Komfort-Feature – nie die App stören.
    }
  }

  @override
  Future<bool> requestPin() async {
    try {
      return await _channel.invokeMethod<bool>('requestPin') ?? false;
    } catch (_) {
      return false;
    }
  }
}
