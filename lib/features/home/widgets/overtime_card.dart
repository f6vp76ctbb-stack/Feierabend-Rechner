import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/formatting.dart';
import '../../overtime/overtime_screen.dart';
import '../state/home_providers.dart';

/// Kompakte Karte auf dem Hauptschirm: Überstunden-Saldo auf einen Blick.
class OvertimeCard extends ConsumerWidget {
  const OvertimeCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final total = ref.watch(overtimeBalanceProvider);
    final thisWeek = ref.watch(overtimeThisWeekProvider);
    final color = total >= 0 ? scheme.secondary : scheme.primary;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => OvertimeScreen.open(context),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Row(
            children: [
              Icon(Icons.savings_rounded, color: scheme.primary),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Überstunden-Konto',
                        style: theme.textTheme.bodyLarge),
                    Text(
                      'Diese Woche ${Formatting.signedDuration(thisWeek)}',
                      style: theme.textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
              Text(
                Formatting.signedDuration(total),
                style: theme.textTheme.titleMedium?.copyWith(color: color),
              ),
              Icon(Icons.chevron_right_rounded,
                  color: scheme.onSurface.withValues(alpha: 0.3)),
            ],
          ),
        ),
      ),
    );
  }
}
