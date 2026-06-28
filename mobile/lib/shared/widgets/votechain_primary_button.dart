import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_radius.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';

/// Full-width primary action button with optional loading state.
class VoteChainPrimaryButton extends StatelessWidget {
  const VoteChainPrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.isLoading = false,
    this.loadingLabel,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isLoading;
  final String? loadingLabel;

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null && !isLoading;

    return SizedBox(
      width: double.infinity,
      height: AppSpacing.touchTargetMin + AppSpacing.xs,
      child: ElevatedButton(
        onPressed: enabled ? onPressed : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryContainer,
          foregroundColor: AppColors.onPrimaryContainer,
          disabledBackgroundColor:
              AppColors.primaryContainer.withValues(alpha: 0.5),
          disabledForegroundColor:
              AppColors.onPrimaryContainer.withValues(alpha: 0.5),
          elevation: 0,
          shadowColor: AppColors.primaryContainer.withValues(alpha: 0.2),
          shape: const RoundedRectangleBorder(
            borderRadius: AppRadius.buttonBorder,
          ),
          textStyle: AppTypography.buttonLabel.copyWith(
            color: AppColors.onPrimaryContainer,
          ),
        ),
        child: isLoading
            ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.onPrimaryContainer.withValues(
                        alpha: 0.9,
                      ),
                    ),
                  ),
                  if (loadingLabel != null) ...[
                    const SizedBox(width: AppSpacing.sm),
                    Text(loadingLabel!),
                  ],
                ],
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(label),
                  if (icon != null) ...[
                    const SizedBox(width: AppSpacing.sm),
                    Icon(icon, size: 20),
                  ],
                ],
              ),
      ),
    );
  }
}

/// Alias for primary buttons that show a loading indicator while submitting.
typedef VoteChainLoadingButton = VoteChainPrimaryButton;
