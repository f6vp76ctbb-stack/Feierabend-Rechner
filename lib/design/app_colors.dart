import 'package:flutter/material.dart';

/// Farb-Tokens der App (siehe CLAUDE.md §7).
///
/// Warme, ruhige Palette. Kein grelles Rot. Erfolg = sanftes Grün.
abstract final class AppColors {
  /// Primär: warmes Indigo/Violett (Fokus, Buttons).
  static const Color primary = Color(0xFF6C5CE7);
  static const Color primaryLight = Color(0xFF8B7EF0);
  static const Color primaryDark = Color(0xFF5546C4);

  /// Akzent/Erfolg: sanftes Grün ("frei!").
  static const Color success = Color(0xFF00B894);

  /// Warmer, freundlicher Sekundär-Akzent (Sonnenuntergang).
  static const Color accentWarm = Color(0xFFFFA45C);

  // Hintergründe
  static const Color bgLight = Color(0xFFF7F7FB);
  static const Color bgDark = Color(0xFF15151E);

  // Flächen / Karten
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color surfaceDark = Color(0xFF20202D);

  // Text
  static const Color textLight = Color(0xFF1E1E28);
  static const Color textDark = Color(0xFFF3F3F8);
  static const Color mutedLight = Color(0xFF6B6B7B);
  static const Color mutedDark = Color(0xFF9B9BAE);
}
