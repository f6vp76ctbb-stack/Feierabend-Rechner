import 'package:shared_preferences/shared_preferences.dart';

import '../domain/models/work_config.dart';
import '../domain/reminder_planner.dart';

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
  static const _kProfiles = 'profiles_v1';
  static const _kOvertime = 'overtime_v1';
  static const _kDailyTarget = 'daily_target_minutes';
  static const _kProPurchased = 'pro_purchased';
  static const _kProTrialUntil = 'pro_trial_until_ms';
  static const _kRemindersEnabled = 'reminders_enabled';
  static const _kReminderLead = 'reminder_lead_minutes'; // v1.0: eine Vorwarnung
  static const _kReminderLeads = 'reminder_leads'; // Minuten, kommagetrennt
  static const _kReminderHalf = 'reminder_half';
  static const _kReminderAtEnd = 'reminder_at_end';
  static const _kReminderQuote = 'reminder_quote';
  static const _kOnboardingDone = 'onboarding_done';
  static const _kDesignsOwned = 'designs_owned';
  static const _kDesignSelected = 'design_selected';
  static const _kAnalyticsConsent = 'analytics_consent';

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

  // --- Profile (kompletter Zustand als JSON-Blob) ---

  String? loadProfilesRaw() => _prefs.getString(_kProfiles);

  Future<void> saveProfilesRaw(String json) =>
      _prefs.setString(_kProfiles, json);

  // --- Überstunden-Konto (Liste als JSON-Blob) ---

  String? loadOvertimeRaw() => _prefs.getString(_kOvertime);

  Future<void> saveOvertimeRaw(String json) =>
      _prefs.setString(_kOvertime, json);

  // --- Soll pro Tag (Vergleichswert fürs Überstunden-Konto), Minuten ---

  int? loadDailyTargetMinutes() => _prefs.getInt(_kDailyTarget);

  Future<void> saveDailyTargetMinutes(int minutes) =>
      _prefs.setInt(_kDailyTarget, minutes);

  // --- Pro (Kauf-Cache + Gratis-Test nach Belohnungsvideo) ---

  bool loadProPurchased() => _prefs.getBool(_kProPurchased) ?? false;

  Future<void> saveProPurchased(bool value) =>
      _prefs.setBool(_kProPurchased, value);

  DateTime? loadProTrialUntil() {
    final ms = _prefs.getInt(_kProTrialUntil);
    return ms == null ? null : DateTime.fromMillisecondsSinceEpoch(ms);
  }

  Future<void> saveProTrialUntil(DateTime until) =>
      _prefs.setInt(_kProTrialUntil, until.millisecondsSinceEpoch);

  // --- Erinnerungen (Benachrichtigungen) ---

  /// Gespeicherte Erinnerungs-Optionen; übernimmt die einzelne Vorwarnung aus v1.0.
  ReminderOptions loadReminderOptions() {
    final raw = _prefs.getString(_kReminderLeads);
    final leads = raw == null
        ? [Duration(minutes: _prefs.getInt(_kReminderLead) ?? 30)]
        : [
            for (final part in raw.split(','))
              if (int.tryParse(part) case final m?) Duration(minutes: m),
          ];
    return ReminderOptions(
      enabled: _prefs.getBool(_kRemindersEnabled) ?? false,
      leads: leads,
      halfTime: _prefs.getBool(_kReminderHalf) ?? false,
      atEnd: _prefs.getBool(_kReminderAtEnd) ?? true,
      withQuote: _prefs.getBool(_kReminderQuote) ?? true,
    );
  }

  Future<void> saveReminderOptions(ReminderOptions o) async {
    await _prefs.setBool(_kRemindersEnabled, o.enabled);
    await _prefs.setString(
        _kReminderLeads, o.leads.map((l) => l.inMinutes).join(','));
    await _prefs.setBool(_kReminderHalf, o.halfTime);
    await _prefs.setBool(_kReminderAtEnd, o.atEnd);
    await _prefs.setBool(_kReminderQuote, o.withQuote);
  }

  // --- Einführung beim ersten Start ---

  /// Wer die App schon benutzt hat (gespeicherte Eingaben), sieht sie nicht mehr.
  bool loadOnboardingDone() =>
      _prefs.getBool(_kOnboardingDone) ??
      (_prefs.containsKey(_kStartMinutes) || _prefs.containsKey(_kProfiles));

  Future<void> saveOnboardingDone(bool value) =>
      _prefs.setBool(_kOnboardingDone, value);

  // --- Designs (gekaufte + gewähltes) ---

  Set<String> loadOwnedDesigns() =>
      (_prefs.getStringList(_kDesignsOwned) ?? const []).toSet();

  Future<void> saveOwnedDesigns(Set<String> ids) =>
      _prefs.setStringList(_kDesignsOwned, ids.toList()..sort());

  String? loadSelectedDesign() => _prefs.getString(_kDesignSelected);

  Future<void> saveSelectedDesign(String id) =>
      _prefs.setString(_kDesignSelected, id);

  // --- Nutzungsstatistik (Einwilligung) ---

  /// `null` = noch nicht gefragt.
  bool? loadAnalyticsConsent() => _prefs.getBool(_kAnalyticsConsent);

  Future<void> saveAnalyticsConsent(bool value) =>
      _prefs.setBool(_kAnalyticsConsent, value);
}
