import 'package:flutter_test/flutter_test.dart';
import 'package:oufoq_platform/features/ads/presentation/utils/feed_ad_slot_mapper.dart';

void main() {
  group('FeedAdSlotMapper', () {
    test('لا توجد إعلانات لعدد صفر أو فاصل غير صالح', () {
      expect(FeedAdSlotMapper.itemCount(0, 5), 0);
      expect(FeedAdSlotMapper.adCount(12, 0), 0);
      expect(FeedAdSlotMapper.isAdSlot(5, 0), isFalse);
    });

    test('يحسب عدد العناصر المدمجة والإعلانات بدقة كل 5 مقالات', () {
      expect(FeedAdSlotMapper.adCount(1, 5), 0);
      expect(FeedAdSlotMapper.adCount(5, 5), 1);
      expect(FeedAdSlotMapper.adCount(12, 5), 2);
      expect(FeedAdSlotMapper.itemCount(5, 5), 6);
      expect(FeedAdSlotMapper.itemCount(12, 5), 14);
    });

    test('يحدد مواضع الإعلانات بشكل صحيح', () {
      // الفهرس 5 هو أول إعلان (بعد 5 مقالات)، والفهرس 11 هو الثاني.
      expect(FeedAdSlotMapper.isAdSlot(5, 5), isTrue);
      expect(FeedAdSlotMapper.isAdSlot(11, 5), isTrue);
      expect(FeedAdSlotMapper.isAdSlot(0, 5), isFalse);
      expect(FeedAdSlotMapper.isAdSlot(4, 5), isFalse);
      expect(FeedAdSlotMapper.isAdSlot(6, 5), isFalse);
    });

    test('خريطة الفهارس لا تسبب RangeError لأي عدد مقالات', () {
      for (final int articleCount in <int>[0, 1, 5, 12, 25]) {
        final int merged = FeedAdSlotMapper.itemCount(articleCount, 5);
        for (int i = 0; i < merged; i++) {
          if (!FeedAdSlotMapper.isAdSlot(i, 5)) {
            final int articleIndex =
                FeedAdSlotMapper.articleIndexAt(i, 5);
            expect(
              articleIndex >= 0 && articleIndex < articleCount,
              isTrue,
              reason: 'فهرس مقال غير صالح $articleIndex لعدد $articleCount',
            );
          }
        }
      }
    });

    test('كل مقال أصلي يظهر مرة واحدة بالضبط في القائمة المدمجة', () {
      const int articleCount = 12;
      final Set<int> seen = <int>{};
      final int merged = FeedAdSlotMapper.itemCount(articleCount, 5);
      for (int i = 0; i < merged; i++) {
        if (!FeedAdSlotMapper.isAdSlot(i, 5)) {
          seen.add(FeedAdSlotMapper.articleIndexAt(i, 5));
        }
      }
      expect(seen.length, articleCount);
    });
  });
}
