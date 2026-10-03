import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('de'),
    Locale('en'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In de, this message translates to:
  /// **'Feierabend Rechner'**
  String get appTitle;

  /// No description provided for @brandName.
  ///
  /// In de, this message translates to:
  /// **'Feierabend'**
  String get brandName;

  /// No description provided for @unitHours.
  ///
  /// In de, this message translates to:
  /// **'Std'**
  String get unitHours;

  /// No description provided for @unitMinutes.
  ///
  /// In de, this message translates to:
  /// **'Min'**
  String get unitMinutes;

  /// No description provided for @clockOutAt.
  ///
  /// In de, this message translates to:
  /// **'FEIERABEND UM'**
  String get clockOutAt;

  /// No description provided for @reached.
  ///
  /// In de, this message translates to:
  /// **'Feierabend!'**
  String get reached;

  /// No description provided for @remainingLabel.
  ///
  /// In de, this message translates to:
  /// **'noch'**
  String get remainingLabel;

  /// No description provided for @settingsTooltip.
  ///
  /// In de, this message translates to:
  /// **'Einstellungen'**
  String get settingsTooltip;

  /// No description provided for @startLabel.
  ///
  /// In de, this message translates to:
  /// **'Start'**
  String get startLabel;

  /// No description provided for @workLabel.
  ///
  /// In de, this message translates to:
  /// **'Arbeitszeit'**
  String get workLabel;

  /// No description provided for @breakLabel.
  ///
  /// In de, this message translates to:
  /// **'Pause'**
  String get breakLabel;

  /// No description provided for @breakAuto.
  ///
  /// In de, this message translates to:
  /// **'automatisch angepasst'**
  String get breakAuto;

  /// No description provided for @arbzgTitle.
  ///
  /// In de, this message translates to:
  /// **'Pause automatisch'**
  String get arbzgTitle;

  /// No description provided for @arbzgSubtitle.
  ///
  /// In de, this message translates to:
  /// **'Bis 6 Std keine Pause nötig – darüber passt sie sich an.'**
  String get arbzgSubtitle;

  /// No description provided for @presenceSummary.
  ///
  /// In de, this message translates to:
  /// **'Anwesenheit {presence} · inkl. {breakDuration} Pause'**
  String presenceSummary(String presence, String breakDuration);

  /// No description provided for @quickSelect.
  ///
  /// In de, this message translates to:
  /// **'Schnellwahl'**
  String get quickSelect;

  /// No description provided for @presetSixNoBreak.
  ///
  /// In de, this message translates to:
  /// **'6 Std ohne Pause'**
  String get presetSixNoBreak;

  /// No description provided for @presetEightStandard.
  ///
  /// In de, this message translates to:
  /// **'8 Std + 45 min'**
  String get presetEightStandard;

  /// No description provided for @startTimeTitle.
  ///
  /// In de, this message translates to:
  /// **'Startzeit'**
  String get startTimeTitle;

  /// No description provided for @hour.
  ///
  /// In de, this message translates to:
  /// **'Stunde'**
  String get hour;

  /// No description provided for @minute.
  ///
  /// In de, this message translates to:
  /// **'Minute'**
  String get minute;

  /// No description provided for @now.
  ///
  /// In de, this message translates to:
  /// **'Jetzt'**
  String get now;

  /// No description provided for @startTimeHint.
  ///
  /// In de, this message translates to:
  /// **'Feierabend wird ab {time} berechnet.'**
  String startTimeHint(String time);

  /// No description provided for @apply.
  ///
  /// In de, this message translates to:
  /// **'Übernehmen'**
  String get apply;

  /// No description provided for @newQuote.
  ///
  /// In de, this message translates to:
  /// **'neuer Spruch'**
  String get newQuote;

  /// No description provided for @chooseJobTitle.
  ///
  /// In de, this message translates to:
  /// **'Berufsgruppe wählen'**
  String get chooseJobTitle;

  /// No description provided for @chooseJobSubtitle.
  ///
  /// In de, this message translates to:
  /// **'Bestimmt den Sprüche-Katalog.'**
  String get chooseJobSubtitle;

  /// No description provided for @profiles.
  ///
  /// In de, this message translates to:
  /// **'Profile'**
  String get profiles;

  /// No description provided for @rename.
  ///
  /// In de, this message translates to:
  /// **'Umbenennen'**
  String get rename;

  /// No description provided for @delete.
  ///
  /// In de, this message translates to:
  /// **'Löschen'**
  String get delete;

  /// No description provided for @atLeastOneProfile.
  ///
  /// In de, this message translates to:
  /// **'Mindestens ein Profil'**
  String get atLeastOneProfile;

  /// No description provided for @newProfile.
  ///
  /// In de, this message translates to:
  /// **'Neues Profil'**
  String get newProfile;

  /// No description provided for @renameProfile.
  ///
  /// In de, this message translates to:
  /// **'Profil umbenennen'**
  String get renameProfile;

  /// No description provided for @deleteProfileTitle.
  ///
  /// In de, this message translates to:
  /// **'„{name}“ löschen?'**
  String deleteProfileTitle(String name);

  /// No description provided for @deleteProfileBody.
  ///
  /// In de, this message translates to:
  /// **'Das Profil wird dauerhaft entfernt.'**
  String get deleteProfileBody;

  /// No description provided for @cancel.
  ///
  /// In de, this message translates to:
  /// **'Abbrechen'**
  String get cancel;

  /// No description provided for @save.
  ///
  /// In de, this message translates to:
  /// **'Speichern'**
  String get save;

  /// No description provided for @profileNameHint.
  ///
  /// In de, this message translates to:
  /// **'z. B. Mo–Do, Freitag, Nachtschicht'**
  String get profileNameHint;

  /// No description provided for @overtimeAccount.
  ///
  /// In de, this message translates to:
  /// **'Überstunden-Konto'**
  String get overtimeAccount;

  /// No description provided for @overtimeThisWeek.
  ///
  /// In de, this message translates to:
  /// **'Diese Woche {value}'**
  String overtimeThisWeek(String value);

  /// No description provided for @overtimeThisWeekColon.
  ///
  /// In de, this message translates to:
  /// **'Diese Woche: {value}'**
  String overtimeThisWeekColon(String value);

  /// No description provided for @totalBalance.
  ///
  /// In de, this message translates to:
  /// **'GESAMTSALDO'**
  String get totalBalance;

  /// No description provided for @addDay.
  ///
  /// In de, this message translates to:
  /// **'Tag'**
  String get addDay;

  /// No description provided for @bookToday.
  ///
  /// In de, this message translates to:
  /// **'Heute buchen'**
  String get bookToday;

  /// No description provided for @bookedToday.
  ///
  /// In de, this message translates to:
  /// **'Heute gebucht: {value}'**
  String bookedToday(String value);

  /// No description provided for @noEntries.
  ///
  /// In de, this message translates to:
  /// **'Noch keine Einträge'**
  String get noEntries;

  /// No description provided for @noEntriesHint.
  ///
  /// In de, this message translates to:
  /// **'Tippe auf „Heute buchen“ oder „Tag“, um deinen ersten Arbeitstag zu erfassen.'**
  String get noEntriesHint;

  /// No description provided for @workedOf.
  ///
  /// In de, this message translates to:
  /// **'{worked} von {target}'**
  String workedOf(String worked, String target);

  /// No description provided for @addDayTitle.
  ///
  /// In de, this message translates to:
  /// **'Tag hinzufügen'**
  String get addDayTitle;

  /// No description provided for @editDayTitle.
  ///
  /// In de, this message translates to:
  /// **'Tag bearbeiten'**
  String get editDayTitle;

  /// No description provided for @worked.
  ///
  /// In de, this message translates to:
  /// **'Gearbeitet'**
  String get worked;

  /// No description provided for @target.
  ///
  /// In de, this message translates to:
  /// **'Soll'**
  String get target;

  /// No description provided for @balance.
  ///
  /// In de, this message translates to:
  /// **'Saldo: {value}'**
  String balance(String value);

  /// No description provided for @settings.
  ///
  /// In de, this message translates to:
  /// **'Einstellungen'**
  String get settings;

  /// No description provided for @dailyTarget.
  ///
  /// In de, this message translates to:
  /// **'Soll pro Tag'**
  String get dailyTarget;

  /// No description provided for @dailyTargetHint.
  ///
  /// In de, this message translates to:
  /// **'Vergleichswert fürs Überstunden-Konto. Arbeitest du weniger, gibt es Minus – arbeitest du mehr, Plus.'**
  String get dailyTargetHint;

  /// No description provided for @appearance.
  ///
  /// In de, this message translates to:
  /// **'Erscheinungsbild'**
  String get appearance;

  /// No description provided for @themeSystem.
  ///
  /// In de, this message translates to:
  /// **'System'**
  String get themeSystem;

  /// No description provided for @themeLight.
  ///
  /// In de, this message translates to:
  /// **'Hell'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In de, this message translates to:
  /// **'Dunkel'**
  String get themeDark;

  /// No description provided for @autosaveHint.
  ///
  /// In de, this message translates to:
  /// **'Deine Eingaben werden automatisch auf dem Gerät gespeichert.'**
  String get autosaveHint;

  /// No description provided for @proSection.
  ///
  /// In de, this message translates to:
  /// **'Feierabend Pro'**
  String get proSection;

  /// No description provided for @proActive.
  ///
  /// In de, this message translates to:
  /// **'Pro ist aktiv – danke!'**
  String get proActive;

  /// No description provided for @proTrialActive.
  ///
  /// In de, this message translates to:
  /// **'Pro-Test aktiv bis {time}'**
  String proTrialActive(String time);

  /// Nur in der Tester-Version für den geschlossenen Test
  ///
  /// In de, this message translates to:
  /// **'Testversion: Pro und alle Designs sind freigeschaltet – danke fürs Testen!'**
  String get testerBuildActive;

  /// No description provided for @unlockPro.
  ///
  /// In de, this message translates to:
  /// **'Pro freischalten'**
  String get unlockPro;

  /// No description provided for @restorePurchases.
  ///
  /// In de, this message translates to:
  /// **'Käufe wiederherstellen'**
  String get restorePurchases;

  /// No description provided for @privacySettings.
  ///
  /// In de, this message translates to:
  /// **'Datenschutz-Einstellungen (Werbung)'**
  String get privacySettings;

  /// No description provided for @privacyPolicy.
  ///
  /// In de, this message translates to:
  /// **'Datenschutzerklärung'**
  String get privacyPolicy;

  /// No description provided for @legalSection.
  ///
  /// In de, this message translates to:
  /// **'Rechtliches'**
  String get legalSection;

  /// No description provided for @proBadge.
  ///
  /// In de, this message translates to:
  /// **'PRO'**
  String get proBadge;

  /// No description provided for @paywallTitle.
  ///
  /// In de, this message translates to:
  /// **'Feierabend Pro'**
  String get paywallTitle;

  /// No description provided for @paywallSubtitle.
  ///
  /// In de, this message translates to:
  /// **'Einmal zahlen. Für immer frei.'**
  String get paywallSubtitle;

  /// No description provided for @paywallBenefitNoAds.
  ///
  /// In de, this message translates to:
  /// **'Keine Werbung'**
  String get paywallBenefitNoAds;

  /// No description provided for @paywallBenefitProfiles.
  ///
  /// In de, this message translates to:
  /// **'Unbegrenzt Profile (Mo–Do, Freitag, Schicht …)'**
  String get paywallBenefitProfiles;

  /// No description provided for @paywallBenefitOvertime.
  ///
  /// In de, this message translates to:
  /// **'Überstunden-Konto mit Wochenübersicht'**
  String get paywallBenefitOvertime;

  /// No description provided for @paywallBenefitArbzg.
  ///
  /// In de, this message translates to:
  /// **'Pause passt sich automatisch an'**
  String get paywallBenefitArbzg;

  /// No description provided for @paywallBenefitSupport.
  ///
  /// In de, this message translates to:
  /// **'Unterstützt einen unabhängigen Entwickler'**
  String get paywallBenefitSupport;

  /// No description provided for @paywallBuy.
  ///
  /// In de, this message translates to:
  /// **'Pro freischalten – {price}'**
  String paywallBuy(String price);

  /// No description provided for @paywallOneTime.
  ///
  /// In de, this message translates to:
  /// **'Einmalig · kein Abo · keine Werbung'**
  String get paywallOneTime;

  /// No description provided for @paywallTrialAd.
  ///
  /// In de, this message translates to:
  /// **'24 Std. gratis testen (kurzes Video)'**
  String get paywallTrialAd;

  /// No description provided for @paywallUnavailable.
  ///
  /// In de, this message translates to:
  /// **'Der Store ist gerade nicht erreichbar. Bitte später erneut versuchen.'**
  String get paywallUnavailable;

  /// No description provided for @purchaseSuccess.
  ///
  /// In de, this message translates to:
  /// **'Danke! Pro ist freigeschaltet.'**
  String get purchaseSuccess;

  /// No description provided for @purchasePending.
  ///
  /// In de, this message translates to:
  /// **'Kauf wird bearbeitet …'**
  String get purchasePending;

  /// No description provided for @purchaseError.
  ///
  /// In de, this message translates to:
  /// **'Kauf nicht abgeschlossen. Bitte erneut versuchen.'**
  String get purchaseError;

  /// No description provided for @restoreDone.
  ///
  /// In de, this message translates to:
  /// **'Käufe wurden geprüft.'**
  String get restoreDone;

  /// No description provided for @trialGranted.
  ///
  /// In de, this message translates to:
  /// **'Pro ist 24 Stunden freigeschaltet – viel Spaß!'**
  String get trialGranted;

  /// No description provided for @adNotReady.
  ///
  /// In de, this message translates to:
  /// **'Gerade kein Video verfügbar. Versuch es gleich nochmal.'**
  String get adNotReady;

  /// No description provided for @remindersTitle.
  ///
  /// In de, this message translates to:
  /// **'Erinnerungen'**
  String get remindersTitle;

  /// No description provided for @remindersSwitch.
  ///
  /// In de, this message translates to:
  /// **'Benachrichtigungen'**
  String get remindersSwitch;

  /// No description provided for @remindersHint.
  ///
  /// In de, this message translates to:
  /// **'Vorwarnungen, Halbzeit und Feierabend – auf Wunsch mit Spruch.'**
  String get remindersHint;

  /// No description provided for @notifChannelName.
  ///
  /// In de, this message translates to:
  /// **'Feierabend-Erinnerungen'**
  String get notifChannelName;

  /// No description provided for @notifChannelDesc.
  ///
  /// In de, this message translates to:
  /// **'Hinweise kurz vor und zum Feierabend'**
  String get notifChannelDesc;

  /// No description provided for @notifEndTitle.
  ///
  /// In de, this message translates to:
  /// **'Feierabend! 🎉'**
  String get notifEndTitle;

  /// No description provided for @notifEndBody.
  ///
  /// In de, this message translates to:
  /// **'Geschafft. Ab nach Hause!'**
  String get notifEndBody;

  /// No description provided for @notificationsDenied.
  ///
  /// In de, this message translates to:
  /// **'Benachrichtigungen sind in den Systemeinstellungen blockiert.'**
  String get notificationsDenied;

  /// No description provided for @paywallBenefitReminders.
  ///
  /// In de, this message translates to:
  /// **'Eigene Erinnerungen vor Feierabend – mit Spruch'**
  String get paywallBenefitReminders;

  /// No description provided for @paywallBenefitWidget.
  ///
  /// In de, this message translates to:
  /// **'Live-Countdown als Home-Screen-Widget'**
  String get paywallBenefitWidget;

  /// No description provided for @widgetTitle.
  ///
  /// In de, this message translates to:
  /// **'Home-Screen-Widget'**
  String get widgetTitle;

  /// No description provided for @widgetHint.
  ///
  /// In de, this message translates to:
  /// **'Feierabend-Zeit auf dem Startbildschirm – mit Pro als Live-Countdown.'**
  String get widgetHint;

  /// No description provided for @widgetAdd.
  ///
  /// In de, this message translates to:
  /// **'Widget hinzufügen'**
  String get widgetAdd;

  /// No description provided for @widgetManual.
  ///
  /// In de, this message translates to:
  /// **'Lange auf den Startbildschirm tippen → Widgets → Feierabend.'**
  String get widgetManual;

  /// No description provided for @onbSkip.
  ///
  /// In de, this message translates to:
  /// **'Überspringen'**
  String get onbSkip;

  /// No description provided for @onbNext.
  ///
  /// In de, this message translates to:
  /// **'Weiter'**
  String get onbNext;

  /// No description provided for @onbStart.
  ///
  /// In de, this message translates to:
  /// **'Los geht\'s'**
  String get onbStart;

  /// No description provided for @onb1Title.
  ///
  /// In de, this message translates to:
  /// **'Wann ist Feierabend?'**
  String get onb1Title;

  /// No description provided for @onb1Body.
  ///
  /// In de, this message translates to:
  /// **'Startzeit antippen – die App rechnet Arbeitszeit und Pause dazu und zeigt dir sofort, wann du frei hast.'**
  String get onb1Body;

  /// No description provided for @onbExampleEnd.
  ///
  /// In de, this message translates to:
  /// **'Feierabend'**
  String get onbExampleEnd;

  /// No description provided for @onb2Title.
  ///
  /// In de, this message translates to:
  /// **'Dein Arbeitstag'**
  String get onb2Title;

  /// No description provided for @onb2Body.
  ///
  /// In de, this message translates to:
  /// **'Kurz einstellen, wie lange du arbeitest. Du kannst alles jederzeit ändern.'**
  String get onb2Body;

  /// No description provided for @onbJob.
  ///
  /// In de, this message translates to:
  /// **'Sprüche für'**
  String get onbJob;

  /// No description provided for @onb3Title.
  ///
  /// In de, this message translates to:
  /// **'Noch mehr mit Pro'**
  String get onb3Title;

  /// No description provided for @onb3Body.
  ///
  /// In de, this message translates to:
  /// **'Einmal zahlen, kein Abo – oder erst 24 Std. gratis testen.'**
  String get onb3Body;

  /// No description provided for @onb3ProActive.
  ///
  /// In de, this message translates to:
  /// **'Pro ist aktiv – alles freigeschaltet.'**
  String get onb3ProActive;

  /// No description provided for @onbSeePro.
  ///
  /// In de, this message translates to:
  /// **'Pro ansehen'**
  String get onbSeePro;

  /// No description provided for @notifLeadTitle.
  ///
  /// In de, this message translates to:
  /// **'Noch {duration} bis Feierabend'**
  String notifLeadTitle(String duration);

  /// No description provided for @notifLeadBody.
  ///
  /// In de, this message translates to:
  /// **'Feierabend um {time}.'**
  String notifLeadBody(String time);

  /// No description provided for @notifHalfTitle.
  ///
  /// In de, this message translates to:
  /// **'Halbzeit! ☕'**
  String get notifHalfTitle;

  /// No description provided for @notifHalfBody.
  ///
  /// In de, this message translates to:
  /// **'Die Hälfte ist geschafft – Feierabend um {time}.'**
  String notifHalfBody(String time);

  /// No description provided for @reminderLeads.
  ///
  /// In de, this message translates to:
  /// **'Vorwarnungen'**
  String get reminderLeads;

  /// No description provided for @reminderCustom.
  ///
  /// In de, this message translates to:
  /// **'Eigene'**
  String get reminderCustom;

  /// No description provided for @reminderCustomTitle.
  ///
  /// In de, this message translates to:
  /// **'Eigene Vorwarnung'**
  String get reminderCustomTitle;

  /// No description provided for @reminderMaxLeads.
  ///
  /// In de, this message translates to:
  /// **'Höchstens 6 Vorwarnungen – erst eine abwählen.'**
  String get reminderMaxLeads;

  /// No description provided for @reminderHalf.
  ///
  /// In de, this message translates to:
  /// **'Zur Halbzeit'**
  String get reminderHalf;

  /// No description provided for @reminderEnd.
  ///
  /// In de, this message translates to:
  /// **'Pünktlich zum Feierabend'**
  String get reminderEnd;

  /// No description provided for @reminderQuote.
  ///
  /// In de, this message translates to:
  /// **'Mit Spruch'**
  String get reminderQuote;

  /// No description provided for @reminderQuoteHint.
  ///
  /// In de, this message translates to:
  /// **'Ein Spruch aus deiner Berufsgruppe kommt mit.'**
  String get reminderQuoteHint;

  /// No description provided for @designsTitle.
  ///
  /// In de, this message translates to:
  /// **'Designs'**
  String get designsTitle;

  /// No description provided for @designsSubtitle.
  ///
  /// In de, this message translates to:
  /// **'Einmal kaufen, für immer deins – und du unterstützt die Entwicklung.'**
  String get designsSubtitle;

  /// No description provided for @designsOpen.
  ///
  /// In de, this message translates to:
  /// **'Designs ansehen'**
  String get designsOpen;

  /// No description provided for @designCurrent.
  ///
  /// In de, this message translates to:
  /// **'Aktiv: {name}'**
  String designCurrent(String name);

  /// No description provided for @designOwned.
  ///
  /// In de, this message translates to:
  /// **'Gekauft'**
  String get designOwned;

  /// No description provided for @designActive.
  ///
  /// In de, this message translates to:
  /// **'Aktiv'**
  String get designActive;

  /// No description provided for @designFree.
  ///
  /// In de, this message translates to:
  /// **'Gratis'**
  String get designFree;

  /// No description provided for @designThanks.
  ///
  /// In de, this message translates to:
  /// **'Danke! Dein neues Design ist aktiv.'**
  String get designThanks;

  /// No description provided for @designSupporterBadge.
  ///
  /// In de, this message translates to:
  /// **'Größtes Dankeschön'**
  String get designSupporterBadge;

  /// No description provided for @designSupporterHint.
  ///
  /// In de, this message translates to:
  /// **'Mit Herzen – für alle, die die App am meisten unterstützen wollen.'**
  String get designSupporterHint;

  /// No description provided for @designNameStandard.
  ///
  /// In de, this message translates to:
  /// **'Standard'**
  String get designNameStandard;

  /// No description provided for @designNameSupporter.
  ///
  /// In de, this message translates to:
  /// **'Supporter'**
  String get designNameSupporter;

  /// No description provided for @designNameMidnight.
  ///
  /// In de, this message translates to:
  /// **'Mitternacht'**
  String get designNameMidnight;

  /// No description provided for @designNameSunset.
  ///
  /// In de, this message translates to:
  /// **'Sonnenuntergang'**
  String get designNameSunset;

  /// No description provided for @designNameOcean.
  ///
  /// In de, this message translates to:
  /// **'Ozean'**
  String get designNameOcean;

  /// No description provided for @designNameForest.
  ///
  /// In de, this message translates to:
  /// **'Wald'**
  String get designNameForest;

  /// No description provided for @autoBreakInfoTooltip.
  ///
  /// In de, this message translates to:
  /// **'Mehr Infos'**
  String get autoBreakInfoTooltip;

  /// No description provided for @autoBreakInfoTitle.
  ///
  /// In de, this message translates to:
  /// **'So funktioniert die automatische Pause'**
  String get autoBreakInfoTitle;

  /// No description provided for @autoBreakInfoBody.
  ///
  /// In de, this message translates to:
  /// **'Die App wählt die Pause passend zu deiner Arbeitszeit:'**
  String get autoBreakInfoBody;

  /// No description provided for @autoBreakUpTo6.
  ///
  /// In de, this message translates to:
  /// **'Bis 6 Std Arbeit'**
  String get autoBreakUpTo6;

  /// No description provided for @autoBreakOver6.
  ///
  /// In de, this message translates to:
  /// **'Mehr als 6 Std'**
  String get autoBreakOver6;

  /// No description provided for @autoBreakOver9.
  ///
  /// In de, this message translates to:
  /// **'Mehr als 9 Std'**
  String get autoBreakOver9;

  /// No description provided for @autoBreakNone.
  ///
  /// In de, this message translates to:
  /// **'keine Pause'**
  String get autoBreakNone;

  /// No description provided for @autoBreakLegal.
  ///
  /// In de, this message translates to:
  /// **'Grundlage sind die Mindestpausen des deutschen Arbeitszeitgesetzes (§ 4 ArbZG). Die Pausenregel in deinem Betrieb kann abweichen.'**
  String get autoBreakLegal;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['de', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
