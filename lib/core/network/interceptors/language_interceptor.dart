import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../config/feature_flags.dart';
import '../../l10n/locale_provider.dart';

/// يمرر لغة التطبيق الحالية إلى ووردبريس استعداداً لتعدد اللغات.
class LanguageInterceptor extends Interceptor {
  LanguageInterceptor(this._ref);

  final Ref _ref;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final String languageCode = _ref.read(localeProvider).languageCode;
    options.headers['Accept-Language'] = languageCode;
    if (LocaleConfig.isMultiLanguageEnabled) {
      options.queryParameters = <String, dynamic>{
        ...options.queryParameters,
        'lang': languageCode,
      };
    }
    handler.next(options);
  }
}
