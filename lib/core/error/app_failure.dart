/// الأخطاء الموحدة عبر طبقات التطبيق (Dart 3 sealed classes).
sealed class AppFailure {
  const AppFailure();
}

/// انقطاع الاتصال بالإنترنت.
final class NetworkFailure extends AppFailure {
  const NetworkFailure();
}

/// خطأ من الخادم مع رمز الحالة.
final class ServerFailure extends AppFailure {
  const ServerFailure({this.statusCode, this.message});

  final int? statusCode;
  final String? message;
}

/// عدم توفر بيانات في الكاش المحلي.
final class EmptyCacheFailure extends AppFailure {
  const EmptyCacheFailure();
}

/// خطأ غير متوقع.
final class UnexpectedFailure extends AppFailure {
  const UnexpectedFailure(this.debugMessage);

  final String debugMessage;
}

/// نتيجة عملية إما نجاح ببيانات أو فشل بكائن خطأ.
sealed class Result<T> {
  const Result();

  const factory Result.ok(T data) = Ok<T>;
  const factory Result.err(AppFailure failure) = Err<T>;

  R when<R>({
    required R Function(T data) onSuccess,
    required R Function(AppFailure failure) onFailure,
  }) {
    final Result<T> self = this;
    return switch (self) {
      Ok<T>(:final T data) => onSuccess(data),
      Err<T>(:final AppFailure failure) => onFailure(failure),
    };
  }
}

final class Ok<T> extends Result<T> {
  const Ok(this.data);

  final T data;
}

final class Err<T> extends Result<T> {
  const Err(this.failure);

  final AppFailure failure;
}

/// نتيجة مقسمة لصفحات من WordPress.
class PaginatedResult<T> {
  const PaginatedResult({
    required this.items,
    required this.page,
    required this.hasMore,
    this.totalPages = 1,
  });

  final List<T> items;
  final int page;
  final bool hasMore;
  final int totalPages;

  PaginatedResult<T> copyWith({
    List<T>? items,
    int? page,
    bool? hasMore,
    int? totalPages,
  }) {
    return PaginatedResult<T>(
      items: items ?? this.items,
      page: page ?? this.page,
      hasMore: hasMore ?? this.hasMore,
      totalPages: totalPages ?? this.totalPages,
    );
  }
}
