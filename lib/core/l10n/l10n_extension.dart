import 'package:flutter/material.dart';

import '../utils/date_formatter.dart';
import 'generated/app_localizations.dart';

/// اختصارات الوصول السريع للترجمة والتاريخ داخل الواجهات.
extension L10nContextX on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);

  Locale get currentLocale => Localizations.localeOf(this);

  /// تنسيق تاريخ المقال: نسبي خلال 24 ساعة، وتاريخ كامل بعد ذلك.
  String formatArticleDate(DateTime? dateTime) {
    if (dateTime == null) {
      return '';
    }
    final AppLocalizations l = l10n;
    if (!DateFormatter.isWithin24Hours(dateTime)) {
      return DateFormatter.fullDate(dateTime, currentLocale.languageCode);
    }
    final RelativeTime relative = DateFormatter.relative(dateTime);
    return switch (relative.type) {
      RelativeTimeType.justNow => l.justNow,
      RelativeTimeType.minutes => l.minutesAgo(relative.count),
      RelativeTimeType.hours => l.hoursAgo(relative.count),
      RelativeTimeType.days => l.daysAgo(relative.count),
    };
  }
}
