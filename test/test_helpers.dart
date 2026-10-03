import 'dart:async';

import 'package:feierabend_rechner/app.dart';
import 'package:feierabend_rechner/features/analytics/analytics_providers.dart';
import 'package:feierabend_rechner/features/home/state/home_providers.dart';
import 'package:feierabend_rechner/features/pro/pro_providers.dart';
import 'package:feierabend_rechner/features/reminders/reminder_providers.dart';
import 'package:feierabend_rechner/features/widget/widget_providers.dart';
import 'package:feierabend_rechner/domain/models/widget_snapshot.dart';
import 'package:feierabend_rechner/services/ads_backend.dart';
import 'package:feierabend_rechner/services/analytics_backend.dart';
import 'package:feierabend_rechner/services/notification_backend.dart';
import 'package:feierabend_rechner/services/purchase_backend.dart';
import 'package:feierabend_rechner/services/widget_backend.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Test-Statistik: merkt sich Ereignisse – wie die echte nur, wenn eingeschaltet.
class FakeAnalyticsBackend implements AnalyticsBackend {
  bool enabled = false;
  final events = <String>[];

  @override
  bool get isSupported => true;
  @override
  Future<void> setEnabled(bool value) async => enabled = value;
  @override
  Future<void> log(String name, [Map<String, Object>? params]) async {
    if (enabled) events.add(name);
  }
}

/// Test-Store: steuerbare Ereignisse, kein echter Play-Store.
class FakePurchaseBackend implements PurchaseBackend {
  FakePurchaseBackend({this.supported = true, this.price = '3,99 €'});

  final bool supported;
  final String price;
  final _events = StreamController<PurchaseEvent>.broadcast();
  int buyCalls = 0;
  int restoreCalls = 0;

  void emit(PurchaseEvent e) => _events.add(e);

  @override
  bool get isSupported => supported;
  @override
  Stream<PurchaseEvent> get events => _events.stream;
  @override
  Future<StoreProduct?> loadProduct(String productId) async =>
      supported ? StoreProduct(id: productId, price: price) : null;
  @override
  Future<bool> buy(String productId) async {
    buyCalls++;
    return supported;
  }

  @override
  Future<void> restore() async => restoreCalls++;
  @override
  void dispose() => _events.close();
}

/// Test-Benachrichtigungen: merkt sich jeden geplanten Stand.
class FakeNotificationBackend implements NotificationBackend {
  FakeNotificationBackend({this.grant = true});

  final bool grant;
  final List<List<ReminderNotification>> applied = [];
  int permissionRequests = 0;

  List<ReminderNotification> get current =>
      applied.isEmpty ? const [] : applied.last;

  @override
  bool get isSupported => true;
  @override
  Future<bool> requestPermission() async {
    permissionRequests++;
    return grant;
  }

  @override
  Future<void> apply(
      List<ReminderNotification> notifications, ReminderChannel channel) async {
    applied.add(notifications);
  }
}

/// Test-Widget: merkt sich jeden übertragenen Stand.
class FakeWidgetBackend implements WidgetBackend {
  FakeWidgetBackend({this.supported = true, this.pinSupported = true});

  final bool supported;
  final bool pinSupported;
  final List<WidgetSnapshot> updates = [];
  int pinRequests = 0;

  @override
  bool get isSupported => supported;
  @override
  Future<void> update(WidgetSnapshot snapshot) async => updates.add(snapshot);
  @override
  Future<bool> requestPin() async {
    pinRequests++;
    return pinSupported;
  }
}

/// Baut die App mit gemockter Persistenz und ohne echten Store/Werbung.
Future<Widget> buildApp({
  Map<String, Object> initial = const {},
  bool pro = true,
  Locale locale = const Locale('de'),
  PurchaseBackend? purchases,
  NotificationBackend? notifications,
  WidgetBackend? widgets,
  bool onboarding = false,
  bool tester = false,
  AnalyticsBackend? analytics,
}) async {
  SharedPreferences.setMockInitialValues({
    if (pro) 'pro_purchased': true,
    if (!onboarding) 'onboarding_done': true,
    ...initial,
  });
  final prefs = await SharedPreferences.getInstance();
  return ProviderScope(
    overrides: [
      sharedPreferencesProvider.overrideWithValue(prefs),
      purchaseBackendProvider
          .overrideWithValue(purchases ?? NoopPurchaseBackend()),
      adsBackendProvider.overrideWithValue(NoopAdsBackend()),
      notificationBackendProvider
          .overrideWithValue(notifications ?? NoopNotificationBackend()),
      widgetBackendProvider.overrideWithValue(widgets ?? NoopWidgetBackend()),
      testerBuildProvider.overrideWithValue(tester),
      analyticsBackendProvider
          .overrideWithValue(analytics ?? NoopAnalyticsBackend()),
    ],
    child: FeierabendApp(locale: locale),
  );
}
