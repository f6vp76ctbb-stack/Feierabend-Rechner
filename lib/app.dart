import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/formatting.dart';
import 'design/app_theme.dart';
import 'features/home/home_screen.dart';
import 'features/home/state/home_providers.dart';
import 'features/pro/pro_providers.dart';
import 'features/reminders/reminder_providers.dart';
import 'domain/reminder_planner.dart';
import 'l10n/app_localizations.dart';
import 'services/notification_backend.dart';

/// Wurzel-Widget: Theme (hell/dunkel), Sprache (DE/EN), Routing.
class FeierabendApp extends ConsumerStatefulWidget {
  const FeierabendApp({super.key, this.locale});

  /// Feste Sprache (für Tests/Screenshots). `null` = Gerätesprache.
  final Locale? locale;

  @override
  ConsumerState<FeierabendApp> createState() => _FeierabendAppState();
}

class _FeierabendAppState extends ConsumerState<FeierabendApp> {
  @override
  void initState() {
    super.initState();
    // Free-Nutzer: Einwilligung abfragen + Werbe-SDK starten (einmal pro Start).
    ref.listenManual<bool>(isProProvider, (_, isPro) {
      if (!isPro) ref.read(adsReadyProvider.notifier).ensureStarted();
    }, fireImmediately: true);

    // Feierabend-Erinnerungen immer mit dem aktuellen Plan synchron halten.
    ref.listenManual<List<PlannedReminder>>(reminderPlanProvider, (prev, plan) {
      if (samePlan(prev, plan)) return;
      final lead = ref.read(reminderSettingsProvider).lead;
      ref.read(notificationBackendProvider).apply(plan, _texts(lead));
    }, fireImmediately: true);
  }

  /// Lokalisierte Benachrichtigungstexte (ohne BuildContext, gleiche Regel wie die UI).
  ReminderTexts _texts(Duration lead) {
    final device = WidgetsBinding.instance.platformDispatcher.locale;
    final lang = widget.locale?.languageCode ??
        (device.languageCode == 'de' ? 'de' : 'en');
    final l = lookupAppLocalizations(Locale(lang));
    final units = Units(hour: l.unitHours, minute: l.unitMinutes);
    return ReminderTexts(
      channelName: l.notifChannelName,
      channelDescription: l.notifChannelDesc,
      beforeTitle: l.notifBeforeTitle,
      beforeBody: l.notifBeforeBody(Formatting.durationLong(lead, units)),
      endTitle: l.notifEndTitle,
      endBody: l.notifEndBody,
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp(
      onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: themeMode,
      locale: widget.locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      // Deutsch für deutschsprachige Geräte, sonst Englisch.
      localeResolutionCallback: (deviceLocale, supported) =>
          deviceLocale?.languageCode == 'de'
              ? const Locale('de')
              : const Locale('en'),
      home: const HomeScreen(),
    );
  }
}
