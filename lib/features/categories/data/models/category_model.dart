import '../../../../core/utils/html_sanitizer.dart';
import '../../domain/entities/category_entity.dart';

/// موديل تحليل قسم من WordPress REST API v2.
class CategoryModel extends CategoryEntity {
  const CategoryModel({
    required super.id,
    required super.name,
    required super.slug,
    super.description,
    super.count,
    super.parentId,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: _safeInt(json['id']) ?? 0,
      name: HtmlSanitizer.cleanPlainText(json['name']?.toString()),
      slug: json['slug']?.toString() ?? '',
      description:
          HtmlSanitizer.cleanPlainText(json['description']?.toString()),
      count: _safeInt(json['count']) ?? 0,
      parentId: _safeInt(json['parent']) ?? 0,
    );
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
}
