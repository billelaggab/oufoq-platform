import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../../../../core/l10n/l10n_extension.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../data/ad_unit_ids.dart';
import '../providers/ad_config_provider.dart';

/// بنر متكيف مثبت أسفل الشاشات — يختفي تماماً عند أي فشل.
class OufoqBannerAdSlot extends ConsumerStatefulWidget {
  const OufoqBannerAdSlot({super.key});

  @override
  ConsumerState<OufoqBannerAdSlot> createState() => _OufoqBannerAdSlotState();
}

class _OufoqBannerAdSlotState extends ConsumerState<OufoqBannerAdSlot> {
  BannerAd? _bannerAd;
  AnchoredAdaptiveBannerAdSize? _adSize;
  bool _visible = false;
  bool _initialized = false;

  bool get _skip =>
      Platform.environment.containsKey('FLUTTER_TEST') || !Platform.isAndroid;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _initialized = true;
      _initialize();
    }
  }

  Future<void> _initialize() async {
    if (_skip) {
      return;
    }
    final bool adsOn = ref.read(adConfigProvider).enabled &&
        ref.read(adConfigProvider).bannerEnabled;
    if (!adsOn || AdUnitIds.banner.isEmpty) {
      return;
    }
    final List<ConnectivityResult> connectivity =
        await Connectivity().checkConnectivity();
    if (connectivity.contains(ConnectivityResult.none) || !mounted) {
      return;
    }
    final double width = MediaQuery.sizeOf(context).width;
    final AnchoredAdaptiveBannerAdSize? size =
        await AdSize.getLargeAnchoredAdaptiveBannerAdSize(width.truncate());
    if (size == null || !mounted) {
      return;
    }
    _adSize = size;
    final BannerAd ad = BannerAd(
      adUnitId: AdUnitIds.banner,
      size: size,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) {
          if (mounted) {
            setState(() => _visible = true);
          }
        },
        onAdFailedToLoad: (Ad ad, LoadAdError error) {
          ad.dispose();
          _bannerAd = null;
          if (mounted) {
            setState(() => _visible = false);
          }
        },
      ),
    );
    _bannerAd = ad;
    await ad.load();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    _bannerAd = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // إخفاء فوري إن أُوقفت الإعلانات عن بُعد.
    final bool adsOn = ref.watch(adConfigProvider).enabled &&
        ref.watch(adConfigProvider).bannerEnabled;
    if (!adsOn || !_visible || _bannerAd == null || _adSize == null) {
      return const SizedBox.shrink();
    }
    final OufoqCustomColors custom = AppTheme.customOf(context);
    return SafeArea(
      top: false,
      child: Container(
        width: double.infinity,
        margin: const EdgeInsetsDirectional.only(top: 8),
        padding: const EdgeInsetsDirectional.symmetric(
          horizontal: 8,
          vertical: 6,
        ),
        decoration: BoxDecoration(
          color: custom.adSurface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: custom.cardBorder),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: Text(
                context.l10n.adLabel,
                style: Theme.of(context).textTheme.labelSmall,
              ),
            ),
            SizedBox(
              width: _adSize!.width.toDouble(),
              height: _adSize!.height.toDouble(),
              child: AdWidget(ad: _bannerAd!),
            ),
          ],
        ),
      ),
    );
  }
}
