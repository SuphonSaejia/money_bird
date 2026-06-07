import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

/// Typography built on Google Fonts "Prompt" (a Thai + Latin family, so it
/// renders both languages with one consistent voice).
class AppTextStyles {
  AppTextStyles._();

  /// Builds a Prompt-based [TextTheme] tinted for the given text colours.
  static TextTheme textTheme({
    required Color primary,
    required Color secondary,
  }) {
    final base = GoogleFonts.promptTextTheme();
    TextStyle s(double size, FontWeight w, {Color? c, double? h, double? ls}) =>
        GoogleFonts.prompt(
          fontSize: size,
          fontWeight: w,
          color: c ?? primary,
          height: h,
          letterSpacing: ls,
        );

    return base.copyWith(
      displayLarge: s(40, FontWeight.w700, h: 1.1),
      displayMedium: s(34, FontWeight.w700, h: 1.12),
      displaySmall: s(28, FontWeight.w700, h: 1.15),
      headlineLarge: s(26, FontWeight.w600, h: 1.2),
      headlineMedium: s(22, FontWeight.w600, h: 1.2),
      headlineSmall: s(20, FontWeight.w600, h: 1.25),
      titleLarge: s(18, FontWeight.w600),
      titleMedium: s(16, FontWeight.w600),
      titleSmall: s(14, FontWeight.w600),
      bodyLarge: s(16, FontWeight.w400, h: 1.45),
      bodyMedium: s(14, FontWeight.w400, c: secondary, h: 1.45),
      bodySmall: s(12.5, FontWeight.w400, c: secondary, h: 1.4),
      labelLarge: s(15, FontWeight.w600),
      labelMedium: s(13, FontWeight.w500, c: secondary),
      labelSmall: s(11.5, FontWeight.w500, c: secondary, ls: 0.2),
    );
  }

  /// Oversized figure used for hero money amounts (home + share card).
  static TextStyle money(double size,
          {Color color = AppColors.textPrimary, FontWeight w = FontWeight.w700}) =>
      GoogleFonts.prompt(
        fontSize: size,
        fontWeight: w,
        color: color,
        height: 1.05,
        letterSpacing: -0.5,
      );
}
