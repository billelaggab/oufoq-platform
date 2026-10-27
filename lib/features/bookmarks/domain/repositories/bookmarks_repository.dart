import '../../../article/domain/entities/article_entity.dart';

/// عقد مستودع المحفوظات المحلية (أوفلاين).
abstract interface class BookmarksRepository {
  Future<List<ArticleEntity>> getBookmarks();

  Future<Set<int>> getBookmarkIds();

  Future<bool> isBookmarked(int articleId);

  Future<void> saveBookmark(ArticleEntity article);

  Future<void> removeBookmark(int articleId);
}
