import 'package:dio/dio.dart';

/// إعادة محاولة تلقائية مرة واحدة عند الأخطاء العابرة للشبكة/الخادم.
class RetryInterceptor extends Interceptor {
  RetryInterceptor(this._dio);

  final Dio _dio;
  static const String _retryFlag = 'oufoq_retry_attempted';

  static const Set<int> _retryableStatus = <int>{502, 503, 504};

  bool _isRetryable(DioException error) {
    if (error.type == DioExceptionType.connectionError ||
        error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout) {
      return true;
    }
    final int? status = error.response?.statusCode;
    return status != null && _retryableStatus.contains(status);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final bool alreadyRetried =
        err.requestOptions.extra[_retryFlag] == true;
    if (alreadyRetried || !_isRetryable(err)) {
      handler.next(err);
      return;
    }
    try {
      final RequestOptions options = err.requestOptions;
      options.extra[_retryFlag] = true;
      final Response<dynamic> response = await _dio.fetch<dynamic>(options);
      handler.resolve(response);
    } on DioException catch (retryError) {
      handler.next(retryError);
    }
  }
}
