import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../config/monetization_config.dart';
import '../../services/ads_backend.dart';
import '../../services/purchase_backend.dart';
import '../home/state/home_providers.dart';

/// Store-Anbindung. In Tests/Screenshots per Override ersetzbar.
final purchaseBackendProvider = Provider<PurchaseBackend>((ref) {
  final backend = MonetizationConfig.isMobile
      ? StorePurchaseBackend()
      : NoopPurchaseBackend();
  ref.onDispose(backend.dispose);
  return backend;
});

/// Werbe-Anbindung (AdMob + Einwilligung). In Tests per Override ersetzbar.
final adsBackendProvider = Provider<AdsBackend>(
  (ref) => MonetizationConfig.isMobile ? GoogleAdsBackend() : NoopAdsBackend(),
);

/// Store-Ereignisse (für Hinweise in der UI, z. B. „Kauf wird bearbeitet").
final purchaseEventsProvider = StreamProvider<PurchaseEvent>(
  (ref) => ref.watch(purchaseBackendProvider).events,
);

class ProState {
  final bool purchased;
  final DateTime? trialUntil;

  const ProState({this.purchased = false, this.trialUntil});

  bool isTrialActive(DateTime now) =>
      trialUntil != null && now.isBefore(trialUntil!);

  ProState copyWith({bool? purchased, DateTime? trialUntil}) => ProState(
        purchased: purchased ?? this.purchased,
        trialUntil: trialUntil ?? this.trialUntil,
      );
}

/// Pro-Freischaltung: dauerhafter Kauf (vom Store bestätigt, lokal gecacht)
/// oder befristeter Test nach einem Belohnungsvideo.
class ProController extends Notifier<ProState> {
  @override
  ProState build() {
    final repo = ref.read(settingsRepositoryProvider);
    final backend = ref.watch(purchaseBackendProvider);
    final sub = backend.events.listen((event) {
      if (event.productId == MonetizationConfig.proProductId &&
          event.grantsEntitlement) {
        _setPurchased();
      }
    });
    ref.onDispose(sub.cancel);
    // Beim Start still prüfen, ob schon gekauft wurde (z. B. Neuinstallation).
    if (backend.isSupported) Future.microtask(backend.restore);
    return ProState(
      purchased: repo.loadProPurchased(),
      trialUntil: repo.loadProTrialUntil(),
    );
  }

  void _setPurchased() {
    if (state.purchased) return;
    state = state.copyWith(purchased: true);
    ref.read(settingsRepositoryProvider).saveProPurchased(true);
  }

  /// Öffnet den Kauf-Dialog des Stores. `false`, wenn der Store nicht erreichbar ist.
  Future<bool> buy() =>
      ref.read(purchaseBackendProvider).buy(MonetizationConfig.proProductId);

  Future<void> restore() => ref.read(purchaseBackendProvider).restore();

  /// Schaltet Pro für [duration] frei (nach einem Belohnungsvideo).
  void grantTrial(Duration duration, {DateTime? now}) {
    final until = (now ?? DateTime.now()).add(duration);
    state = state.copyWith(trialUntil: until);
    ref.read(settingsRepositoryProvider).saveProTrialUntil(until);
  }
}

final proControllerProvider =
    NotifierProvider<ProController, ProState>(ProController.new);

/// Ist Pro gerade aktiv? In der Web-Vorschau immer (dort gibt es keinen Store).
final isProProvider = Provider<bool>((ref) {
  if (kIsWeb) return true;
  final state = ref.watch(proControllerProvider);
  if (state.purchased) return true;
  final now = ref.watch(nowProvider).valueOrNull ?? DateTime.now();
  return state.isTrialActive(now);
});

/// Preis des Pro-Kaufs aus dem Store (null, wenn nicht ladbar).
final proProductProvider = FutureProvider<StoreProduct?>((ref) {
  return ref
      .watch(purchaseBackendProvider)
      .loadProduct(MonetizationConfig.proProductId);
});

/// Werbung bereit? (SDK gestartet + Einwilligung erlaubt Anfragen)
class AdsController extends Notifier<bool> {
  bool _started = false;

  @override
  bool build() => false;

  Future<void> ensureStarted() async {
    if (_started) return;
    final backend = ref.read(adsBackendProvider);
    if (!backend.isSupported) return;
    _started = true;
    final ready = await backend.initialize();
    if (!ready) _started = false;
    state = ready;
  }
}

final adsReadyProvider =
    NotifierProvider<AdsController, bool>(AdsController.new);

/// Muss ein Einstieg zu den Werbe-Datenschutzoptionen angeboten werden?
final privacyOptionsRequiredProvider = FutureProvider<bool>((ref) async {
  ref.watch(adsReadyProvider); // nach Einwilligung neu prüfen
  return ref.read(adsBackendProvider).privacyOptionsRequired();
});
