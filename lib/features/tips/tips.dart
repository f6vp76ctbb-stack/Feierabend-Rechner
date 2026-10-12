import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/l10n_ext.dart';
import '../analytics/analytics_providers.dart';
import '../home/state/home_providers.dart';

/// Stellen auf dem Hauptbildschirm, die die Tipps hervorheben.
abstract final class TipTargets {
  static final ring = GlobalKey(debugLabel: 'tip-ring');
  static final inputs = GlobalKey(debugLabel: 'tip-inputs');
  static final presets = GlobalKey(debugLabel: 'tip-presets');
  static final settings = GlobalKey(debugLabel: 'tip-settings');
}

/// Wurden die Tipps gezeigt (oder übersprungen)? `false` → beim nächsten
/// Hauptbildschirm zeigen. „Tipps erneut zeigen“ setzt es zurück.
class TipsController extends Notifier<bool> {
  @override
  bool build() => ref.read(settingsRepositoryProvider).loadTipsDone();

  void finish() {
    state = true;
    ref.read(settingsRepositoryProvider).saveTipsDone(true);
  }

  void replay() {
    state = false;
    ref.read(settingsRepositoryProvider).saveTipsDone(false);
  }
}

final tipsDoneProvider =
    NotifierProvider<TipsController, bool>(TipsController.new);

class _Step {
  const _Step(this.target, this.title, this.body);
  final GlobalKey target;
  final String title;
  final String body;
}

/// Zeigt die Tipps als Overlay über dem Hauptbildschirm. Fertig, wenn
/// durchgetippt oder übersprungen; danach gilt [tipsDoneProvider] = true.
Future<void> showTips(BuildContext context, WidgetRef ref) async {
  final l = context.l10n;
  final steps = [
    _Step(TipTargets.ring, l.tipRingTitle, l.tipRingBody),
    _Step(TipTargets.inputs, l.tipInputsTitle, l.tipInputsBody),
    _Step(TipTargets.presets, l.tipPresetsTitle, l.tipPresetsBody),
    _Step(TipTargets.settings, l.tipSettingsTitle, l.tipSettingsBody),
  ].where((s) => s.target.currentContext != null).toList();
  final ctrl = ref.read(tipsDoneProvider.notifier);
  final analytics = ref.read(analyticsProvider);
  if (steps.isEmpty) {
    ctrl.finish();
    return;
  }

  final done = Completer<void>();
  late final OverlayEntry entry;
  entry = OverlayEntry(
    builder: (_) => _CoachMarks(
      steps: steps,
      onClose: ({required bool skipped, required int step}) {
        entry.remove();
        analytics.log('tips_done', {'skipped': skipped ? 1 : 0, 'step': step});
        ctrl.finish();
        done.complete();
      },
    ),
  );
  Overlay.of(context, rootOverlay: true).insert(entry);
  return done.future;
}

typedef _OnClose = void Function({required bool skipped, required int step});

class _CoachMarks extends StatefulWidget {
  const _CoachMarks({required this.steps, required this.onClose});

  final List<_Step> steps;
  final _OnClose onClose;

  @override
  State<_CoachMarks> createState() => _CoachMarksState();
}

class _CoachMarksState extends State<_CoachMarks> {
  int _index = 0;
  Rect? _hole;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _show(0));
  }

  Future<void> _show(int index) async {
    final target = widget.steps[index].target.currentContext;
    if (target == null || !target.mounted) return _next(from: index);
    await Scrollable.ensureVisible(
      target,
      alignment: 0.05, // Ziel nach oben → Platz für die Karte darunter
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
    );
    if (!mounted || !target.mounted) return;
    final box = target.findRenderObject() as RenderBox?;
    final overlay = context.findRenderObject() as RenderBox?;
    if (box == null || overlay == null) return;
    final topLeft = box.localToGlobal(Offset.zero, ancestor: overlay);
    setState(() {
      _index = index;
      _hole = (topLeft & box.size).inflate(8);
    });
  }

  void _next({int? from}) {
    final i = (from ?? _index) + 1;
    if (i >= widget.steps.length) {
      widget.onClose(skipped: false, step: widget.steps.length);
    } else {
      HapticFeedback.selectionClick();
      _show(i);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l = context.l10n;
    final size = MediaQuery.sizeOf(context);
    final hole = _hole;
    final step = widget.steps[_index];
    final last = _index == widget.steps.length - 1;

    // Karte dorthin, wo mehr Platz ist (unter oder über dem Ziel).
    final pad = MediaQuery.paddingOf(context);
    final below =
        hole == null || size.height - hole.bottom >= hole.top;
    final card = Material(
      color: theme.colorScheme.surface,
      borderRadius: BorderRadius.circular(22),
      elevation: 6,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 12, 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l.tipStep(_index + 1, widget.steps.length),
              style: theme.textTheme.labelMedium
                  ?.copyWith(color: theme.colorScheme.primary),
            ),
            const SizedBox(height: 4),
            Text(step.title, style: theme.textTheme.titleMedium),
            const SizedBox(height: 6),
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Text(step.body, style: theme.textTheme.bodyMedium),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                if (!last)
                  TextButton(
                    onPressed: () =>
                        widget.onClose(skipped: true, step: _index + 1),
                    child: Text(l.onbSkip),
                  ),
                const Spacer(),
                FilledButton(
                  // Das App-Theme macht Knöpfe breit – hier sitzt er in einer Zeile.
                  style: FilledButton.styleFrom(minimumSize: const Size(96, 44)),
                  onPressed: _next,
                  child: Text(last ? l.tipDone : l.onbNext),
                ),
              ],
            ),
          ],
        ),
      ),
    );

    return Material(
      type: MaterialType.transparency,
      child: Stack(
        children: [
          // Abdunkeln mit „Loch“ ums Ziel; Tippen daneben = weiter.
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: _next,
              child: hole == null
                  ? const SizedBox.expand()
                  : TweenAnimationBuilder<Rect?>(
                      tween: RectTween(end: hole),
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.easeOut,
                      builder: (context, rect, _) => CustomPaint(
                        painter: _HolePainter(
                            rect, Colors.black.withValues(alpha: 0.62)),
                      ),
                    ),
            ),
          ),
          if (hole != null)
            Positioned(
              left: 16,
              right: 16,
              top: below ? hole.bottom + 12 : pad.top + 16,
              bottom: below ? pad.bottom + 16 : size.height - hole.top + 12,
              child: Align(
                alignment: below ? Alignment.topCenter : Alignment.bottomCenter,
                // Auf sehr kleinen Bildschirmen lieber scrollen als abschneiden.
                child: SingleChildScrollView(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 220),
                    child: KeyedSubtree(key: ValueKey(_index), child: card),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _HolePainter extends CustomPainter {
  _HolePainter(this.hole, this.color);

  final Rect? hole;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final dim = Path()..addRect(Offset.zero & size);
    final h = hole;
    final path = h == null
        ? dim
        : Path.combine(
            PathOperation.difference,
            dim,
            Path()..addRRect(RRect.fromRectAndRadius(h, const Radius.circular(20))),
          );
    canvas.drawPath(path, Paint()..color = color);
  }

  @override
  bool shouldRepaint(_HolePainter old) => old.hole != hole || old.color != color;
}
