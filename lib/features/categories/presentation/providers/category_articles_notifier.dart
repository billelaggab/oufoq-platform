import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/error/app_failure.dart';
import '../../../../core/error/error_mapper.dart';
import '../../../article/domain/entities/article_entity.dart';
import '../../../home/presentation/providers/news_providers.dart';

/// حالة مقالات قسم معيّن مع تصفح لانهائي.
class CategoryArticlesState {
  const CategoryArticlesState({
    this.articles = const <ArticleEntity>[],
    this.hasMore = true,
    this.isLoadingMore = false,
    this.categoryId = 0,
  });

  final List<ArticleEntity> articles;
  final bool hasMore;
  final bool isLoadingMore;
  final int categoryId;

  CategoryArticlesState copyWith({
    List<ArticleEntity>? articles,
    bool? hasMore,
    bool? isLoadingMore,
    int? categoryId,
  }) {
    return CategoryArticlesState(
      articles: articles ?? this.articles,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      categoryId: categoryId ?? this.categoryId,
    );
  }
}

class CategoryArticlesNotifier
    extends AsyncNotifier<CategoryArticlesState> {
  int _page = 1;

  /// يبطل نتائج «تحميل المزيد» القديمة عند تبديل القسم.
  int _requestId = 0;

  @override
  Future<CategoryArticlesState> build() async {
    return const CategoryArticlesState();
  }

  Future<void> loadCategory(int categoryId) async {
    final int requestId = ++_requestId;
    _page = 1;
    state = const AsyncLoading<CategoryArticlesState>();
    try {
      final Result<PaginatedResult<ArticleEntity>> result =
          await ref.read(newsRepositoryProvider).getPosts(
                page: 1,
                categoryId: categoryId,
              );
      if (requestId != _requestId) {
        return;
      }
      switch (result) {
        case Ok<PaginatedResult<ArticleEntity>>(:final PaginatedResult<ArticleEntity> data):
          state = AsyncData<CategoryArticlesState>(
            CategoryArticlesState(
              articles: data.items,
              hasMore: data.hasMore,
              categoryId: categoryId,
            ),
          );
        case Err<dynamic>(:final AppFailure failure):
          state = AsyncError<CategoryArticlesState>(failure, StackTrace.current);
      }
    } on Object catch (error, stackTrace) {
      if (requestId != _requestId) {
        return;
      }
      state = AsyncError<CategoryArticlesState>(
          ErrorMapper.map(error), stackTrace);
    }
  }

  Future<void> loadMore() async {
    final CategoryArticlesState? current = state.value;
    if (current == null ||
        !current.hasMore ||
        current.isLoadingMore ||
        current.articles.isEmpty) {
      return;
    }
    final int requestId = _requestId;
    final int categoryId = current.categoryId;
    state = AsyncData<CategoryArticlesState>(
      current.copyWith(isLoadingMore: true),
    );
    final int nextPage = _page + 1;
    try {
      final Result<PaginatedResult<ArticleEntity>> result =
          await ref.read(newsRepositoryProvider).getPosts(
                page: nextPage,
                categoryId: categoryId,
              );
      // تغيّر القسم أو بدأ تحميل جديد أثناء الانتظار => تجاهل هذه النتيجة.
      if (requestId != _requestId) {
        return;
      }
      final CategoryArticlesState? latest = state.value;
      if (latest == null || latest.categoryId != categoryId) {
        return;
      }
      switch (result) {
        case Ok<PaginatedResult<ArticleEntity>>(:final PaginatedResult<ArticleEntity> data):
          _page = nextPage;
          state = AsyncData<CategoryArticlesState>(
            latest.copyWith(
              articles: <ArticleEntity>[...latest.articles, ...data.items],
              hasMore: data.hasMore,
              isLoadingMore: false,
            ),
          );
        case Err<dynamic>(:final AppFailure failure):
          state = AsyncData<CategoryArticlesState>(
            latest.copyWith(
              hasMore: !ErrorMapper.isEndOfPagination(failure),
              isLoadingMore: false,
            ),
          );
      }
    } on Object catch (error, stackTrace) {
      if (requestId != _requestId) {
        return;
      }
      state = AsyncError<CategoryArticlesState>(
        ErrorMapper.map(error),
        stackTrace,
      );
    }
  }
}

final AsyncNotifierProvider<CategoryArticlesNotifier, CategoryArticlesState>
    categoryArticlesNotifierProvider =
    AsyncNotifierProvider<CategoryArticlesNotifier, CategoryArticlesState>(
        CategoryArticlesNotifier.new);
