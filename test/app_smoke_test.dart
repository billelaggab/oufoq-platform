import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:oufoq_platform/app.dart';
import 'package:oufoq_platform/core/error/app_failure.dart';
import 'package:oufoq_platform/core/network/connectivity_provider.dart';
import 'package:oufoq_platform/core/storage/preferences_service.dart';
import 'package:oufoq_platform/features/ads/domain/ad_config.dart';
import 'package:oufoq_platform/features/ads/presentation/providers/ad_config_provider.dart';
import 'package:oufoq_platform/features/article/domain/entities/article_entity.dart';
import 'package:oufoq_platform/features/bookmarks/domain/repositories/bookmarks_repository.dart';
import 'package:oufoq_platform/features/bookmarks/presentation/providers/bookmarks_providers.dart';
import 'package:oufoq_platform/features/categories/domain/entities/category_entity.dart';
import 'package:oufoq_platform/features/home/domain/repositories/category_repository.dart';
import 'package:oufoq_platform/features/home/domain/repositories/news_repository.dart';
import 'package:oufoq_platform/features/home/presentation/providers/news_providers.dart';

class _FakeNewsRepository implements NewsRepository {
  @override
  Future<Result<PaginatedResult<ArticleEntity>>> getPosts({
    required int page,
    int? categoryId,
    String? searchQuery,
    bool forceRefresh = false,
  }) async =>
      const Ok<PaginatedResult<ArticleEntity>>(
        PaginatedResult<ArticleEntity>(
          items: <ArticleEntity>[],
          page: 1,
          hasMore: false,
        ),
      );

  @override
  Future<Result<List<ArticleEntity>>> getBreakingNews({int? categoryId}) async =>
      const Ok<List<ArticleEntity>>(<ArticleEntity>[]);

  @override
  Future<Result<List<ArticleEntity>>> getFeaturedPosts() async =>
      const Ok<List<ArticleEntity>>(<ArticleEntity>[]);

  @override
  Future<Result<ArticleEntity>> getPostById(int id) async =>
      const Err<ArticleEntity>(UnexpectedFailure('not found'));

  @override
  Future<Result<ArticleEntity>> getPostBySlug(String slug) async =>
      const Err<ArticleEntity>(UnexpectedFailure('not found'));

  @override
  Future<Result<List<ArticleEntity>>> getRelatedPosts({
    required int categoryId,
    required int excludePostId,
  }) async =>
      const Ok<List<ArticleEntity>>(<ArticleEntity>[]);
}

class _FakeCategoryRepository implements CategoryRepository {
  @override
  Future<Result<List<CategoryEntity>>> getCategories({
    bool forceRefresh = false,
  }) async =>
      const Ok<List<CategoryEntity>>(<CategoryEntity>[]);
}

class _FakeBookmarksRepository implements BookmarksRepository {
  @override
  Future<List<ArticleEntity>> getBookmarks() async =>
      const <ArticleEntity>[];

  @override
  Future<Set<int>> getBookmarkIds() async => <int>{};

  @override
  Future<bool> isBookmarked(int articleId) async => false;

  @override
  Future<void> removeBookmark(int articleId) async {}

  @override
  Future<void> saveBookmark(ArticleEntity article) async {}
}

class _FakeAdConfigNotifier extends AdConfigNotifier {
  @override
  Future<AdConfig> build() async => AdConfig.safeDefaults;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('إقلاع التطبيق بالعربية RTL مع شريط تنقل من 4 تبويبات',
      (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final PreferencesService prefs = await PreferencesService.create();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          preferencesServiceProvider.overrideWithValue(prefs),
          newsRepositoryProvider.overrideWithValue(_FakeNewsRepository()),
          categoryRepositoryProvider
              .overrideWithValue(_FakeCategoryRepository()),
          bookmarksRepositoryProvider
              .overrideWithValue(_FakeBookmarksRepository()),
          adConfigAsyncProvider.overrideWith(_FakeAdConfigNotifier.new),
          connectivityProvider.overrideWith(
            (Ref ref) =>
                Stream<List<ConnectivityResult>>.value(
                    <ConnectivityResult>[ConnectivityResult.wifi]),
          ),
        ],
        child: const OufoqApp(),
      ),
    );

    // ترك المهام الأولية (Future.wait والشبكات الوهمية) تستقر.
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pump(const Duration(milliseconds: 100));

    // اتجاه الواجهة عربي RTL.
    final Directionality directionality =
        tester.widget<Directionality>(find.byType(Directionality));
    expect(directionality.textDirection, TextDirection.rtl);

    // شريط التنقل السفلي بتبويباته الأربعة.
    expect(find.byType(NavigationBar), findsOneWidget);
    expect(find.byType(NavigationDestination), findsNWidgets(4));

    // اسم التطبيق يظهر في شريط الرئيسية.
    expect(find.text('منصة أفق'), findsOneWidget);
  });
}
