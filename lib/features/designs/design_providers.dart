import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../design/app_designs.dart';
import '../../services/purchase_backend.dart';
import '../home/state/home_providers.dart';
import '../pro/pro_providers.dart';

class DesignsState {
  /// IDs der gekauften Designs (Standard ist immer dabei).
  final Set<String> owned;

  /// Gewähltes Design.
  final String selected;

  /// Web-Vorschau / Tester-Version: alles zum Ausprobieren freigeschaltet.
  final bool unlockAll;

  const DesignsState({
    required this.owned,
    required this.selected,
    this.unlockAll = false,
  });

  bool owns(AppDesign d) => unlockAll || d.isFree || owned.contains(d.id);

  DesignsState copyWith({Set<String>? owned, String? selected}) => DesignsState(
        owned: owned ?? this.owned,
        selected: selected ?? this.selected,
        unlockAll: unlockAll,
      );
}

/// Gekaufte Designs (vom Store bestätigt, lokal gecacht) und das gewählte Design.
///
/// Wiederherstellen läuft über denselben Store-Abgleich wie Pro
/// (`ProController` stößt ihn beim Start an).
class DesignsController extends Notifier<DesignsState> {
  @override
  DesignsState build() {
    final repo = ref.read(settingsRepositoryProvider);
    final backend = ref.watch(purchaseBackendProvider);
    final sub = backend.events.listen((event) {
      final design = AppDesigns.byProductId(event.productId);
      if (design == null || !event.grantsEntitlement) return;
      // Frisch gekauft → gleich anziehen; wiederhergestellt → nur freischalten.
      _grant(design, select: event.type == PurchaseEventType.purchased);
    });
    ref.onDispose(sub.cancel);
    return DesignsState(
      owned: repo.loadOwnedDesigns(),
      selected: repo.loadSelectedDesign() ?? AppDesigns.standard.id,
      unlockAll: kIsWeb || ref.watch(testerBuildProvider),
    );
  }

  void _grant(AppDesign design, {required bool select}) {
    if (!state.owned.contains(design.id)) {
      state = state.copyWith(owned: {...state.owned, design.id});
      ref.read(settingsRepositoryProvider).saveOwnedDesigns(state.owned);
    }
    if (select) this.select(design);
  }

  /// Wählt ein Design – nur, wenn es gratis oder gekauft ist.
  bool select(AppDesign design) {
    if (!state.owns(design)) return false;
    state = state.copyWith(selected: design.id);
    ref.read(settingsRepositoryProvider).saveSelectedDesign(design.id);
    return true;
  }

  /// Öffnet den Kauf-Dialog. `false`, wenn der Store nicht erreichbar ist.
  Future<bool> buy(AppDesign design) async {
    final productId = design.productId;
    if (productId == null) return false;
    return ref.read(purchaseBackendProvider).buy(productId);
  }
}

final designsProvider =
    NotifierProvider<DesignsController, DesignsState>(DesignsController.new);

/// Aktives Design (fällt auf Standard zurück, falls nicht – mehr – gekauft).
final activeDesignProvider = Provider<AppDesign>((ref) {
  final state = ref.watch(designsProvider);
  final design = AppDesigns.byId(state.selected);
  return state.owns(design) ? design : AppDesigns.standard;
});

/// Lokalisierter Store-Preis eines Designs (null, wenn nicht ladbar).
final designPriceProvider =
    FutureProvider.family<String?, String>((ref, productId) async {
  final product =
      await ref.watch(purchaseBackendProvider).loadProduct(productId);
  return product?.price;
});
