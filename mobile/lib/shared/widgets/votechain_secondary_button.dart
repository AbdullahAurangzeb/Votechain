import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_radius.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';

/// Outlined secondary action button — Stitch blue border style.
class VoteChainSecondaryButton extends StatelessWidget {
  const VoteChainSecondaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.expanded = true,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool expanded;

  @override
  Widget build(BuildContext context) {
    final child = OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.brandSecondary,
        minimumSize: Size(
          expanded ? double.infinity : 0,
          AppSpacing.touchTargetMin + AppSpacing.xs,
        ),
        side: const BorderSide(color: AppColors.brandSecondary, width: 2),
        shape: const RoundedRectangleBorder(
          borderRadius: AppRadius.buttonBorder,
        ),
        textStyle: AppTypography.buttonLabel.copyWith(
          color: AppColors.brandSecondary,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: expanded ? MainAxisSize.max : MainAxisSize.min,
        children: [
          Text(label),
          if (icon != null) ...[
            const SizedBox(width: AppSpacing.sm),
            Icon(icon, size: 20),
          ],
        ],
      ),
    );

    return expanded ? SizedBox(width: double.infinity, child: child) : child;
  }
}
