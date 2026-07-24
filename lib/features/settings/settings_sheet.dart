import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../home/state/home_providers.dart';

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

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Einstellungen', style: theme.textTheme.titleMedium),
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
