import 'dart:async';

import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../config/monetization_config.dart';

/// Abstraktion über AdMob inkl. Einwilligung (UMP/DSGVO), damit Tests und die
/// Web-Vorschau ohne Werbe-SDK laufen.
abstract class AdsBackend {
  bool get isSupported;

  /// Fragt (falls nötig) die Einwilligung ab und startet das Werbe-SDK.
  /// Liefert `true`, wenn Anzeigen angefordert werden dürfen.
  Future<bool> initialize();

  /// Muss die App einen Einstieg zu den Datenschutz-Optionen anbieten? (EU/UK)
  Future<bool> privacyOptionsRequired();
  Future<void> showPrivacyOptions();

  /// Lädt und zeigt ein Belohnungsvideo. `true`, wenn die Belohnung verdient wurde.
  Future<bool> showRewarded();
}

class NoopAdsBackend implements AdsBackend {
  @override
  bool get isSupported => false;
  @override
  Future<bool> initialize() async => false;
  @override
  Future<bool> privacyOptionsRequired() async => false;
  @override
  Future<void> showPrivacyOptions() async {}
  @override
  Future<bool> showRewarded() async => false;
}

class GoogleAdsBackend implements AdsBackend {
  bool _sdkStarted = false;
  Future<bool>? _initFuture;

  @override
  bool get isSupported => true;

  @override
  Future<bool> initialize() => _initFuture ??= _initialize();

  Future<bool> _initialize() async {
    final done = Completer<void>();
    try {
      ConsentInformation.instance.requestConsentInfoUpdate(
        ConsentRequestParameters(),
        () async {
          try {
            await ConsentForm.loadAndShowConsentFormIfRequired((_) {});
          } finally {
            if (!done.isCompleted) done.complete();
          }
        },
        (_) {
          if (!done.isCompleted) done.complete();
        },
      );
      await done.future.timeout(const Duration(seconds: 20), onTimeout: () {});
      final allowed = await ConsentInformation.instance.canRequestAds();
      if (allowed && !_sdkStarted) {
        await MobileAds.instance.initialize();
        _sdkStarted = true;
      }
      return allowed;
    } catch (_) {
      _initFuture = null; // Beim nächsten Mal erneut versuchen.
      return false;
    }
  }

  @override
  Future<bool> privacyOptionsRequired() async {
    try {
      final status =
          await ConsentInformation.instance.getPrivacyOptionsRequirementStatus();
      return status == PrivacyOptionsRequirementStatus.required;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<void> showPrivacyOptions() async {
    try {
      await ConsentForm.showPrivacyOptionsForm((_) {});
    } catch (_) {}
  }

  @override
  Future<bool> showRewarded() async {
    if (!await initialize()) return false;
    final loaded = Completer<RewardedAd?>();
    await RewardedAd.load(
      adUnitId: MonetizationConfig.rewardedAdUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) => loaded.complete(ad),
        onAdFailedToLoad: (_) => loaded.complete(null),
      ),
    );
    final ad = await loaded.future
        .timeout(const Duration(seconds: 15), onTimeout: () => null);
    if (ad == null) return false;

    var earned = false;
    final finished = Completer<bool>();
    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        if (!finished.isCompleted) finished.complete(earned);
      },
      onAdFailedToShowFullScreenContent: (ad, _) {
        ad.dispose();
        if (!finished.isCompleted) finished.complete(false);
      },
    );
    await ad.show(onUserEarnedReward: (_, _) => earned = true);
    return finished.future;
  }
}
