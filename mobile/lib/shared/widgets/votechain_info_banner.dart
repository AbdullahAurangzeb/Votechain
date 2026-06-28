import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_icons.dart';
import '../../theme/app_radius.dart';
import '../../theme/app_spacing.dart';

/// Info callout banner with icon — registration and form hints.
class VoteChainInfoBanner extends StatelessWidget {
  const VoteChainInfoBanner({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm + AppSpacing.xs),
      decoration: BoxDecoration(
        color: AppColors.brandTertiary.withValues(alpha: 0.05),
        borderRadius: AppRadius.defaultBorder,
        border: Border.all(
          color: AppColors.brandTertiary.withValues(alpha: 0.1),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            AppIcons.info,
            color: AppColors.brandTertiary,
            size: AppSpacing.lg,
          ),
          const SizedBox(width: AppSpacing.sm + AppSpacing.xs),
          Expanded(
            child: Text(
              message,
              style: textTheme.bodySmall?.copyWith(
                color: AppColors.onSurfaceVariant,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Backward-compatible alias for registration info banner.
typedef AuthInfoBanner = VoteChainInfoBanner;
