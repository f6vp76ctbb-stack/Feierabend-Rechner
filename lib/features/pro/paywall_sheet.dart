import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../config/monetization_config.dart';
import '../../design/app_colors.dart';
import '../../l10n/l10n_ext.dart';
import '../../services/purchase_backend.dart';
import 'pro_providers.dart';

/// Elegantes Kauf-Overlay: erscheint kontextuell, wenn eine Pro-Funktion
/// angetippt wird (nie ungefragt beim Start).
class PaywallSheet extends ConsumerStatefulWidget {
  const PaywallSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) => const PaywallSheet(),
    );
  }

  @override
  ConsumerState<PaywallSheet> createState() => _PaywallSheetState();
}

class _PaywallSheetState extends ConsumerState<PaywallSheet> {
  String? _status;
  bool _busy = false;

  Future<void> _buy() async {
    final l = context.l10n;
    HapticFeedback.selectionClick();
    setState(() => _busy = true);
    final started = await ref.read(proControllerProvider.notifier).buy();
    if (!mounted) return;
    setState(() {
      _busy = false;
      if (!started) _status = l.paywallUnavailable;
    });
  }

  Future<void> _watchAd() async {
    final l = context.l10n;
    setState(() => _busy = true);
    final earned = await ref.read(adsBackendProvider).showRewarded();
    if (!mounted) return;
    setState(() => _busy = false);
    if (earned) {
      ref
          .read(proControllerProvider.notifier)
          .grantTrial(MonetizationConfig.rewardedTrial);
      final messenger = ScaffoldMessenger.of(context);
      Navigator.of(context).pop();
      messenger.showSnackBar(SnackBar(content: Text(l.trialGranted)));
    } else {
      setState(() => _status = l.adNotReady);
    }
  }

  Future<void> _restore() async {
    final l = context.l10n;
    await ref.read(proControllerProvider.notifier).restore();
    if (mounted) setState(() => _status = l.restoreDone);
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final theme = Theme.of(context);
    final product = ref.watch(proProductProvider);
    final storeAvailable = ref.watch(purchaseBackendProvider).isSupported;
    final adsSupported = ref.watch(adsBackendProvider).isSupported;

    // Kauf erfolgreich → Overlay schließen und bedanken.
    ref.listen<bool>(isProProvider, (prev, isPro) {
      if (isPro && prev == false && Navigator.of(context).canPop()) {
        final messenger = ScaffoldMessenger.of(context);
        Navigator.of(context).pop();
        messenger.showSnackBar(SnackBar(content: Text(l.purchaseSuccess)));
      }
    });
    ref.listen<AsyncValue<PurchaseEvent>>(purchaseEventsProvider, (_, next) {
      final event = next.valueOrNull;
      if (event == null) return;
      setState(() {
        _status = switch (event.type) {
          PurchaseEventType.pending => l.purchasePending,
          PurchaseEventType.error => l.purchaseError,
          _ => _status,
        };
      });
    });

    final price = product.valueOrNull?.price;
    final buyLabel = price == null ? l.unlockPro : l.paywallBuy(price);

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.primary, AppColors.accentWarm],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(Icons.workspace_premium_rounded,
                    color: Colors.white, size: 36),
              ),
            ),
            const SizedBox(height: 14),
            Text(l.paywallTitle,
                textAlign: TextAlign.center,
                style: theme.textTheme.headlineMedium),
            const SizedBox(height: 4),
            Text(l.paywallSubtitle,
                textAlign: TextAlign.center, style: theme.textTheme.bodyLarge),
            const SizedBox(height: 20),
            for (final benefit in [
              l.paywallBenefitNoAds,
              l.paywallBenefitProfiles,
              l.paywallBenefitOvertime,
              l.paywallBenefitArbzg,
              l.paywallBenefitReminders,
              l.paywallBenefitSupport,
            ])
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 5),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle_rounded,
                        color: AppColors.success, size: 22),
                    const SizedBox(width: 12),
                    Expanded(
                        child: Text(benefit, style: theme.textTheme.bodyLarge)),
                  ],
                ),
              ),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: _busy || !storeAvailable ? null : _buy,
              child: Text(buyLabel),
            ),
            const SizedBox(height: 6),
            Text(l.paywallOneTime,
                textAlign: TextAlign.center, style: theme.textTheme.bodyMedium),
            if (adsSupported) ...[
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: _busy ? null : _watchAd,
                icon: const Icon(Icons.play_circle_outline_rounded),
                label: Text(l.paywallTrialAd),
              ),
            ],
            if (_status != null) ...[
              const SizedBox(height: 12),
              Text(_status!,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium),
            ],
            if (storeAvailable)
              TextButton(
                onPressed: _busy ? null : _restore,
                child: Text(l.restorePurchases),
              ),
          ],
        ),
      ),
    );
  }
}

/// Kleines „PRO"-Abzeichen für gesperrte Funktionen.
class ProBadge extends StatelessWidget {
  const ProBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.accentWarm],
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        context.l10n.proBadge,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          letterSpacing: 0.8,
          fontVariations: [FontVariation('wght', 700)],
        ),
      ),
    );
  }
}
