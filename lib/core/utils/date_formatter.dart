import 'package:intl/intl.dart';

/// نوع الزمن النسبي لتترجم الطبقة المرئية نصه عبر ملفات .arb.
enum RelativeTimeType { justNow, minutes, hours, days }

class RelativeTime {
  const RelativeTime(this.type, this.count);

  final RelativeTimeType type;
  final int count;
}

/// أدوات تنسيق التواريخ حسب لغة التطبيق النشطة.
abstract final class DateFormatter {
  const DateFormatter._();

  /// تنسيق تاريخ كامل مترجم (مثال: 27 أكتوبر 2026).
  static String fullDate(DateTime dateTime, String localeCode) {
    return DateFormat('d MMMM y', localeCode).format(dateTime.toLocal());
  }

  /// تاريخ قصير للبطاقات (مثال: 27 أكتوبر).
  static String shortDate(DateTime dateTime, String localeCode) {
    return DateFormat('d MMM', localeCode).format(dateTime.toLocal());
  }

  /// حساب الزمن النسبي الذكي.
  /// خلال آخر 24 ساعة => نسبي، وما قبل ذلك => تاريخ كامل تترجمه الواجهة.
  static RelativeTime relative(DateTime dateTime, {DateTime? now}) {
    final DateTime reference = (now ?? DateTime.now()).toUtc();
    final Duration diff = reference.difference(dateTime.toUtc());

    if (diff.inMinutes < 1) {
      return const RelativeTime(RelativeTimeType.justNow, 0);
    }
    if (diff.inMinutes < 60) {
      return RelativeTime(RelativeTimeType.minutes, diff.inMinutes);
    }
    if (diff.inHours < 24) {
      return RelativeTime(RelativeTimeType.hours, diff.inHours);
    }
    return RelativeTime(RelativeTimeType.days, diff.inDays);
  }

  static bool isWithin24Hours(DateTime dateTime, {DateTime? now}) {
    final Duration diff =
        (now ?? DateTime.now()).toUtc().difference(dateTime.toUtc());
    return diff.inHours < 24;
  }
}
