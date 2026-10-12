import 'monetization_config.dart';

/// Feste Angaben zur App (Store-Link, Kontakt, Version).
abstract final class AppInfo {
  static const packageName = 'com.thinkube.feierabendrechner';

  static const playStoreUrl =
      'https://play.google.com/store/apps/details?id=$packageName';

  static const contactEmail = 'thinkube@outlook.de';

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
