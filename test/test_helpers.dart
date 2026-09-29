import 'dart:async';

import 'package:feierabend_rechner/app.dart';
import 'package:feierabend_rechner/features/home/state/home_providers.dart';
import 'package:feierabend_rechner/domain/reminder_planner.dart';
import 'package:feierabend_rechner/features/pro/pro_providers.dart';
import 'package:feierabend_rechner/features/reminders/reminder_providers.dart';
import 'package:feierabend_rechner/services/ads_backend.dart';
import 'package:feierabend_rechner/services/notification_backend.dart';
import 'package:feierabend_rechner/services/purchase_backend.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  final List<List<PlannedReminder>> applied = [];
  ReminderTexts? lastTexts;
  int permissionRequests = 0;

  List<PlannedReminder> get current => applied.isEmpty ? const [] : applied.last;

  @override
  bool get isSupported => true;
  @override
  Future<bool> requestPermission() async {
    permissionRequests++;
    return grant;
  }

  @override
  Future<void> apply(List<PlannedReminder> plan, ReminderTexts texts) async {
    applied.add(plan);
    lastTexts = texts;
  }
}

/// Baut die App mit gemockter Persistenz und ohne echten Store/Werbung.
Future<Widget> buildApp({
  Map<String, Object> initial = const {},
  bool pro = true,
  Locale locale = const Locale('de'),
  PurchaseBackend? purchases,
  NotificationBackend? notifications,
}) async {
  SharedPreferences.setMockInitialValues({
    if (pro) 'pro_purchased': true,
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
    ],
    child: FeierabendApp(locale: locale),
  );
}
