import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/storage/app_database.dart';
import '../../../article/domain/entities/article_entity.dart';
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
    } else {
      await repo.saveBookmark(article);
    }
    ref.invalidate(bookmarkIdsProvider);
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
    ref
        .watch(bookmarksRepositoryProvider)
        .getBookmarkIds()
        .then((Set<int> ids) => state = ids)
        .catchError((Object _) => state);
    return <int>{};
  }
}

final NotifierProvider<BookmarkIdsNotifier, Set<int>> bookmarkIdsProvider =
    NotifierProvider<BookmarkIdsNotifier, Set<int>>(BookmarkIdsNotifier.new);

/// استعلام تفاعلي سريع عن حالة حفظ مقال.
final isBookmarkedProvider = Provider.family<bool, int>(
  (Ref ref, int articleId) {
    return ref.watch(bookmarkIdsProvider).contains(articleId);
  },
);
