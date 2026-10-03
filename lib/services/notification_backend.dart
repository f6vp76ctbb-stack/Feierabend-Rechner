import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

import '../domain/reminder_planner.dart';

/// Benachrichtigungskanal (Android), lokalisiert von der App übergeben.
class ReminderChannel {
  final String name;
  final String description;

  const ReminderChannel({required this.name, required this.description});
}

/// Eine fertig formulierte, geplante Benachrichtigung.
class ReminderNotification {
  final int id;
  final DateTime at;
  final String title;
  final String body;

  const ReminderNotification({
    required this.id,
    required this.at,
    required this.title,
    required this.body,
  });

  @override
  String toString() => 'ReminderNotification($id @ $at: $title / $body)';
}

/// Abstraktion über lokale Benachrichtigungen (Tests/Web: Noop).
abstract class NotificationBackend {
  bool get isSupported;

  /// Fragt die Benachrichtigungs-Berechtigung an (Android 13+ / iOS).
  Future<bool> requestPermission();

  /// Ersetzt alle geplanten Erinnerungen der App durch [notifications].
  Future<void> apply(
      List<ReminderNotification> notifications, ReminderChannel channel);
}

class NoopNotificationBackend implements NotificationBackend {
  @override
  bool get isSupported => false;
  @override
  Future<bool> requestPermission() async => false;
  @override
  Future<void> apply(
      List<ReminderNotification> notifications, ReminderChannel channel) async {}
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
  Future<void> apply(
      List<ReminderNotification> notifications, ReminderChannel channel) async {
    try {
      await _ensureInitialized();
      // Nur eigene, noch ausstehende Erinnerungen abräumen (angezeigte bleiben stehen).
      final pending = await _plugin.pendingNotificationRequests();
      for (final p in pending) {
        if (ReminderPlanner.isOwnId(p.id)) await _plugin.cancel(id: p.id);
      }
      for (final n in notifications) {
        await _plugin.zonedSchedule(
          id: n.id,
          // Absoluter Zeitpunkt in UTC – unabhängig von Zeitzonen-Daten.
          scheduledDate: tz.TZDateTime.from(n.at.toUtc(), tz.UTC),
          notificationDetails: NotificationDetails(
            android: AndroidNotificationDetails(
              'feierabend_reminders',
              channel.name,
              channelDescription: channel.description,
              importance: Importance.high,
              priority: Priority.high,
              // Mehrzeilig, damit der Spruch ganz zu lesen ist.
              styleInformation: BigTextStyleInformation(n.body),
            ),
            iOS: const DarwinNotificationDetails(),
          ),
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
          title: n.title,
          body: n.body,
        );
      }
    } catch (_) {
      // Erinnerungen sind ein Komfort-Feature – nie die App stören.
    }
  }
}
