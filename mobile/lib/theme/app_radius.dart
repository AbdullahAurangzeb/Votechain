import 'package:flutter/material.dart';

/// VoteChain border-radius tokens from [docs/STITCH_ANALYSIS.md].
///
/// Resolved values: buttons 14px, inputs 12px, cards 16px.
abstract final class AppRadius {
  static const double sm = 4;
  static const double defaultRadius = 8;
  static const double input = 12;
  static const double button = 14;
  static const double lg = 16;
  static const double xl = 24;
  static const double full = 9999;

  static const BorderRadius smBorder = BorderRadius.all(Radius.circular(sm));
  static const BorderRadius defaultBorder =
      BorderRadius.all(Radius.circular(defaultRadius));
  static const BorderRadius inputBorder =
      BorderRadius.all(Radius.circular(input));
  static const BorderRadius buttonBorder =
      BorderRadius.all(Radius.circular(button));
  static const BorderRadius cardBorder = BorderRadius.all(Radius.circular(lg));
  static const BorderRadius modalBorder = BorderRadius.all(Radius.circular(xl));
  static const BorderRadius sheetTopBorder = BorderRadius.vertical(
    top: Radius.circular(xl),
  );
  static const BorderRadius badgeBorder =
      BorderRadius.all(Radius.circular(defaultRadius));
  static const BorderRadius pillBorder =
      BorderRadius.all(Radius.circular(full));
}
