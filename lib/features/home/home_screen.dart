import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/formatting.dart';
import '../../design/app_colors.dart';
import 'state/home_providers.dart';
import 'widgets/countdown_ring.dart';
import 'widgets/duration_adjust_sheet.dart';

/// Hauptbildschirm — beantwortet EINE Frage: „Wann habe ich frei?"
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final result = ref.watch(resultProvider);
    final remaining = ref.watch(remainingProvider);
    final progress = ref.watch(progressProvider);
    final reached = remaining <= Duration.zero;

    return Scaffold(
      body: Stack(
        children: [
          const _BackgroundGlow(),
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) => SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const _Header(),
                        const SizedBox(height: 24),
                        Center(
                          child: CountdownRing(
                            progress: progress,
                            size: 300,
                            child: _RingContent(
                              reached: reached,
                              endLabel: Formatting.clock(
                                result.endHour,
                                result.endMinute,
                              ),
                              crossesMidnight: result.crossesMidnight,
                              remaining: remaining,
                            ),
                          ),
                        ),
                        const SizedBox(height: 28),
                        _InputCard(),
                        const SizedBox(height: 16),
                        Text(
                          'Anwesenheit ${Formatting.durationHm(result.presence)} '
                          '· inkl. ${Formatting.durationLong(result.breakUsed)} Pause',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.primary, AppColors.accentWarm],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.wb_twilight_rounded, color: Colors.white, size: 24),
        ),
        const SizedBox(width: 12),
        Text('Feierabend', style: theme.textTheme.headlineMedium),
      ],
    );
  }
}

class _RingContent extends StatelessWidget {
  const _RingContent({
    required this.reached,
    required this.endLabel,
    required this.crossesMidnight,
    required this.remaining,
  });

  final bool reached;
  final String endLabel;
  final bool crossesMidnight;
  final Duration remaining;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('FEIERABEND UM', style: theme.textTheme.labelLarge),
        const SizedBox(height: 4),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                endLabel,
                style: theme.textTheme.displayLarge?.copyWith(fontSize: 60),
              ),
              if (crossesMidnight)
                Padding(
                  padding: const EdgeInsets.only(top: 6, left: 4),
                  child: Text(
                    '+1',
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: AppColors.accentWarm,
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        if (reached)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('🎉', style: TextStyle(fontSize: 18)),
              const SizedBox(width: 6),
              Text(
                'Feierabend!',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: AppColors.success,
                ),
              ),
            ],
          )
        else
          Column(
            children: [
              Text('noch', style: theme.textTheme.bodyMedium),
              Text(
                Formatting.durationLong(remaining),
                style: theme.textTheme.titleMedium,
              ),
            ],
          ),
      ],
    );
  }
}

class _InputCard extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final start = ref.watch(startTimeProvider);
    final config = ref.watch(workConfigProvider);

    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Column(
          children: [
            _Tile(
              icon: Icons.login_rounded,
              label: 'Start',
              value: start.format(context),
              onTap: () => _pickStart(context, ref),
            ),
            const Divider(height: 1, indent: 16, endIndent: 16),
            _Tile(
              icon: Icons.work_outline_rounded,
              label: 'Arbeitszeit',
              value: Formatting.durationHm(config.work),
              onTap: () => _pickWork(context, ref),
            ),
            const Divider(height: 1, indent: 16, endIndent: 16),
            _Tile(
              icon: Icons.coffee_rounded,
              label: 'Pause',
              value: Formatting.durationHm(config.breakTime),
              onTap: () => _pickBreak(context, ref),
            ),
            const Divider(height: 1, indent: 16, endIndent: 16),
            SwitchListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              secondary: const Icon(Icons.gavel_rounded),
              title: const Text('Pause nach Gesetz (ArbZG)'),
              subtitle: const Text('> 6 h → 30 min · > 9 h → 45 min'),
              value: config.arbzgAutoBreak,
              onChanged: (v) {
                HapticFeedback.selectionClick();
                ref.read(workConfigProvider.notifier).setArbzgAuto(v);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickStart(BuildContext context, WidgetRef ref) async {
    final current = ref.read(startTimeProvider);
    final picked = await showTimePicker(
      context: context,
      initialTime: current,
      initialEntryMode: TimePickerEntryMode.input,
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
        child: child!,
      ),
    );
    if (picked != null) {
      ref.read(startTimeProvider.notifier).set(picked);
    }
  }

  Future<void> _pickWork(BuildContext context, WidgetRef ref) async {
    final picked = await DurationAdjustSheet.show(
      context,
      title: 'Arbeitszeit',
      initial: ref.read(workConfigProvider).work,
      step: const Duration(minutes: 15),
      min: Duration.zero,
      max: const Duration(hours: 16),
      presets: const [
        Duration(hours: 4),
        Duration(hours: 6),
        Duration(hours: 7),
        Duration(hours: 8),
      ],
    );
    if (picked != null) {
      ref.read(workConfigProvider.notifier).setWork(picked);
    }
  }

  Future<void> _pickBreak(BuildContext context, WidgetRef ref) async {
    final picked = await DurationAdjustSheet.show(
      context,
      title: 'Pause',
      initial: ref.read(workConfigProvider).breakTime,
      step: const Duration(minutes: 5),
      min: Duration.zero,
      max: const Duration(hours: 3),
      presets: const [
        Duration.zero,
        Duration(minutes: 30),
        Duration(minutes: 45),
        Duration(minutes: 60),
      ],
    );
    if (picked != null) {
      ref.read(workConfigProvider.notifier).setBreak(picked);
    }
  }
}

class _Tile extends StatelessWidget {
  const _Tile({
    required this.icon,
    required this.label,
    required this.value,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      leading: Icon(icon, color: theme.colorScheme.primary),
      title: Text(label, style: theme.textTheme.bodyLarge),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(value, style: theme.textTheme.titleMedium),
          const SizedBox(width: 4),
          Icon(Icons.chevron_right_rounded,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.3)),
        ],
      ),
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
    );
  }
}

/// Sanfter, warmer Farbverlauf im Hintergrund.
class _BackgroundGlow extends StatelessWidget {
  const _BackgroundGlow();

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Positioned.fill(
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: const Alignment(0, -0.8),
            radius: 1.2,
            colors: [
              AppColors.primary.withValues(alpha: dark ? 0.18 : 0.10),
              Colors.transparent,
            ],
          ),
        ),
      ),
    );
  }
}
