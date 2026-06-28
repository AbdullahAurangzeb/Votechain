import 'package:flutter/material.dart';

import '../../../../theme/app_colors.dart';
import '../../../../theme/app_spacing.dart';
import '../../domain/entities/verification_phase.dart';

/// Scan pipeline step row on AI scanning screen.
class ScanPipelineStepTile extends StatelessWidget {
  const ScanPipelineStepTile({
    super.key,
    required this.step,
    required this.activeStep,
    required this.title,
    this.subtitle,
  });

  final ScanPipelineStep step;
  final ScanPipelineStep activeStep;
  final String title;
  final String? subtitle;

  bool get _isComplete => step.index < activeStep.index;
  bool get _isActive => step == activeStep;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _StepIcon(isComplete: _isComplete, isActive: _isActive),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: AppSpacing.xs),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: textTheme.labelLarge?.copyWith(
                    color: _isActive || _isComplete
                        ? (_isActive
                            ? AppColors.primaryDisplay
                            : AppColors.onSurface)
                        : AppColors.onSurfaceVariant,
                    fontWeight: _isActive ? FontWeight.w700 : FontWeight.w600,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    subtitle!,
                    style: textTheme.bodySmall?.copyWith(
                      color: _isActive
                          ? AppColors.onSurfaceVariant
                          : AppColors.textSecondary,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _StepIcon extends StatelessWidget {
  const _StepIcon({required this.isComplete, required this.isActive});

  final bool isComplete;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    if (isComplete) {
      return CircleAvatar(
        radius: 14,
        backgroundColor: AppColors.primaryDisplay,
        child: const Icon(Icons.check, size: 16, color: AppColors.onPrimary),
      );
    }
    if (isActive) {
      return SizedBox(
        width: 28,
        height: 28,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: AppColors.primaryDisplay,
        ),
      );
    }
    return const Icon(
      Icons.radio_button_unchecked,
      color: AppColors.onSurfaceVariant,
      size: 28,
    );
  }
}
