import 'package:sqflite/sqflite.dart';

import '../../../../core/config/app_constants.dart';
import '../../../../core/storage/app_database.dart';
import '../../article/domain/entities/article_entity.dart';

/// الوصول المحلي لجدول المقالات المحفوظة في SQLite.
class BookmarksLocalDataSource {
  BookmarksLocalDataSource(this._database);

  final AppDatabase _database;

  Future<List<ArticleEntity>> getAllBookmarks() async {
    final Database db = _database.rawDatabase;
    final List<Map<String, Object?>> rows = await db.query(
      AppConstants.bookmarksTable,
      orderBy: 'saved_at DESC',
    );
    return rows.map(ArticleEntity.fromBookmarkMap).toList(growable: false);
  }

  Future<bool> isBookmarked(int articleId) async {
    final Database db = _database.rawDatabase;
    final List<Map<String, Object?>> rows = await db.query(
      AppConstants.bookmarksTable,
      where: 'id = ?',
      whereArgs: <Object?>[articleId],
      limit: 1,
    );
    return rows.isNotEmpty;
  }

  Future<void> insertBookmark(ArticleEntity article) async {
    final Database db = _database.rawDatabase;
    await db.insert(
      AppConstants.bookmarksTable,
      article.toBookmarkMap(DateTime.now()),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> deleteBookmark(int articleId) async {
    final Database db = _database.rawDatabase;
    await db.delete(
      AppConstants.bookmarksTable,
      where: 'id = ?',
      whereArgs: <Object?>[articleId],
    );
  }

  Future<Set<int>> getAllBookmarkIds() async {
    final Database db = _database.rawDatabase;
    final List<Map<String, Object?>> rows = await db.query(
      AppConstants.bookmarksTable,
      columns: <String>['id'],
    );
    return rows
        .map((Map<String, Object?> row) => row['id']! as int)
        .toSet();
  }
}
