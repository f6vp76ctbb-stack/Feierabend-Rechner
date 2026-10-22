import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Lizenzen, die Flutter nicht von selbst kennt (die der Pakete sammelt es
/// automatisch): die gebündelte Schrift Inter (SIL Open Font License 1.1).
void registerExtraLicenses() {
  LicenseRegistry.addLicense(() async* {
    final text = await rootBundle.loadString('assets/licenses/Inter-OFL.txt');
    yield LicenseEntryWithLineBreaks(const ['Inter (font)'], text);
  });
}
