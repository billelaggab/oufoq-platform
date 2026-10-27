import 'dart:async';
import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../../data/ad_unit_ids.dart';
import 'ad_config_provider.dart';

/// إعلان فتح التطبيق عند العودة من الخلفية (مطفأ افتراضياً).
class AppOpenAdController extends Notifier<void> {
  AppOpenAd? _appOpenAd;
  DateTime? _lastShownAt;
  AppLifecycleListener? _lifecycleListener;
  bool _isShowing = false;

  static const Duration _minimumInterval = Duration(hours: 4);

  @override
  void build() {
    ref.onDispose(() {
      _lifecycleListener?.dispose();
      _appOpenAd?.dispose();
      _appOpenAd = null;
    });
    if (!_supported) {
      return;
    }
    _lifecycleListener = AppLifecycleListener(
      onResume: _onResumed,
    );
  }

  bool get _supported =>
      !Platform.environment.containsKey('FLUTTER_TEST') && Platform.isAndroid;

  Future<void> _onResumed() async {
    final bool enabled = ref.read(adConfigProvider).appOpenEnabled;
    if (!enabled || _isShowing) {
      return;
    }
    if (_lastShownAt != null &&
        DateTime.now().difference(_lastShownAt!) < _minimumInterval) {
      return;
    }
    await _loadAndShow();
  }

  Future<void> _loadAndShow() async {
    final String unitId = AdUnitIds.appOpen;
    if (unitId.isEmpty) {
      return;
    }
    final Completer<void> completer = Completer<void>();
    await AppOpenAd.load(
      adUnitId: unitId,
      request: const AdRequest(),
      adLoadCallback: AppOpenAdLoadCallback(
        onAdLoaded: (AppOpenAd ad) {
          _appOpenAd = ad;
          if (!completer.isCompleted) {
            completer.complete();
          }
        },
        onAdFailedToLoad: (LoadAdError error) {
          if (!completer.isCompleted) {
            completer.complete();
          }
        },
      ),
    );
    await completer.future;
    final AppOpenAd? ad = _appOpenAd;
    if (ad == null) {
      return;
    }
    _isShowing = true;
    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (AppOpenAd shownAd) {
        shownAd.dispose();
        _appOpenAd = null;
        _isShowing = false;
        _lastShownAt = DateTime.now();
      },
      onAdFailedToShowFullScreenContent: (AppOpenAd shownAd, AdError _) {
        shownAd.dispose();
        _appOpenAd = null;
        _isShowing = false;
      },
    );
    await ad.show();
  }
}

final NotifierProvider<AppOpenAdController, void> appOpenAdControllerProvider =
    NotifierProvider<AppOpenAdController, void>(AppOpenAdController.new);
