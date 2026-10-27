import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/config/env_config.dart';
import '../../../../core/error/app_failure.dart';
import '../../../../core/error/error_mapper.dart';
import '../../../article/domain/entities/article_entity.dart';
import '../../../categories/domain/entities/category_entity.dart';
import '../../../ads/presentation/providers/ad_config_provider.dart';
import '../../domain/repositories/category_repository.dart';
import '../../domain/repositories/news_repository.dart';
import 'news_providers.dart';

/// الحالة الكاملة للشاشة الرئيسية.
class HomeFeedState {
  const HomeFeedState({
    this.breaking = const <ArticleEntity>[],
    this.featured = const <ArticleEntity>[],
    this.categories = const <CategoryEntity>[],
    this.posts = const <ArticleEntity>[],
    this.selectedCategoryId,
    this.page = 1,
    this.hasMore = true,
    this.isLoadingMore = false,
  });

  final List<ArticleEntity> breaking;
  final List<ArticleEntity> featured;
  final List<CategoryEntity> categories;
  final List<ArticleEntity> posts;
  final int? selectedCategoryId;
  final int page;
  final bool hasMore;
  final bool isLoadingMore;

  HomeFeedState copyWith({
    List<ArticleEntity>? breaking,
    List<ArticleEntity>? featured,
    List<CategoryEntity>? categories,
    List<ArticleEntity>? posts,
    int? selectedCategoryId,
    bool clearCategorySelection = false,
    int? page,
    bool? hasMore,
    bool? isLoadingMore,
  }) {
    return HomeFeedState(
      breaking: breaking ?? this.breaking,
      featured: featured ?? this.featured,
      categories: categories ?? this.categories,
      posts: posts ?? this.posts,
      selectedCategoryId: clearCategorySelection
          ? null
          : (selectedCategoryId ?? this.selectedCategoryId),
      page: page ?? this.page,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }
}

class HomeFeedNotifier extends AsyncNotifier<HomeFeedState> {
  NewsRepository get _news => ref.read(newsRepositoryProvider);
  CategoryRepository get _categories => ref.read(categoryRepositoryProvider);

  @override
  Future<HomeFeedState> build() => _bootstrap();

  Future<HomeFeedState> _bootstrap({bool forceRefresh = false}) async {
    final int breakingCatId = ref.read(adConfigProvider).breakingCategoryId > 0
        ? ref.read(adConfigProvider).breakingCategoryId
        : EnvConfig.fallbackBreakingCategoryId;

    // تحميل متوازٍ مع عزل فشل كل جزء عن الآخر.
    final List<dynamic> results = await Future.wait<dynamic>(<Future<dynamic>>[
      _news.getBreakingNews(categoryId: breakingCatId),
      _news.getFeaturedPosts(),
      _categories.getCategories(forceRefresh: forceRefresh),
      _news.getPosts(page: 1, forceRefresh: forceRefresh),
    ]);

    final Result<List<ArticleEntity>> breakingResult =
        results[0] as Result<List<ArticleEntity>>;
    final Result<List<ArticleEntity>> featuredResult =
        results[1] as Result<List<ArticleEntity>>;
    final Result<List<CategoryEntity>> categoriesResult =
        results[2] as Result<List<CategoryEntity>>;
    final Result<PaginatedResult<ArticleEntity>> postsResult =
        results[3] as Result<PaginatedResult<ArticleEntity>>;

    // فشل القائمة الرئيسية هو وحده الذي يُسقط الشاشة في حالة خطأ.
    if (postsResult case Err<dynamic>(:final AppFailure failure)) {
      throw failure;
    }
    final PaginatedResult<ArticleEntity> postsPage =
        (postsResult as Ok<PaginatedResult<ArticleEntity>>).data;

    return HomeFeedState(
      breaking: switch (breakingResult) {
        Ok<List<ArticleEntity>>(:final List<ArticleEntity> data) => data,
        Err<dynamic>() => const <ArticleEntity>[],
      },
      featured: switch (featuredResult) {
        Ok<List<ArticleEntity>>(:final List<ArticleEntity> data) => data,
        Err<dynamic>() => const <ArticleEntity>[],
      },
      categories: switch (categoriesResult) {
        Ok<List<CategoryEntity>>(:final List<CategoryEntity> data) => data,
        Err<dynamic>() => const <CategoryEntity>[],
      },
      posts: postsPage.items,
      page: 1,
      hasMore: postsPage.hasMore,
    );
  }

  Future<void> refresh() async {
    state = const AsyncLoading<HomeFeedState>();
    try {
      state = AsyncData<HomeFeedState>(await _bootstrap(forceRefresh: true));
    } on Object catch (error, stackTrace) {
      state = AsyncError<HomeFeedState>(ErrorMapper.map(error), stackTrace);
    }
  }

  Future<void> selectCategory(int? categoryId) async {
    final HomeFeedState current = state.value ?? const HomeFeedState();
    state = AsyncData<HomeFeedState>(
      current.copyWith(
        selectedCategoryId: categoryId,
        clearCategorySelection: categoryId == null,
        posts: const <ArticleEntity>[],
        page: 1,
        hasMore: true,
      ),
    );
    try {
      final Result<PaginatedResult<ArticleEntity>> result =
          await _news.getPosts(page: 1, categoryId: categoryId);
      switch (result) {
        case Ok<PaginatedResult<ArticleEntity>>(:final PaginatedResult<ArticleEntity> data):
          state = AsyncData<HomeFeedState>(
            (state.value ?? const HomeFeedState()).copyWith(
              posts: data.items,
              page: 1,
              hasMore: data.hasMore,
            ),
          );
        case Err<dynamic>(:final AppFailure failure):
          state = AsyncError<HomeFeedState>(failure, StackTrace.current);
      }
    } on Object catch (error, stackTrace) {
      state = AsyncError<HomeFeedState>(ErrorMapper.map(error), stackTrace);
    }
  }

  Future<void> loadMore() async {
    final HomeFeedState? current = state.value;
    if (current == null ||
        current.isLoadingMore ||
        !current.hasMore ||
        current.posts.isEmpty) {
      return;
    }
    state = AsyncData<HomeFeedState>(current.copyWith(isLoadingMore: true));
    final int nextPage = current.page + 1;
    try {
      final Result<PaginatedResult<ArticleEntity>> result =
          await _news.getPosts(
        page: nextPage,
        categoryId: current.selectedCategoryId,
      );
      switch (result) {
        case Ok<PaginatedResult<ArticleEntity>>(:final PaginatedResult<ArticleEntity> data):
          state = AsyncData<HomeFeedState>(
            (state.value ?? current).copyWith(
              posts: <ArticleEntity>[...current.posts, ...data.items],
              page: nextPage,
              hasMore: data.hasMore,
              isLoadingMore: false,
            ),
          );
        case Err<dynamic>(:final AppFailure failure):
          if (ErrorMapper.isEndOfPagination(failure)) {
            state = AsyncData<HomeFeedState>(
              (state.value ?? current)
                  .copyWith(hasMore: false, isLoadingMore: false),
            );
          } else {
            state = AsyncData<HomeFeedState>(
              (state.value ?? current)
                  .copyWith(isLoadingMore: false),
            );
          }
      }
    } on Object catch (error, stackTrace) {
      state = AsyncError<HomeFeedState>(ErrorMapper.map(error), stackTrace);
    }
  }
}

final AsyncNotifierProvider<HomeFeedNotifier, HomeFeedState>
    homeFeedNotifierProvider =
    AsyncNotifierProvider<HomeFeedNotifier, HomeFeedState>(
        HomeFeedNotifier.new);
