import '../config/app_constants.dart';

/// أدوات تنظيف محتوى ووردبريس HTML وفك ترميز الكيانات.
abstract final class HtmlSanitizer {
  const HtmlSanitizer._();

  static final RegExp _tagsRegExp = RegExp(r'<[^>]*>');
  static final RegExp _scriptStyleRegExp =
      RegExp(r'<(script|style)\b[^>]*>.*?</\1>', dotAll: true, caseSensitive: false);
  static final RegExp _decimalEntityRegExp = RegExp(r'&#(\d+);');
  static final RegExp _hexEntityRegExp = RegExp(r'&#x([0-9a-fA-F]+);');
  static final RegExp _whitespaceRegExp = RegExp(r'\s+');

  /// خريطة الكيانات الشائعة في محتوى ووردبريس العربي.
  static const Map<String, String> _namedEntities = <String, String>{
    '&amp;': '&',
    '&quot;': '"',
    '&apos;': "'",
    '&nbsp;': ' ',
    '&laquo;': '«',
    '&raquo;': '»',
    '&lsquo;': '‘',
    '&rsquo;': '’',
    '&ldquo;': '“',
    '&rdquo;': '”',
    '&ndash;': '–',
    '&mdash;': '—',
    '&hellip;': '…',
    '&lt;': '<',
    '&gt;': '>',
    '&times;': '×',
    '&divide;': '÷',
    '&copy;': '©',
    '&reg;': '®',
    '&trade;': '™',
    '&deg;': '°',
  };

  /// تحويل HTML خام إلى نص نقٍ نظيف لعرضه داخل عناصر [Text].
  static String cleanPlainText(String? rawHtml) {
    if (rawHtml == null || rawHtml.isEmpty) {
      return '';
    }
    String text = rawHtml;

    // إزالة محتوى السكربتات والأنماط بالكامل.
    text = text.replaceAll(_scriptStyleRegExp, '');

    // فك الكيانات الرقمية العشرية (مثل &#8211;).
    text = text.replaceAllMapped(_decimalEntityRegExp,
        (Match m) => String.fromCharCode(int.parse(m.group(1)!)));

    // فك الكيانات الرقمية السداسية عشرية (مثل &#x2014;).
    text = text.replaceAllMapped(_hexEntityRegExp,
        (Match m) => String.fromCharCode(int.parse(m.group(1)!, radix: 16)));

    // فك الكيانات المسماة.
    for (final MapEntry<String, String> entry in _namedEntities.entries) {
      if (text.contains(entry.key)) {
        text = text.replaceAll(entry.key, entry.value);
      }
    }

    // إزالة الوسوم ثم ضغط المسافات.
    text = text.replaceAll(_tagsRegExp, ' ');
    text = text.replaceAll(_whitespaceRegExp, ' ');
    return text.trim();
  }

  /// تحييد الوسوم الخطرة وأنماط العرض الثابتة داخل محتوى المقال
  /// لمنع التجاوز الأفقي على شاشات الهاتف.
  static String sanitizeArticleHtml(String rawHtml) {
    String html = rawHtml;
    html = html.replaceAll(_scriptStyleRegExp, '');
    // إزالة قيم العرض/الارتفاع الثابتة من أنماط CSS.
    html = html.replaceAll(RegExp(r'(width|height)\s*:\s*\d+(\.\d+)?px\s*;?', caseSensitive: false), '');
    // إزالة سمات width/height المباشرة على الوسوم.
    html = html.replaceAll(RegExp(r'\s(width|height)\s*=\s*"[^"]*"', caseSensitive: false), '');
    return html;
  }

  /// تقدير وقت القراءة بالدقائق على أساس 180 كلمة/دقيقة بحد أدنى دقيقة.
  static int estimateReadingTimeMinutes(String? htmlContent) {
    final String plain = cleanPlainText(htmlContent);
    if (plain.isEmpty) {
      return 1;
    }
    final List<String> words = plain.split(_whitespaceRegExp)
      ..removeWhere((String w) => w.trim().isEmpty);
    final int minutes =
        (words.length / AppConstants.arabicReadingWordsPerMinute).ceil();
    return minutes < 1 ? 1 : minutes;
  }
}
