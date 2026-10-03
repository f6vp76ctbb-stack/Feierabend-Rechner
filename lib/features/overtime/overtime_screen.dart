import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/formatting.dart';
import '../../domain/models/overtime_entry.dart';
import '../../domain/overtime_calculator.dart';
import '../../l10n/l10n_ext.dart';
import '../home/state/home_providers.dart';
import 'overtime_entry_sheet.dart';
import '../analytics/analytics_providers.dart';

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
      appBar: AppBar(title: Text(context.l10n.overtimeAccount)),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _addOrEdit(context, ref),
        icon: const Icon(Icons.add_rounded),
        label: Text(context.l10n.addDay),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 96),
        children: [
          _BalanceHeader(total: total, thisWeek: thisWeek),
          const SizedBox(height: 12),
          FilledButton.tonalIcon(
            onPressed: () => _bookToday(context, ref),
            icon: const Icon(Icons.today_rounded),
            label: Text(context.l10n.bookToday),
          ),
          const SizedBox(height: 16),
          if (weeks.isEmpty)
            const _EmptyState()
          else
            for (final week in weeks) _WeekSection(week: week),
        ],
      ),
    );
  }

  /// Bucht den heutigen Tag mit einem Tipp: gearbeitet = heutige Arbeitszeit
  /// des aktiven Profils, Soll = „Soll pro Tag".
  void _bookToday(BuildContext context, WidgetRef ref) {
    ref.read(analyticsProvider).log('overtime_book');
    final worked = ref.read(workConfigProvider).work.inMinutes;
    final target = ref.read(dailyTargetProvider).inMinutes;
    final entry = OvertimeEntry(
      date: DateTime.now(),
      workedMinutes: worked,
      targetMinutes: target,
    );
    ref.read(overtimeControllerProvider.notifier).upsert(entry);
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        content: Text(
          context.l10n.bookedToday(
              Formatting.signedDuration(entry.overtimeMinutes, context.units)),
        ),
      ));
  }

  Future<void> _addOrEdit(
    BuildContext context,
    WidgetRef ref, {
    OvertimeEntry? existing,
  }) async {
    final worked = ref.read(workConfigProvider).work.inMinutes;
    final target = ref.read(dailyTargetProvider).inMinutes;
    final result = await OvertimeEntrySheet.show(
      context,
      existing: existing,
      defaultWorkedMinutes: worked,
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
            Text(context.l10n.totalBalance, style: theme.textTheme.labelLarge),
            const SizedBox(height: 6),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                Formatting.signedDuration(total, context.units),
                style: theme.textTheme.displayLarge
                    ?.copyWith(fontSize: 52, color: color),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              context.l10n.overtimeThisWeekColon(
                  Formatting.signedDuration(thisWeek, context.units)),
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

  String _dayLabel(BuildContext c, DateTime d) => DateFormat.E(c.lang).format(d);
  String _shortDate(BuildContext c, DateTime d) =>
      DateFormat.MMMd(c.lang).format(d);

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
                  '${_shortDate(context, start)} – ${_shortDate(context, end)}',
                  style: theme.textTheme.labelLarge,
                ),
              ),
              Text(
                Formatting.signedDuration(week.balanceMinutes, context.units),
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
                  dayLabel: _dayLabel(context, week.entries[i].date),
                  shortDate: _shortDate(context, week.entries[i].date),
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
        context.l10n.workedOf(
          Formatting.durationHm(Duration(minutes: entry.workedMinutes)),
          Formatting.durationHm(Duration(minutes: entry.targetMinutes)),
        ),
        style: theme.textTheme.bodyMedium,
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            Formatting.signedDuration(ot, context.units),
            style: theme.textTheme.titleMedium?.copyWith(
              color: ot >= 0
                  ? theme.colorScheme.secondary
                  : theme.colorScheme.onSurface,
            ),
          ),
          IconButton(
            tooltip: context.l10n.delete,
            icon: const Icon(Icons.delete_outline_rounded),
            onPressed: () => ref
                .read(overtimeControllerProvider.notifier)
                .deleteFor(entry.date),
          ),
        ],
      ),
      onTap: () async {
        final result = await OvertimeEntrySheet.show(
          context,
          existing: entry,
          defaultWorkedMinutes: entry.workedMinutes,
          defaultTargetMinutes: entry.targetMinutes,
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
          Text(context.l10n.noEntries, style: theme.textTheme.titleMedium),
          const SizedBox(height: 4),
          Text(
            context.l10n.noEntriesHint,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}
