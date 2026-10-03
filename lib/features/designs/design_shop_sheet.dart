import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../design/app_designs.dart';
import '../../design/hearts_painter.dart';
import '../../l10n/app_localizations.dart';
import '../../l10n/l10n_ext.dart';
import '../../services/purchase_backend.dart';
import '../pro/pro_providers.dart';
import 'design_providers.dart';

/// Lokalisierter Name eines Designs.
String designName(AppLocalizations l, AppDesign d) => switch (d.id) {
      'supporter' => l.designNameSupporter,
      'midnight' => l.designNameMidnight,
      'sunset' => l.designNameSunset,
      'ocean' => l.designNameOcean,
      'forest' => l.designNameForest,
      _ => l.designNameStandard,
    };

/// Design-Shop: Supporter groß oben, die übrigen im Raster.
class DesignShopSheet extends ConsumerWidget {
  const DesignShopSheet({super.key});

  static Future<void> show(BuildContext context) => showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        builder: (_) => const DesignShopSheet(),
      );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l = context.l10n;

    ref.listen<AsyncValue<PurchaseEvent>>(purchaseEventsProvider, (_, next) {
      final event = next.valueOrNull;
      if (event == null || AppDesigns.byProductId(event.productId) == null) {
        return;
      }
      final text = switch (event.type) {
        PurchaseEventType.purchased => l.designThanks,
        PurchaseEventType.pending => l.purchasePending,
        PurchaseEventType.error => l.purchaseError,
        _ => null,
      };
      if (text != null) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(text)));
      }
    });

    final others = [
      for (final d in AppDesigns.all)
        if (d != AppDesigns.supporter) d,
    ];

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(l.designsTitle, style: theme.textTheme.headlineMedium),
            const SizedBox(height: 4),
            Text(l.designsSubtitle, style: theme.textTheme.bodyMedium),
            const SizedBox(height: 16),
            const _DesignCard(design: AppDesigns.supporter, featured: true),
            const SizedBox(height: 12),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 0.82,
              children: [for (final d in others) _DesignCard(design: d)],
            ),
          ],
        ),
      ),
    );
  }
}

class _DesignCard extends ConsumerWidget {
  const _DesignCard({required this.design, this.featured = false});

  final AppDesign design;
  final bool featured;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l = context.l10n;
    final state = ref.watch(designsProvider);
    final active = ref.watch(activeDesignProvider) == design;
    final owned = state.owns(design);
    final productId = design.productId;
    final price = productId == null || owned
        ? null
        : ref.watch(designPriceProvider(productId)).valueOrNull;
    final dark = theme.brightness == Brightness.dark;
    final accent = design.primaryFor(theme.brightness);

    Future<void> onTap() async {
      HapticFeedback.selectionClick();
      final ctrl = ref.read(designsProvider.notifier);
      if (owned) {
        ctrl.select(design);
        return;
      }
      final messenger = ScaffoldMessenger.of(context);
      final started = await ctrl.buy(design);
      if (!started) {
        messenger.showSnackBar(SnackBar(content: Text(l.paywallUnavailable)));
      }
    }

    final status = active
        ? Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.check_circle_rounded, size: 18, color: accent),
              const SizedBox(width: 4),
              Text(l.designActive,
                  style: theme.textTheme.labelLarge?.copyWith(color: accent)),
            ],
          )
        : Text(
            design.isFree
                ? l.designFree
                : owned
                    ? l.designOwned
                    : (price ?? '…'),
            style: theme.textTheme.labelLarge?.copyWith(
              color: owned ? null : accent,
              fontVariations: const [FontVariation('wght', 700)],
            ),
          );

    final preview = _DesignPreview(design: design, dark: dark, tall: featured);

    return Material(
      color: theme.colorScheme.surface,
      borderRadius: BorderRadius.circular(22),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOut,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: active ? accent : theme.dividerColor.withValues(alpha: 0.4),
              width: active ? 2.5 : 1,
            ),
          ),
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (featured) SizedBox(height: 120, child: preview) else Expanded(child: preview),
              const SizedBox(height: 10),
              if (featured)
                Row(
                  children: [
                    Expanded(
                      child: Text(designName(l, design),
                          style: theme.textTheme.titleMedium),
                    ),
                    status,
                  ],
                )
              else ...[
                // Name und Preis untereinander – auch lange Namen passen.
                Text(
                  designName(l, design),
                  style: theme.textTheme.titleMedium,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Align(alignment: Alignment.centerLeft, child: status),
              ],
              if (featured) ...[
                const SizedBox(height: 4),
                Text(l.designSupporterHint, style: theme.textTheme.bodyMedium),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Mini-Vorschau: Hintergrund, Ring und Uhrzeit im jeweiligen Design.
class _DesignPreview extends StatelessWidget {
  const _DesignPreview({required this.design, required this.dark, this.tall = false});

  final AppDesign design;
  final bool dark;
  final bool tall;

  @override
  Widget build(BuildContext context) {
    final bg = dark ? design.bgDark : design.bgLight;
    final text = dark ? Colors.white : const Color(0xFF1E1E28);
    final glow = design.primary.withValues(alpha: dark ? 0.22 : 0.12);
    final l = context.l10n;
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: bg,
          gradient: RadialGradient(
            center: const Alignment(0, -0.6),
            radius: 1.1,
            colors: [Color.alphaBlend(glow, bg), bg],
          ),
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (design.hearts)
              CustomPaint(
                painter: HeartsPainter(
                    color: design.primary.withValues(alpha: dark ? 0.28 : 0.2)),
              ),
            Align(
              // Beim großen Supporter-Kärtchen Platz fürs Abzeichen links lassen.
              alignment: tall ? const Alignment(0.55, 0) : Alignment.center,
              child: AspectRatio(
                aspectRatio: 1,
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: CustomPaint(
                    painter: _MiniRingPainter(design.ring),
                    child: Center(
                      child: FittedBox(
                        child: Padding(
                          padding: const EdgeInsets.all(14),
                          child: Text(
                            '15:29',
                            style: TextStyle(
                              color: text,
                              fontSize: 22,
                              fontVariations: const [FontVariation('wght', 700)],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            if (tall && design == AppDesigns.supporter)
              Positioned(
                top: 8,
                left: 8,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: design.primary,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.favorite_rounded,
                            size: 14, color: Colors.white),
                        const SizedBox(width: 4),
                        Text(
                          l.designSupporterBadge,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontVariations: [FontVariation('wght', 600)],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _MiniRingPainter extends CustomPainter {
  _MiniRingPainter(this.colors);

  final List<Color> colors;

  @override
  void paint(Canvas canvas, Size size) {
    final stroke = size.shortestSide * 0.09;
    final rect = Offset.zero & size;
    final arcRect = rect.deflate(stroke / 2);
    canvas.drawArc(
      arcRect,
      0,
      2 * math.pi,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..color = colors.first.withValues(alpha: 0.14),
    );
    canvas.drawArc(
      arcRect,
      -math.pi / 2,
      2 * math.pi * 0.72,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeWidth = stroke
        ..shader = SweepGradient(
          transform: const GradientRotation(-math.pi / 2 - 0.12),
          colors: colors,
        ).createShader(rect),
    );
  }

  @override
  bool shouldRepaint(_MiniRingPainter old) => old.colors != colors;
}
