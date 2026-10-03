import 'package:firebase_core/firebase_core.dart';

/// Firebase-Projekt für die Nutzungsstatistik (Google Analytics 4).
///
/// Die Werte stammen aus `google-services.json` und werden beim Build per
/// `--dart-define` gesetzt (siehe `android-bundle.yml`). Sie sind nicht geheim –
/// sie stehen ohnehin in jeder App. Fehlen sie, bleibt Analytics komplett aus.
abstract final class FirebaseConfig {
  static const _apiKey = String.fromEnvironment('FIREBASE_API_KEY');
  static const _appId = String.fromEnvironment('FIREBASE_APP_ID');
  static const _senderId = String.fromEnvironment('FIREBASE_SENDER_ID');
  static const _projectId = String.fromEnvironment('FIREBASE_PROJECT_ID');

  static bool get isConfigured =>
      _apiKey.isNotEmpty &&
      _appId.isNotEmpty &&
      _senderId.isNotEmpty &&
      _projectId.isNotEmpty;

  static FirebaseOptions get options => const FirebaseOptions(
        apiKey: _apiKey,
        appId: _appId,
        messagingSenderId: _senderId,
        projectId: _projectId,
      );
}
