import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/sprueche.dart';
import '../../../l10n/l10n_ext.dart';
import '../state/home_providers.dart';

/// Karte mit lustigem Spruch (antippen = neuer Spruch) + Berufsgruppen-Auswahl.
class SpruchCard extends ConsumerWidget {
  const SpruchCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final gruppe = ref.watch(berufsgruppeProvider);
    final index = ref.watch(spruchControllerProvider);
    final list = Sprueche.forGruppe(gruppe, context.lang);
    final spruch = list.isEmpty ? '' : list[index % list.length];

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          HapticFeedback.selectionClick();
          ref.read(spruchControllerProvider.notifier).next();
        },
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('„', style: theme.textTheme.displayLarge?.copyWith(
                    fontSize: 40, color: scheme.primary, height: 0.9)),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 6, left: 4),
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 250),
                        child: Text(
                          spruch,
                          key: ValueKey(spruch),
                          style: theme.textTheme.bodyLarge,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  ActionChip(
                    avatar: Icon(Icons.badge_outlined, size: 18, color: scheme.primary),
                    label: Text(Sprueche.label(gruppe, context.lang)),
                    onPressed: () => _pickGruppe(context, ref),
                  ),
                  const Spacer(),
                  Icon(Icons.refresh_rounded,
                      size: 20, color: scheme.onSurface.withValues(alpha: 0.4)),
                  const SizedBox(width: 4),
                  Text(context.l10n.newQuote, style: theme.textTheme.bodyMedium),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickGruppe(BuildContext context, WidgetRef ref) async {
    final current = ref.read(berufsgruppeProvider);
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        final theme = Theme.of(context);
        return Padding(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(context.l10n.chooseJobTitle, style: theme.textTheme.titleMedium),
              const SizedBox(height: 4),
              Text(context.l10n.chooseJobSubtitle,
                  style: theme.textTheme.bodyMedium),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final g in Sprueche.berufsgruppen)
                    ChoiceChip(
                      label: Text(Sprueche.label(g, context.lang)),
                      selected: g == current,
                      onSelected: (_) {
                        HapticFeedback.selectionClick();
                        // Gruppenwechsel wählt automatisch einen frischen Spruch.
                        ref.read(berufsgruppeProvider.notifier).set(g);
                        Navigator.of(context).pop();
                      },
                    ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
