// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Feierabend – Clock-Out Timer';

  @override
  String get brandName => 'Feierabend';

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
  String get breakAuto => 'automatic (legal minimum)';

  @override
  String get arbzgTitle => 'Legal break (German law)';

  @override
  String get arbzgSubtitle => '> 6 h → 30 min · > 9 h → 45 min';

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
  String get proSection => 'Feierabend Pro';

  @override
  String get proActive => 'Pro is active – thank you!';

  @override
  String proTrialActive(String time) {
    return 'Pro trial active until $time';
  }

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
  String get paywallTitle => 'Feierabend Pro';

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
  String get paywallBenefitArbzg => 'Automatic legal break calculation';

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
  String get remindersHint => 'Shortly before and right at clock-out.';

  @override
  String get reminderLead => 'Heads-up';

  @override
  String get notifChannelName => 'Clock-out reminders';

  @override
  String get notifChannelDesc => 'Alerts shortly before and at clock-out';

  @override
  String get notifBeforeTitle => 'Almost clock-out time';

  @override
  String notifBeforeBody(String duration) {
    return '$duration to go – then you’re free.';
  }

  @override
  String get notifEndTitle => 'Time to go! 🎉';

  @override
  String get notifEndBody => 'You made it. Head home!';

  @override
  String get notificationsDenied =>
      'Notifications are blocked in system settings.';

  @override
  String get paywallBenefitReminders => 'Reminders before and at clock-out';
}
