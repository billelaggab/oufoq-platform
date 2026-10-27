import '../../../../core/error/app_failure.dart';
import '../../../../core/error/error_mapper.dart';
import '../../../article/domain/entities/article_entity.dart';
import '../../domain/repositories/news_repository.dart';
import '../datasources/news_remote_data_source.dart';

class NewsRepositoryImpl implements NewsRepository {
  NewsRepositoryImpl(this._remoteDataSource);

  final NewsRemoteDataSource _remoteDataSource;

  @override
  Future<Result<PaginatedResult<ArticleEntity>>> getPosts({
    required int page,
    int? categoryId,
    String? searchQuery,
    bool forceRefresh = false,
  }) async {
    try {
      final ({List<ArticleEntity> posts, int totalPages}) data =
          await _remoteDataSource.fetchPosts(
        page: page,
        categoryId: categoryId,
        searchQuery: searchQuery,
        forceRefresh: forceRefresh,
      );
      return Ok<PaginatedResult<ArticleEntity>>(
        PaginatedResult<ArticleEntity>(
          items: data.posts,
          page: page,
          totalPages: data.totalPages,
          hasMore: page < data.totalPages,
        ),
      );
    } on Object catch (error, stackTrace) {
      return Err<PaginatedResult<ArticleEntity>>(
        ErrorMapper.map(error, stackTrace),
      );
    }
  }

  @override
  Future<Result<List<ArticleEntity>>> getBreakingNews({int? categoryId}) async {
    try {
      final List<ArticleEntity> items =
          await _remoteDataSource.fetchBreakingNews(categoryId: categoryId);
      return Ok<List<ArticleEntity>>(items);
    } on Object catch (error, stackTrace) {
      return Err<List<ArticleEntity>>(ErrorMapper.map(error, stackTrace));
    }
  }

  @override
  Future<Result<List<ArticleEntity>>> getFeaturedPosts() async {
    try {
      final List<ArticleEntity> items =
          await _remoteDataSource.fetchFeaturedPosts();
      return Ok<List<ArticleEntity>>(items);
    } on Object catch (error, stackTrace) {
      return Err<List<ArticleEntity>>(ErrorMapper.map(error, stackTrace));
    }
  }

  @override
  Future<Result<ArticleEntity>> getPostById(int id) async {
    try {
      final ArticleEntity article = await _remoteDataSource.fetchPostById(id);
      return Ok<ArticleEntity>(article);
    } on Object catch (error, stackTrace) {
      return Err<ArticleEntity>(ErrorMapper.map(error, stackTrace));
    }
  }

  @override
  Future<Result<ArticleEntity>> getPostBySlug(String slug) async {
    try {
      final ArticleEntity article =
          await _remoteDataSource.fetchPostBySlug(slug);
      return Ok<ArticleEntity>(article);
    } on Object catch (error, stackTrace) {
      return Err<ArticleEntity>(ErrorMapper.map(error, stackTrace));
    }
  }

  @override
  Future<Result<List<ArticleEntity>>> getRelatedPosts({
    required int categoryId,
    required int excludePostId,
  }) async {
    try {
      final List<ArticleEntity> items =
          await _remoteDataSource.fetchRelatedPosts(
        categoryId: categoryId,
        excludePostId: excludePostId,
      );
      return Ok<List<ArticleEntity>>(items);
    } on Object catch (error, stackTrace) {
      return Err<List<ArticleEntity>>(ErrorMapper.map(error, stackTrace));
    }
  }
}
