import 'package:dio/dio.dart';

import 'app_failure.dart';

/// تحويل أخطاء Dio والاستثناءات الخام إلى كائنات [AppFailure] نظيفة.
abstract final class ErrorMapper {
  const ErrorMapper._();

  static AppFailure map(Object error, [StackTrace? stackTrace]) {
    if (error is AppFailure) {
      return error;
    }
    if (error is DioException) {
      return _mapDio(error);
    }
    return UnexpectedFailure(error.toString());
  }

  static AppFailure _mapDio(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.transformTimeout:
        return const NetworkFailure();
      case DioExceptionType.connectionError:
        return const NetworkFailure();
      case DioExceptionType.cancel:
        return const UnexpectedFailure('Request cancelled');
      case DioExceptionType.badCertificate:
        return const ServerFailure(message: 'bad_certificate');
      case DioExceptionType.unknown:
        if (error.error is AppFailure) {
          return error.error! as AppFailure;
        }
        return const NetworkFailure();
      case DioExceptionType.badResponse:
        return _mapBadResponse(error);
    }
  }

  static AppFailure _mapBadResponse(DioException error) {
    final int? status = error.response?.statusCode;
    final dynamic data = error.response?.data;

    // حالة ووردبريس الشهيرة عند تجاوز رقم الصفحة الأخيرة.
    if (status == 400 && data is Map && data['code'] == 'rest_post_invalid_page_number') {
      return const ServerFailure(statusCode: 400, message: 'rest_post_invalid_page_number');
    }
    if (status != null && status >= 500) {
      return ServerFailure(statusCode: status, message: 'server_error');
    }
    return ServerFailure(statusCode: status, message: 'unexpected_response');
  }

  /// هل الخطأ يعني نهاية الصفحات في ووردبريس؟
  static bool isEndOfPagination(AppFailure failure) {
    return failure is ServerFailure &&
        failure.statusCode == 400 &&
        failure.message == 'rest_post_invalid_page_number';
  }
}
