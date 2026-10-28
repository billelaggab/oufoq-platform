import '../../../../core/error/app_failure.dart';
import '../../../article/domain/entities/article_entity.dart';

/// عقد مستودع الأخبار.
abstract interface class NewsRepository {
  Future<Result<PaginatedResult<ArticleEntity>>> getPosts({
    required int page,
    int? categoryId,
    String? searchQuery,
    bool forceRefresh = false,
  });

  Future<Result<List<ArticleEntity>>> getBreakingNews({
    int? categoryId,
    bool forceRefresh = false,
  });

  Future<Result<List<ArticleEntity>>> getFeaturedPosts({
    bool forceRefresh = false,
  });

  Future<Result<ArticleEntity>> getPostById(int id);

  Future<Result<ArticleEntity>> getPostBySlug(String slug);

  Future<Result<List<ArticleEntity>>> getRelatedPosts({
    required int categoryId,
    required int excludePostId,
  });
}
