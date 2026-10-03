import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'design/app_theme.dart';
import 'features/analytics/analytics_consent.dart';
import 'features/home/home_screen.dart';
import 'features/designs/design_providers.dart';
import 'features/home/state/home_providers.dart';
import 'features/onboarding/onboarding_screen.dart';
import 'features/pro/pro_providers.dart';
import 'features/reminders/reminder_providers.dart';
import 'features/widget/widget_providers.dart';
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
    ref.listenManual<ReminderSchedule>(reminderScheduleProvider, (prev, schedule) {
      if (prev == schedule) return;
      final lang = _lang;
      final l = lookupAppLocalizations(Locale(lang));
      ref.read(notificationBackendProvider).apply(
            buildReminderNotifications(schedule, l, lang: lang),
            ReminderChannel(
                name: l.notifChannelName, description: l.notifChannelDesc),
          );
    }, fireImmediately: true);

    // Home-Screen-Widget mit Feierabend-Zeit und Pro-Status versorgen.
    ref.listenManual(widgetSnapshotProvider, (prev, snapshot) {
      if (prev == snapshot) return;
      ref.read(widgetBackendProvider).update(snapshot);
    }, fireImmediately: true);
  }

  /// Sprache ohne BuildContext – gleiche Regel wie die UI (Deutsch, sonst Englisch).
  String get _lang {
    final device = WidgetsBinding.instance.platformDispatcher.locale;
    return widget.locale?.languageCode ??
        (device.languageCode == 'de' ? 'de' : 'en');
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeModeProvider);
    final design = ref.watch(activeDesignProvider);

    return MaterialApp(
      onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(design),
      darkTheme: AppTheme.dark(design),
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
          ? const AnalyticsConsentGate(
              key: ValueKey('home'),
              child: HomeScreen(),
            )
          : const OnboardingScreen(key: ValueKey('onboarding')),
    );
  }
}
