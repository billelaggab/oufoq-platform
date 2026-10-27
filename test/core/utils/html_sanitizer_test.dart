import 'package:flutter_test/flutter_test.dart';
import 'package:oufoq_platform/core/utils/html_sanitizer.dart';

void main() {
  group('HtmlSanitizer.cleanPlainText', () {
    test('يزيل وسوم HTML ويفك الكيانات المسماة الشائعة في ووردبريس', () {
      const String raw =
          '<p>عنوان &mdash; اختبار &laquo;منصة أفق&raquo; &amp; أخبار</p>';
      final String result = HtmlSanitizer.cleanPlainText(raw);
      expect(result.contains('<'), isFalse);
      // لا تتبقى أي كيانات HTML (مسماة أو رقمية) بعد الفك.
      expect(RegExp(r'&[a-zA-Z]+;|&#').hasMatch(result), isFalse);
      expect(result, contains('—'));
      expect(result, contains('«منصة أفق»'));
      expect(result, contains('أخبار'));
    });

    test('يفك الكيانات الرقمية العشرية والسداسية عشرية والإنجليزية', () {
      const String raw =
          '&#8220;Hello&#8221; &#x2014; world &hellip; &#038; co';
      final String result = HtmlSanitizer.cleanPlainText(raw);
      expect(result, contains('“Hello”'));
      expect(result, contains('—'));
      expect(result, contains('…'));
      expect(result, contains('& co'));
    });

    test('يتعامل بأمان مع القيم الفارغة والـ null', () {
      expect(HtmlSanitizer.cleanPlainText(null), '');
      expect(HtmlSanitizer.cleanPlainText(''), '');
    });

    test('يضغط المسافات المتتالية', () {
      final String result =
          HtmlSanitizer.cleanPlainText('<div>خبر     عاجل</div>');
      expect(result, 'خبر عاجل');
    });
  });

  group('HtmlSanitizer.sanitizeArticleHtml', () {
    test('يزيل وسوم السكربت وأنماط العرض الثابتة', () {
      const String raw =
          '<script>alert(1)</script><p style="width: 800px; color: red;">نص</p>';
      final String result = HtmlSanitizer.sanitizeArticleHtml(raw);
      expect(result.contains('script'), isFalse);
      expect(result.contains('800px'), isFalse);
      expect(result, contains('نص'));
    });
  });

  group('HtmlSanitizer.estimateReadingTimeMinutes', () {
    test('الحد الأدنى دقيقة واحدة للنص القصير أو الفارغ', () {
      expect(HtmlSanitizer.estimateReadingTimeMinutes(null), 1);
      expect(HtmlSanitizer.estimateReadingTimeMinutes('كلمة'), 1);
    });

    test('يحسب وقت القراءة العربية على أساس 180 كلمة/دقيقة', () {
      final String longText = List<String>.filled(360, 'كلمة').join(' ');
      expect(HtmlSanitizer.estimateReadingTimeMinutes('<p>$longText</p>'), 2);
    });
  });
}
