import 'package:equatable/equatable.dart';

/// كيان المقال الموحد المستقل عن مصدر البيانات (شبكة أو قاعدة محلية).
class ArticleEntity extends Equatable {
  const ArticleEntity({
    required this.id,
    required this.slug,
    required this.link,
    required this.title,
    required this.excerpt,
    required this.htmlContent,
    required this.publishedAt,
    this.modifiedAt,
    this.featuredImageThumbUrl,
    this.featuredImageFullUrl,
    this.categoryIds = const <int>[],
    this.primaryCategoryName,
    this.authorName,
    this.readingTimeMinutes = 1,
  });

  final int id;
  final String slug;
  final String link;
  final String title;
  final String excerpt;
  final String htmlContent;
  final DateTime? publishedAt;
  final DateTime? modifiedAt;
  final String? featuredImageThumbUrl;
  final String? featuredImageFullUrl;
  final List<int> categoryIds;
  final String? primaryCategoryName;
  final String? authorName;
  final int readingTimeMinutes;

  /// هل توجد صورة بارزة قابلة للعرض؟
  bool get hasFeaturedImage =>
      featuredImageThumbUrl != null && featuredImageThumbUrl!.isNotEmpty;

  ArticleEntity copyWith({
    int? id,
    String? slug,
    String? link,
    String? title,
    String? excerpt,
    String? htmlContent,
    DateTime? publishedAt,
    DateTime? modifiedAt,
    String? featuredImageThumbUrl,
    String? featuredImageFullUrl,
    List<int>? categoryIds,
    String? primaryCategoryName,
    String? authorName,
    int? readingTimeMinutes,
  }) {
    return ArticleEntity(
      id: id ?? this.id,
      slug: slug ?? this.slug,
      link: link ?? this.link,
      title: title ?? this.title,
      excerpt: excerpt ?? this.excerpt,
      htmlContent: htmlContent ?? this.htmlContent,
      publishedAt: publishedAt ?? this.publishedAt,
      modifiedAt: modifiedAt ?? this.modifiedAt,
      featuredImageThumbUrl: featuredImageThumbUrl ?? this.featuredImageThumbUrl,
      featuredImageFullUrl: featuredImageFullUrl ?? this.featuredImageFullUrl,
      categoryIds: categoryIds ?? this.categoryIds,
      primaryCategoryName: primaryCategoryName ?? this.primaryCategoryName,
      authorName: authorName ?? this.authorName,
      readingTimeMinutes: readingTimeMinutes ?? this.readingTimeMinutes,
    );
  }

  /// تمثيل الصف في جدول SQLite للمحفوظات.
  Map<String, Object?> toBookmarkMap(DateTime savedAt) {
    return <String, Object?>{
      'id': id,
      'slug': slug,
      'link': link,
      'title': title,
      'excerpt': excerpt,
      'html_content': htmlContent,
      'published_at': publishedAt?.toIso8601String(),
      'featured_image_url': featuredImageFullUrl ?? featuredImageThumbUrl,
      'category_name': primaryCategoryName,
      'author_name': authorName,
      'reading_time': readingTimeMinutes,
      'saved_at': savedAt.toIso8601String(),
    };
  }

  factory ArticleEntity.fromBookmarkMap(Map<String, Object?> map) {
    return ArticleEntity(
      id: map['id']! as int,
      slug: (map['slug'] as String?) ?? '',
      link: (map['link'] as String?) ?? '',
      title: (map['title'] as String?) ?? '',
      excerpt: (map['excerpt'] as String?) ?? '',
      htmlContent: (map['html_content'] as String?) ?? '',
      publishedAt: DateTime.tryParse(map['published_at'] as String? ?? ''),
      modifiedAt: null,
      featuredImageFullUrl: map['featured_image_url'] as String?,
      featuredImageThumbUrl: map['featured_image_url'] as String?,
      categoryIds: const <int>[],
      primaryCategoryName: map['category_name'] as String?,
      authorName: map['author_name'] as String?,
      readingTimeMinutes: (map['reading_time'] as int?) ?? 1,
    );
  }

  @override
  List<Object?> get props => <Object?>[id, title, link];
}
