import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Zentrales Theme (Material 3, hell + dunkel gleichwertig).
///
/// Schrift: gebündeltes Inter (Variable Font). Große Radien, weiche Optik.
abstract final class AppTheme {
  static const String fontFamily = 'Inter';

  /// Standard-Eckenradius für Karten/Overlays (weiche Ecken, 20–24 px).
  static const double radius = 24;

  static ThemeData light() => _base(
        brightness: Brightness.light,
        background: AppColors.bgLight,
        surface: AppColors.surfaceLight,
        onSurface: AppColors.textLight,
        muted: AppColors.mutedLight,
      );

  static ThemeData dark() => _base(
        brightness: Brightness.dark,
        background: AppColors.bgDark,
        surface: AppColors.surfaceDark,
        onSurface: AppColors.textDark,
        muted: AppColors.mutedDark,
      );

  static ThemeData _base({
    required Brightness brightness,
    required Color background,
    required Color surface,
    required Color onSurface,
    required Color muted,
  }) {
    final scheme = ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: brightness,
    ).copyWith(
      primary: AppColors.primary,
      secondary: AppColors.success,
      surface: surface,
      onSurface: onSurface,
    );

    final textTheme = _textTheme(onSurface, muted);

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: background,
      fontFamily: fontFamily,
      textTheme: textTheme,
      splashFactory: InkSparkle.splashFactory,
      cardTheme: CardThemeData(
        elevation: 0,
        color: surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radius),
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: surface,
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        showDragHandle: true,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(56),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          textStyle: textTheme.titleMedium?.copyWith(
            fontVariations: const [FontVariation('wght', 600)],
          ),
        ),
      ),
    );
  }

  static TextTheme _textTheme(Color onSurface, Color muted) {
    // Variable-Font-Gewichte über fontVariations (robuster als fontWeight).
    FontVariation w(double weight) => FontVariation('wght', weight);
    return TextTheme(
      // Die riesige Feierabend-Uhrzeit.
      displayLarge: TextStyle(
        fontFamily: fontFamily,
        fontSize: 84,
        height: 1.0,
        letterSpacing: -2,
        fontVariations: [w(700)],
        color: onSurface,
      ),
      headlineMedium: TextStyle(
        fontFamily: fontFamily,
        fontSize: 26,
        fontVariations: [w(600)],
        color: onSurface,
      ),
      titleMedium: TextStyle(
        fontFamily: fontFamily,
        fontSize: 17,
        fontVariations: [w(600)],
        color: onSurface,
      ),
      bodyLarge: TextStyle(
        fontFamily: fontFamily,
        fontSize: 16,
        fontVariations: [w(400)],
        color: onSurface,
      ),
      bodyMedium: TextStyle(
        fontFamily: fontFamily,
        fontSize: 14,
        fontVariations: [w(400)],
        color: muted,
      ),
      labelLarge: TextStyle(
        fontFamily: fontFamily,
        fontSize: 13,
        letterSpacing: 0.5,
        fontVariations: [w(500)],
        color: muted,
      ),
    );
  }
}
