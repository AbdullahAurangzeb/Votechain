import 'package:flutter/animation.dart';

/// VoteChain motion tokens from [docs/STITCH_ANALYSIS.md].
///
/// Use with `flutter_animate` or standard Flutter animation widgets.
/// Keep animations subtle — no bouncy or playful curves.
abstract final class AppAnimations {
  // ── Durations ────────────────────────────────────────────────────────────
  static const Duration instant = Duration(milliseconds: 100);
  static const Duration fast = Duration(milliseconds: 150);
  static const Duration normal = Duration(milliseconds: 200);
  static const Duration medium = Duration(milliseconds: 300);
  static const Duration slow = Duration(milliseconds: 400);
  static const Duration celebration = Duration(milliseconds: 800);

  /// Blockchain processing loop — may repeat until tx confirms.
  static const Duration processingLoop = Duration(milliseconds: 1200);

  /// Skeleton shimmer cycle.
  static const Duration shimmer = Duration(milliseconds: 1500);

  // ── Curves ───────────────────────────────────────────────────────────────
  static const Curve standard = Curves.easeInOut;
  static const Curve enter = Curves.easeOut;
  static const Curve exit = Curves.easeIn;
  static const Curve emphasis = Curves.easeOutCubic;

  // ── Semantic aliases ─────────────────────────────────────────────────────
  static const Duration bottomNavTransition = normal;
  static const Duration cardSelection = fast;
  static const Duration cardSelectionMax = slow;
  static const Duration dialogTransition = medium;
  static const Duration splashFade = slow;
  static const Duration successScale = celebration;
  static const Duration ocrScanLoop = medium;
  static const Duration faceScanLoop = medium;
}
