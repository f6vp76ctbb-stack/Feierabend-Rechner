import 'monetization_config.dart';

/// Feste Angaben zur App (Store-Link, Kontakt, Version).
abstract final class AppInfo {
  static const packageName = 'com.thinkube.feierabendrechner';

  static const playStoreUrl =
      'https://play.google.com/store/apps/details?id=$packageName';

  static const contactEmail = 'thinkube@outlook.de';

  /// Anbieter für Impressum (§ 5 DDG) und Datenschutzerklärung – an einer Stelle,
  /// gleich wie bei der App „Qubble“ (web/impressum.html dort). Einzelunternehmen:
  /// Pflicht ist der volle Name, „Thinkube“ ist nur die Geschäftsbezeichnung.
  /// USt-IdNr./W-IdNr. gehören dazu, sobald vorhanden – die Steuernummer nie.
  static const providerName = 'Sam Däubler';
  static const businessName = 'Thinkube';
  static const providerStreet = 'Mähderweg 5';
  static const providerCity = '88451 Dettingen';

  /// Online-Fassung (Datenschutzerklärung: `MonetizationConfig.privacyPolicyUrl`).
  static const legalNoticeUrl =
      'https://f6vp76ctbb-stack.github.io/Feierabend-Rechner/impressum.html';

  /// Version – CI setzt den versionCode per `--dart-define=APP_VERSION_CODE`.
  static const versionName =
      String.fromEnvironment('APP_VERSION_NAME', defaultValue: '1.0.0');
  static const versionCode = String.fromEnvironment('APP_VERSION_CODE');

  /// Für Feedback-Mails, z. B. „1.0.0 (39) · Tester“.
  static String get versionLabel => [
        versionName,
        if (versionCode.isNotEmpty) '($versionCode)',
        if (MonetizationConfig.testerBuild) '· Tester',
      ].join(' ');
}
