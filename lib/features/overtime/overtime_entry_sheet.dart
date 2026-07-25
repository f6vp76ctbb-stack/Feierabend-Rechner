import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/formatting.dart';
import '../../domain/models/overtime_entry.dart';

/// Overlay zum Anlegen/Bearbeiten eines Überstunden-Tages.
///
/// Liefert einen [OvertimeEntry] oder `null` bei Abbruch.
class OvertimeEntrySheet extends StatefulWidget {
  const OvertimeEntrySheet({
    super.key,
    this.existing,
    required this.defaultWorkedMinutes,
    required this.defaultTargetMinutes,
  });

  final OvertimeEntry? existing;
  final int defaultWorkedMinutes;
  final int defaultTargetMinutes;

  static Future<OvertimeEntry?> show(
    BuildContext context, {
    OvertimeEntry? existing,
    required int defaultWorkedMinutes,
    required int defaultTargetMinutes,
  }) {
    return showModalBottomSheet<OvertimeEntry>(
      context: context,
      isScrollControlled: true,
      builder: (_) => OvertimeEntrySheet(
        existing: existing,
        defaultWorkedMinutes: defaultWorkedMinutes,
        defaultTargetMinutes: defaultTargetMinutes,
      ),
    );
  }

  @override
  State<OvertimeEntrySheet> createState() => _OvertimeEntrySheetState();
}

class _OvertimeEntrySheetState extends State<OvertimeEntrySheet> {
  late DateTime _date =
      widget.existing?.date ?? DateTime.now();
  late int _worked =
      widget.existing?.workedMinutes ?? widget.defaultWorkedMinutes;
  late int _target =
      widget.existing?.targetMinutes ?? widget.defaultTargetMinutes;

  static const _step = 15;
  static const _maxMinutes = 24 * 60;

  void _bump(void Function(int) setter, int current, int delta) {
    final next = current + delta;
    if (next < 0 || next > _maxMinutes) return;
    HapticFeedback.selectionClick();
    setState(() => setter(next));
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 366)),
    );
    if (picked != null) setState(() => _date = picked);
  }

  static const _weekdays = [
    'Mo', 'Di', 'Mi', 'Do', 'Fr', 'Sa', 'So',
  ];

  String get _dateLabel {
    final wd = _weekdays[_date.weekday - 1];
    return '$wd, ${_date.day.toString().padLeft(2, '0')}.'
        '${_date.month.toString().padLeft(2, '0')}.${_date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final overtime = _worked - _target;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        24,
        8,
        24,
        24 + MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            widget.existing == null ? 'Tag hinzufügen' : 'Tag bearbeiten',
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: _pickDate,
            icon: const Icon(Icons.calendar_today_rounded, size: 18),
            label: Text(_dateLabel),
          ),
          const SizedBox(height: 16),
          _StepperRow(
            label: 'Gearbeitet',
            value: Formatting.durationHm(Duration(minutes: _worked)),
            onMinus: () => _bump((v) => _worked = v, _worked, -_step),
            onPlus: () => _bump((v) => _worked = v, _worked, _step),
          ),
          const SizedBox(height: 12),
          _StepperRow(
            label: 'Soll',
            value: Formatting.durationHm(Duration(minutes: _target)),
            onMinus: () => _bump((v) => _target = v, _target, -_step),
            onPlus: () => _bump((v) => _target = v, _target, _step),
          ),
          const SizedBox(height: 16),
          Center(
            child: Text(
              'Saldo: ${Formatting.signedDuration(overtime)}',
              style: theme.textTheme.titleMedium?.copyWith(
                color: overtime >= 0
                    ? theme.colorScheme.secondary
                    : theme.colorScheme.onSurface,
              ),
            ),
          ),
          const SizedBox(height: 20),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(
              OvertimeEntry(
                date: _date,
                workedMinutes: _worked,
                targetMinutes: _target,
              ),
            ),
            child: const Text('Speichern'),
          ),
        ],
      ),
    );
  }
}

class _StepperRow extends StatelessWidget {
  const _StepperRow({
    required this.label,
    required this.value,
    required this.onMinus,
    required this.onPlus,
  });

  final String label;
  final String value;
  final VoidCallback onMinus;
  final VoidCallback onPlus;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: theme.textTheme.labelLarge),
              const SizedBox(height: 2),
              Text(value, style: theme.textTheme.headlineMedium),
            ],
          ),
        ),
        _RoundBtn(icon: Icons.remove_rounded, onTap: onMinus),
        const SizedBox(width: 8),
        _RoundBtn(icon: Icons.add_rounded, onTap: onPlus),
      ],
    );
  }
}

class _RoundBtn extends StatelessWidget {
  const _RoundBtn({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Material(
      color: scheme.primary.withValues(alpha: 0.12),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(
          width: 48,
          height: 48,
          child: Icon(icon, color: scheme.primary),
        ),
      ),
    );
  }
}
