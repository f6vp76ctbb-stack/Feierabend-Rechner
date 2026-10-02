import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../config/monetization_config.dart';
import '../../core/formatting.dart';
import '../../data/sprueche.dart';
import '../../domain/reminder_planner.dart';
import '../../l10n/app_localizations.dart';
import '../../services/notification_backend.dart';
import '../home/state/home_providers.dart';
import '../pro/pro_providers.dart';

/// Benachrichtigungs-Anbindung. In Tests/Screenshots per Override ersetzbar.
final notificationBackendProvider = Provider<NotificationBackend>(
  (ref) => MonetizationConfig.isMobile
      ? LocalNotificationBackend()
      : NoopNotificationBackend(),
);

/// Erinnerungs-Optionen (an/aus, Vorwarnungen, Halbzeit, Feierabend, Spruch), persistiert.
class ReminderSettingsController extends Notifier<ReminderOptions> {
  @override
  ReminderOptions build() =>
      ref.read(settingsRepositoryProvider).loadReminderOptions();

  void _set(ReminderOptions options) {
    state = options;
    ref.read(settingsRepositoryProvider).saveReminderOptions(options);
  }

  void setEnabled(bool value) => _set(state.copyWith(enabled: value));
  void toggleLead(Duration lead) => _set(state.toggleLead(lead));
  void setHalfTime(bool value) => _set(state.copyWith(halfTime: value));
  void setAtEnd(bool value) => _set(state.copyWith(atEnd: value));
  void setWithQuote(bool value) => _set(state.copyWith(withQuote: value));
}

final reminderSettingsProvider =
    NotifierProvider<ReminderSettingsController, ReminderOptions>(
  ReminderSettingsController.new,
);

/// Alles, wovon die geplanten Benachrichtigungen abhängen (nur mit Pro aktiv).
class ReminderSchedule {
  final List<PlannedReminder> plan;
  final DateTime feierabend;
  final bool withQuote;
  final String gruppe;

  const ReminderSchedule({
    required this.plan,
    required this.feierabend,
    required this.withQuote,
    required this.gruppe,
  });

  @override
  bool operator ==(Object other) =>
      other is ReminderSchedule &&
      listEquals(other.plan, plan) &&
      other.feierabend == feierabend &&
      other.withQuote == withQuote &&
      other.gruppe == gruppe;

  @override
  int get hashCode =>
      Object.hash(Object.hashAll(plan), feierabend, withQuote, gruppe);
}

/// Aktueller Plan. Ändert sich, sobald Startzeit, Arbeitszeit, Pause,
/// Einstellungen, Berufsgruppe oder Pro-Status sich ändern.
final reminderScheduleProvider = Provider<ReminderSchedule>((ref) {
  final options = ref.watch(reminderSettingsProvider);
  final isPro = ref.watch(isProProvider);
  final startTime = ref.watch(startTimeProvider);
  final feierabend = ref.watch(feierabendDateTimeProvider);
  final now = DateTime.now();
  final start = DateTime(
      now.year, now.month, now.day, startTime.hour, startTime.minute);
  return ReminderSchedule(
    plan: ReminderPlanner.plan(
      start: start,
      feierabend: feierabend,
      now: now,
      options: options.copyWith(enabled: options.enabled && isPro),
    ),
    feierabend: feierabend,
    withQuote: options.withQuote,
    gruppe: ref.watch(berufsgruppeProvider),
  );
});

/// Formuliert die Benachrichtigungen aus – mit Spruch ohne Wiederholung innerhalb eines Tages.
List<ReminderNotification> buildReminderNotifications(
  ReminderSchedule schedule,
  AppLocalizations l, {
  required String lang,
  Random? random,
}) {
  final units = Units(hour: l.unitHours, minute: l.unitMinutes);
  final time = Formatting.clock(
      schedule.feierabend.hour, schedule.feierabend.minute);
  final quotes = [...Sprueche.forGruppe(schedule.gruppe, lang)]
    ..shuffle(random ?? Random());
  var next = 0;

  String withQuote(String body) {
    if (!schedule.withQuote || quotes.isEmpty) return body;
    return '$body\n${quotes[next++ % quotes.length]}';
  }

  return [
    for (final r in schedule.plan)
      switch (r.kind) {
        ReminderKind.before => ReminderNotification(
            id: r.id,
            at: r.at,
            title: l.notifLeadTitle(Formatting.durationLong(r.lead!, units)),
            body: withQuote(l.notifLeadBody(time)),
          ),
        ReminderKind.half => ReminderNotification(
            id: r.id,
            at: r.at,
            title: l.notifHalfTitle,
            body: withQuote(l.notifHalfBody(time)),
          ),
        ReminderKind.end => ReminderNotification(
            id: r.id,
            at: r.at,
            title: l.notifEndTitle,
            body: withQuote(l.notifEndBody),
          ),
      },
  ];
}
