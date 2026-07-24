import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/formatting.dart';
import '../../domain/models/overtime_entry.dart';
import '../../domain/overtime_calculator.dart';
import '../home/state/home_providers.dart';
import 'overtime_entry_sheet.dart';

/// Überstunden-Konto: Gesamtsaldo oben, darunter die Wochen mit Tageseinträgen.
class OvertimeScreen extends ConsumerWidget {
  const OvertimeScreen({super.key});

  static Future<void> open(BuildContext context) {
    return Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const OvertimeScreen()),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final weeks = ref.watch(overtimeWeeksProvider);
    final total = ref.watch(overtimeBalanceProvider);
    final thisWeek = ref.watch(overtimeThisWeekProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Überstunden-Konto')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _addOrEdit(context, ref),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Tag'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 96),
        children: [
          _BalanceHeader(total: total, thisWeek: thisWeek),
          const SizedBox(height: 16),
          if (weeks.isEmpty)
            const _EmptyState()
          else
            for (final week in weeks) _WeekSection(week: week),
        ],
      ),
    );
  }

  Future<void> _addOrEdit(
    BuildContext context,
    WidgetRef ref, {
    OvertimeEntry? existing,
  }) async {
    final target = ref.read(workConfigProvider).work.inMinutes;
    final result = await OvertimeEntrySheet.show(
      context,
      existing: existing,
      defaultTargetMinutes: target,
    );
    if (result != null) {
      ref.read(overtimeControllerProvider.notifier).upsert(result);
    }
  }
}

class _BalanceHeader extends StatelessWidget {
  const _BalanceHeader({required this.total, required this.thisWeek});

  final int total;
  final int thisWeek;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final positive = total >= 0;
    final color =
        positive ? theme.colorScheme.secondary : theme.colorScheme.primary;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text('GESAMTSALDO', style: theme.textTheme.labelLarge),
            const SizedBox(height: 6),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                Formatting.signedDuration(total),
                style: theme.textTheme.displayLarge
                    ?.copyWith(fontSize: 52, color: color),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Diese Woche: ${Formatting.signedDuration(thisWeek)}',
              style: theme.textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}

class _WeekSection extends ConsumerWidget {
  const _WeekSection({required this.week});

  final OvertimeWeek week;

  static const _months = [
    'Jan', 'Feb', 'März', 'Apr', 'Mai', 'Juni',
    'Juli', 'Aug', 'Sept', 'Okt', 'Nov', 'Dez',
  ];
  static const _weekdays = ['Mo', 'Di', 'Mi', 'Do', 'Fr', 'Sa', 'So'];

  String _dayLabel(DateTime d) => _weekdays[d.weekday - 1];
  String _shortDate(DateTime d) => '${d.day}. ${_months[d.month - 1]}';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final start = week.weekStart;
    final end = week.weekEnd;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(4, 12, 4, 6),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  '${_shortDate(start)} – ${_shortDate(end)}',
                  style: theme.textTheme.labelLarge,
                ),
              ),
              Text(
                Formatting.signedDuration(week.balanceMinutes),
                style: theme.textTheme.titleMedium?.copyWith(
                  color: week.balanceMinutes >= 0
                      ? theme.colorScheme.secondary
                      : theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
        Card(
          margin: EdgeInsets.zero,
          child: Column(
            children: [
              for (var i = 0; i < week.entries.length; i++) ...[
                if (i > 0) const Divider(height: 1, indent: 16, endIndent: 16),
                _EntryTile(
                  entry: week.entries[i],
                  dayLabel: _dayLabel(week.entries[i].date),
                  shortDate: _shortDate(week.entries[i].date),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _EntryTile extends ConsumerWidget {
  const _EntryTile({
    required this.entry,
    required this.dayLabel,
    required this.shortDate,
  });

  final OvertimeEntry entry;
  final String dayLabel;
  final String shortDate;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final ot = entry.overtimeMinutes;
    return ListTile(
      title: Text('$dayLabel, $shortDate'),
      subtitle: Text(
        '${Formatting.durationHm(Duration(minutes: entry.workedMinutes))} '
        'von ${Formatting.durationHm(Duration(minutes: entry.targetMinutes))}',
        style: theme.textTheme.bodyMedium,
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            Formatting.signedDuration(ot),
            style: theme.textTheme.titleMedium?.copyWith(
              color: ot >= 0
                  ? theme.colorScheme.secondary
                  : theme.colorScheme.onSurface,
            ),
          ),
          IconButton(
            tooltip: 'Löschen',
            icon: const Icon(Icons.delete_outline_rounded),
            onPressed: () => ref
                .read(overtimeControllerProvider.notifier)
                .deleteFor(entry.date),
          ),
        ],
      ),
      onTap: () async {
        final target = ref.read(workConfigProvider).work.inMinutes;
        final result = await OvertimeEntrySheet.show(
          context,
          existing: entry,
          defaultTargetMinutes: target,
        );
        if (result != null) {
          ref.read(overtimeControllerProvider.notifier).upsert(result);
        }
      },
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: 48),
      child: Column(
        children: [
          Icon(Icons.event_note_rounded,
              size: 56, color: theme.colorScheme.primary.withValues(alpha: 0.5)),
          const SizedBox(height: 12),
          Text('Noch keine Einträge', style: theme.textTheme.titleMedium),
          const SizedBox(height: 4),
          Text(
            'Tippe auf „Tag", um deinen ersten Arbeitstag zu erfassen.',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}
