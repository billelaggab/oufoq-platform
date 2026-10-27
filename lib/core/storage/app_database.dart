import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqflite/sqflite.dart';

import '../config/app_constants.dart';

/// قاعدة بيانات SQLite للمقالات المحفوظة للقراءة بدون إنترنت.
class AppDatabase {
  AppDatabase._(this._db);

  final Database _db;

  Database get rawDatabase => _db;

  static Future<AppDatabase> open({String? databasePath}) async {
    final String path = databasePath ??
        await getDatabasesPath().then(
          (String dir) => '$dir/${AppConstants.offlineDatabaseName}',
        );

    final Database db = await openDatabase(
      path,
      version: 1,
      onCreate: (Database db, int version) async {
        await db.execute('''
          CREATE TABLE ${AppConstants.bookmarksTable}(
            id INTEGER PRIMARY KEY,
            slug TEXT,
            link TEXT,
            title TEXT NOT NULL,
            excerpt TEXT,
            html_content TEXT NOT NULL,
            published_at TEXT,
            featured_image_url TEXT,
            category_name TEXT,
            author_name TEXT,
            reading_time INTEGER,
            saved_at TEXT NOT NULL
          )
        ''');
      },
    );
    return AppDatabase._(db);
  }

  Future<void> close() => _db.close();
}

/// مزوّد قاعدة البيانات (يُحقن في main ليعمل أيضاً في الاختبارات).
final Provider<AppDatabase> appDatabaseProvider = Provider<AppDatabase>((Ref ref) {
  throw UnimplementedError(
    'appDatabaseProvider يجب أن يُحقن في ProviderScope داخل main()',
  );
});
