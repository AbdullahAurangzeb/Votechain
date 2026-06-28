import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_radius.dart';
import '../../theme/app_spacing.dart';

/// Ghost / link-style text button — Stitch secondary auth links.
class VoteChainTextButton extends StatelessWidget {
  const VoteChainTextButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.expanded = false,
  });

  final String label;
  final VoidCallback onPressed;
  final IconData? icon;
  final bool expanded;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    final child = TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        foregroundColor: AppColors.brandSecondary,
        minimumSize: Size(
          expanded ? double.infinity : 0,
          AppSpacing.touchTargetMin,
        ),
        shape: const RoundedRectangleBorder(
          borderRadius: AppRadius.buttonBorder,
        ),
        textStyle: textTheme.labelLarge?.copyWith(
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
