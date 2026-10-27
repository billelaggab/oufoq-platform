import '../../../article/domain/entities/article_entity.dart';
import '../../domain/repositories/bookmarks_repository.dart';
import '../bookmarks_local_data_source.dart';

class BookmarksRepositoryImpl implements BookmarksRepository {
  BookmarksRepositoryImpl(this._localDataSource);

  final BookmarksLocalDataSource _localDataSource;

  @override
  Future<List<ArticleEntity>> getBookmarks() =>
      _localDataSource.getAllBookmarks();

  @override
  Future<Set<int>> getBookmarkIds() =>
      _localDataSource.getAllBookmarkIds();

  @override
  Future<bool> isBookmarked(int articleId) =>
      _localDataSource.isBookmarked(articleId);

  @override
  Future<void> saveBookmark(ArticleEntity article) =>
      _localDataSource.insertBookmark(article);

  @override
  Future<void> removeBookmark(int articleId) =>
      _localDataSource.deleteBookmark(articleId);
}
