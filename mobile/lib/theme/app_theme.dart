import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app_colors.dart';
import 'app_radius.dart';
import 'app_spacing.dart';
import 'app_theme_extensions.dart';
import 'app_typography.dart';

/// VoteChain Material 3 theme assembly — dark mode primary.
///
/// Usage:
/// ```dart
/// MaterialApp(theme: AppTheme.dark, darkTheme: AppTheme.dark);
/// ```
abstract final class AppTheme {
  static ThemeData get dark {
    final colorScheme = AppColors.darkColorScheme;
    final textTheme = AppTypography.textTheme;

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: colorScheme,
      textTheme: textTheme,
      scaffoldBackgroundColor: AppColors.surfaceContainerLowest,
      canvasColor: AppColors.surfaceContainerLowest,
      dividerColor: AppColors.borderSubtle,
      disabledColor: AppColors.disabled.withValues(alpha: 0.5),
      splashColor: AppColors.brandPrimary.withValues(alpha: 0.12),
      highlightColor: AppColors.brandPrimary.withValues(alpha: 0.08),
      extensions: [
        AppColorsExtension.dark,
        AppLayoutExtension.standard,
        AppTypographyExtension.dark,
        AppElevationExtension.dark,
      ],
      appBarTheme: AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.onSurface,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: textTheme.headlineMedium,
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: AppColors.surface,
        selectedItemColor: AppColors.brandPrimary,
        unselectedItemColor: AppColors.textSecondary,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        selectedLabelStyle: textTheme.labelMedium?.copyWith(
          color: AppColors.brandPrimary,
        ),
        unselectedLabelStyle: textTheme.labelMedium?.copyWith(
          color: AppColors.textSecondary,
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.surface,
        indicatorColor: AppColors.brandPrimary.withValues(alpha: 0.15),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return textTheme.labelMedium?.copyWith(
              color: AppColors.brandPrimary,
            );
          }
          return textTheme.labelMedium?.copyWith(
            color: AppColors.textSecondary,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(
              color: AppColors.brandPrimary,
              size: 24,
            );
          }
          return const IconThemeData(
            color: AppColors.textSecondary,
            size: 24,
          );
        }),
      ),
      cardTheme: CardThemeData(
        color: AppColors.surfaceContainer,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.cardBorder,
          side: const BorderSide(
            color: AppColors.borderSubtle,
            width: 1,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm + AppSpacing.xs,
        ),
        border: OutlineInputBorder(
          borderRadius: AppRadius.inputBorder,
          borderSide: const BorderSide(
            color: AppColors.borderSubtle,
            width: 1,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppRadius.inputBorder,
          borderSide: const BorderSide(
            color: AppColors.borderSubtle,
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppRadius.inputBorder,
          borderSide: const BorderSide(
            color: AppColors.brandSecondary,
            width: 1,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: AppRadius.inputBorder,
          borderSide: const BorderSide(
            color: AppColors.error,
            width: 1,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: AppRadius.inputBorder,
          borderSide: const BorderSide(
            color: AppColors.error,
            width: 1,
          ),
        ),
        labelStyle: textTheme.bodySmall?.copyWith(
          color: AppColors.textSecondary,
        ),
        hintStyle: textTheme.bodySmall?.copyWith(
          color: AppColors.textSecondary,
        ),
        errorStyle: textTheme.labelMedium?.copyWith(
          color: AppColors.error,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.brandPrimary,
          foregroundColor: AppColors.onPrimary,
          disabledBackgroundColor:
              AppColors.disabled.withValues(alpha: 0.5),
          disabledForegroundColor:
              AppColors.onPrimary.withValues(alpha: 0.5),
          minimumSize: const Size.fromHeight(AppSpacing.touchTargetMin),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.sm + AppSpacing.xs,
          ),
          shape: const RoundedRectangleBorder(
            borderRadius: AppRadius.buttonBorder,
          ),
          textStyle: AppTypography.buttonLabel,
          elevation: 0,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.brandSecondary,
          minimumSize: const Size.fromHeight(AppSpacing.touchTargetMin),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.sm + AppSpacing.xs,
          ),
          shape: const RoundedRectangleBorder(
            borderRadius: AppRadius.buttonBorder,
          ),
          side: const BorderSide(
            color: AppColors.outline,
            width: 1,
          ),
          textStyle: AppTypography.buttonLabel.copyWith(
            color: AppColors.brandSecondary,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.brandSecondary,
          minimumSize: const Size.fromHeight(AppSpacing.touchTargetMin),
          textStyle: textTheme.labelLarge?.copyWith(
            color: AppColors.brandSecondary,
          ),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.surfaceContainerHigh,
        disabledColor: AppColors.disabled.withValues(alpha: 0.3),
        selectedColor: AppColors.brandPrimary.withValues(alpha: 0.15),
        labelStyle: AppTypography.statusBadge,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.badgePaddingHorizontal,
          vertical: AppSpacing.badgePaddingVertical,
        ),
        shape: const RoundedRectangleBorder(
          borderRadius: AppRadius.badgeBorder,
        ),
        side: BorderSide.none,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.surfaceContainer,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.modalBorder,
          side: const BorderSide(
            color: AppColors.borderSubtle,
            width: 1,
          ),
        ),
        titleTextStyle: textTheme.headlineMedium,
        contentTextStyle: textTheme.bodySmall?.copyWith(
          color: AppColors.onSurfaceVariant,
        ),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.surfaceContainer,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.sheetTopBorder,
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.borderSubtle,
        thickness: 1,
        space: 1,
      ),
      iconTheme: const IconThemeData(
        color: AppColors.textSecondary,
        size: 24,
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.brandTertiary,
        linearTrackColor: AppColors.surfaceContainerHigh,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.surfaceContainerHigh,
        contentTextStyle: textTheme.bodySmall,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.defaultBorder,
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
