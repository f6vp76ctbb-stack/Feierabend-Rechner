import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Das App-Zeichen: Abendhimmel-Verlauf, Countdown-Ring und untergehende Sonne.
///
/// Wird im Header gezeigt und zum Rendern der Launcher-/Store-Icons genutzt
/// (`tool/store_assets_test.dart`).
class AppIconPainter extends CustomPainter {
  const AppIconPainter({
    this.drawBackground = true,
    this.drawForeground = true,
    this.contentScale = 1.0,
    this.monochrome = false,
  });

  final bool drawBackground;
  final bool drawForeground;

  /// Skaliert Ring + Sonne (für die Safe-Zone adaptiver Android-Icons).
  final double contentScale;

  /// Einfarbig weiß (für Android-13-„Themed Icons").
  final bool monochrome;

  static const _skyTop = Color(0xFF4B3FB8);
  static const _skyMid = Color(0xFF7C5CE7);
  static const _skyBottom = Color(0xFFFF9F6B);
  static const _sun = Color(0xFFFFD58A);

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.shortestSide;
    final rect = Offset.zero & size;

    if (drawBackground) {
      canvas.drawRect(
        rect,
        Paint()
          ..shader = const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [_skyTop, _skyMid, _skyBottom],
            stops: [0.0, 0.55, 1.0],
          ).createShader(rect),
      );
    }
    if (!drawForeground) return;

    final c = rect.center;
    final k = contentScale;
    final ringRadius = 0.30 * s * k;
    final stroke = 0.075 * s * k;
    final white = Colors.white;

    // Ring: dezente Spur + 3/4-Fortschritt.
    canvas.drawCircle(
      c,
      ringRadius,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..color = white.withValues(alpha: monochrome ? 0.45 : 0.28),
    );
    canvas.drawArc(
      Rect.fromCircle(center: c, radius: ringRadius),
      -math.pi / 2,
      math.pi * 1.5,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..strokeCap = StrokeCap.round
        ..color = white,
    );

    // Untergehende Sonne über dem Horizont.
    final horizonY = c.dy + 0.085 * s * k;
    final sunCenter = Offset(c.dx, horizonY + 0.005 * s * k);
    final sunRadius = 0.115 * s * k;
    canvas.save();
    canvas.clipRect(Rect.fromLTRB(0, 0, size.width, horizonY));
    canvas.drawCircle(
      sunCenter,
      sunRadius,
      Paint()..color = monochrome ? white : _sun,
    );
    canvas.restore();
    canvas.drawLine(
      Offset(c.dx - 0.15 * s * k, horizonY),
      Offset(c.dx + 0.15 * s * k, horizonY),
      Paint()
        ..color = white
        ..strokeWidth = 0.032 * s * k
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(AppIconPainter old) =>
      old.drawBackground != drawBackground ||
      old.drawForeground != drawForeground ||
      old.contentScale != contentScale ||
      old.monochrome != monochrome;
}

/// Abgerundetes App-Zeichen für die Oberfläche.
class AppIconMark extends StatelessWidget {
  const AppIconMark({super.key, this.size = 40});

  final double size;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(size * 0.28),
      child: SizedBox.square(
        dimension: size,
        child: const CustomPaint(painter: AppIconPainter()),
      ),
    );
  }
}
