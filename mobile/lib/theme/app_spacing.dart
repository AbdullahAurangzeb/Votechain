/// VoteChain spacing tokens — 4px base grid from [docs/STITCH_ANALYSIS.md].
///
/// Widgets must reference [AppSpacing] constants, never literal numbers.
abstract final class AppSpacing {
  /// Base grid unit (4px).
  static const double unit = 4;

  static const double xs = unit;
  static const double sm = unit * 2;
  static const double md = unit * 4;
  static const double lg = unit * 6;
  static const double xl = unit * 8;
  static const double xxl = unit * 12;

  /// Section gutter (24px).
  static const double gutter = lg;

  /// Horizontal screen padding on mobile (16px).
  static const double screenHorizontal = md;

  /// Horizontal screen padding on tablet/desktop admin (64px).
  static const double screenHorizontalDesktop = unit * 16;

  /// Internal card padding minimum (16px).
  static const double cardPaddingMin = md;

  /// Internal card padding maximum (20px).
  static const double cardPaddingMax = 20;

  /// Minimum touch target height (48dp).
  static const double touchTargetMin = 48;

  /// Max content width for wide layouts (1200px).
  static const double maxContentWidth = 1200;

  /// Empty-state illustration height (128dp).
  static const double emptyStateIllustrationHeight = 128;

  /// Icon-to-text gap (4px).
  static const double iconTextGap = xs;

  /// Status badge horizontal padding (8px).
  static const double badgePaddingHorizontal = sm;

  /// Status badge vertical padding (4px).
  static const double badgePaddingVertical = xs;
}
