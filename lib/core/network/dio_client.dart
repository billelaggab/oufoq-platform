import 'package:dio/dio.dart';
import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../config/app_constants.dart';
import '../config/env_config.dart';
import '../l10n/locale_provider.dart';
import 'file_cache_store.dart';
import 'interceptors/language_interceptor.dart';
import 'interceptors/retry_interceptor.dart';

/// مخزن الكاش المشترك الدائم (يُستخدم أيضاً عند مسح الكاش من الإعدادات).
final Provider<CacheStore> cacheStoreProvider = Provider<CacheStore>(
  (Ref ref) => FileCacheStore(),
);

/// عميل Dio مهيأ مع الكاش واللغة وإعادة المحاولة.
final Provider<Dio> dioProvider = Provider<Dio>((Ref ref) {
  final CacheStore store = ref.watch(cacheStoreProvider);

  final CacheOptions cacheOptions = CacheOptions(
    store: store,
    policy: CachePolicy.request,
    maxStale: AppConstants.cacheMaxStale,
    hitCacheOnNetworkFailure: true,
    // عزل الكاش حسب اللغة حتى لا تختلط الأخبار عند تفعيل تعدد اللغات.
    keyBuilder: ({
      required Uri url,
      Map<String, String>? headers,
      Object? body,
    }) {
      final String locale = ref.read(localeProvider).languageCode;
      return '${locale}_$url';
    },
  );

  final Dio dio = Dio(
    BaseOptions(
      baseUrl: EnvConfig.wpBaseUrl,
      connectTimeout: AppConstants.connectTimeout,
      receiveTimeout: AppConstants.receiveTimeout,
      headers: <String, String>{'Accept': 'application/json'},
      responseType: ResponseType.json,
    ),
  );

  dio.interceptors.addAll(<Interceptor>[
    LanguageInterceptor(ref),
    RetryInterceptor(dio),
    DioCacheInterceptor(options: cacheOptions),
  ]);

  ref.onDispose(dio.close);
  return dio;
});
