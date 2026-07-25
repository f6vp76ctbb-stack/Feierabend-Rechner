import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/formatting.dart';
import '../home/state/home_providers.dart';
import '../home/widgets/duration_adjust_sheet.dart';

/// Einstellungs-Overlay: aktuell Theme-Wahl (System/Hell/Dunkel).
/// Bewusst schlank gehalten, leicht erweiterbar.
class SettingsSheet extends ConsumerWidget {
  const SettingsSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) => const SettingsSheet(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final mode = ref.watch(themeModeProvider);
    final dailyTarget = ref.watch(dailyTargetProvider);

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Einstellungen', style: theme.textTheme.titleMedium),
          const SizedBox(height: 20),
          Text('Soll pro Tag', style: theme.textTheme.labelLarge),
          const SizedBox(height: 6),
          OutlinedButton.icon(
            onPressed: () async {
              final picked = await DurationAdjustSheet.show(
                context,
                title: 'Soll pro Tag',
                initial: dailyTarget,
                step: const Duration(minutes: 15),
                min: Duration.zero,
                max: const Duration(hours: 16),
                presets: const [
                  Duration(hours: 6),
                  Duration(hours: 7),
                  Duration(hours: 8),
                  Duration(hours: 8, minutes: 30),
                ],
              );
              if (picked != null) {
                ref.read(dailyTargetProvider.notifier).set(picked);
              }
            },
            icon: const Icon(Icons.flag_outlined, size: 18),
            label: Text(Formatting.durationHm(dailyTarget)),
          ),
          const SizedBox(height: 6),
          Text(
            'Vergleichswert fürs Überstunden-Konto. Arbeitest du weniger, gibt es '
            'Minus – arbeitest du mehr, Plus.',
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 20),
          Text('Erscheinungsbild', style: theme.textTheme.labelLarge),
          const SizedBox(height: 10),
          SegmentedButton<ThemeMode>(
            segments: const [
              ButtonSegment(
                value: ThemeMode.system,
                label: Text('System'),
                icon: Icon(Icons.brightness_auto_rounded),
              ),
              ButtonSegment(
                value: ThemeMode.light,
                label: Text('Hell'),
                icon: Icon(Icons.light_mode_rounded),
              ),
              ButtonSegment(
                value: ThemeMode.dark,
                label: Text('Dunkel'),
                icon: Icon(Icons.dark_mode_rounded),
              ),
            ],
            selected: {mode},
            showSelectedIcon: false,
            onSelectionChanged: (sel) {
              HapticFeedback.selectionClick();
              ref.read(themeModeProvider.notifier).set(sel.first);
            },
          ),
          const SizedBox(height: 20),
          Text(
            'Deine Eingaben (Startzeit, Arbeitszeit, Pause, Berufsgruppe) werden '
            'automatisch gespeichert.',
            style: theme.textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}
