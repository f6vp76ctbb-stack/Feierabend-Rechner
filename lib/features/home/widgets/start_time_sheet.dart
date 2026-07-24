import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/formatting.dart';

/// Bottom-Sheet zum Einstellen der Startzeit über ▲▼-Pfeile (Stunde & Minute).
///
/// Öffnen über [show]; liefert die gewählte [TimeOfDay] oder `null` bei Abbruch.
class StartTimeSheet extends StatefulWidget {
  const StartTimeSheet({super.key, required this.initial});

  final TimeOfDay initial;

  static Future<TimeOfDay?> show(BuildContext context, TimeOfDay initial) {
    return showModalBottomSheet<TimeOfDay>(
      context: context,
      isScrollControlled: true,
      builder: (_) => StartTimeSheet(initial: initial),
    );
  }

  @override
  State<StartTimeSheet> createState() => _StartTimeSheetState();
}

class _StartTimeSheetState extends State<StartTimeSheet> {
  late int _hour = widget.initial.hour;
  late int _minute = widget.initial.minute;

  void _changeMinute(int delta) {
    HapticFeedback.selectionClick();
    setState(() {
      var total = _hour * 60 + _minute + delta;
      total %= 24 * 60; // Überlauf sauber umbrechen (23:59 → 00:00)
      if (total < 0) total += 24 * 60;
      _hour = total ~/ 60;
      _minute = total % 60;
    });
  }

  void _changeHour(int delta) {
    HapticFeedback.selectionClick();
    setState(() => _hour = (_hour + delta + 24) % 24);
  }

  void _setNow() {
    final now = TimeOfDay.now();
    HapticFeedback.selectionClick();
    setState(() {
      _hour = now.hour;
      _minute = now.minute;
    });
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
          Text('Startzeit', style: theme.textTheme.titleMedium),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _Stepper(
                label: 'Stunde',
                value: _hour.toString().padLeft(2, '0'),
                onUp: () => _changeHour(1),
                onDown: () => _changeHour(-1),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  ':',
                  style: theme.textTheme.displayLarge?.copyWith(fontSize: 48),
                ),
              ),
              _Stepper(
                label: 'Minute',
                value: _minute.toString().padLeft(2, '0'),
                onUp: () => _changeMinute(1),
                onDown: () => _changeMinute(-1),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Center(
            child: TextButton.icon(
              onPressed: _setNow,
              icon: const Icon(Icons.schedule_rounded, size: 18),
              label: const Text('Jetzt'),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Feierabend wird ab ${Formatting.clock(_hour, _minute)} berechnet.',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 20),
          FilledButton(
            onPressed: () =>
                Navigator.of(context).pop(TimeOfDay(hour: _hour, minute: _minute)),
            child: const Text('Übernehmen'),
          ),
        ],
      ),
    );
  }
}

class _Stepper extends StatelessWidget {
  const _Stepper({
    required this.label,
    required this.value,
    required this.onUp,
    required this.onDown,
  });

  final String label;
  final String value;
  final VoidCallback onUp;
  final VoidCallback onDown;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _Arrow(icon: Icons.keyboard_arrow_up_rounded, onTap: onUp),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Text(
            value,
            style: theme.textTheme.displayLarge?.copyWith(fontSize: 56),
          ),
        ),
        _Arrow(icon: Icons.keyboard_arrow_down_rounded, onTap: onDown),
        const SizedBox(height: 4),
        Text(label, style: theme.textTheme.labelLarge),
      ],
    );
  }
}

class _Arrow extends StatelessWidget {
  const _Arrow({required this.icon, required this.onTap});

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
          width: 56,
          height: 44,
          child: Icon(icon, size: 30, color: scheme.primary),
        ),
      ),
    );
  }
}
