import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Ein Farb-Design der App. „Standard" ist gratis, alle anderen sind
/// einzelne Einmalkäufe (nicht in Pro enthalten).
@immutable
class AppDesign {
  /// Stabile ID (Persistenz).
  final String id;

  /// Play-Produkt-ID; `null` = gratis.
  final String? productId;

  /// Buttons, Schalter, Fokus.
  final Color primary;

  /// Etwas hellere Variante für den Dark Mode (Lesbarkeit auf dunklem Grund).
  final Color? primaryOnDark;

  /// Fortschrittsring von Start → Feierabend.
  final List<Color> ring;

  /// „Feierabend!"/Erfolg.
  final Color free;

  /// Kleiner Akzent (z. B. „+1" bei Nachtschicht).
  final Color warm;

  final Color bgLight;
  final Color bgDark;
  final Color surfaceDark;

  /// Zarte Herzen im Hintergrund (Supporter).
  final bool hearts;

  const AppDesign({
    required this.id,
    required this.productId,
    required this.primary,
    this.primaryOnDark,
    required this.ring,
    required this.free,
    required this.warm,
    required this.bgLight,
    required this.bgDark,
    required this.surfaceDark,
    this.hearts = false,
  });

  bool get isFree => productId == null;

  Color primaryFor(Brightness b) =>
      b == Brightness.dark ? (primaryOnDark ?? primary) : primary;

  @override
  bool operator ==(Object other) => other is AppDesign && other.id == id;

  @override
  int get hashCode => id.hashCode;
}

/// Alle Designs – Reihenfolge = Anzeige im Design-Shop.
abstract final class AppDesigns {
  static const standard = AppDesign(
    id: 'standard',
    productId: null,
    primary: AppColors.primary,
    ring: [AppColors.primary, AppColors.primaryLight, AppColors.success],
    free: AppColors.success,
    warm: AppColors.accentWarm,
    bgLight: AppColors.bgLight,
    bgDark: AppColors.bgDark,
    surfaceDark: AppColors.surfaceDark,
  );

  /// Das teuerste: mit Herzen – für alle, die die Entwicklung unterstützen wollen.
  static const supporter = AppDesign(
    id: 'supporter',
    productId: 'design_supporter',
    primary: Color(0xFFD63384),
    primaryOnDark: Color(0xFFE0559A),
    ring: [Color(0xFFD63384), Color(0xFFF78FB3), Color(0xFFFFB8A8)],
    free: Color(0xFFD63384),
    warm: Color(0xFFFF8FA3),
    bgLight: Color(0xFFFFF5F8),
    bgDark: Color(0xFF1C1218),
    surfaceDark: Color(0xFF2A1B24),
    hearts: true,
  );

  static const midnight = AppDesign(
    id: 'midnight',
    productId: 'design_midnight',
    primary: Color(0xFF3F3DA8),
    primaryOnDark: Color(0xFF6E6BE6),
    ring: [Color(0xFF3F3DA8), Color(0xFF7B6CF6), Color(0xFFF6C453)],
    free: Color(0xFFC98A10),
    warm: Color(0xFFF6C453),
    bgLight: Color(0xFFF3F3F9),
    bgDark: Color(0xFF0B0B14),
    surfaceDark: Color(0xFF181828),
  );

  static const sunset = AppDesign(
    id: 'sunset',
    productId: 'design_sunset',
    primary: Color(0xFFD9572B),
    primaryOnDark: Color(0xFFE8673C),
    ring: [Color(0xFFD9572B), Color(0xFFF39C6B), Color(0xFFFDCB6E)],
    free: Color(0xFF00A884),
    warm: Color(0xFFE84393),
    bgLight: Color(0xFFFFF8F2),
    bgDark: Color(0xFF1C1512),
    surfaceDark: Color(0xFF2A201B),
  );

  static const ocean = AppDesign(
    id: 'ocean',
    productId: 'design_ocean',
    primary: Color(0xFF0A74C9),
    primaryOnDark: Color(0xFF2E8FE0),
    ring: [Color(0xFF0A74C9), Color(0xFF48B1F5), Color(0xFF00CEC9)],
    free: Color(0xFF00A3A0),
    warm: Color(0xFFFFA45C),
    bgLight: Color(0xFFF2F8FC),
    bgDark: Color(0xFF0F1820),
    surfaceDark: Color(0xFF1A2632),
  );

  static const forest = AppDesign(
    id: 'forest',
    productId: 'design_forest',
    primary: Color(0xFF2E7D50),
    primaryOnDark: Color(0xFF3F9E68),
    ring: [Color(0xFF2E7D50), Color(0xFF6AB187), Color(0xFFB8D86B)],
    free: Color(0xFF2E7D50),
    warm: Color(0xFFE1A23B),
    bgLight: Color(0xFFF4F8F2),
    bgDark: Color(0xFF111914),
    surfaceDark: Color(0xFF1C2820),
  );

  static const all = [standard, supporter, midnight, sunset, ocean, forest];

  static List<AppDesign> get paid => [
        for (final d in all)
          if (!d.isFree) d,
      ];

  static AppDesign byId(String? id) =>
      all.firstWhere((d) => d.id == id, orElse: () => standard);

  static AppDesign? byProductId(String productId) {
    for (final d in all) {
      if (d.productId == productId) return d;
    }
    return null;
  }
}

/// Design-Farben, die nicht in [ColorScheme] passen – per `Theme.of(context)`.
class DesignColors extends ThemeExtension<DesignColors> {
  final List<Color> ring;
  final Color free;
  final Color warm;
  final Color glow;
  final bool hearts;

  const DesignColors({
    required this.ring,
    required this.free,
    required this.warm,
    required this.glow,
    required this.hearts,
  });

  factory DesignColors.of(AppDesign d) => DesignColors(
        ring: d.ring,
        free: d.free,
        warm: d.warm,
        glow: d.primary,
        hearts: d.hearts,
      );

  @override
  DesignColors copyWith({
    List<Color>? ring,
    Color? free,
    Color? warm,
    Color? glow,
    bool? hearts,
  }) =>
      DesignColors(
        ring: ring ?? this.ring,
        free: free ?? this.free,
        warm: warm ?? this.warm,
        glow: glow ?? this.glow,
        hearts: hearts ?? this.hearts,
      );

  @override
  DesignColors lerp(DesignColors? other, double t) {
    if (other == null) return this;
    return DesignColors(
      ring: [
        for (var i = 0; i < ring.length; i++)
          Color.lerp(ring[i], other.ring[i], t)!,
      ],
      free: Color.lerp(free, other.free, t)!,
      warm: Color.lerp(warm, other.warm, t)!,
      glow: Color.lerp(glow, other.glow, t)!,
      hearts: t < 0.5 ? hearts : other.hearts,
    );
  }
}

extension DesignColorsX on BuildContext {
  /// Farben des aktiven Designs (Standard, falls kein Theme sie liefert).
  DesignColors get design =>
      Theme.of(this).extension<DesignColors>() ??
      DesignColors.of(AppDesigns.standard);
}
