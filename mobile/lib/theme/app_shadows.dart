import 'package:flutter/material.dart';

import 'app_colors.dart';

/// VoteChain elevation and glow tokens — tonal layering over drop shadows.
///
/// Cards use borders (level 1); glows are restricted to active/selected states.
abstract final class AppShadows {
  /// Level 3 — modals and bottom sheets.
  static const List<BoxShadow> modal = [
    BoxShadow(
      color: Color(0x66000000),
      blurRadius: 32,
      offset: Offset(0, 8),
    ),
  ];

  /// Level 2 — selected candidate / active selection (Royal Blue).
  static List<BoxShadow> selectionGlowBlue = [
    BoxShadow(
      color: AppColors.brandSecondary.withValues(alpha: 0.2),
      blurRadius: 15,
      spreadRadius: 0,
    ),
  ];

  /// Active bottom-nav tab — Emerald glow.
  static List<BoxShadow> navActiveGlow = [
    BoxShadow(
      color: AppColors.brandPrimary.withValues(alpha: 0.35),
      blurRadius: 12,
      spreadRadius: 0,
    ),
  ];

  /// Vote confirmation / success — Emerald inner glow.
  static List<BoxShadow> successGlow = [
    BoxShadow(
      color: AppColors.brandPrimary.withValues(alpha: 0.25),
      blurRadius: 16,
      spreadRadius: -2,
    ),
  ];

  /// Blockchain processing — Purple accent pulse.
  static List<BoxShadow> blockchainGlow = [
    BoxShadow(
      color: AppColors.brandTertiary.withValues(alpha: 0.3),
      blurRadius: 16,
      spreadRadius: 0,
    ),
  ];

  /// Flat cards — no shadow; use [AppColors.borderSubtle] border instead.
  static const List<BoxShadow> none = [];
}
