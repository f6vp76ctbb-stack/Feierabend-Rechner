import 'package:feierabend_rechner/design/app_designs.dart';
import 'package:feierabend_rechner/features/designs/design_providers.dart';
import 'package:feierabend_rechner/features/home/home_screen.dart';
import 'package:feierabend_rechner/features/home/state/home_providers.dart';
import 'package:feierabend_rechner/features/pro/pro_providers.dart';
import 'package:feierabend_rechner/services/purchase_backend.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../test_helpers.dart';

Future<(ProviderContainer, FakePurchaseBackend, SharedPreferences)> _container(
    [Map<String, Object> initial = const {}]) async {
  SharedPreferences.setMockInitialValues(initial);
  final prefs = await SharedPreferences.getInstance();
  final store = FakePurchaseBackend();
  final c = ProviderContainer(overrides: [
    sharedPreferencesProvider.overrideWithValue(prefs),
    purchaseBackendProvider.overrideWithValue(store),
  ]);
  addTearDown(c.dispose);
  return (c, store, prefs);
}

Color _homePrimary(WidgetTester tester) =>
    Theme.of(tester.element(find.byType(HomeScreen))).colorScheme.primary;

void main() {
  group('Katalog', () {
    test('5 kaufbare Designs mit eindeutigen Produkt-IDs, Standard gratis', () {
      expect(AppDesigns.paid.length, 5);
      expect(AppDesigns.standard.isFree, isTrue);
      final ids = AppDesigns.paid.map((d) => d.productId).toSet();
      expect(ids.length, 5);
      expect(ids.every((id) => RegExp(r'^[a-z0-9_.]+$').hasMatch(id!)), isTrue);
    });

    test('nur Supporter hat Herzen', () {
      expect(AppDesigns.all.where((d) => d.hearts), [AppDesigns.supporter]);
    });

    test('unbekannte ID → Standard', () {
      expect(AppDesigns.byId('gibts-nicht'), AppDesigns.standard);
      expect(AppDesigns.byProductId('feierabend_pro'), isNull);
    });
  });

  group('DesignsController', () {
    test('Kauf schaltet frei und zieht das Design gleich an', () async {
      final (c, store, prefs) = await _container();
      c.read(designsProvider);
      store.emit(const PurchaseEvent('design_ocean', PurchaseEventType.purchased));
      await Future<void>.delayed(Duration.zero);

      expect(c.read(activeDesignProvider), AppDesigns.ocean);
      expect(prefs.getStringList('designs_owned'), ['ocean']);
      expect(prefs.getString('design_selected'), 'ocean');
    });

    test('Wiederherstellen schaltet frei, wechselt aber nicht', () async {
      final (c, store, _) = await _container();
      c.read(designsProvider);
      store.emit(const PurchaseEvent('design_forest', PurchaseEventType.restored));
      await Future<void>.delayed(Duration.zero);

      expect(c.read(designsProvider).owns(AppDesigns.forest), isTrue);
      expect(c.read(activeDesignProvider), AppDesigns.standard);
    });

    test('Nicht gekauftes Design lässt sich nicht wählen', () async {
      final (c, _, _) = await _container();
      expect(c.read(designsProvider.notifier).select(AppDesigns.supporter), isFalse);
      expect(c.read(activeDesignProvider), AppDesigns.standard);
    });

    test('Abbruch/Fehler schalten nichts frei', () async {
      final (c, store, _) = await _container();
      c.read(designsProvider);
      store.emit(const PurchaseEvent('design_sunset', PurchaseEventType.canceled));
      await Future<void>.delayed(Duration.zero);
      expect(c.read(designsProvider).owns(AppDesigns.sunset), isFalse);
    });

    test('Gewähltes, aber nicht gekauftes Design fällt auf Standard zurück', () async {
      final (c, _, _) = await _container({'design_selected': 'midnight'});
      expect(c.read(activeDesignProvider), AppDesigns.standard);
    });
  });

  testWidgets('Shop: Kauf starten, nach Bestätigung ist das Design aktiv', (
    tester,
  ) async {
    final store = FakePurchaseBackend();
    await tester.pumpWidget(await buildApp(purchases: store));
    await tester.pump();
    expect(_homePrimary(tester), AppDesigns.standard.primary);

    await tester.tap(find.byIcon(Icons.settings_rounded));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Designs ansehen'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Designs ansehen'));
    await tester.pumpAndSettle();

    expect(find.text('Supporter'), findsOneWidget);
    expect(find.text('Größtes Dankeschön'), findsOneWidget);
    await tester.ensureVisible(find.text('Wald'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Wald'));
    await tester.pumpAndSettle();
    expect(store.buyCalls, 1);

    store.emit(const PurchaseEvent('design_forest', PurchaseEventType.purchased));
    await tester.pumpAndSettle();
    expect(find.text('Danke! Dein neues Design ist aktiv.'), findsOneWidget);
    expect(_homePrimary(tester), AppDesigns.forest.primary);
  });

  testWidgets('Shop: gekauftes Design wird per Tipp gewählt', (tester) async {
    await tester.pumpWidget(await buildApp(
      purchases: FakePurchaseBackend(),
      initial: {'designs_owned': <String>['supporter']},
    ));
    await tester.pump();

    await tester.tap(find.byIcon(Icons.settings_rounded));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Designs ansehen'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Designs ansehen'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Supporter'));
    await tester.pumpAndSettle();

    expect(_homePrimary(tester), AppDesigns.supporter.primary);
    expect(find.byIcon(Icons.favorite_rounded), findsWidgets);
  });
}
