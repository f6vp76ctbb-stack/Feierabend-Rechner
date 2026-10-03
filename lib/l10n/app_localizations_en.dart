// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Clock-Out Calculator';

  @override
  String get brandName => 'Clock-Out';

  @override
  String get unitHours => 'h';

  @override
  String get unitMinutes => 'min';

  @override
  String get clockOutAt => 'CLOCK-OUT AT';

  @override
  String get reached => 'Time to go!';

  @override
  String get remainingLabel => 'time left';

  @override
  String get settingsTooltip => 'Settings';

  @override
  String get startLabel => 'Start';

  @override
  String get workLabel => 'Work time';

  @override
  String get breakLabel => 'Break';

  @override
  String get breakAuto => 'adjusted automatically';

  @override
  String get arbzgTitle => 'Automatic break';

  @override
  String get arbzgSubtitle =>
      'Up to 6 h no break needed – above that it adapts.';

  @override
  String presenceSummary(String presence, String breakDuration) {
    return 'At work $presence · incl. $breakDuration break';
  }

  @override
  String get quickSelect => 'Quick pick';

  @override
  String get presetSixNoBreak => '6 h, no break';

  @override
  String get presetEightStandard => '8 h + 45 min';

  @override
  String get startTimeTitle => 'Start time';

  @override
  String get hour => 'Hour';

  @override
  String get minute => 'Minute';

  @override
  String get now => 'Now';

  @override
  String startTimeHint(String time) {
    return 'Clock-out is calculated from $time.';
  }

  @override
  String get apply => 'Apply';

  @override
  String get newQuote => 'new quote';

  @override
  String get chooseJobTitle => 'Choose your job';

  @override
  String get chooseJobSubtitle => 'Sets your quote collection.';

  @override
  String get profiles => 'Profiles';

  @override
  String get rename => 'Rename';

  @override
  String get delete => 'Delete';

  @override
  String get atLeastOneProfile => 'At least one profile';

  @override
  String get newProfile => 'New profile';

  @override
  String get renameProfile => 'Rename profile';

  @override
  String deleteProfileTitle(String name) {
    return 'Delete “$name”?';
  }

  @override
  String get deleteProfileBody => 'The profile will be removed permanently.';

  @override
  String get cancel => 'Cancel';

  @override
  String get save => 'Save';

  @override
  String get profileNameHint => 'e.g. Mon–Thu, Friday, Night shift';

  @override
  String get overtimeAccount => 'Overtime account';

  @override
  String overtimeThisWeek(String value) {
    return 'This week $value';
  }

  @override
  String overtimeThisWeekColon(String value) {
    return 'This week: $value';
  }

  @override
  String get totalBalance => 'TOTAL BALANCE';

  @override
  String get addDay => 'Day';

  @override
  String get bookToday => 'Book today';

  @override
  String bookedToday(String value) {
    return 'Booked today: $value';
  }

  @override
  String get noEntries => 'No entries yet';

  @override
  String get noEntriesHint =>
      'Tap “Book today” or “Day” to log your first workday.';

  @override
  String workedOf(String worked, String target) {
    return '$worked of $target';
  }

  @override
  String get addDayTitle => 'Add day';

  @override
  String get editDayTitle => 'Edit day';

  @override
  String get worked => 'Worked';

  @override
  String get target => 'Target';

  @override
  String balance(String value) {
    return 'Balance: $value';
  }

  @override
  String get settings => 'Settings';

  @override
  String get dailyTarget => 'Daily target';

  @override
  String get dailyTargetHint =>
      'Used for your overtime account. Work less and you go negative – work more and you go positive.';

  @override
  String get appearance => 'Appearance';

  @override
  String get themeSystem => 'System';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get autosaveHint =>
      'Your inputs are saved automatically on your device.';

  @override
  String get proSection => 'Clock-Out Pro';

  @override
  String get proActive => 'Pro is active – thank you!';

  @override
  String proTrialActive(String time) {
    return 'Pro trial active until $time';
  }

  @override
  String get testerBuildActive =>
      'Tester version: Pro and all designs are unlocked – thanks for testing!';

  @override
  String get unlockPro => 'Unlock Pro';

  @override
  String get restorePurchases => 'Restore purchases';

  @override
  String get privacySettings => 'Privacy settings (ads)';

  @override
  String get privacyPolicy => 'Privacy policy';

  @override
  String get legalSection => 'Legal';

  @override
  String get proBadge => 'PRO';

  @override
  String get paywallTitle => 'Clock-Out Pro';

  @override
  String get paywallSubtitle => 'Pay once. Free forever.';

  @override
  String get paywallBenefitNoAds => 'No ads';

  @override
  String get paywallBenefitProfiles =>
      'Unlimited profiles (Mon–Thu, Friday, shifts …)';

  @override
  String get paywallBenefitOvertime => 'Overtime account with weekly overview';

  @override
  String get paywallBenefitArbzg => 'Break adjusts automatically';

  @override
  String get paywallBenefitSupport => 'Supports an independent developer';

  @override
  String paywallBuy(String price) {
    return 'Unlock Pro – $price';
  }

  @override
  String get paywallOneTime => 'One-time · no subscription · no ads';

  @override
  String get paywallTrialAd => 'Try free for 24 h (short video)';

  @override
  String get paywallUnavailable =>
      'The store is currently unavailable. Please try again later.';

  @override
  String get purchaseSuccess => 'Thank you! Pro is unlocked.';

  @override
  String get purchasePending => 'Purchase pending …';

  @override
  String get purchaseError => 'Purchase not completed. Please try again.';

  @override
  String get restoreDone => 'Purchases checked.';

  @override
  String get trialGranted => 'Pro unlocked for 24 hours – enjoy!';

  @override
  String get adNotReady =>
      'No video available right now. Please try again shortly.';

  @override
  String get remindersTitle => 'Reminders';

  @override
  String get remindersSwitch => 'Notifications';

  @override
  String get remindersHint =>
      'Heads-ups, halftime and clock-out – with a quote if you like.';

  @override
  String get notifChannelName => 'Clock-out reminders';

  @override
  String get notifChannelDesc => 'Alerts shortly before and at clock-out';

  @override
  String get notifEndTitle => 'Time to go! 🎉';

  @override
  String get notifEndBody => 'You made it. Head home!';

  @override
  String get notificationsDenied =>
      'Notifications are blocked in system settings.';

  @override
  String get paywallBenefitReminders =>
      'Your own clock-out reminders – with a quote';

  @override
  String get paywallBenefitWidget => 'Live countdown as a home screen widget';

  @override
  String get widgetTitle => 'Home screen widget';

  @override
  String get widgetHint =>
      'Your clock-out time on the home screen – a live countdown with Pro.';

  @override
  String get widgetAdd => 'Add widget';

  @override
  String get widgetManual =>
      'Long-press your home screen → Widgets → Clock-Out.';

  @override
  String get onbSkip => 'Skip';

  @override
  String get onbNext => 'Next';

  @override
  String get onbStart => 'Let\'s go';

  @override
  String get onb1Title => 'When can you clock out?';

  @override
  String get onb1Body =>
      'Tap your start time – the app adds work time and break and instantly shows when you’re free.';

  @override
  String get onbExampleEnd => 'Clock-out';

  @override
  String get onb2Title => 'Your workday';

  @override
  String get onb2Body =>
      'Quickly set how long you work. You can change everything any time.';

  @override
  String get onbJob => 'Quotes for';

  @override
  String get onb3Title => 'Even more with Pro';

  @override
  String get onb3Body =>
      'Pay once, no subscription – or try it free for 24 hours first.';

  @override
  String get onb3ProActive => 'Pro is active – everything unlocked.';

  @override
  String get onbSeePro => 'See Pro';

  @override
  String notifLeadTitle(String duration) {
    return '$duration until clock-out';
  }

  @override
  String notifLeadBody(String time) {
    return 'Clock-out at $time.';
  }

  @override
  String get notifHalfTitle => 'Halfway there! ☕';

  @override
  String notifHalfBody(String time) {
    return 'Half done – clock-out at $time.';
  }

  @override
  String get reminderLeads => 'Heads-ups';

  @override
  String get reminderCustom => 'Custom';

  @override
  String get reminderCustomTitle => 'Custom heads-up';

  @override
  String get reminderMaxLeads => '6 heads-ups max – deselect one first.';

  @override
  String get reminderHalf => 'At halftime';

  @override
  String get reminderEnd => 'Right at clock-out';

  @override
  String get reminderQuote => 'With a quote';

  @override
  String get reminderQuoteHint => 'Adds a quote for your job.';

  @override
  String get designsTitle => 'Designs';

  @override
  String get designsSubtitle =>
      'Buy once, yours forever – and you support development.';

  @override
  String get designsOpen => 'Browse designs';

  @override
  String designCurrent(String name) {
    return 'Active: $name';
  }

  @override
  String get designOwned => 'Owned';

  @override
  String get designActive => 'Active';

  @override
  String get designFree => 'Free';

  @override
  String get designThanks => 'Thank you! Your new design is active.';

  @override
  String get designSupporterBadge => 'Biggest thank-you';

  @override
  String get designSupporterHint =>
      'With hearts – for everyone who wants to support the app the most.';

  @override
  String get designNameStandard => 'Classic';

  @override
  String get designNameSupporter => 'Supporter';

  @override
  String get designNameMidnight => 'Midnight';

  @override
  String get designNameSunset => 'Sunset';

  @override
  String get designNameOcean => 'Ocean';

  @override
  String get designNameForest => 'Forest';

  @override
  String get autoBreakInfoTooltip => 'More info';

  @override
  String get autoBreakInfoTitle => 'How the automatic break works';

  @override
  String get autoBreakInfoBody =>
      'The app picks the break to match your work time:';

  @override
  String get autoBreakUpTo6 => 'Up to 6 h of work';

  @override
  String get autoBreakOver6 => 'More than 6 h';

  @override
  String get autoBreakOver9 => 'More than 9 h';

  @override
  String get autoBreakNone => 'no break';

  @override
  String get autoBreakLegal =>
      'Based on the minimum breaks of the German Working Hours Act (§ 4 ArbZG). Your workplace rules may differ.';

  @override
  String get analyticsAskTitle => 'Can the app count along?';

  @override
  String get analyticsAskBody =>
      'Usage statistics (Google Analytics) show me which features are used, so I can improve the app where it matters. No names, no precise location, no advertising ID – your work times stay on your device. You can change this anytime in Settings.';

  @override
  String get analyticsYes => 'Sure';

  @override
  String get analyticsNo => 'No thanks';

  @override
  String get analyticsSetting => 'Share usage statistics';

  @override
  String get analyticsSettingHint =>
      'Helps improve the app (Google Analytics).';
}
