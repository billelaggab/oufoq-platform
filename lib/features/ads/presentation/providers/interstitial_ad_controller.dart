import 'dart:async';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../../../../core/storage/preferences_service.dart';
import '../../data/ad_service.dart';
import '../../data/ad_unit_ids.dart';
import '../../domain/ad_config.dart';
import 'ad_config_provider.dart';

/// سياسة نقية قابلة للاختبار دون أي اعتماد على منصة الإعلانات.
abstract final class InterstitialPolicy {
  const InterstitialPolicy._();

  /// الشرط المزدوج الصارم: عدد المقالات + فترة التهدئة + مفتاح التفعيل.
  static bool shouldShow({
    required AdConfig config,
    required int articlesRead,
    required DateTime? lastShownAt,
    required DateTime now,
  }) {
    if (!config.enabled || !config.interstitialEnabled) {
      return false;
    }
    if (articlesRead < config.interstitialArticleThreshold) {
      return false;
    }
    if (lastShownAt == null) {
      return true;
    }
    return now.difference(lastShownAt).inMinutes >=
        config.interstitialCooldownMinutes;
  }
}

/// حالة منسق الإعلانات البينية.
class InterstitialState {
  const InterstitialState({
    this.articlesRead = 0,
    this.lastShownAt,
    this.isLoaded = false,
  });

  final int articlesRead;
  final DateTime? lastShownAt;
  final bool isLoaded;

  InterstitialState copyWith({
    int? articlesRead,
    DateTime? lastShownAt,
    bool? isLoaded,
  }) {
    return InterstitialState(
      articlesRead: articlesRead ?? this.articlesRead,
      lastShownAt: lastShownAt ?? this.lastShownAt,
      isLoaded: isLoaded ?? this.isLoaded,
    );
  }
}

/// منسق الإعلان البيني: تحميل مسبق، عدّاد مقالات، وفاصل زمني صارم.
class InterstitialAdController extends Notifier<InterstitialState> {
  InterstitialAd? _ad;
  bool _isLoading = false;

  @override
  InterstitialState build() {
    ref.onDispose(_disposeAd);
    _schedulePreload();
    // استعادة آخر ظهور من التخزين حتى لا يتكرر الإعلان بعد إعادة التشغيل.
    final int? lastShownMillis = ref
        .read(preferencesServiceProvider)
        .getInt(PrefKeys.interstitialAdLastShown);
    return InterstitialState(
      lastShownAt: lastShownMillis == null
          ? null
          : DateTime.fromMillisecondsSinceEpoch(lastShownMillis),
    );
  }

  bool get _platformSupported =>
      !Platform.environment.containsKey('FLUTTER_TEST') && Platform.isAndroid;

  void _schedulePreload() {
    if (!_platformSupported) {
      return;
    }
    final AdConfig config = ref.read(adConfigProvider);
    if (!config.enabled || !config.interstitialEnabled) {
      return;
    }
    // تحميل غير معطِّل بعد أول إطار لعدم إبطاء إقلاع التطبيق،
    // مع انتظار تهيئة SDK أولاً.
    Future<void>.delayed(Duration.zero, _ensureInitializedAndLoad);
  }

  Future<void> _ensureInitializedAndLoad() async {
    await AdService.initialize();
    if (!AdService.isReady) {
      return;
    }
    await _loadAd();
  }

  Future<void> _loadAd() async {
    if (_isLoading ||
        _ad != null ||
        !_platformSupported ||
        !AdService.isReady) {
      return;
    }
    final String unitId = AdUnitIds.interstitial;
    if (unitId.isEmpty) {
      return;
    }
    _isLoading = true;
    await InterstitialAd.load(
      adUnitId: unitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (InterstitialAd ad) {
          _ad = ad;
          _isLoading = false;
          state = state.copyWith(isLoaded: true);
        },
        onAdFailedToLoad: (LoadAdError error) {
          _isLoading = false;
          state = state.copyWith(isLoaded: false);
        },
      ),
    );
  }

  /// يُستدعى عند إنهاء قراءة مقال. لا يعرض إعلاناً عند فتح التطبيق أبداً.
  Future<void> onArticleRead() async {
    final AdConfig config = ref.read(adConfigProvider);
    final int count = state.articlesRead + 1;
    final DateTime now = DateTime.now();

    final bool eligible = InterstitialPolicy.shouldShow(
      config: config,
      articlesRead: count,
      lastShownAt: state.lastShownAt,
      now: now,
    );
    state = state.copyWith(articlesRead: count);

    if (!eligible || _ad == null) {
      if (eligible && _ad == null) {
        _schedulePreload();
      }
      return;
    }

    final InterstitialAd ad = _ad!;
    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (InterstitialAd shownAd) {
        shownAd.dispose();
        _ad = null;
        _loadAd();
      },
      onAdFailedToShowFullScreenContent: (InterstitialAd shownAd, AdError _) {
        shownAd.dispose();
        _ad = null;
        _loadAd();
      },
    );
    await ad.show();
    state = state.copyWith(
      articlesRead: 0,
      lastShownAt: now,
      isLoaded: false,
    );
    unawaited(
      ref.read(preferencesServiceProvider).setInt(
            PrefKeys.interstitialAdLastShown,
            now.millisecondsSinceEpoch,
          ),
    );
  }

  void _disposeAd() {
    _ad?.dispose();
    _ad = null;
  }
}

final NotifierProvider<InterstitialAdController, InterstitialState>
    interstitialAdControllerProvider =
    NotifierProvider<InterstitialAdController, InterstitialState>(
        InterstitialAdController.new);
