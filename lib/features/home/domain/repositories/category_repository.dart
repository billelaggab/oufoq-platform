import '../../../../core/error/app_failure.dart';
import '../../../categories/domain/entities/category_entity.dart';

/// عقد مستودع الأقسام.
abstract interface class CategoryRepository {
  Future<Result<List<CategoryEntity>>> getCategories({
    bool forceRefresh = false,
  });
}
