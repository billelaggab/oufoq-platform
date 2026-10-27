import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/error/app_failure.dart';
import '../../../home/presentation/providers/news_providers.dart';
import '../../domain/entities/category_entity.dart';

/// قائمة الأقسام الكاملة من ووردبريس.
final FutureProvider<List<CategoryEntity>> categoriesProvider =
    FutureProvider<List<CategoryEntity>>((Ref ref) async {
  final Result<List<CategoryEntity>> result =
      await ref.watch(categoryRepositoryProvider).getCategories();
  return result.when(
    onSuccess: (List<CategoryEntity> data) => data,
    onFailure: (AppFailure failure) => throw failure,
  );
});
