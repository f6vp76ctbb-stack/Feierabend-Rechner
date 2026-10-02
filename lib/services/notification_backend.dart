import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

import '../domain/reminder_planner.dart';

/// Texte für die Benachrichtigungen (lokalisiert von der App übergeben).
class ReminderTexts {
  final String channelName;
  final String channelDescription;
  final String beforeTitle;
  final String beforeBody;
  final String endTitle;
  final String endBody;

  const ReminderTexts({
    required this.channelName,
    required this.channelDescription,
    required this.beforeTitle,
    required this.beforeBody,
    required this.endTitle,
    required this.endBody,
  });
}

/// Abstraktion über lokale Benachrichtigungen (Tests/Web: Noop).
abstract class NotificationBackend {
  bool get isSupported;

  /// Fragt die Benachrichtigungs-Berechtigung an (Android 13+ / iOS).
  Future<bool> requestPermission();

  /// Ersetzt alle geplanten Erinnerungen durch [plan].
  Future<void> apply(List<PlannedReminder> plan, ReminderTexts texts);
}

class NoopNotificationBackend implements NotificationBackend {
  @override
  bool get isSupported => false;
  @override
  Future<bool> requestPermission() async => false;
  @override
  Future<void> apply(List<PlannedReminder> plan, ReminderTexts texts) async {}
}

/// Lokale Benachrichtigungen über `flutter_local_notifications`.
///
/// Bewusst **nicht-exakte** Alarme (`inexactAllowWhileIdle`): brauchen keine
/// Sonder-Berechtigung/Play-Erklärung; Android kann sie um wenige Minuten verschieben.
class LocalNotificationBackend implements NotificationBackend {
  final _plugin = FlutterLocalNotificationsPlugin();
  Future<void>? _init;

  @override
  bool get isSupported => true;

  Future<void> _ensureInitialized() => _init ??= _plugin
      .initialize(
        settings: const InitializationSettings(
          // Weiße Silhouette des App-Zeichens (auch Teil des adaptiven Icons).
          android: AndroidInitializationSettings('@drawable/ic_launcher_monochrome'),
          iOS: DarwinInitializationSettings(
            requestAlertPermission: false,
            requestBadgePermission: false,
            requestSoundPermission: false,
          ),
        ),
      )
      .then((_) {});

  @override
  Future<bool> requestPermission() async {
    try {
      await _ensureInitialized();
      if (defaultTargetPlatform == TargetPlatform.android) {
        final android = _plugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
        return await android?.requestNotificationsPermission() ?? true;
      }
      final ios = _plugin.resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin>();
      return await ios?.requestPermissions(alert: true, sound: true) ?? false;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<void> apply(List<PlannedReminder> plan, ReminderTexts texts) async {
    try {
      await _ensureInitialized();
      for (final id in ReminderPlanner.allIds) {
        await _plugin.cancel(id: id);
      }
      final details = NotificationDetails(
        android: AndroidNotificationDetails(
          'feierabend_reminders',
          texts.channelName,
          channelDescription: texts.channelDescription,
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: const DarwinNotificationDetails(),
      );
      for (final r in plan) {
        final before = r.kind == ReminderKind.before;
        await _plugin.zonedSchedule(
          id: r.id,
          // Absoluter Zeitpunkt in UTC – unabhängig von Zeitzonen-Daten.
          scheduledDate: tz.TZDateTime.from(r.at.toUtc(), tz.UTC),
          notificationDetails: details,
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
          title: before ? texts.beforeTitle : texts.endTitle,
          body: before ? texts.beforeBody : texts.endBody,
        );
      }
    } catch (_) {
      // Erinnerungen sind ein Komfort-Feature – nie die App stören.
    }
  }
}
