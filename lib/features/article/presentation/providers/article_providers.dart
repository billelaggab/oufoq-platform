import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/error/app_failure.dart';
import '../../../home/presentation/providers/news_providers.dart';
import '../../domain/entities/article_entity.dart';

/// جلب مقال عبر المعرّف عند الفتح من إشعار أو رابط عميق.
final articleByIdProvider =
    FutureProvider.autoDispose.family<ArticleEntity, int>((Ref ref, int id) async {
  final Result<ArticleEntity> result =
      await ref.watch(newsRepositoryProvider).getPostById(id);
  return result.when(
    onSuccess: (ArticleEntity article) => article,
    onFailure: (AppFailure failure) => throw failure,
  );
});

/// جلب مقال عبر الـ slug (روابط ووردبريس العميقة).
final articleBySlugProvider = FutureProvider.autoDispose
    .family<ArticleEntity, String>((Ref ref, String slug) async {
  final Result<ArticleEntity> result =
      await ref.watch(newsRepositoryProvider).getPostBySlug(slug);
  return result.when(
    onSuccess: (ArticleEntity article) => article,
    onFailure: (AppFailure failure) => throw failure,
  );
});

/// المقالات ذات الصلة من نفس القسم (تخفق بهدوء بدون إنترنت).
final relatedArticlesProvider = FutureProvider.autoDispose
    .family<List<ArticleEntity>, ArticleEntity>((Ref ref, ArticleEntity article) async {
  final int categoryId =
      article.categoryIds.isNotEmpty ? article.categoryIds.first : 0;
  if (categoryId == 0) {
    return const <ArticleEntity>[];
  }
  final Result<List<ArticleEntity>> result =
      await ref.watch(newsRepositoryProvider).getRelatedPosts(
            categoryId: categoryId,
            excludePostId: article.id,
          );
  return result.when(
    onSuccess: (List<ArticleEntity> items) => items,
    onFailure: (AppFailure _) => const <ArticleEntity>[],
  );
});
