import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'design/app_theme.dart';
import 'features/home/home_screen.dart';
import 'features/home/state/home_providers.dart';
import 'features/pro/pro_providers.dart';
import 'l10n/app_localizations.dart';

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
