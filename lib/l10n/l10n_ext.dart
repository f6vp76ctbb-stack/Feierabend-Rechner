import 'package:flutter/widgets.dart';

import '../core/formatting.dart';
import 'app_localizations.dart';

/// Kurzer Zugriff auf Übersetzungen und sprachabhängige Einheiten.
extension L10nContext on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);

  Units get units => Units(hour: l10n.unitHours, minute: l10n.unitMinutes);

  /// Sprachcode (`de`/`en`) der aktuellen UI.
  String get lang => Localizations.localeOf(this).languageCode;
}
