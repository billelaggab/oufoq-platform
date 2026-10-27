/// منطق نقي لحساب مواضع الإعلانات المدمجة داخل قائمة المقالات.
///
/// يُدرج إعلان مدمج بعد كل [interval] مقالات دون إضاعة أو تكرار أي مقال.
abstract final class FeedAdSlotMapper {
  const FeedAdSlotMapper._();

  /// هل الموضع المدمج في الفهرس [mergedIndex] يمثل إعلاناً؟
  static bool isAdSlot(int mergedIndex, int interval) {
    if (interval <= 0) {
      return false;
    }
    return (mergedIndex + 1) % (interval + 1) == 0;
  }

  /// تحويل فهرس القائمة المدمجة إلى فهرس المقال في قائمة المقالات الأصلية.
  static int articleIndexAt(int mergedIndex, int interval) {
    if (interval <= 0) {
      return mergedIndex;
    }
    final int adsBefore = mergedIndex ~/ (interval + 1);
    return mergedIndex - adsBefore;
  }

  /// إجمالي عدد عناصر القائمة المدمجة (مقالات + إعلانات).
  static int itemCount(int articleCount, int interval) {
    if (interval <= 0 || articleCount <= 0) {
      return articleCount;
    }
    final int ads = articleCount ~/ interval;
    return articleCount + ads;
  }

  /// عدد الإعلانات المدمجة لعدد مقالات معطى.
  static int adCount(int articleCount, int interval) {
    if (interval <= 0 || articleCount <= 0) {
      return 0;
    }
    return articleCount ~/ interval;
  }
}
