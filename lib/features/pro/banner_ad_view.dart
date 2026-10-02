import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../../config/monetization_config.dart';
import 'pro_providers.dart';

/// Unaufdringliches, verankertes Banner am unteren Rand — nur für Free-Nutzer
/// und nur, wenn die Werbe-Einwilligung Anfragen erlaubt.
class BottomBannerAd extends ConsumerWidget {
  const BottomBannerAd({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isPro = ref.watch(isProProvider);
    final ready = ref.watch(adsReadyProvider);
    if (isPro || !ready || !MonetizationConfig.isMobile) {
      return const SizedBox.shrink();
    }
    return const SafeArea(top: false, child: _AdaptiveBanner());
  }
}

class _AdaptiveBanner extends StatefulWidget {
  const _AdaptiveBanner();

  @override
  State<_AdaptiveBanner> createState() => _AdaptiveBannerState();
}

class _AdaptiveBannerState extends State<_AdaptiveBanner> {
  BannerAd? _ad;
  bool _loaded = false;
  int? _requestedWidth;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final width = MediaQuery.sizeOf(context).width.truncate();
    if (width != _requestedWidth) {
      _requestedWidth = width;
      _load(width);
    }
  }

  Future<void> _load(int width) async {
    final size = await AdSize.getLargeAnchoredAdaptiveBannerAdSize(width);
    if (!mounted || size == null) return;
    await _ad?.dispose();
    final ad = BannerAd(
      adUnitId: MonetizationConfig.bannerAdUnitId,
      size: size,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) {
          if (mounted) setState(() => _loaded = true);
        },
        onAdFailedToLoad: (ad, _) {
          ad.dispose();
          if (mounted) setState(() => _loaded = false);
        },
      ),
    );
    setState(() {
      _ad = ad;
      _loaded = false;
    });
    await ad.load();
  }

  @override
  void dispose() {
    _ad?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ad = _ad;
    if (ad == null || !_loaded) return const SizedBox.shrink();
    return SizedBox(
      width: ad.size.width.toDouble(),
      height: ad.size.height.toDouble(),
      child: AdWidget(ad: ad),
    );
  }
}
