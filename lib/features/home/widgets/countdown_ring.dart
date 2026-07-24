import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Kreisförmiger Fortschritts-Ring mit frei platzierbarem Inhalt in der Mitte.
class CountdownRing extends StatelessWidget {
  const CountdownRing({
    super.key,
    required this.progress,
    required this.child,
    this.size = 260,
    this.stroke = 14,
  });

  /// 0.0–1.0 Anteil des bereits vergangenen Arbeitstags.
  final double progress;
  final Widget child;
  final double size;
  final double stroke;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: progress.clamp(0.0, 1.0)),
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeOut,
            builder: (context, value, _) => CustomPaint(
              size: Size.square(size),
              painter: _RingPainter(
                progress: value,
                stroke: stroke,
                track: scheme.primary.withValues(alpha: 0.12),
                gradient: SweepGradient(
                  startAngle: -math.pi / 2,
                  endAngle: 3 * math.pi / 2,
                  colors: [
                    scheme.primary,
                    const Color(0xFF8B7EF0),
                    scheme.secondary,
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(stroke + 16),
            child: Center(child: child),
          ),
        ],
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter({
    required this.progress,
    required this.stroke,
    required this.track,
    required this.gradient,
  });

  final double progress;
  final double stroke;
  final Color track;
  final Gradient gradient;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final center = rect.center;
    final radius = (size.width - stroke) / 2;

    final trackPaint = Paint()
      ..color = track
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(center, radius, trackPaint);

    if (progress <= 0) return;

    final arcPaint = Paint()
      ..shader = gradient.createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      2 * math.pi * progress,
      false,
      arcPaint,
    );
  }

  @override
  bool shouldRepaint(_RingPainter old) =>
      old.progress != progress || old.track != track;
}
