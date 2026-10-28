import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/storage/app_database.dart';
import '../../../article/domain/entities/article_entity.dart';
import '../../../home/presentation/providers/news_providers.dart';
import '../../data/bookmarks_local_data_source.dart';
import '../../data/repositories/bookmarks_repository_impl.dart';
import '../../domain/repositories/bookmarks_repository.dart';

final Provider<BookmarksLocalDataSource> bookmarksLocalDataSourceProvider =
    Provider<BookmarksLocalDataSource>((Ref ref) {
  return BookmarksLocalDataSource(ref.watch(appDatabaseProvider));
});

final Provider<BookmarksRepository> bookmarksRepositoryProvider =
    Provider<BookmarksRepository>((Ref ref) {
  return BookmarksRepositoryImpl(ref.watch(bookmarksLocalDataSourceProvider));
});

/// قائمة المقالات المحفوظة مرتبة الأحدث حفظاً.
class BookmarksNotifier extends AsyncNotifier<List<ArticleEntity>> {
  @override
  Future<List<ArticleEntity>> build() {
    return ref.watch(bookmarksRepositoryProvider).getBookmarks();
  }

  Future<bool> toggle(ArticleEntity article) async {
    final BookmarksRepository repo = ref.read(bookmarksRepositoryProvider);
    final bool currentlySaved = await repo.isBookmarked(article.id);
    if (currentlySaved) {
      await repo.removeBookmark(article.id);
      ref.read(bookmarkIdsProvider.notifier).remove(article.id);
    } else {
      // البطاقات القادمة من القوائم لا تحمل متن المقال؛ نجلبه قبل الحفظ
      // حتى تعمل القراءة دون اتصال من المحفوظات.
      ArticleEntity toSave = article;
      if (article.htmlContent.trim().isEmpty) {
        final full = await ref
            .read(newsRepositoryProvider)
            .getPostById(article.id);
        toSave = full.when(
          onSuccess: (ArticleEntity value) => value,
          onFailure: (_) => article,
        );
      }
      await repo.saveBookmark(toSave);
      ref.read(bookmarkIdsProvider.notifier).add(article.id);
    }
    ref.invalidateSelf();
    return !currentlySaved;
  }
}

final AsyncNotifierProvider<BookmarksNotifier, List<ArticleEntity>>
    bookmarksNotifierProvider =
    AsyncNotifierProvider<BookmarksNotifier, List<ArticleEntity>>(
        BookmarksNotifier.new);

/// مجموعة معرّفات المقالات المحفوظة لتحديث الأيقونات لحظياً.
class BookmarkIdsNotifier extends Notifier<Set<int>> {
  @override
  Set<int> build() {
    // تحميل أولي غير متزامن ثم تحديث الحالة.
    Future<void>.microtask(() async {
      try {
        state = await ref.read(bookmarksRepositoryProvider).getBookmarkIds();
      } on Object {
        // تبقى المجموعة فارغة إن تعذّر التحميل الأولي.
      }
    });
    return <int>{};
  }

  /// تحديث فوري للأيقونة دون إعادة تحميل كامل (يمنع الوميض).
  void add(int articleId) {
    state = <int>{...state, articleId};
  }

  void remove(int articleId) {
    state = <int>{...state}..remove(articleId);
  }
}

final NotifierProvider<BookmarkIdsNotifier, Set<int>> bookmarkIdsProvider =
    NotifierProvider<BookmarkIdsNotifier, Set<int>>(BookmarkIdsNotifier.new);

/// استعلام تفاعلي سريع عن حالة حفظ مقال.
final isBookmarkedProvider = Provider.autoDispose.family<bool, int>(
  (Ref ref, int articleId) {
    return ref.watch(bookmarkIdsProvider).contains(articleId);
  },
);
