import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/models/widget_snapshot.dart';
import '../../services/widget_backend.dart';
import '../home/state/home_providers.dart';
import '../pro/pro_providers.dart';

/// Home-Screen-Widget gibt es (vorerst) nur auf Android.
final widgetBackendProvider = Provider<WidgetBackend>(
  (ref) => !kIsWeb && defaultTargetPlatform == TargetPlatform.android
      ? AndroidWidgetBackend()
      : NoopWidgetBackend(),
);

/// Aktueller Widget-Stand. Ändert sich nur bei Startzeit, Arbeitszeit,
/// Pause oder Pro-Status – nicht im Sekundentakt.
final widgetSnapshotProvider = Provider<WidgetSnapshot>((ref) {
  final start = ref.watch(startTimeProvider);
  final end = ref.watch(feierabendDateTimeProvider);
  final pro = ref.watch(proControllerProvider);
  final now = DateTime.now();
  return WidgetSnapshot(
    start: DateTime(now.year, now.month, now.day, start.hour, start.minute),
    end: end,
    proForever: pro.purchased,
    proUntil: pro.isTrialActive(now) ? pro.trialUntil : null,
  );
});
