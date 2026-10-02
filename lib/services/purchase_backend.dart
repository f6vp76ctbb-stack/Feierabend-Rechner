import 'dart:async';

import 'package:in_app_purchase/in_app_purchase.dart';

/// Ereignis aus dem Store, auf das die App reagiert.
enum PurchaseEventType { purchased, restored, pending, error, canceled }

class PurchaseEvent {
  final String productId;
  final PurchaseEventType type;

  const PurchaseEvent(this.productId, this.type);

  bool get grantsEntitlement =>
      type == PurchaseEventType.purchased || type == PurchaseEventType.restored;
}

/// Produkt aus dem Store (nur, was die UI braucht).
class StoreProduct {
  final String id;

  /// Lokalisierter Preis inkl. Währung, z. B. „3,99 €".
  final String price;

  const StoreProduct({required this.id, required this.price});
}

/// Abstraktion über den App-Store, damit Tests und die Web-Vorschau ohne
/// echten Store auskommen.
abstract class PurchaseBackend {
  bool get isSupported;
  Stream<PurchaseEvent> get events;
  Future<StoreProduct?> loadProduct(String productId);

  /// Startet den Kauf-Dialog. `false`, wenn er gar nicht gestartet werden konnte.
  Future<bool> buy(String productId);
  Future<void> restore();
  void dispose();
}

/// Kein Store verfügbar (Web-Vorschau, Tests).
class NoopPurchaseBackend implements PurchaseBackend {
  @override
  bool get isSupported => false;
  @override
  Stream<PurchaseEvent> get events => const Stream.empty();
  @override
  Future<StoreProduct?> loadProduct(String productId) async => null;
  @override
  Future<bool> buy(String productId) async => false;
  @override
  Future<void> restore() async {}
  @override
  void dispose() {}
}

/// Google Play Billing / App Store über das offizielle `in_app_purchase`-Plugin.
class StorePurchaseBackend implements PurchaseBackend {
  StorePurchaseBackend() {
    _subscription = _iap.purchaseStream.listen(
      _onPurchases,
      onError: (Object _) {},
    );
  }

  final InAppPurchase _iap = InAppPurchase.instance;
  final _events = StreamController<PurchaseEvent>.broadcast();
  final Map<String, ProductDetails> _products = {};
  StreamSubscription<List<PurchaseDetails>>? _subscription;

  @override
  bool get isSupported => true;

  @override
  Stream<PurchaseEvent> get events => _events.stream;

  Future<void> _onPurchases(List<PurchaseDetails> purchases) async {
    for (final p in purchases) {
      final type = switch (p.status) {
        PurchaseStatus.pending => PurchaseEventType.pending,
        PurchaseStatus.purchased => PurchaseEventType.purchased,
        PurchaseStatus.restored => PurchaseEventType.restored,
        PurchaseStatus.error => PurchaseEventType.error,
        PurchaseStatus.canceled => PurchaseEventType.canceled,
      };
      _events.add(PurchaseEvent(p.productID, type));
      // Pflicht: Käufe bestätigen, sonst erstattet Google sie nach 3 Tagen.
      if (p.pendingCompletePurchase) {
        try {
          await _iap.completePurchase(p);
        } catch (_) {
          // Wird beim nächsten Start erneut zugestellt.
        }
      }
    }
  }

  @override
  Future<StoreProduct?> loadProduct(String productId) async {
    try {
      if (!await _iap.isAvailable()) return null;
      final response = await _iap.queryProductDetails({productId});
      if (response.productDetails.isEmpty) return null;
      final details = response.productDetails.first;
      _products[productId] = details;
      return StoreProduct(id: details.id, price: details.price);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<bool> buy(String productId) async {
    var details = _products[productId];
    if (details == null) {
      await loadProduct(productId);
      details = _products[productId];
    }
    if (details == null) return false;
    try {
      return await _iap.buyNonConsumable(
        purchaseParam: PurchaseParam(productDetails: details),
      );
    } catch (_) {
      return false;
    }
  }

  @override
  Future<void> restore() async {
    try {
      await _iap.restorePurchases();
    } catch (_) {}
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _events.close();
  }
}
