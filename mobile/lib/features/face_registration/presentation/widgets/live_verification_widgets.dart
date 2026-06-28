import 'package:flutter/material.dart';

import '../../../../theme/app_colors.dart';
import '../../../../theme/app_radius.dart';
import '../../../../theme/app_spacing.dart';

/// Live verification checklist item.
class LiveVerificationCheckTile extends StatelessWidget {
  const LiveVerificationCheckTile({
    super.key,
    required this.icon,
    required this.label,
    this.isMet = false,
  });

  final IconData icon;
  final String label;
  final bool isMet;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm + AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer.withValues(alpha: 0.6),
        borderRadius: AppRadius.defaultBorder,
        border: Border.all(
          color: isMet
              ? AppColors.primaryDisplay.withValues(alpha: 0.3)
              : AppColors.borderSubtle,
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: isMet ? AppColors.primaryDisplay : AppColors.onSurfaceVariant,
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              label,
              style: textTheme.labelLarge?.copyWith(
                color: isMet ? AppColors.onSurface : AppColors.onSurfaceVariant,
              ),
            ),
          ),
          if (isMet)
            const Icon(
              Icons.check_circle,
              color: AppColors.primaryDisplay,
              size: 18,
            ),
        ],
      ),
    );
  }
}

/// Security feature chip on live verification screen.
class LiveVerificationTrustChip extends StatelessWidget {
  const LiveVerificationTrustChip({
    super.key,
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.sm + AppSpacing.xs),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLow,
          borderRadius: AppRadius.defaultBorder,
          border: Border.all(color: AppColors.borderSubtle),
        ),
        child: Column(
          children: [
            Icon(icon, color: AppColors.primaryDisplay, size: 22),
            const SizedBox(height: AppSpacing.xs),
            Text(
              label,
              textAlign: TextAlign.center,
              style: textTheme.labelMedium,
            ),
          ],
        ),
      ),
    );
  }
}
