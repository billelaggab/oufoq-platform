import 'package:flutter/material.dart';

/// إعدادات اللغات المفعّلة للمستخدم النهائي.
///
/// الإصدار 1.0: العربية فقط. لتفعيل الإنجليزية/الفرنسية مستقبلاً تُضاف
/// اللغة إلى [activeLocales] فقط دون تعديل أي شاشة.
abstract final class LocaleConfig {
  const LocaleConfig._();

  /// اللغة الافتراضية للتطبيق.
  static const Locale defaultLocale = Locale('ar');

  /// اللغات المفعّلة حالياً في الإصدار 1.0 (العربية فقط).
  static const List<Locale> activeLocales = <Locale>[
    Locale('ar'),
    // Locale('en'), // فك التعليق عند جاهزية المحتوى الإنجليزي
    // Locale('fr'), // فك التعليق عند جاهزية المحتوى الفرنسي
  ];

  /// يظهر خيار تبديل اللغة في الإعدادات تلقائياً عند وجود أكثر من لغة.
  static bool get isMultiLanguageEnabled => activeLocales.length > 1;
}

/// مفاتيح تفعيل الميزات التجريبية.
abstract final class FeatureFlags {
  const FeatureFlags._();

  /// إعلان فتح التطبيق (مطفأ افتراضياً في الإطلاق الأول).
  static const bool appOpenAdEnabled = false;

  /// تفعيل مبدل اللغة (مرتبط آلياً بعدد اللغات النشطة).
  static bool get enableLanguageSwitcher => LocaleConfig.isMultiLanguageEnabled;
}
