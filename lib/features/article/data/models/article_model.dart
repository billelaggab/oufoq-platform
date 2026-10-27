import '../../../../core/utils/html_sanitizer.dart';
import '../../domain/entities/article_entity.dart';

/// موديل تحليل استجابة مقال من WordPress REST API v2.
///
/// محصّن بالكامل ضد الحقول الناقصة أو الأنواع غير المتوقعة
/// (مثل كائن الخطأ `rest_forbidden` داخل `_embedded`).
class ArticleModel extends ArticleEntity {
  const ArticleModel({
    required super.id,
    required super.slug,
    required super.link,
    required super.title,
    required super.excerpt,
    required super.htmlContent,
    required super.publishedAt,
    super.modifiedAt,
    super.featuredImageThumbUrl,
    super.featuredImageFullUrl,
    super.categoryIds,
    super.primaryCategoryName,
    super.authorName,
    super.readingTimeMinutes,
  });

  factory ArticleModel.fromJson(Map<String, dynamic> json) {
    final String rawContent = _renderedField(json['content']);
    final DateTime? published = DateTime.tryParse(json['date']?.toString() ?? '');
    final DateTime? modified = DateTime.tryParse(json['modified']?.toString() ?? '');

    final _ImagePair? images = _extractImages(json);

    return ArticleModel(
      id: _safeInt(json['id']) ?? 0,
      slug: json['slug']?.toString() ?? '',
      link: json['link']?.toString() ?? '',
      title: HtmlSanitizer.cleanPlainText(_renderedField(json['title'])),
      excerpt: HtmlSanitizer.cleanPlainText(_renderedField(json['excerpt'])),
      htmlContent: HtmlSanitizer.sanitizeArticleHtml(rawContent),
      publishedAt: published,
      modifiedAt: modified,
      featuredImageThumbUrl: images?.thumb,
      featuredImageFullUrl: images?.full,
      categoryIds: _safeIntList(json['categories']),
      primaryCategoryName: _extractPrimaryCategoryName(json),
      authorName: _extractAuthorName(json),
      readingTimeMinutes:
          HtmlSanitizer.estimateReadingTimeMinutes(rawContent),
    );
  }

  /// استخراج النص من حقل {rendered: ...} مع حماية القيم bool/null.
  static String _renderedField(dynamic field) {
    if (field is Map && field['rendered'] is String) {
      return field['rendered'] as String;
    }
    return '';
  }

  static int? _safeInt(dynamic value) {
    if (value is int) {
      return value;
    }
    if (value is String) {
      return int.tryParse(value);
    }
    return null;
  }

  static List<int> _safeIntList(dynamic value) {
    if (value is List) {
      return value
          .map(_safeInt)
          .whereType<int>()
          .toList(growable: false);
    }
    return const <int>[];
  }

  /// سلسلة الاستخراج الآمنة للصورة البارزة.
  static _ImagePair? _extractImages(Map<String, dynamic> json) {
    // 1) الحقل المخصص من إضافة Oufoq Bridge إن وُجد.
    final dynamic custom = json['oufoq_featured_image'];
    if (custom is Map) {
      final String? medium = custom['medium']?.toString();
      final String? full = custom['full']?.toString();
      if (medium != null || full != null) {
        return _ImagePair(medium ?? full, full ?? medium);
      }
    }

    // 2) _embedded['wp:featuredmedia'] مع الحماية من كائن الخطأ.
    final dynamic embedded = json['_embedded'];
    if (embedded is! Map) {
      return null;
    }
    final dynamic mediaList = embedded['wp:featuredmedia'];
    if (mediaList is! List || mediaList.isEmpty) {
      return null;
    }
    final dynamic media = mediaList.first;
    if (media is! Map) {
      return null;
    }
    // ووردبريس قد يعيد كائن خطأ عند حذف/حماية الصورة.
    if (media['code'] is String && media['source_url'] == null) {
      return null;
    }

    final dynamic sizes = (media['media_details'] as Map?)?['sizes'];

    String? sizeUrl(String sizeName) {
      if (sizes is Map && sizes[sizeName] is Map) {
        final dynamic url = (sizes[sizeName] as Map)['source_url'];
        return url?.toString();
      }
      return null;
    }

    final String? thumb = sizeUrl('medium_large') ??
        sizeUrl('large') ??
        sizeUrl('full') ??
        media['source_url']?.toString();
    final String? full =
        sizeUrl('full') ?? media['source_url']?.toString() ?? thumb;

    if (thumb == null && full == null) {
      return null;
    }
    return _ImagePair(thumb, full);
  }

  static String? _extractPrimaryCategoryName(Map<String, dynamic> json) {
    final dynamic embedded = json['_embedded'];
    if (embedded is! Map) {
      return null;
    }
    final dynamic terms = embedded['wp:term'];
    if (terms is! List) {
      return null;
    }
    for (final dynamic group in terms) {
      if (group is! List) {
        continue;
      }
      for (final dynamic term in group) {
        if (term is Map &&
            term['taxonomy'] == 'category' &&
            term['name'] is String) {
          return HtmlSanitizer.cleanPlainText(term['name'] as String);
        }
      }
    }
    return null;
  }

  static String? _extractAuthorName(Map<String, dynamic> json) {
    final dynamic embedded = json['_embedded'];
    if (embedded is! Map) {
      return null;
    }
    final dynamic authors = embedded['author'];
    if (authors is List && authors.isNotEmpty && authors.first is Map) {
      final dynamic name = (authors.first as Map)['name'];
      return name?.toString();
    }
    return null;
  }
}

class _ImagePair {
  const _ImagePair(this.thumb, this.full);

  final String? thumb;
  final String? full;
}
