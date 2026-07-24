import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../data/settings_repository.dart';
import '../../../data/sprueche.dart';
import '../../../domain/feierabend_calculator.dart';
import '../../../domain/models/feierabend_result.dart';
import '../../../domain/models/profile.dart';
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

/// Zustand aller Profile + aktuell aktives Profil.
class ProfilesState {
  final List<Profile> profiles;
  final String activeId;

  const ProfilesState({required this.profiles, required this.activeId});

  Profile get active =>
      profiles.firstWhere((p) => p.id == activeId, orElse: () => profiles.first);

  ProfilesState copyWith({List<Profile>? profiles, String? activeId}) =>
      ProfilesState(
        profiles: profiles ?? this.profiles,
        activeId: activeId ?? this.activeId,
      );
}

/// Verwaltet Profile (anlegen, umschalten, umbenennen, löschen) inkl. der
/// Arbeitszeit-/Pausen-Konfiguration des aktiven Profils. Persistiert als JSON.
class ProfilesController extends Notifier<ProfilesState> {
  @override
  ProfilesState build() {
    final repo = ref.read(settingsRepositoryProvider);
    final raw = repo.loadProfilesRaw();
    if (raw != null) {
      try {
        final map = jsonDecode(raw) as Map<String, dynamic>;
        final profiles = (map['profiles'] as List)
            .map((e) => Profile.fromJson((e as Map).cast<String, dynamic>()))
            .toList();
        if (profiles.isNotEmpty) {
          final savedActive = map['activeId'] as String?;
          final activeId = profiles.any((p) => p.id == savedActive)
              ? savedActive!
              : profiles.first.id;
          return ProfilesState(profiles: profiles, activeId: activeId);
        }
      } catch (_) {
        // Kaputter Blob → auf Default zurückfallen.
      }
    }
    // Migration: altes Einzel-Config (Phase 4) oder Default → „Standard"-Profil.
    final legacy = repo.loadWorkConfig() ?? const WorkConfig();
    final def = Profile(id: _newId(), name: 'Standard', config: legacy);
    return ProfilesState(profiles: [def], activeId: def.id);
  }

  static String _newId() =>
      '${DateTime.now().microsecondsSinceEpoch}_${Random().nextInt(1 << 20)}';

  void _apply(ProfilesState next) {
    state = next;
    final json = jsonEncode({
      'activeId': next.activeId,
      'profiles': next.profiles.map((p) => p.toJson()).toList(),
    });
    ref.read(settingsRepositoryProvider).saveProfilesRaw(json);
  }

  void _updateActiveConfig(WorkConfig config) {
    final profiles = [
      for (final p in state.profiles)
        if (p.id == state.activeId) p.copyWith(config: config) else p,
    ];
    _apply(state.copyWith(profiles: profiles));
  }

  void setActive(String id) {
    if (state.profiles.any((p) => p.id == id)) {
      _apply(state.copyWith(activeId: id));
    }
  }

  /// Legt ein neues Profil an (kopiert die aktuelle Config) und aktiviert es.
  String addProfile(String name) {
    final id = _newId();
    final profile = Profile(id: id, name: name, config: state.active.config);
    _apply(ProfilesState(
      profiles: [...state.profiles, profile],
      activeId: id,
    ));
    return id;
  }

  void renameProfile(String id, String name) {
    final profiles = [
      for (final p in state.profiles)
        if (p.id == id) p.copyWith(name: name) else p,
    ];
    _apply(state.copyWith(profiles: profiles));
  }

  /// Löscht ein Profil (mind. eines bleibt immer erhalten).
  void deleteProfile(String id) {
    if (state.profiles.length <= 1) return;
    final profiles = state.profiles.where((p) => p.id != id).toList();
    final activeId = state.activeId == id ? profiles.first.id : state.activeId;
    _apply(ProfilesState(profiles: profiles, activeId: activeId));
  }

  void setWork(Duration work) =>
      _updateActiveConfig(state.active.config.copyWith(work: work));
  void setBreak(Duration breakTime) =>
      _updateActiveConfig(state.active.config.copyWith(breakTime: breakTime));
  void setArbzgAuto(bool value) =>
      _updateActiveConfig(state.active.config.copyWith(arbzgAutoBreak: value));
}

final profilesControllerProvider =
    NotifierProvider<ProfilesController, ProfilesState>(ProfilesController.new);

/// Das aktuell aktive Profil.
final activeProfileProvider =
    Provider<Profile>((ref) => ref.watch(profilesControllerProvider).active);

/// Arbeitszeit-/Pausen-Konfiguration des aktiven Profils (Basis der Berechnung).
final workConfigProvider =
    Provider<WorkConfig>((ref) => ref.watch(activeProfileProvider).config);

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
