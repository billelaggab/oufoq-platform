import 'package:flutter_test/flutter_test.dart';
import 'package:oufoq_platform/features/ads/domain/ad_config.dart';
import 'package:oufoq_platform/features/ads/presentation/providers/interstitial_ad_controller.dart';

void main() {
  const AdConfig config = AdConfig();
  final DateTime now = DateTime(2026, 10, 27, 12);

  group('InterstitialPolicy.shouldShow', () {
    test('لا يعرض قبل بلوغ حد المقالات الأربع', () {
      expect(
        InterstitialPolicy.shouldShow(
          config: config,
          articlesRead: 3,
          lastShownAt: null,
          now: now,
        ),
        isFalse,
      );
    });

    test('يعرض بعد 4 مقالات في المرة الأولى دون قيد زمني سابق', () {
      expect(
        InterstitialPolicy.shouldShow(
          config: config,
          articlesRead: 4,
          lastShownAt: null,
          now: now,
        ),
        isTrue,
      );
    });

    test('يحترم فترة التهدئة 3 دقائق', () {
      final DateTime recent = now.subtract(const Duration(minutes: 2));
      expect(
        InterstitialPolicy.shouldShow(
          config: config,
          articlesRead: 8,
          lastShownAt: recent,
          now: now,
        ),
        isFalse,
      );

      final DateTime old = now.subtract(const Duration(minutes: 3));
      expect(
        InterstitialPolicy.shouldShow(
          config: config,
          articlesRead: 8,
          lastShownAt: old,
          now: now,
        ),
        isTrue,
      );
    });

    test('مفتاح الإيقاف الشامل يمنع العرض مهما تحققت بقية الشروط', () {
      const AdConfig disabled = AdConfig(enabled: false);
      expect(
        InterstitialPolicy.shouldShow(
          config: disabled,
          articlesRead: 20,
          lastShownAt: now.subtract(const Duration(days: 1)),
          now: now,
        ),
        isFalse,
      );
    });

    test('تعطيل الإعلانات البينية تحديداً يمنع العرض', () {
      const AdConfig noInterstitial =
          AdConfig(interstitialEnabled: false);
      expect(
        InterstitialPolicy.shouldShow(
          config: noInterstitial,
          articlesRead: 10,
          lastShownAt: null,
          now: now,
        ),
        isFalse,
      );
    });
  });
}
