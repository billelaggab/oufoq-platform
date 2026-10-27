import 'package:dio/dio.dart';
import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';

import '../../../../core/config/app_constants.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../article/data/models/article_model.dart';
import '../../../categories/data/models/category_model.dart';
import '../../../categories/domain/entities/category_entity.dart';

/// مصدر البيانات الشبكي لـ WordPress REST API v2.
class NewsRemoteDataSource {
  NewsRemoteDataSource(this._dio, this._cacheOptions);

  final Dio _dio;
  final CacheOptions _cacheOptions;

  Future<({List<ArticleModel> posts, int totalPages})> fetchPosts({
    required int page,
    int perPage = AppConstants.defaultPageSize,
    int? categoryId,
    String? searchQuery,
    bool forceRefresh = false,
  }) async {
    final Map<String, dynamic> query = <String, dynamic>{
      'page': page,
      'per_page': perPage,
      '_embed': ApiEndpoints.embedArgsLite,
      '_fields': ApiEndpoints.postListFields,
      if (categoryId != null && categoryId > 0) 'categories': categoryId,
      if (searchQuery != null && searchQuery.trim().isNotEmpty)
        'search': searchQuery.trim(),
    };

    final Response<dynamic> response = await _dio.get<dynamic>(
      ApiEndpoints.posts,
      queryParameters: query,
      options: _requestOptions(forceRefresh),
    );

    return (
      posts: _parsePosts(response.data),
      totalPages: _parseTotalPages(response),
    );
  }

  Future<List<ArticleModel>> fetchBreakingNews({
    required int? categoryId,
    int limit = AppConstants.breakingPostsLimit,
  }) async {
    if (categoryId == null || categoryId <= 0) {
      return const <ArticleModel>[];
    }
    final Response<dynamic> response = await _dio.get<dynamic>(
      ApiEndpoints.posts,
      queryParameters: <String, dynamic>{
        'categories': categoryId,
        'per_page': limit,
        '_fields': 'id,date,modified,slug,link,title,excerpt,categories,'
            'featured_media,_links,_embedded,oufoq_featured_image',
        '_embed': ApiEndpoints.embedArgsLite,
      },
      options: _requestOptions(false),
    );
    return _parsePosts(response.data);
  }

  Future<List<ArticleModel>> fetchFeaturedPosts({
    int limit = AppConstants.featuredPostsLimit,
  }) async {
    // محاولة جلب المقالات المثبتة (sticky) ثم الرجوع للأحدث.
    List<ArticleModel> featured = const <ArticleModel>[];
    try {
      final Response<dynamic> stickyResponse = await _dio.get<dynamic>(
        ApiEndpoints.posts,
        queryParameters: <String, dynamic>{
          'sticky': true,
          'per_page': limit,
          '_embed': ApiEndpoints.embedArgsLite,
          '_fields': ApiEndpoints.postListFields,
        },
        options: _requestOptions(false),
      );
      featured = _parsePosts(stickyResponse.data);
    } on DioException {
      featured = const <ArticleModel>[];
    }
    if (featured.isNotEmpty) {
      return featured;
    }
    final Response<dynamic> response = await _dio.get<dynamic>(
      ApiEndpoints.posts,
      queryParameters: <String, dynamic>{
        'per_page': limit,
        '_embed': ApiEndpoints.embedArgsLite,
        '_fields': ApiEndpoints.postListFields,
      },
      options: _requestOptions(false),
    );
    return _parsePosts(response.data);
  }

  Future<ArticleModel> fetchPostById(int id) async {
    final Response<dynamic> response = await _dio.get<dynamic>(
      ApiEndpoints.postById(id),
      queryParameters: <String, dynamic>{
        '_embed': ApiEndpoints.embedArgs,
      },
      options: _requestOptions(false),
    );
    return ArticleModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<ArticleModel> fetchPostBySlug(String slug) async {
    final Response<dynamic> response = await _dio.get<dynamic>(
      ApiEndpoints.posts,
      queryParameters: <String, dynamic>{
        'slug': slug,
        '_embed': ApiEndpoints.embedArgs,
      },
      options: _requestOptions(false),
    );
    final List<ArticleModel> items = _parsePosts(response.data);
    if (items.isEmpty) {
      throw DioException(
        requestOptions: response.requestOptions,
        response: response,
        type: DioExceptionType.badResponse,
      );
    }
    return items.first;
  }

  Future<List<ArticleModel>> fetchRelatedPosts({
    required int categoryId,
    required int excludePostId,
    int limit = AppConstants.relatedPostsLimit,
  }) async {
    if (categoryId <= 0) {
      return const <ArticleModel>[];
    }
    final Response<dynamic> response = await _dio.get<dynamic>(
      ApiEndpoints.posts,
      queryParameters: <String, dynamic>{
        'categories': categoryId,
        'exclude': excludePostId,
        'per_page': limit,
        '_embed': ApiEndpoints.embedArgsLite,
        '_fields': ApiEndpoints.postListFields,
      },
      options: _requestOptions(false),
    );
    return _parsePosts(response.data);
  }

  Future<List<CategoryEntity>> fetchCategories() async {
    final Response<dynamic> response = await _dio.get<dynamic>(
      ApiEndpoints.categories,
      queryParameters: <String, dynamic>{
        'per_page': 50,
        'hide_empty': true,
        'orderby': 'count',
        'order': 'desc',
        '_fields': ApiEndpoints.categoryFields,
      },
      options: _requestOptions(false),
    );
    if (response.data is! List) {
      return const <CategoryEntity>[];
    }
    return (response.data as List)
        .whereType<Map<String, dynamic>>()
        .map(CategoryModel.fromJson)
        .toList(growable: false);
  }

  Options _requestOptions(bool forceRefresh) {
    return _cacheOptions
        .copyWith(
          policy: forceRefresh
              ? CachePolicy.refreshForceCache
              : CachePolicy.request,
        )
        .toOptions();
  }

  List<ArticleModel> _parsePosts(dynamic data) {
    if (data is! List) {
      return const <ArticleModel>[];
    }
    return data
        .whereType<Map<String, dynamic>>()
        .map(ArticleModel.fromJson)
        .toList(growable: false);
  }

  int _parseTotalPages(Response<dynamic> response) {
    final List<String>? header = response.headers.map['x-wp-totalpages'];
    if (header != null && header.isNotEmpty) {
      return int.tryParse(header.first) ?? 1;
    }
    return 1;
  }
}
