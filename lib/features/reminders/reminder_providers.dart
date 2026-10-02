import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../config/monetization_config.dart';
import '../../domain/reminder_planner.dart';
import '../../services/notification_backend.dart';
import '../home/state/home_providers.dart';
import '../pro/pro_providers.dart';

/// Benachrichtigungs-Anbindung. In Tests/Screenshots per Override ersetzbar.
final notificationBackendProvider = Provider<NotificationBackend>(
  (ref) => MonetizationConfig.isMobile
      ? LocalNotificationBackend()
      : NoopNotificationBackend(),
);

class ReminderSettings {
  final bool enabled;
  final Duration lead;

  const ReminderSettings({required this.enabled, required this.lead});

  ReminderSettings copyWith({bool? enabled, Duration? lead}) => ReminderSettings(
        enabled: enabled ?? this.enabled,
        lead: lead ?? this.lead,
      );
}

/// An/Aus + Vorwarnzeit, persistiert.
class ReminderSettingsController extends Notifier<ReminderSettings> {
  @override
  ReminderSettings build() {
    final repo = ref.read(settingsRepositoryProvider);
    return ReminderSettings(
      enabled: repo.loadRemindersEnabled(),
      lead: Duration(minutes: repo.loadReminderLeadMinutes()),
    );
  }

  void setEnabled(bool value) {
    state = state.copyWith(enabled: value);
    ref.read(settingsRepositoryProvider).saveRemindersEnabled(value);
  }

  void setLead(Duration lead) {
    state = state.copyWith(lead: lead);
    ref.read(settingsRepositoryProvider).saveReminderLeadMinutes(lead.inMinutes);
  }
}

final reminderSettingsProvider =
    NotifierProvider<ReminderSettingsController, ReminderSettings>(
  ReminderSettingsController.new,
);

/// Aktueller Erinnerungs-Plan (nur mit Pro). Ändert sich, sobald Startzeit,
/// Arbeitszeit, Pause, Einstellungen oder Pro-Status sich ändern.
final reminderPlanProvider = Provider<List<PlannedReminder>>((ref) {
  final settings = ref.watch(reminderSettingsProvider);
  final isPro = ref.watch(isProProvider);
  final feierabend = ref.watch(feierabendDateTimeProvider);
  return ReminderPlanner.plan(
    feierabend: feierabend,
    now: DateTime.now(),
    lead: settings.lead,
    enabled: settings.enabled && isPro,
  );
});

/// Vergleicht zwei Pläne inhaltlich (vermeidet unnötiges Neu-Planen).
bool samePlan(List<PlannedReminder>? a, List<PlannedReminder> b) =>
    a != null && listEquals(a, b);
