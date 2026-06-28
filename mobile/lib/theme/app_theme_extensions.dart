import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_radius.dart';
import 'app_shadows.dart';
import 'app_spacing.dart';
import 'app_typography.dart';

/// Extended VoteChain surface and semantic colors beyond [ColorScheme].
@immutable
class AppColorsExtension extends ThemeExtension<AppColorsExtension> {
  const AppColorsExtension({
    required this.blockchain,
    required this.textSecondary,
    required this.borderSubtle,
    required this.warning,
    required this.success,
    required this.disabled,
    required this.skeletonBase,
    required this.skeletonHighlight,
    required this.primaryDisplay,
  });

  final Color blockchain;
  final Color textSecondary;
  final Color borderSubtle;
  final Color warning;
  final Color success;
  final Color disabled;
  final Color skeletonBase;
  final Color skeletonHighlight;
  final Color primaryDisplay;

  static AppColorsExtension get dark => const AppColorsExtension(
        blockchain: AppColors.brandTertiary,
        textSecondary: AppColors.textSecondary,
        borderSubtle: AppColors.borderSubtle,
        warning: AppColors.warning,
        success: AppColors.success,
        disabled: AppColors.disabled,
        skeletonBase: AppColors.skeletonBase,
        skeletonHighlight: AppColors.skeletonHighlight,
        primaryDisplay: AppColors.primaryDisplay,
      );

  @override
  AppColorsExtension copyWith({
    Color? blockchain,
    Color? textSecondary,
    Color? borderSubtle,
    Color? warning,
    Color? success,
    Color? disabled,
    Color? skeletonBase,
    Color? skeletonHighlight,
    Color? primaryDisplay,
  }) {
    return AppColorsExtension(
      blockchain: blockchain ?? this.blockchain,
      textSecondary: textSecondary ?? this.textSecondary,
      borderSubtle: borderSubtle ?? this.borderSubtle,
      warning: warning ?? this.warning,
      success: success ?? this.success,
      disabled: disabled ?? this.disabled,
      skeletonBase: skeletonBase ?? this.skeletonBase,
      skeletonHighlight: skeletonHighlight ?? this.skeletonHighlight,
      primaryDisplay: primaryDisplay ?? this.primaryDisplay,
    );
  }

  @override
  AppColorsExtension lerp(AppColorsExtension? other, double t) {
    if (other is! AppColorsExtension) return this;
    return AppColorsExtension(
      blockchain: Color.lerp(blockchain, other.blockchain, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      borderSubtle: Color.lerp(borderSubtle, other.borderSubtle, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      success: Color.lerp(success, other.success, t)!,
      disabled: Color.lerp(disabled, other.disabled, t)!,
      skeletonBase: Color.lerp(skeletonBase, other.skeletonBase, t)!,
      skeletonHighlight:
          Color.lerp(skeletonHighlight, other.skeletonHighlight, t)!,
      primaryDisplay: Color.lerp(primaryDisplay, other.primaryDisplay, t)!,
    );
  }
}

/// VoteChain layout and component dimension tokens via [ThemeExtension].
@immutable
class AppLayoutExtension extends ThemeExtension<AppLayoutExtension> {
  const AppLayoutExtension({
    required this.screenHorizontal,
    required this.gutter,
    required this.cardPadding,
    required this.touchTargetMin,
    required this.borderWidth,
    required this.borderWidthSelected,
    required this.iconSizeDefault,
    required this.backdropBlurSigma,
  });

  final double screenHorizontal;
  final double gutter;
  final double cardPadding;
  final double touchTargetMin;
  final double borderWidth;
  final double borderWidthSelected;
  final double iconSizeDefault;
  final double backdropBlurSigma;

  static AppLayoutExtension get standard => const AppLayoutExtension(
        screenHorizontal: AppSpacing.screenHorizontal,
        gutter: AppSpacing.gutter,
        cardPadding: AppSpacing.cardPaddingMin,
        touchTargetMin: AppSpacing.touchTargetMin,
        borderWidth: 1,
        borderWidthSelected: 2,
        iconSizeDefault: 24,
        backdropBlurSigma: 12,
      );

  @override
  AppLayoutExtension copyWith({
    double? screenHorizontal,
    double? gutter,
    double? cardPadding,
    double? touchTargetMin,
    double? borderWidth,
    double? borderWidthSelected,
    double? iconSizeDefault,
    double? backdropBlurSigma,
  }) {
    return AppLayoutExtension(
      screenHorizontal: screenHorizontal ?? this.screenHorizontal,
      gutter: gutter ?? this.gutter,
      cardPadding: cardPadding ?? this.cardPadding,
      touchTargetMin: touchTargetMin ?? this.touchTargetMin,
      borderWidth: borderWidth ?? this.borderWidth,
      borderWidthSelected: borderWidthSelected ?? this.borderWidthSelected,
      iconSizeDefault: iconSizeDefault ?? this.iconSizeDefault,
      backdropBlurSigma: backdropBlurSigma ?? this.backdropBlurSigma,
    );
  }

  @override
  AppLayoutExtension lerp(AppLayoutExtension? other, double t) {
    if (other is! AppLayoutExtension) return this;
    return AppLayoutExtension(
      screenHorizontal:
          lerpDouble(screenHorizontal, other.screenHorizontal, t)!,
      gutter: lerpDouble(gutter, other.gutter, t)!,
      cardPadding: lerpDouble(cardPadding, other.cardPadding, t)!,
      touchTargetMin: lerpDouble(touchTargetMin, other.touchTargetMin, t)!,
      borderWidth: lerpDouble(borderWidth, other.borderWidth, t)!,
      borderWidthSelected:
          lerpDouble(borderWidthSelected, other.borderWidthSelected, t)!,
      iconSizeDefault: lerpDouble(iconSizeDefault, other.iconSizeDefault, t)!,
      backdropBlurSigma:
          lerpDouble(backdropBlurSigma, other.backdropBlurSigma, t)!,
    );
  }
}

/// VoteChain typography extras beyond [TextTheme].
@immutable
class AppTypographyExtension extends ThemeExtension<AppTypographyExtension> {
  const AppTypographyExtension({
    required this.statusBadge,
    required this.transactionHash,
    required this.buttonLabel,
  });

  final TextStyle statusBadge;
  final TextStyle transactionHash;
  final TextStyle buttonLabel;

  static AppTypographyExtension get dark => AppTypographyExtension(
        statusBadge: AppTypography.statusBadge,
        transactionHash: AppTypography.transactionHash,
        buttonLabel: AppTypography.buttonLabel,
      );

  @override
  AppTypographyExtension copyWith({
    TextStyle? statusBadge,
    TextStyle? transactionHash,
    TextStyle? buttonLabel,
  }) {
    return AppTypographyExtension(
      statusBadge: statusBadge ?? this.statusBadge,
      transactionHash: transactionHash ?? this.transactionHash,
      buttonLabel: buttonLabel ?? this.buttonLabel,
    );
  }

  @override
  AppTypographyExtension lerp(AppTypographyExtension? other, double t) {
    if (other is! AppTypographyExtension) return this;
    return AppTypographyExtension(
      statusBadge: TextStyle.lerp(statusBadge, other.statusBadge, t)!,
      transactionHash:
          TextStyle.lerp(transactionHash, other.transactionHash, t)!,
      buttonLabel: TextStyle.lerp(buttonLabel, other.buttonLabel, t)!,
    );
  }
}

/// VoteChain elevation level presets (border + optional glow).
@immutable
class AppElevationExtension extends ThemeExtension<AppElevationExtension> {
  const AppElevationExtension({
    required this.cardBorderRadius,
    required this.modalShadow,
    required this.selectionGlowBlue,
    required this.navActiveGlow,
    required this.blockchainGlow,
  });

  final BorderRadius cardBorderRadius;
  final List<BoxShadow> modalShadow;
  final List<BoxShadow> selectionGlowBlue;
  final List<BoxShadow> navActiveGlow;
  final List<BoxShadow> blockchainGlow;

  static AppElevationExtension get dark => AppElevationExtension(
        cardBorderRadius: AppRadius.cardBorder,
        modalShadow: AppShadows.modal,
        selectionGlowBlue: AppShadows.selectionGlowBlue,
        navActiveGlow: AppShadows.navActiveGlow,
        blockchainGlow: AppShadows.blockchainGlow,
      );

  @override
  AppElevationExtension copyWith({
    BorderRadius? cardBorderRadius,
    List<BoxShadow>? modalShadow,
    List<BoxShadow>? selectionGlowBlue,
    List<BoxShadow>? navActiveGlow,
    List<BoxShadow>? blockchainGlow,
  }) {
    return AppElevationExtension(
      cardBorderRadius: cardBorderRadius ?? this.cardBorderRadius,
      modalShadow: modalShadow ?? this.modalShadow,
      selectionGlowBlue: selectionGlowBlue ?? this.selectionGlowBlue,
      navActiveGlow: navActiveGlow ?? this.navActiveGlow,
      blockchainGlow: blockchainGlow ?? this.blockchainGlow,
    );
  }

  @override
  AppElevationExtension lerp(AppElevationExtension? other, double t) {
    if (other is! AppElevationExtension) return this;
    return AppElevationExtension(
      cardBorderRadius:
          BorderRadius.lerp(cardBorderRadius, other.cardBorderRadius, t)!,
      modalShadow: t < 0.5 ? modalShadow : other.modalShadow,
      selectionGlowBlue:
          t < 0.5 ? selectionGlowBlue : other.selectionGlowBlue,
      navActiveGlow: t < 0.5 ? navActiveGlow : other.navActiveGlow,
      blockchainGlow: t < 0.5 ? blockchainGlow : other.blockchainGlow,
    );
  }
}

/// Convenience accessors for VoteChain [ThemeExtension]s.
extension VoteChainThemeContext on BuildContext {
  AppColorsExtension get appColors =>
      Theme.of(this).extension<AppColorsExtension>()!;

  AppLayoutExtension get appLayout =>
      Theme.of(this).extension<AppLayoutExtension>()!;

  AppTypographyExtension get appTypography =>
      Theme.of(this).extension<AppTypographyExtension>()!;

  AppElevationExtension get appElevation =>
      Theme.of(this).extension<AppElevationExtension>()!;
}
