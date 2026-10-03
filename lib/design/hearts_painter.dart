import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Zarte, verstreute Herzen (Supporter-Design). Feste Anordnung, kein Flackern.
class HeartsPainter extends CustomPainter {
  HeartsPainter({required this.color});

  final Color color;

  /// Relative Positionen (x, y), Größe und Drehung – handverteilt, ruhig.
  static const _hearts = <(double, double, double, double)>[
    (0.08, 0.06, 22, -0.3),
    (0.86, 0.10, 30, 0.25),
    (0.62, 0.03, 14, 0.1),
    (0.30, 0.16, 12, -0.15),
    (0.93, 0.34, 16, -0.2),
    (0.04, 0.40, 26, 0.2),
    (0.78, 0.52, 12, 0.35),
    (0.14, 0.66, 14, -0.25),
    (0.90, 0.72, 24, 0.15),
    (0.06, 0.88, 18, 0.3),
    (0.55, 0.94, 14, -0.1),
    (0.80, 0.96, 20, -0.3),
  ];

  static Path heart(double size) {
    final s = size;
    return Path()
      ..moveTo(0, s * 0.32)
      ..cubicTo(-s * 0.02, s * 0.05, -s * 0.5, -s * 0.05, -s * 0.5, -s * 0.18)
      ..cubicTo(-s * 0.5, -s * 0.42, -s * 0.18, -s * 0.52, 0, -s * 0.28)
      ..cubicTo(s * 0.18, -s * 0.52, s * 0.5, -s * 0.42, s * 0.5, -s * 0.18)
      ..cubicTo(s * 0.5, -s * 0.05, s * 0.02, s * 0.05, 0, s * 0.32)
      ..close();
  }

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    final scale = math.min(size.width, 420) / 420 + 0.5;
    for (final (x, y, s, rot) in _hearts) {
      canvas
        ..save()
        ..translate(x * size.width, y * size.height)
        ..rotate(rot)
        ..drawPath(heart(s * scale), paint)
        ..restore();
    }
  }

  @override
  bool shouldRepaint(HeartsPainter old) => old.color != color;
}
