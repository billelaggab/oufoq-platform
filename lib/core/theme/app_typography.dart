import 'package:flutter/material.dart';

/// نظام الطباعة المعتمد حصرياً على خط Tajawal.
///
/// قاعدة ذهبية: letterSpacing = 0.0 دائماً لمنع تفكك الحروف العربية.
abstract final class AppTypography {
  const AppTypography._();

  static const String fontFamily = 'Tajawal';

  static TextTheme textTheme(Color textPrimary, Color textSecondary) {
    return TextTheme(
      headlineLarge: TextStyle(
        fontFamily: fontFamily,
        fontSize: 24,
        fontWeight: FontWeight.w800,
        height: 1.35,
        letterSpacing: 0.0,
        color: textPrimary,
      ),
      headlineMedium: TextStyle(
        fontFamily: fontFamily,
        fontSize: 20,
        fontWeight: FontWeight.w700,
        height: 1.35,
        letterSpacing: 0.0,
        color: textPrimary,
      ),
      titleLarge: TextStyle(
        fontFamily: fontFamily,
        fontSize: 18,
        fontWeight: FontWeight.w700,
        height: 1.40,
        letterSpacing: 0.0,
        color: textPrimary,
      ),
      titleMedium: TextStyle(
        fontFamily: fontFamily,
        fontSize: 16,
        fontWeight: FontWeight.w700,
        height: 1.40,
        letterSpacing: 0.0,
        color: textPrimary,
      ),
      bodyLarge: TextStyle(
        fontFamily: fontFamily,
        fontSize: 17,
        fontWeight: FontWeight.w400,
        height: 1.70,
        letterSpacing: 0.0,
        color: textPrimary,
      ),
      bodyMedium: TextStyle(
        fontFamily: fontFamily,
        fontSize: 14,
        fontWeight: FontWeight.w400,
        height: 1.55,
        letterSpacing: 0.0,
        color: textSecondary,
      ),
      labelLarge: TextStyle(
        fontFamily: fontFamily,
        fontSize: 14,
        fontWeight: FontWeight.w500,
        height: 1.20,
        letterSpacing: 0.0,
        color: textPrimary,
      ),
      labelSmall: TextStyle(
        fontFamily: fontFamily,
        fontSize: 12,
        fontWeight: FontWeight.w500,
        height: 1.20,
        letterSpacing: 0.0,
        color: textSecondary,
      ),
    );
  }
}
