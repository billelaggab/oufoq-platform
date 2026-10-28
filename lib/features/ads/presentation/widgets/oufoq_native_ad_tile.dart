import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../../../../core/l10n/l10n_extension.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../data/ad_service.dart';
import '../../data/ad_unit_ids.dart';
import '../../data/consent_manager.dart';
import '../providers/ad_config_provider.dart';

/// إعلان مدمج داخل قوائم الأخبار — يختفي بهدوء عند الفشل.
class OufoqNativeAdTile extends ConsumerStatefulWidget {
  const OufoqNativeAdTile({super.key, this.compact = false});

  /// نموذج أصغر للقوائم المضغوطة.
  final bool compact;

  @override
  ConsumerState<OufoqNativeAdTile> createState() => _OufoqNativeAdTileState();
}

class _OufoqNativeAdTileState extends ConsumerState<OufoqNativeAdTile> {
  NativeAd? _nativeAd;
  bool _loaded = false;
  bool _initialized = false;
  bool _retryScheduled = false;
  int _retryCount = 0;

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
        ref.read(adConfigProvider).nativeEnabled;
    if (!adsOn || AdUnitIds.native.isEmpty) {
      return;
    }
    await AdService.initialize();
    if (!AdService.isReady || !await ConsentManager.canRequestAds()) {
      return;
    }
    final List<ConnectivityResult> connectivity =
        await Connectivity().checkConnectivity();
    if (connectivity.contains(ConnectivityResult.none) || !mounted) {
      return;
    }
    final NativeAd ad = NativeAd(
      adUnitId: AdUnitIds.native,
      request: const AdRequest(),
      nativeTemplateStyle: NativeTemplateStyle(
        templateType:
            widget.compact ? TemplateType.small : TemplateType.medium,
      ),
      listener: NativeAdListener(
        onAdLoaded: (_) {
          if (mounted) {
            setState(() => _loaded = true);
          }
        },
        onAdFailedToLoad: (Ad ad, LoadAdError error) {
          ad.dispose();
          _nativeAd = null;
          if (mounted) {
            setState(() => _loaded = false);
          }
          _scheduleRetry();
        },
      ),
    );
    _nativeAd = ad;
    await ad.load();
  }

  /// إعادة محاولة محدودة بدل ترك المساحة فارغة بعد فشل عابر.
  void _scheduleRetry() {
    if (_retryScheduled || _retryCount >= 2 || !mounted) {
      return;
    }
    _retryScheduled = true;
    _retryCount++;
    Future<void>.delayed(const Duration(seconds: 3), () {
      _retryScheduled = false;
      if (mounted && !_loaded) {
        _initialize();
      }
    });
  }

  @override
  void dispose() {
    _nativeAd?.dispose();
    _nativeAd = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool adsOn = ref.watch(adConfigProvider).enabled &&
        ref.watch(adConfigProvider).nativeEnabled;
    if (!adsOn || !_loaded || _nativeAd == null) {
      return const SizedBox.shrink();
    }
    final OufoqCustomColors custom = AppTheme.customOf(context);
    return AnimatedSize(
      duration: const Duration(milliseconds: 250),
      child: Container(
        margin: const EdgeInsetsDirectional.symmetric(
          horizontal: 16,
          vertical: 8,
        ),
        padding: const EdgeInsetsDirectional.all(10),
        decoration: BoxDecoration(
          color: custom.adSurface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: custom.cardBorder),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: Container(
                padding: const EdgeInsetsDirectional.symmetric(
                  horizontal: 8,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: custom.textSecondary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  context.l10n.adLabel,
                  style: Theme.of(context).textTheme.labelSmall,
                ),
              ),
            ),
            const SizedBox(height: 6),
            SizedBox(height: widget.compact ? 96 : 240, child: AdWidget(ad: _nativeAd!)),
          ],
        ),
      ),
    );
  }
}
