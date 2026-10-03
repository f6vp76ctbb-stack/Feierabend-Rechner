import 'package:flutter/material.dart';

import '../../../core/formatting.dart';
import '../../../l10n/l10n_ext.dart';

/// Kurze Erklärung zur automatischen Pause – erst auf Wunsch (ⓘ), damit der
/// Schalter selbst freundlich und schlicht bleibt.
class AutoBreakInfoSheet extends StatelessWidget {
  const AutoBreakInfoSheet({super.key});

  static Future<void> show(BuildContext context) => showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        builder: (_) => const AutoBreakInfoSheet(),
      );

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l = context.l10n;
    final u = context.units;

    Widget rule(String when, String pause) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              Expanded(child: Text(when, style: theme.textTheme.bodyLarge)),
              Text(
                pause,
                style: theme.textTheme.titleMedium
                    ?.copyWith(color: theme.colorScheme.primary),
              ),
            ],
          ),
        );

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(l.autoBreakInfoTitle, style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(l.autoBreakInfoBody, style: theme.textTheme.bodyMedium),
            const SizedBox(height: 8),
            rule(l.autoBreakUpTo6, l.autoBreakNone),
            const Divider(height: 1),
            rule(l.autoBreakOver6,
                Formatting.durationLong(const Duration(minutes: 30), u)),
            const Divider(height: 1),
            rule(l.autoBreakOver9,
                Formatting.durationLong(const Duration(minutes: 45), u)),
            const SizedBox(height: 12),
            Text(l.autoBreakLegal, style: theme.textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }
}
