import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../data/settings_repository.dart';
import '../../../data/sprueche.dart';
import '../../../domain/feierabend_calculator.dart';
import '../../../domain/models/feierabend_result.dart';
import '../../../domain/models/work_config.dart';

/// Wird in `main()` (und in Tests) mit einer echten Instanz überschrieben.
final sharedPreferencesProvider = Provider<SharedPreferences>(
  (ref) => throw UnimplementedError('sharedPreferencesProvider must be overridden'),
);

/// Zentrale Persistenz-Schicht.
final settingsRepositoryProvider = Provider<SettingsRepository>(
  (ref) => SettingsRepository(ref.watch(sharedPreferencesProvider)),
);

/// Die (zustandslose) Kern-Logik als Provider — leicht mockbar in Tests.
final calculatorProvider = Provider<FeierabendCalculator>(
  (ref) => const FeierabendCalculator(),
);

/// Startzeit (Wanduhr). Zuletzt genutzte Zeit, sonst aktuelle Uhrzeit.
class StartTimeNotifier extends Notifier<TimeOfDay> {
  @override
  TimeOfDay build() {
    final saved = ref.read(settingsRepositoryProvider).loadStartMinutes();
    if (saved != null) {
      return TimeOfDay(hour: saved ~/ 60, minute: saved % 60);
    }
    final now = DateTime.now();
    return TimeOfDay(hour: now.hour, minute: now.minute);
  }

  void set(TimeOfDay value) {
    state = value;
    ref
        .read(settingsRepositoryProvider)
        .saveStartMinutes(value.hour * 60 + value.minute);
  }

  void resetToNow() {
    final now = DateTime.now();
    set(TimeOfDay(hour: now.hour, minute: now.minute));
  }
}

final startTimeProvider =
    NotifierProvider<StartTimeNotifier, TimeOfDay>(StartTimeNotifier.new);

/// Arbeitszeit-/Pausen-Konfiguration (persistiert).
class WorkConfigNotifier extends Notifier<WorkConfig> {
  @override
  WorkConfig build() =>
      ref.read(settingsRepositoryProvider).loadWorkConfig() ?? const WorkConfig();

  void _persist() =>
      ref.read(settingsRepositoryProvider).saveWorkConfig(state);

  void setWork(Duration work) {
    state = state.copyWith(work: work);
    _persist();
  }

  void setBreak(Duration breakTime) {
    state = state.copyWith(breakTime: breakTime);
    _persist();
  }

  void setArbzgAuto(bool value) {
    state = state.copyWith(arbzgAutoBreak: value);
    _persist();
  }
}

final workConfigProvider =
    NotifierProvider<WorkConfigNotifier, WorkConfig>(WorkConfigNotifier.new);

/// Abgeleitetes Ergebnis (Uhrzeit-Darstellung, Mitternachts-Flag).
final resultProvider = Provider<FeierabendResult>((ref) {
  final calc = ref.watch(calculatorProvider);
  final start = ref.watch(startTimeProvider);
  final config = ref.watch(workConfigProvider);
  return calc.calculate(
    start: Duration(hours: start.hour, minutes: start.minute),
    config: config,
  );
});

/// Tickt jede Sekunde — Grundlage für den Live-Countdown.
final nowProvider = StreamProvider<DateTime>((ref) async* {
  yield DateTime.now();
  yield* Stream<DateTime>.periodic(
    const Duration(seconds: 1),
    (_) => DateTime.now(),
  );
});

/// Feierabend als konkreter Zeitpunkt (Basisdatum: heute).
final feierabendDateTimeProvider = Provider<DateTime>((ref) {
  final calc = ref.watch(calculatorProvider);
  final start = ref.watch(startTimeProvider);
  final config = ref.watch(workConfigProvider);
  final now = DateTime.now();
  final startDt = DateTime(now.year, now.month, now.day, start.hour, start.minute);
  return calc.feierabendFrom(startDt, config);
});

/// Verbleibende Zeit bis Feierabend (kann negativ = bereits erreicht sein).
final remainingProvider = Provider<Duration>((ref) {
  final end = ref.watch(feierabendDateTimeProvider);
  final now = ref.watch(nowProvider).valueOrNull ?? DateTime.now();
  return end.difference(now);
});

/// Ausgewählte Berufsgruppe für den Sprüche-Katalog (persistiert).
class BerufsgruppeNotifier extends Notifier<String> {
  @override
  String build() =>
      ref.read(settingsRepositoryProvider).loadBerufsgruppe() ??
      Sprueche.defaultGruppe;

  void set(String gruppe) {
    state = gruppe;
    ref.read(settingsRepositoryProvider).saveBerufsgruppe(gruppe);
  }
}

final berufsgruppeProvider =
    NotifierProvider<BerufsgruppeNotifier, String>(BerufsgruppeNotifier.new);

/// Seed, der den aktuell gezeigten Spruch bestimmt. „Neuer Spruch" erhöht ihn.
class SpruchSeedNotifier extends Notifier<int> {
  @override
  int build() => DateTime.now().millisecondsSinceEpoch;

  void shuffle() => state = state + 1 + Random().nextInt(100000);
}

final spruchSeedProvider =
    NotifierProvider<SpruchSeedNotifier, int>(SpruchSeedNotifier.new);

/// Aktueller Spruch, abhängig von Berufsgruppe + Seed.
final spruchProvider = Provider<String>((ref) {
  final gruppe = ref.watch(berufsgruppeProvider);
  final seed = ref.watch(spruchSeedProvider);
  final list = Sprueche.forGruppe(gruppe);
  if (list.isEmpty) return '';
  return list[Random(seed).nextInt(list.length)];
});

/// Theme-Modus (System/Hell/Dunkel), persistiert.
class ThemeModeNotifier extends Notifier<ThemeMode> {
  @override
  ThemeMode build() {
    switch (ref.read(settingsRepositoryProvider).loadThemeName()) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  void set(ThemeMode mode) {
    state = mode;
    ref.read(settingsRepositoryProvider).saveThemeName(mode.name);
  }
}

final themeModeProvider =
    NotifierProvider<ThemeModeNotifier, ThemeMode>(ThemeModeNotifier.new);

/// Fortschritt des Arbeitstags 0.0–1.0 (für den Countdown-Ring).
final progressProvider = Provider<double>((ref) {
  final calc = ref.watch(calculatorProvider);
  final config = ref.watch(workConfigProvider);
  final remaining = ref.watch(remainingProvider);
  final total = calc.presence(config).inSeconds;
  if (total <= 0) return 1;
  final done = total - remaining.inSeconds;
  return (done / total).clamp(0.0, 1.0);
});
