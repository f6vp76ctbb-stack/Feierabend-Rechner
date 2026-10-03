import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/formatting.dart';
import '../../data/sprueche.dart';
import '../../design/app_colors.dart';
import '../../design/app_icon.dart';
import '../../l10n/l10n_ext.dart';
import '../home/state/home_providers.dart';
import '../pro/paywall_sheet.dart';
import '../pro/pro_providers.dart';
import '../reminders/reminder_providers.dart';
import '../widget/widget_providers.dart';

/// Wurde die Einführung schon gesehen/übersprungen? (persistiert)
class OnboardingController extends Notifier<bool> {
  @override
  bool build() => ref.read(settingsRepositoryProvider).loadOnboardingDone();

  void finish() {
    state = true;
    ref.read(settingsRepositoryProvider).saveOnboardingDone(true);
  }
}

final onboardingDoneProvider =
    NotifierProvider<OnboardingController, bool>(OnboardingController.new);

/// Kurze Einführung beim ersten Start: 3 Seiten, jederzeit überspringbar.
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  static const _count = 3;
  final _pages = PageController();
  int _index = 0;

  bool get _isLast => _index == _count - 1;

  @override
  void dispose() {
    _pages.dispose();
    super.dispose();
  }

  void _finish() {
    HapticFeedback.mediumImpact();
    ref.read(onboardingDoneProvider.notifier).finish();
  }

  void _next() {
    HapticFeedback.selectionClick();
    _pages.nextPage(
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(8, 4, 8, 0),
                child: AnimatedOpacity(
                  opacity: _isLast ? 0 : 1,
                  duration: const Duration(milliseconds: 200),
                  child: TextButton(
                    onPressed: _isLast ? null : _finish,
                    child: Text(l.onbSkip),
                  ),
                ),
              ),
            ),
            Expanded(
              child: PageView(
                controller: _pages,
                onPageChanged: (i) => setState(() => _index = i),
                children: const [_WelcomePage(), _SetupPage(), _ProPage()],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (var i = 0; i < _count; i++)
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    curve: Curves.easeOut,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: i == _index ? 22 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: i == _index
                          ? scheme.primary
                          : scheme.primary.withValues(alpha: 0.25),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
              ],
            ),
            Padding(
              padding: _compact(context)
                  ? const EdgeInsets.fromLTRB(24, 12, 24, 12)
                  : const EdgeInsets.fromLTRB(24, 20, 24, 20),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: FilledButton(
                  onPressed: _isLast ? _finish : _next,
                  child: Text(_isLast ? l.onbStart : l.onbNext),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Kleine Bildschirme (z. B. 320 × 640): kleinere Symbole und Abstände.
bool _compact(BuildContext context) => MediaQuery.sizeOf(context).height < 700;

/// Gemeinsamer Rahmen: zentriert, max. Breite, scrollbar bei wenig Platz.
class _Page extends StatelessWidget {
  const _Page({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: children,
          ),
        ),
      ),
    );
  }
}

class _Title extends StatelessWidget {
  const _Title(this.title, this.body);

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(title,
            textAlign: TextAlign.center, style: theme.textTheme.headlineMedium),
        const SizedBox(height: 10),
        Text(body,
            textAlign: TextAlign.center, style: theme.textTheme.bodyLarge),
      ],
    );
  }
}

// --- Seite 1: Worum geht's? ---

class _WelcomePage extends StatelessWidget {
  const _WelcomePage();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l = context.l10n;
    final u = context.units;
    final compact = _compact(context);

    Widget time(String label, String value, Color color) => Column(
          children: [
            Text(label, style: theme.textTheme.labelMedium),
            const SizedBox(height: 4),
            Text(
              value,
              style: theme.textTheme.headlineMedium?.copyWith(
                color: color,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        );

    return _Page(
      children: [
        Center(child: AppIconMark(size: compact ? 64 : 96)),
        SizedBox(height: compact ? 16 : 28),
        _Title(l.onb1Title, l.onb1Body),
        SizedBox(height: compact ? 16 : 28),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    time(l.startLabel, Formatting.clock(6, 44),
                        theme.colorScheme.onSurface),
                    Icon(Icons.arrow_forward_rounded,
                        color: theme.colorScheme.primary),
                    time(l.onbExampleEnd, Formatting.clock(15, 29),
                        AppColors.success),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  l.presenceSummary(
                    Formatting.durationLong(
                        const Duration(hours: 8, minutes: 45), u),
                    Formatting.durationLong(const Duration(minutes: 45), u),
                  ),
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// --- Seite 2: Arbeitstag einrichten ---

class _SetupPage extends ConsumerWidget {
  const _SetupPage();

  static const _works = [360, 420, 450, 480, 540];
  static const _breaks = [0, 30, 45, 60];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l = context.l10n;
    final u = context.units;
    final config = ref.watch(workConfigProvider);
    final gruppe = ref.watch(berufsgruppeProvider);
    final profiles = ref.read(profilesControllerProvider.notifier);

    Widget label(String text) => Padding(
          padding: const EdgeInsets.only(top: 20, bottom: 8),
          child: Text(text, style: theme.textTheme.labelLarge),
        );

    Widget chips<T>(List<T> values, String Function(T) text,
            bool Function(T) selected, void Function(T) onTap) =>
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final v in values)
              ChoiceChip(
                label: Text(text(v)),
                selected: selected(v),
                onSelected: (_) {
                  HapticFeedback.selectionClick();
                  onTap(v);
                },
              ),
          ],
        );

    return _Page(
      children: [
        _Title(l.onb2Title, l.onb2Body),
        label(l.workLabel),
        chips<int>(
          _works,
          (m) => Formatting.durationLong(Duration(minutes: m), u),
          (m) => config.work.inMinutes == m,
          (m) {
            profiles.setWork(Duration(minutes: m));
            // Soll fürs Überstunden-Konto passend mitziehen.
            ref.read(dailyTargetProvider.notifier).set(Duration(minutes: m));
          },
        ),
        label(l.breakLabel),
        chips<int>(
          _breaks,
          (m) => Formatting.durationLong(Duration(minutes: m), u),
          (m) => !config.arbzgAutoBreak && config.breakTime.inMinutes == m,
          (m) {
            if (config.arbzgAutoBreak) profiles.setArbzgAuto(false);
            profiles.setBreak(Duration(minutes: m));
          },
        ),
        label(l.onbJob),
        chips<String>(
          Sprueche.berufsgruppen,
          (g) => Sprueche.label(g, context.lang),
          (g) => g == gruppe,
          (g) => ref.read(berufsgruppeProvider.notifier).set(g),
        ),
      ],
    );
  }
}

// --- Seite 3: Pro vorstellen (ohne Druck) ---

class _ProPage extends ConsumerWidget {
  const _ProPage();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l = context.l10n;
    final isPro = ref.watch(isProProvider);
    final compact = _compact(context);

    final benefits = [
      if (ref.watch(widgetBackendProvider).isSupported)
        (Icons.widgets_outlined, l.paywallBenefitWidget),
      if (ref.watch(notificationBackendProvider).isSupported)
        (Icons.notifications_active_outlined, l.paywallBenefitReminders),
      (Icons.savings_outlined, l.paywallBenefitOvertime),
      (Icons.people_alt_outlined, l.paywallBenefitProfiles),
      (Icons.block_rounded, l.paywallBenefitNoAds),
    ];

    return _Page(
      children: [
        Center(
          child: Container(
            width: compact ? 64 : 88,
            height: compact ? 64 : 88,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.primary, AppColors.accentWarm],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(26),
            ),
            child: Icon(Icons.workspace_premium_rounded,
                color: Colors.white, size: compact ? 36 : 48),
          ),
        ),
        SizedBox(height: compact ? 16 : 28),
        _Title(l.onb3Title, isPro ? l.onb3ProActive : l.onb3Body),
        const SizedBox(height: 20),
        for (final (icon, text) in benefits)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(
              children: [
                Icon(icon, color: theme.colorScheme.primary),
                const SizedBox(width: 14),
                Expanded(child: Text(text, style: theme.textTheme.bodyLarge)),
              ],
            ),
          ),
        if (!isPro) ...[
          const SizedBox(height: 12),
          Center(
            child: TextButton.icon(
              onPressed: () => PaywallSheet.show(context),
              icon: const Icon(Icons.workspace_premium_outlined),
              label: Text(l.onbSeePro),
            ),
          ),
        ],
      ],
    );
  }
}
