import 'package:shared_preferences/shared_preferences.dart';

import '../domain/models/work_config.dart';

/// Persistenz für Einstellungen & letzte Eingaben (offline, lokal).
///
/// Dünne, typisierte Hülle um [SharedPreferences]. Kennt bewusst keine
/// Flutter-UI-Typen (z. B. ThemeMode/TimeOfDay) — die Umwandlung passiert in
/// den Providern. So bleibt die Datenschicht schlank und testbar.
class SettingsRepository {
  SettingsRepository(this._prefs);

  final SharedPreferences _prefs;

  static const _kWorkMinutes = 'work_minutes';
  static const _kBreakMinutes = 'break_minutes';
  static const _kArbzgAuto = 'arbzg_auto';
  static const _kStartMinutes = 'start_minutes';
  static const _kBerufsgruppe = 'berufsgruppe';
  static const _kThemeName = 'theme_name';

  // --- Arbeitszeit-/Pausen-Konfiguration ---

  /// Gespeicherte Konfiguration oder `null`, wenn noch nie gespeichert.
  WorkConfig? loadWorkConfig() {
    final work = _prefs.getInt(_kWorkMinutes);
    if (work == null) return null;
    return WorkConfig(
      work: Duration(minutes: work),
      breakTime: Duration(minutes: _prefs.getInt(_kBreakMinutes) ?? 45),
      arbzgAutoBreak: _prefs.getBool(_kArbzgAuto) ?? false,
    );
  }

  Future<void> saveWorkConfig(WorkConfig config) async {
    await _prefs.setInt(_kWorkMinutes, config.work.inMinutes);
    await _prefs.setInt(_kBreakMinutes, config.breakTime.inMinutes);
    await _prefs.setBool(_kArbzgAuto, config.arbzgAutoBreak);
  }

  // --- Letzte Startzeit (Minuten seit Mitternacht) ---

  int? loadStartMinutes() => _prefs.getInt(_kStartMinutes);

  Future<void> saveStartMinutes(int minutes) =>
      _prefs.setInt(_kStartMinutes, minutes);

  // --- Berufsgruppe (Sprüche-Katalog) ---

  String? loadBerufsgruppe() => _prefs.getString(_kBerufsgruppe);

  Future<void> saveBerufsgruppe(String gruppe) =>
      _prefs.setString(_kBerufsgruppe, gruppe);

  // --- Theme ('system' | 'light' | 'dark') ---

  String? loadThemeName() => _prefs.getString(_kThemeName);

  Future<void> saveThemeName(String name) =>
      _prefs.setString(_kThemeName, name);
}
