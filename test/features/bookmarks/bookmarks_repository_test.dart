import 'package:flutter_test/flutter_test.dart';
import 'package:oufoq_platform/core/storage/app_database.dart';
import 'package:oufoq_platform/features/article/domain/entities/article_entity.dart';
import 'package:oufoq_platform/features/bookmarks/data/bookmarks_local_data_source.dart';
import 'package:oufoq_platform/features/bookmarks/data/repositories/bookmarks_repository_impl.dart';
import 'package:sqflite_common_ffi/sqflite_common_ffi.dart';

void main() {
  late AppDatabase database;
  late BookmarksRepositoryImpl repository;

  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  setUp(() async {
    database = await AppDatabase.open(databasePath: inMemoryDatabasePath);
    repository =
        BookmarksRepositoryImpl(BookmarksLocalDataSource(database));
  });

  tearDown(() => database.close());

  const ArticleEntity article = ArticleEntity(
    id: 900,
    slug: 'saved-article',
    link: 'https://example.com/saved-article',
    title: 'مقال محفوظ للقراءة أوفلاين',
    excerpt: 'مقتطف المقال',
    htmlContent: '<p>المحتوى الكامل للمقال بدون إنترنت</p>',
    publishedAt: null,
    primaryCategoryName: 'تقارير',
    readingTimeMinutes: 3,
  );

  test('حفظ مقال ثم استرجاعه كاملاً من قاعدة البيانات', () async {
    await repository.saveBookmark(article);

    expect(await repository.isBookmarked(article.id), isTrue);
    final Set<int> ids = await repository.getBookmarkIds();
    expect(ids, contains(article.id));

    final List<ArticleEntity> all = await repository.getBookmarks();
    expect(all, hasLength(1));
    final ArticleEntity restored = all.single;
    expect(restored.title, article.title);
    expect(restored.htmlContent, article.htmlContent);
    expect(restored.primaryCategoryName, 'تقارير');
    expect(restored.readingTimeMinutes, 3);
  });

  test('حذف مقال محفوظ يفرغ القائمة ويحدّث المعرّفات', () async {
    await repository.saveBookmark(article);
    expect(await repository.isBookmarked(article.id), isTrue);

    await repository.removeBookmark(article.id);

    expect(await repository.isBookmarked(article.id), isFalse);
    expect(await repository.getBookmarks(), isEmpty);
    expect(await repository.getBookmarkIds(), isEmpty);
  });

  test('إعادة حفظ المقال نفسه لا تكرره (REPLACE)', () async {
    await repository.saveBookmark(article);
    await repository.saveBookmark(article);
    expect(await repository.getBookmarks(), hasLength(1));
  });
}
