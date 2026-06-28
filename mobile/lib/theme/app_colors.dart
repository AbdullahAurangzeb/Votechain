import 'package:flutter/material.dart';

/// VoteChain color tokens sourced from Google Stitch / [docs/STITCH_ANALYSIS.md].
///
/// All colors are defined here — widgets must never hardcode hex values.
abstract final class AppColors {
  // ── Brand ──────────────────────────────────────────────────────────────
  static const Color brandPrimary = Color(0xFF16A34A);
  static const Color brandSecondary = Color(0xFF2563EB);
  static const Color brandTertiary = Color(0xFF7C3AED);
  static const Color brandNeutral = Color(0xFF0B1120);

  // ── Surfaces (Material 3 tonal scale) ───────────────────────────────────
  static const Color surfaceContainerLowest = Color(0xFF080E1D);
  static const Color surface = Color(0xFF0D1322);
  static const Color surfaceDim = Color(0xFF0D1322);
  static const Color surfaceContainerLow = Color(0xFF151B2B);
  static const Color surfaceContainer = Color(0xFF191F2F);
  static const Color surfaceContainerHigh = Color(0xFF242A3A);
  static const Color surfaceContainerHighest = Color(0xFF2F3445);
  static const Color surfaceBright = Color(0xFF33394A);
  static const Color surfaceVariant = Color(0xFF2F3445);

  // ── Text ─────────────────────────────────────────────────────────────────
  static const Color onSurface = Color(0xFFDDE2F8);
  static const Color onSurfaceVariant = Color(0xFFBDCABA);
  static const Color textSecondary = Color(0xFF94A3B8);
  static const Color onPrimary = Color(0xFFFFFFFF);

  // ── Primary / Secondary / Tertiary (M3 mapped) ───────────────────────────
  static const Color primaryDisplay = Color(0xFF62DF7D);
  static const Color primaryContainer = Color(0xFF1CA64D);
  static const Color onPrimaryContainer = Color(0xFF003111);
  static const Color secondaryContainer = Color(0xFF0053DB);
  static const Color onSecondaryContainer = Color(0xFFCDD7FF);
  static const Color tertiaryContainer = Color(0xFFA476FF);
  static const Color onTertiaryContainer = Color(0xFF36007D);

  // ── Outline & borders ────────────────────────────────────────────────────
  static const Color outline = Color(0xFF879485);
  static const Color outlineVariant = Color(0xFF3E4A3D);
  static const Color borderSubtle = Color(0x1AFFFFFF);

  // ── Semantic ─────────────────────────────────────────────────────────────
  static const Color error = Color(0xFFDC2626);
  static const Color errorText = Color(0xFFFFB4AB);
  static const Color errorContainer = Color(0xFF93000A);
  static const Color onError = Color(0xFFFFFFFF);
  static const Color warning = Color(0xFFF59E0B);
  static const Color success = brandPrimary;
  static const Color disabled = Color(0xFF475569);

  // ── Skeleton / shimmer ───────────────────────────────────────────────────
  static const Color skeletonBase = surfaceContainer;
  static const Color skeletonHighlight = surface;

  /// Material 3 [ColorScheme] for VoteChain dark theme (primary mode).
  static ColorScheme get darkColorScheme => const ColorScheme(
        brightness: Brightness.dark,
        primary: brandPrimary,
        onPrimary: onPrimary,
        primaryContainer: primaryContainer,
        onPrimaryContainer: onPrimaryContainer,
        secondary: brandSecondary,
        onSecondary: onPrimary,
        secondaryContainer: secondaryContainer,
        onSecondaryContainer: onSecondaryContainer,
        tertiary: brandTertiary,
        onTertiary: onPrimary,
        tertiaryContainer: tertiaryContainer,
        onTertiaryContainer: onTertiaryContainer,
        error: error,
        onError: onError,
        errorContainer: errorContainer,
        onErrorContainer: errorText,
        surface: surface,
        onSurface: onSurface,
        onSurfaceVariant: onSurfaceVariant,
        outline: outline,
        outlineVariant: outlineVariant,
        shadow: Colors.black,
        scrim: Colors.black54,
        inverseSurface: onSurface,
        onInverseSurface: surfaceContainerHighest,
        inversePrimary: primaryDisplay,
        surfaceTint: primaryDisplay,
        surfaceContainerHighest: surfaceContainerHighest,
        surfaceContainerHigh: surfaceContainerHigh,
        surfaceContainer: surfaceContainer,
        surfaceContainerLow: surfaceContainerLow,
        surfaceContainerLowest: surfaceContainerLowest,
        surfaceBright: surfaceBright,
        surfaceDim: surfaceDim,
      );
}
