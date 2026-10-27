import 'package:flutter/material.dart';

/// ألوان مخصصة إضافية لا تغطيها ColorScheme الأساسية.
@immutable
class OufoqCustomColors extends ThemeExtension<OufoqCustomColors> {
  const OufoqCustomColors({
    required this.breaking,
    required this.accent,
    required this.adSurface,
    required this.textSecondary,
    required this.cardBorder,
  });

  /// لون الأخبار العاجلة الحصري.
  final Color breaking;

  /// لون التميز (الكهرماني الدافئ).
  final Color accent;

  /// خلفية بطاقة الإعلان الهادئة.
  final Color adSurface;

  /// النص الثانوي (التواريخ والمقتطفات).
  final Color textSecondary;

  /// حدود البطاقات والفواصل.
  final Color cardBorder;

  static const OufoqCustomColors light = OufoqCustomColors(
    breaking: Color(0xFFDC2626),
    accent: Color(0xFFD97706),
    adSurface: Color(0xFFF1F5F9),
    textSecondary: Color(0xFF475569),
    cardBorder: Color(0xFFE2E8F0),
  );

  static const OufoqCustomColors dark = OufoqCustomColors(
    breaking: Color(0xFFEF4444),
    accent: Color(0xFFF59E0B),
    adSurface: Color(0xFF1A263D),
    textSecondary: Color(0xFF94A3B8),
    cardBorder: Color(0xFF1E293B),
  );

  @override
  OufoqCustomColors copyWith({
    Color? breaking,
    Color? accent,
    Color? adSurface,
    Color? textSecondary,
    Color? cardBorder,
  }) {
    return OufoqCustomColors(
      breaking: breaking ?? this.breaking,
      accent: accent ?? this.accent,
      adSurface: adSurface ?? this.adSurface,
      textSecondary: textSecondary ?? this.textSecondary,
      cardBorder: cardBorder ?? this.cardBorder,
    );
  }

  @override
  OufoqCustomColors lerp(ThemeExtension<OufoqCustomColors>? other, double t) {
    if (other is! OufoqCustomColors) {
      return this;
    }
    return OufoqCustomColors(
      breaking: Color.lerp(breaking, other.breaking, t)!,
      accent: Color.lerp(accent, other.accent, t)!,
      adSurface: Color.lerp(adSurface, other.adSurface, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      cardBorder: Color.lerp(cardBorder, other.cardBorder, t)!,
    );
  }
}

/// اللوحة اللونية المعتمدة للوضعين النهاري والليلي.
abstract final class AppColors {
  const AppColors._();

  // الوضع النهاري
  static const Color lightPrimary = Color(0xFF0F4C81);
  static const Color lightBackground = Color(0xFFF8FAFC);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightTextPrimary = Color(0xFF0F172A);

  // الوضع الليلي (كحلي رمادي مريح للعين)
  static const Color darkPrimary = Color(0xFF38BDF8);
  static const Color darkBackground = Color(0xFF0B1120);
  static const Color darkSurface = Color(0xFF151F32);
  static const Color darkTextPrimary = Color(0xFFF1F5F9);
}
