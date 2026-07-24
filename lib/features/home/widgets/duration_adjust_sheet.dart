import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/formatting.dart';

/// Sanftes Bottom-Sheet zum Einstellen einer Dauer (Arbeitszeit / Pause).
///
/// Öffnen über [show]; liefert die gewählte [Duration] oder `null` bei Abbruch.
class DurationAdjustSheet extends StatefulWidget {
  const DurationAdjustSheet({
    super.key,
    required this.title,
    required this.initial,
    required this.step,
    required this.min,
    required this.max,
    required this.presets,
  });

  final String title;
  final Duration initial;
  final Duration step;
  final Duration min;
  final Duration max;
  final List<Duration> presets;

  static Future<Duration?> show(
    BuildContext context, {
    required String title,
    required Duration initial,
    required Duration step,
    required Duration min,
    required Duration max,
    required List<Duration> presets,
  }) {
    return showModalBottomSheet<Duration>(
      context: context,
      isScrollControlled: true,
      builder: (_) => DurationAdjustSheet(
        title: title,
        initial: initial,
        step: step,
        min: min,
        max: max,
        presets: presets,
      ),
    );
  }

  @override
  State<DurationAdjustSheet> createState() => _DurationAdjustSheetState();
}

class _DurationAdjustSheetState extends State<DurationAdjustSheet> {
  late Duration _value = widget.initial;

  void _change(Duration delta) {
    final next = _value + delta;
    if (next < widget.min || next > widget.max) return;
    HapticFeedback.selectionClick();
    setState(() => _value = next);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
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
          Text(widget.title, style: theme.textTheme.titleMedium),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _RoundButton(
                icon: Icons.remove_rounded,
                onTap: () => _change(-widget.step),
                enabled: _value - widget.step >= widget.min,
              ),
              Text(
                Formatting.durationHm(_value),
                style: theme.textTheme.displayLarge?.copyWith(fontSize: 56),
              ),
              _RoundButton(
                icon: Icons.add_rounded,
                onTap: () => _change(widget.step),
                enabled: _value + widget.step <= widget.max,
              ),
            ],
          ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: [
              for (final p in widget.presets)
                ChoiceChip(
                  label: Text(Formatting.durationHm(p)),
                  selected: p == _value,
                  onSelected: (_) {
                    HapticFeedback.selectionClick();
                    setState(() => _value = p);
                  },
                ),
            ],
          ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(_value),
            child: const Text('Übernehmen'),
          ),
        ],
      ),
    );
  }
}

class _RoundButton extends StatelessWidget {
  const _RoundButton({
    required this.icon,
    required this.onTap,
    required this.enabled,
  });

  final IconData icon;
  final VoidCallback onTap;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Material(
      color: enabled
          ? scheme.primary.withValues(alpha: 0.12)
          : scheme.onSurface.withValues(alpha: 0.05),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: enabled ? onTap : null,
        child: SizedBox(
          width: 60,
          height: 60,
          child: Icon(
            icon,
            size: 28,
            color: enabled ? scheme.primary : scheme.onSurface.withValues(alpha: 0.3),
          ),
        ),
      ),
    );
  }
}
