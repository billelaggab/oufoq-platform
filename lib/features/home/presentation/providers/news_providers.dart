import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/dio_client.dart';
import '../../data/datasources/news_remote_data_source.dart';
import '../../data/repositories/category_repository_impl.dart';
import '../../data/repositories/news_repository_impl.dart';
import '../../domain/repositories/category_repository.dart';
import '../../domain/repositories/news_repository.dart';

/// حقن مصدر البيانات الشبكي.
final Provider<NewsRemoteDataSource> newsRemoteDataSourceProvider =
    Provider<NewsRemoteDataSource>((Ref ref) {
  return NewsRemoteDataSource(
    ref.watch(dioProvider),
    CacheOptions(
      store: ref.watch(cacheStoreProvider),
      policy: CachePolicy.request,
      maxStale: const Duration(days: 7),
      hitCacheOnNetworkFailure: true,
    ),
  );
});

final Provider<NewsRepository> newsRepositoryProvider =
    Provider<NewsRepository>((Ref ref) {
  return NewsRepositoryImpl(ref.watch(newsRemoteDataSourceProvider));
});

final Provider<CategoryRepository> categoryRepositoryProvider =
    Provider<CategoryRepository>((Ref ref) {
  return CategoryRepositoryImpl(ref.watch(newsRemoteDataSourceProvider));
});
