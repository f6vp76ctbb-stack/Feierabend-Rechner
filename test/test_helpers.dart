import 'dart:async';

import 'package:feierabend_rechner/app.dart';
import 'package:feierabend_rechner/features/home/state/home_providers.dart';
import 'package:feierabend_rechner/features/pro/pro_providers.dart';
import 'package:feierabend_rechner/services/ads_backend.dart';
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

/// Baut die App mit gemockter Persistenz und ohne echten Store/Werbung.
Future<Widget> buildApp({
  Map<String, Object> initial = const {},
  bool pro = true,
  Locale locale = const Locale('de'),
  PurchaseBackend? purchases,
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
    ],
    child: FeierabendApp(locale: locale),
  );
}
