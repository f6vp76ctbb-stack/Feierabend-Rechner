// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get appTitle => 'Feierabend Rechner';

  @override
  String get brandName => 'Feierabend';

  @override
  String get unitHours => 'Std';

  @override
  String get unitMinutes => 'Min';

  @override
  String get clockOutAt => 'FEIERABEND UM';

  @override
  String get reached => 'Feierabend!';

  @override
  String get remainingLabel => 'noch';

  @override
  String get settingsTooltip => 'Einstellungen';

  @override
  String get startLabel => 'Start';

  @override
  String get workLabel => 'Arbeitszeit';

  @override
  String get breakLabel => 'Pause';

  @override
  String get breakAuto => 'automatisch angepasst';

  @override
  String get arbzgTitle => 'Pause automatisch';

  @override
  String get arbzgSubtitle =>
      'Bis 6 Std keine Pause nötig – darüber passt sie sich an.';

  @override
  String presenceSummary(String presence, String breakDuration) {
    return 'Anwesenheit $presence · inkl. $breakDuration Pause';
  }

  @override
  String get quickSelect => 'Schnellwahl';

  @override
  String get presetSixNoBreak => '6 Std ohne Pause';

  @override
  String get presetEightStandard => '8 Std + 45 min';

  @override
  String get startTimeTitle => 'Startzeit';

  @override
  String get hour => 'Stunde';

  @override
  String get minute => 'Minute';

  @override
  String get now => 'Jetzt';

  @override
  String startTimeHint(String time) {
    return 'Feierabend wird ab $time berechnet.';
  }

  @override
  String get apply => 'Übernehmen';

  @override
  String get newQuote => 'neuer Spruch';

  @override
  String get chooseJobTitle => 'Berufsgruppe wählen';

  @override
  String get chooseJobSubtitle => 'Bestimmt den Sprüche-Katalog.';

  @override
  String get profiles => 'Profile';

  @override
  String get rename => 'Umbenennen';

  @override
  String get delete => 'Löschen';

  @override
  String get atLeastOneProfile => 'Mindestens ein Profil';

  @override
  String get newProfile => 'Neues Profil';

  @override
  String get renameProfile => 'Profil umbenennen';

  @override
  String deleteProfileTitle(String name) {
    return '„$name“ löschen?';
  }

  @override
  String get deleteProfileBody => 'Das Profil wird dauerhaft entfernt.';

  @override
  String get cancel => 'Abbrechen';

  @override
  String get save => 'Speichern';

  @override
  String get profileNameHint => 'z. B. Mo–Do, Freitag, Nachtschicht';

  @override
  String get overtimeAccount => 'Überstunden-Konto';

  @override
  String overtimeThisWeek(String value) {
    return 'Diese Woche $value';
  }

  @override
  String overtimeThisWeekColon(String value) {
    return 'Diese Woche: $value';
  }

  @override
  String get totalBalance => 'GESAMTSALDO';

  @override
  String get addDay => 'Tag';

  @override
  String get bookToday => 'Heute buchen';

  @override
  String bookedToday(String value) {
    return 'Heute gebucht: $value';
  }

  @override
  String get noEntries => 'Noch keine Einträge';

  @override
  String get noEntriesHint =>
      'Tippe auf „Heute buchen“ oder „Tag“, um deinen ersten Arbeitstag zu erfassen.';

  @override
  String workedOf(String worked, String target) {
    return '$worked von $target';
  }

  @override
  String get addDayTitle => 'Tag hinzufügen';

  @override
  String get editDayTitle => 'Tag bearbeiten';

  @override
  String get worked => 'Gearbeitet';

  @override
  String get target => 'Soll';

  @override
  String balance(String value) {
    return 'Saldo: $value';
  }

  @override
  String get settings => 'Einstellungen';

  @override
  String get dailyTarget => 'Soll pro Tag';

  @override
  String get dailyTargetHint =>
      'Vergleichswert fürs Überstunden-Konto. Arbeitest du weniger, gibt es Minus – arbeitest du mehr, Plus.';

  @override
  String get appearance => 'Erscheinungsbild';

  @override
  String get themeSystem => 'System';

  @override
  String get themeLight => 'Hell';

  @override
  String get themeDark => 'Dunkel';

  @override
  String get autosaveHint =>
      'Deine Eingaben werden automatisch auf dem Gerät gespeichert.';

  @override
  String get proSection => 'Feierabend Pro';

  @override
  String get proActive => 'Pro ist aktiv – danke!';

  @override
  String proTrialActive(String time) {
    return 'Pro-Test aktiv bis $time';
  }

  @override
  String get testerBuildActive =>
      'Testversion: Pro und alle Designs sind freigeschaltet – danke fürs Testen!';

  @override
  String get unlockPro => 'Pro freischalten';

  @override
  String get restorePurchases => 'Käufe wiederherstellen';

  @override
  String get privacySettings => 'Datenschutz-Einstellungen (Werbung)';

  @override
  String get privacyPolicy => 'Datenschutzerklärung';

  @override
  String get legalSection => 'Rechtliches';

  @override
  String get proBadge => 'PRO';

  @override
  String get paywallTitle => 'Feierabend Pro';

  @override
  String get paywallSubtitle => 'Einmal zahlen. Für immer frei.';

  @override
  String get paywallBenefitNoAds => 'Keine Werbung';

  @override
  String get paywallBenefitProfiles =>
      'Unbegrenzt Profile (Mo–Do, Freitag, Schicht …)';

  @override
  String get paywallBenefitOvertime => 'Überstunden-Konto mit Wochenübersicht';

  @override
  String get paywallBenefitArbzg => 'Pause passt sich automatisch an';

  @override
  String get paywallBenefitSupport =>
      'Unterstützt einen unabhängigen Entwickler';

  @override
  String paywallBuy(String price) {
    return 'Pro freischalten – $price';
  }

  @override
  String get paywallOneTime => 'Einmalig · kein Abo · keine Werbung';

  @override
  String get paywallTrialAd => '24 Std. gratis testen (kurzes Video)';

  @override
  String get paywallUnavailable =>
      'Der Store ist gerade nicht erreichbar. Bitte später erneut versuchen.';

  @override
  String get purchaseSuccess => 'Danke! Pro ist freigeschaltet.';

  @override
  String get purchasePending => 'Kauf wird bearbeitet …';

  @override
  String get purchaseError =>
      'Kauf nicht abgeschlossen. Bitte erneut versuchen.';

  @override
  String get restoreDone => 'Käufe wurden geprüft.';

  @override
  String get trialGranted => 'Pro ist 24 Stunden freigeschaltet – viel Spaß!';

  @override
  String get adNotReady =>
      'Gerade kein Video verfügbar. Versuch es gleich nochmal.';

  @override
  String get remindersTitle => 'Erinnerungen';

  @override
  String get remindersSwitch => 'Benachrichtigungen';

  @override
  String get remindersHint =>
      'Vorwarnungen, Halbzeit und Feierabend – auf Wunsch mit Spruch.';

  @override
  String get notifChannelName => 'Feierabend-Erinnerungen';

  @override
  String get notifChannelDesc => 'Hinweise kurz vor und zum Feierabend';

  @override
  String get notifEndTitle => 'Feierabend! 🎉';

  @override
  String get notifEndBody => 'Geschafft. Ab nach Hause!';

  @override
  String get notificationsDenied =>
      'Benachrichtigungen sind in den Systemeinstellungen blockiert.';

  @override
  String get paywallBenefitReminders =>
      'Eigene Erinnerungen vor Feierabend – mit Spruch';

  @override
  String get paywallBenefitWidget => 'Live-Countdown als Home-Screen-Widget';

  @override
  String get widgetTitle => 'Home-Screen-Widget';

  @override
  String get widgetHint =>
      'Feierabend-Zeit auf dem Startbildschirm – mit Pro als Live-Countdown.';

  @override
  String get widgetAdd => 'Widget hinzufügen';

  @override
  String get widgetManual =>
      'Lange auf den Startbildschirm tippen → Widgets → Feierabend.';

  @override
  String get onbSkip => 'Überspringen';

  @override
  String get onbNext => 'Weiter';

  @override
  String get onbStart => 'Los geht\'s';

  @override
  String get onb1Title => 'Wann ist Feierabend?';

  @override
  String get onb1Body =>
      'Startzeit antippen – die App rechnet Arbeitszeit und Pause dazu und zeigt dir sofort, wann du frei hast.';

  @override
  String get onbExampleEnd => 'Feierabend';

  @override
  String get onb2Title => 'Dein Arbeitstag';

  @override
  String get onb2Body =>
      'Kurz einstellen, wie lange du arbeitest. Du kannst alles jederzeit ändern.';

  @override
  String get onbJob => 'Sprüche für';

  @override
  String get onb3Title => 'Noch mehr mit Pro';

  @override
  String get onb3Body =>
      'Einmal zahlen, kein Abo – oder erst 24 Std. gratis testen.';

  @override
  String get onb3ProActive => 'Pro ist aktiv – alles freigeschaltet.';

  @override
  String get onbSeePro => 'Pro ansehen';

  @override
  String notifLeadTitle(String duration) {
    return 'Noch $duration bis Feierabend';
  }

  @override
  String notifLeadBody(String time) {
    return 'Feierabend um $time.';
  }

  @override
  String get notifHalfTitle => 'Halbzeit! ☕';

  @override
  String notifHalfBody(String time) {
    return 'Die Hälfte ist geschafft – Feierabend um $time.';
  }

  @override
  String get reminderLeads => 'Vorwarnungen';

  @override
  String get reminderCustom => 'Eigene';

  @override
  String get reminderCustomTitle => 'Eigene Vorwarnung';

  @override
  String get reminderMaxLeads =>
      'Höchstens 6 Vorwarnungen – erst eine abwählen.';

  @override
  String get reminderHalf => 'Zur Halbzeit';

  @override
  String get reminderEnd => 'Pünktlich zum Feierabend';

  @override
  String get reminderQuote => 'Mit Spruch';

  @override
  String get reminderQuoteHint =>
      'Ein Spruch aus deiner Berufsgruppe kommt mit.';

  @override
  String get designsTitle => 'Designs';

  @override
  String get designsSubtitle =>
      'Einmal kaufen, für immer deins – und du unterstützt die Entwicklung.';

  @override
  String get designsOpen => 'Designs ansehen';

  @override
  String designCurrent(String name) {
    return 'Aktiv: $name';
  }

  @override
  String get designOwned => 'Gekauft';

  @override
  String get designActive => 'Aktiv';

  @override
  String get designFree => 'Gratis';

  @override
  String get designThanks => 'Danke! Dein neues Design ist aktiv.';

  @override
  String get designSupporterBadge => 'Größtes Dankeschön';

  @override
  String get designSupporterHint =>
      'Mit Herzen – für alle, die die App am meisten unterstützen wollen.';

  @override
  String get designNameStandard => 'Standard';

  @override
  String get designNameSupporter => 'Supporter';

  @override
  String get designNameMidnight => 'Mitternacht';

  @override
  String get designNameSunset => 'Sonnenuntergang';

  @override
  String get designNameOcean => 'Ozean';

  @override
  String get designNameForest => 'Wald';

  @override
  String get autoBreakInfoTooltip => 'Mehr Infos';

  @override
  String get autoBreakInfoTitle => 'So funktioniert die automatische Pause';

  @override
  String get autoBreakInfoBody =>
      'Die App wählt die Pause passend zu deiner Arbeitszeit:';

  @override
  String get autoBreakUpTo6 => 'Bis 6 Std Arbeit';

  @override
  String get autoBreakOver6 => 'Mehr als 6 Std';

  @override
  String get autoBreakOver9 => 'Mehr als 9 Std';

  @override
  String get autoBreakNone => 'keine Pause';

  @override
  String get autoBreakLegal =>
      'Grundlage sind die Mindestpausen des deutschen Arbeitszeitgesetzes (§ 4 ArbZG). Die Pausenregel in deinem Betrieb kann abweichen.';
}
