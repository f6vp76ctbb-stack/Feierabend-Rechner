import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/formatting.dart';
import '../../../l10n/l10n_ext.dart';
import '../../overtime/overtime_screen.dart';
import '../../pro/paywall_sheet.dart';
import '../../pro/pro_providers.dart';
import '../state/home_providers.dart';

/// Kompakte Karte auf dem Hauptschirm: Überstunden-Saldo auf einen Blick.
/// Für Free-Nutzer ein Pro-Teaser, der die Paywall öffnet.
class OvertimeCard extends ConsumerWidget {
  const OvertimeCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final l = context.l10n;
    final isPro = ref.watch(isProProvider);
    final total = ref.watch(overtimeBalanceProvider);
    final thisWeek = ref.watch(overtimeThisWeekProvider);
    final color = total >= 0 ? scheme.secondary : scheme.primary;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => isPro
            ? OvertimeScreen.open(context)
            : PaywallSheet.show(context),
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
                    Text(l.overtimeAccount, style: theme.textTheme.bodyLarge),
                    if (isPro)
                      Text(
                        l.overtimeThisWeek(
                            Formatting.signedDuration(thisWeek, context.units)),
                        style: theme.textTheme.bodyMedium,
                      ),
                  ],
                ),
              ),
              if (isPro)
                Text(
                  Formatting.signedDuration(total, context.units),
                  style: theme.textTheme.titleMedium?.copyWith(color: color),
                )
              else
                const ProBadge(),
              Icon(Icons.chevron_right_rounded,
                  color: scheme.onSurface.withValues(alpha: 0.3)),
            ],
          ),
        ),
      ),
    );
  }
}
