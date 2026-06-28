import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';

/// Multi-step progress header — Stitch "Step N of M" pattern.
class VoteChainStepIndicator extends StatelessWidget {
  const VoteChainStepIndicator({
    super.key,
    required this.currentStep,
    required this.totalSteps,
    required this.stepLabel,
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
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              'STEP $currentStep OF $totalSteps'.toUpperCase(),
              style: textTheme.labelMedium?.copyWith(
                color: AppColors.primaryDisplay,
                letterSpacing: 1.2,
              ),
            ),
            Text(
              stepLabel,
              style: textTheme.labelLarge,
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

/// Backward-compatible alias for registration step indicator.
typedef AuthStepIndicator = VoteChainStepIndicator;
