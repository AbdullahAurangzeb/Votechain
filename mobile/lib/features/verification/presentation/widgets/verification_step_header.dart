import 'package:flutter/material.dart';

import '../../../../theme/app_colors.dart';
import '../../../../theme/app_radius.dart';
import '../../../../theme/app_spacing.dart';

/// Step 2 of 4 progress header for identity verification.
class VerificationStepHeader extends StatelessWidget {
  const VerificationStepHeader({
    super.key,
    this.currentStep = 2,
    this.totalSteps = 4,
    this.stepLabel = 'Identity Verification',
  });

  final int currentStep;
  final int totalSteps;
  final String stepLabel;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final progress = currentStep / totalSteps;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm + AppSpacing.xs,
                vertical: AppSpacing.xs,
              ),
              decoration: BoxDecoration(
                color: AppColors.primaryDisplay.withValues(alpha: 0.1),
                borderRadius: AppRadius.pillBorder,
                border: Border.all(
                  color: AppColors.primaryDisplay.withValues(alpha: 0.2),
                ),
              ),
              child: Text(
                'STEP $currentStep OF $totalSteps'.toUpperCase(),
                style: textTheme.labelMedium?.copyWith(
                  color: AppColors.primaryDisplay,
                  letterSpacing: 1,
                ),
              ),
            ),
            Text(
              stepLabel,
              style: textTheme.labelMedium?.copyWith(
                color: AppColors.onSurfaceVariant,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm + AppSpacing.xs),
        ClipRRect(
          borderRadius: BorderRadius.circular(AppSpacing.xs),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 4,
            backgroundColor: AppColors.surfaceVariant,
            valueColor: const AlwaysStoppedAnimation<Color>(
              AppColors.primaryDisplay,
            ),
          ),
        ),
      ],
    );
  }
}
