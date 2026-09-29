import 'package:feierabend_rechner/config/monetization_config.dart';
import 'package:feierabend_rechner/features/home/state/home_providers.dart';
import 'package:feierabend_rechner/features/pro/pro_providers.dart';
import 'package:feierabend_rechner/services/ads_backend.dart';
import 'package:feierabend_rechner/services/purchase_backend.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../test_helpers.dart';

Future<(ProviderContainer, FakePurchaseBackend)> makeContainer([
  Map<String, Object> initial = const {},
]) async {
  SharedPreferences.setMockInitialValues(initial);
  final prefs = await SharedPreferences.getInstance();
  final store = FakePurchaseBackend();
  final c = ProviderContainer(overrides: [
    sharedPreferencesProvider.overrideWithValue(prefs),
    purchaseBackendProvider.overrideWithValue(store),
    adsBackendProvider.overrideWithValue(NoopAdsBackend()),
  ]);
  addTearDown(c.dispose);
  return (c, store);
}

void main() {
  test('Free standardmäßig, fragt beim Start still den Kaufstatus ab', () async {
    final (c, store) = await makeContainer();
    expect(c.read(isProProvider), isFalse);
    await Future<void>.delayed(Duration.zero);
    expect(store.restoreCalls, 1);
  });

  test('Kauf-Ereignis schaltet Pro frei und wird gespeichert', () async {
    final (c, store) = await makeContainer();
    c.read(proControllerProvider);
    store.emit(const PurchaseEvent(
        MonetizationConfig.proProductId, PurchaseEventType.purchased));
    await Future<void>.delayed(Duration.zero);

    expect(c.read(isProProvider), isTrue);
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getBool('pro_purchased'), isTrue);
  });

  test('Wiederhergestellter Kauf schaltet ebenfalls frei', () async {
    final (c, store) = await makeContainer();
    c.read(proControllerProvider);
    store.emit(const PurchaseEvent(
        MonetizationConfig.proProductId, PurchaseEventType.restored));
    await Future<void>.delayed(Duration.zero);
    expect(c.read(isProProvider), isTrue);
  });

  test('Fremde Produkte oder Fehler schalten nichts frei', () async {
    final (c, store) = await makeContainer();
    c.read(proControllerProvider);
    store.emit(const PurchaseEvent('anderes', PurchaseEventType.purchased));
    store.emit(const PurchaseEvent(
        MonetizationConfig.proProductId, PurchaseEventType.error));
    await Future<void>.delayed(Duration.zero);
    expect(c.read(isProProvider), isFalse);
  });

  test('24-Std-Test nach Belohnungsvideo schaltet befristet frei', () async {
    final (c, _) = await makeContainer();
    c.read(proControllerProvider.notifier).grantTrial(const Duration(hours: 24));
    expect(c.read(isProProvider), isTrue);
    expect(c.read(proControllerProvider).purchased, isFalse);
  });

  test('Abgelaufener Test ist kein Pro', () async {
    final past = DateTime.now().subtract(const Duration(hours: 1));
    final (c, _) =
        await makeContainer({'pro_trial_until_ms': past.millisecondsSinceEpoch});
    expect(c.read(isProProvider), isFalse);
  });

  test('Gecachter Kauf gilt sofort beim Start (offline)', () async {
    final (c, _) = await makeContainer({'pro_purchased': true});
    expect(c.read(isProProvider), isTrue);
  });
}
