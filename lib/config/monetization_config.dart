import 'package:flutter/foundation.dart';

/// Zentrale IDs für In-App-Kauf und Werbung.
///
/// AdMob-Anzeigenblöcke werden beim Build per `--dart-define` gesetzt
/// (siehe `store/ADMOB.md`). Ohne Angabe gelten Googles offizielle Test-IDs –
/// die zeigen „Test Ad"-Banner und verdienen nichts, sind aber für interne Tests
/// genau richtig (eigene echte Anzeigen anklicken ist verboten).
abstract final class MonetizationConfig {
  /// Produkt-ID des einmaligen Pro-Kaufs. Muss exakt so in der Play Console
  /// unter „Monetarisieren → Produkte → In-App-Produkte" angelegt werden.
  static const proProductId = 'feierabend_pro';

  static const _testPublisher = 'ca-app-pub-3940256099942544';

  static const _bannerAndroid = String.fromEnvironment(
    'ADMOB_BANNER_ANDROID',
    defaultValue: '$_testPublisher/9214589741',
  );
  static const _rewardedAndroid = String.fromEnvironment(
    'ADMOB_REWARDED_ANDROID',
    defaultValue: '$_testPublisher/5224354917',
  );
  static const _bannerIos = String.fromEnvironment(
    'ADMOB_BANNER_IOS',
    defaultValue: '$_testPublisher/2435281174',
  );
  static const _rewardedIos = String.fromEnvironment(
    'ADMOB_REWARDED_IOS',
    defaultValue: '$_testPublisher/1712485313',
  );

  static bool get _isIos => defaultTargetPlatform == TargetPlatform.iOS;

  static String get bannerAdUnitId => _isIos ? _bannerIos : _bannerAndroid;
  static String get rewardedAdUnitId => _isIos ? _rewardedIos : _rewardedAndroid;

  /// `true`, solange noch Googles Test-Anzeigenblöcke eingebaut sind.
  static bool get usesTestAds => bannerAdUnitId.startsWith(_testPublisher);

  /// Werbung & Store gibt es nur in den mobilen Apps (nicht in der Web-Vorschau).
  static bool get isMobile =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS);

  /// Tester-Version für den geschlossenen Test (`--dart-define=TESTER_BUILD=true`):
  /// Pro und alle Designs sind freigeschaltet, Werbung startet gar nicht erst.
  /// Gehört NUR in den Test-Track – der Store-Build setzt das nie → `false`.
  static const testerBuild = bool.fromEnvironment('TESTER_BUILD');

  /// Dauer des Gratis-Tests nach einem Belohnungsvideo.
  static const rewardedTrial = Duration(hours: 24);

  /// Öffentliche Datenschutzerklärung (liegt in `web/privacy.html`).
  static const privacyPolicyUrl =
      'https://f6vp76ctbb-stack.github.io/Feierabend-Rechner/privacy.html';
}
