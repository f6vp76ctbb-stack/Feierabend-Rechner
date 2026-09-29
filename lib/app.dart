import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/formatting.dart';
import 'design/app_theme.dart';
import 'features/home/home_screen.dart';
import 'features/home/state/home_providers.dart';
import 'features/onboarding/onboarding_screen.dart';
import 'features/pro/pro_providers.dart';
import 'features/reminders/reminder_providers.dart';
import 'features/widget/widget_providers.dart';
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
    // Free-Nutzer: Einwilligung abfragen + Werbe-SDK starten (einmal pro Start),
    // aber erst nach der Einführung – der erste Eindruck gehört der App.
    ref.listenManual<bool>(_adsWantedProvider, (_, wanted) {
      if (wanted) ref.read(adsReadyProvider.notifier).ensureStarted();
    }, fireImmediately: true);

    // Feierabend-Erinnerungen immer mit dem aktuellen Plan synchron halten.
    ref.listenManual<List<PlannedReminder>>(reminderPlanProvider, (prev, plan) {
      if (samePlan(prev, plan)) return;
      final lead = ref.read(reminderSettingsProvider).lead;
      ref.read(notificationBackendProvider).apply(plan, _texts(lead));
    }, fireImmediately: true);

    // Home-Screen-Widget mit Feierabend-Zeit und Pro-Status versorgen.
    ref.listenManual(widgetSnapshotProvider, (prev, snapshot) {
      if (prev == snapshot) return;
      ref.read(widgetBackendProvider).update(snapshot);
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
      home: const _Root(),
    );
  }
}

final _adsWantedProvider = Provider<bool>(
  (ref) => !ref.watch(isProProvider) && ref.watch(onboardingDoneProvider),
);

/// Erster Start → Einführung, danach sanft zum Hauptbildschirm überblenden.
class _Root extends ConsumerWidget {
  const _Root();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final done = ref.watch(onboardingDoneProvider);
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      switchInCurve: Curves.easeOut,
      child: done
          ? const HomeScreen(key: ValueKey('home'))
          : const OnboardingScreen(key: ValueKey('onboarding')),
    );
  }
}
