import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

/// VoteChain typography tokens — Poppins headings, Inter body.
///
/// Stitch scale from [docs/STITCH_ANALYSIS.md]; maps to M3 [TextTheme] roles.
abstract final class AppTypography {
  static TextTheme get textTheme {
    final poppins = GoogleFonts.poppinsTextTheme(
      ThemeData(brightness: Brightness.dark).textTheme,
    );
    final inter = GoogleFonts.interTextTheme(
      ThemeData(brightness: Brightness.dark).textTheme,
    );

    return TextTheme(
      // Poppins — headlines
      displayLarge: poppins.displayLarge?.copyWith(
        fontSize: 40,
        height: 48 / 40,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.8,
        color: AppColors.onSurface,
      ),
      displayMedium: poppins.displayMedium?.copyWith(
        fontSize: 30,
        height: 36 / 30,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.3,
        color: AppColors.onSurface,
      ),
      displaySmall: poppins.displaySmall?.copyWith(
        fontSize: 28,
        height: 36 / 28,
        fontWeight: FontWeight.w600,
        color: AppColors.onSurface,
      ),
      headlineLarge: poppins.headlineLarge?.copyWith(
        fontSize: 28,
        height: 36 / 28,
        fontWeight: FontWeight.w600,
        color: AppColors.onSurface,
      ),
      headlineMedium: poppins.headlineMedium?.copyWith(
        fontSize: 20,
        height: 28 / 20,
        fontWeight: FontWeight.w600,
        color: AppColors.onSurface,
      ),
      headlineSmall: poppins.headlineSmall?.copyWith(
        fontSize: 18,
        height: 24 / 18,
        fontWeight: FontWeight.w500,
        color: AppColors.onSurface,
      ),
      titleLarge: poppins.titleLarge?.copyWith(
        fontSize: 18,
        height: 24 / 18,
        fontWeight: FontWeight.w500,
        color: AppColors.onSurface,
      ),
      titleMedium: poppins.titleMedium?.copyWith(
        fontSize: 16,
        height: 24 / 16,
        fontWeight: FontWeight.w500,
        color: AppColors.onSurface,
      ),
      titleSmall: poppins.titleSmall?.copyWith(
        fontSize: 14,
        height: 20 / 14,
        fontWeight: FontWeight.w500,
        color: AppColors.onSurface,
      ),

      // Inter — body
      bodyLarge: inter.bodyLarge?.copyWith(
        fontSize: 18,
        height: 28 / 18,
        fontWeight: FontWeight.w400,
        color: AppColors.onSurface,
      ),
      bodyMedium: inter.bodyMedium?.copyWith(
        fontSize: 16,
        height: 24 / 16,
        fontWeight: FontWeight.w400,
        color: AppColors.onSurface,
      ),
      bodySmall: inter.bodySmall?.copyWith(
        fontSize: 14,
        height: 20 / 14,
        fontWeight: FontWeight.w400,
        color: AppColors.onSurface,
      ),

      // Inter — labels
      labelLarge: inter.labelLarge?.copyWith(
        fontSize: 14,
        height: 20 / 14,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.1,
        color: AppColors.onSurface,
      ),
      labelMedium: inter.labelMedium?.copyWith(
        fontSize: 12,
        height: 16 / 12,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.5,
        color: AppColors.onSurfaceVariant,
      ),
      labelSmall: inter.labelSmall?.copyWith(
        fontSize: 11,
        height: 16 / 11,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.5,
        color: AppColors.textSecondary,
      ),
    );
  }

  /// Status badges — label-md, all-caps (apply `.toUpperCase()` at call site).
  static TextStyle get statusBadge => GoogleFonts.inter(
        fontSize: 12,
        height: 16 / 12,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.5,
      );

  /// Transaction hashes and receipt IDs — monospace Inter.
  static TextStyle get transactionHash => GoogleFonts.inter(
        fontSize: 12,
        height: 16 / 12,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.25,
        fontFeatures: const [FontFeature.tabularFigures()],
      ).copyWith(
        fontFamilyFallback: const ['monospace'],
      );

  /// Button label — label-lg on primary buttons.
  static TextStyle get buttonLabel => GoogleFonts.inter(
        fontSize: 14,
        height: 20 / 14,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.1,
        color: AppColors.onPrimary,
      );
}
