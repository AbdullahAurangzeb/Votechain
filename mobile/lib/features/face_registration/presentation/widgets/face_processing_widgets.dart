import 'package:flutter/material.dart';

import '../../../../theme/app_colors.dart';
import '../../../../theme/app_radius.dart';
import '../../../../theme/app_spacing.dart';
import '../../domain/entities/face_processing_step.dart';

/// AI face processing step row.
class FaceProcessingStepTile extends StatelessWidget {
  const FaceProcessingStepTile({
    super.key,
    required this.step,
    required this.activeStep,
    required this.title,
    this.isFailed = false,
  });

  final FaceProcessingStep step;
  final FaceProcessingStep activeStep;
  final String title;
  final bool isFailed;

  bool get _isComplete => !isFailed && step.index < activeStep.index;
  bool get _isActive => !isFailed && step == activeStep;
  bool get _isFailedStep => isFailed && step == FaceProcessingStep.checkingDuplicate;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Row(
        children: [
          _StepIcon(
            isComplete: _isComplete,
            isActive: _isActive,
            isFailed: _isFailedStep,
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              title,
              style: textTheme.labelLarge?.copyWith(
                color: _isFailedStep
                    ? AppColors.error
                    : _isActive
                        ? AppColors.primaryDisplay
                        : _isComplete
                            ? AppColors.onSurface
                            : AppColors.onSurfaceVariant,
                fontWeight: _isActive ? FontWeight.w700 : FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StepIcon extends StatelessWidget {
  const _StepIcon({
    required this.isComplete,
    required this.isActive,
    required this.isFailed,
  });

  final bool isComplete;
  final bool isActive;
  final bool isFailed;

  @override
  Widget build(BuildContext context) {
    if (isFailed) {
      return const Icon(Icons.error_outline, color: AppColors.error, size: 24);
    }
    if (isComplete) {
      return const Icon(
        Icons.check_circle,
        color: AppColors.primaryDisplay,
        size: 24,
      );
    }
    if (isActive) {
      return SizedBox(
        width: 24,
        height: 24,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: AppColors.primaryDisplay,
        ),
      );
    }
    return Icon(
      Icons.radio_button_unchecked,
      color: AppColors.onSurfaceVariant.withValues(alpha: 0.5),
      size: 24,
    );
  }
}

/// Circular progress ring for AI face processing screen.
class FaceProcessingRing extends StatelessWidget {
  const FaceProcessingRing({super.key, required this.progress});

  final double progress;

  static const double _size = 200;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final percent = (progress * 100).round();

    return SizedBox(
      width: _size,
      height: _size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: _size,
            height: _size,
            child: CircularProgressIndicator(
              value: progress,
              strokeWidth: 8,
              strokeCap: StrokeCap.round,
              backgroundColor: AppColors.surfaceVariant,
              color: AppColors.primaryDisplay,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  '$percent%',
                  textAlign: TextAlign.center,
                  style: textTheme.displaySmall?.copyWith(
                    color: AppColors.primaryDisplay,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'CURRENT PROGRESS',
                  textAlign: TextAlign.center,
                  style: textTheme.labelMedium?.copyWith(
                    color: AppColors.onSurfaceVariant,
                    letterSpacing: 1,
                    height: 1.2,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Privacy shield note on processing screen.
class FacePrivacyNote extends StatelessWidget {
  const FacePrivacyNote({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: AppRadius.cardBorder,
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.shield_outlined, color: AppColors.primaryDisplay),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              'We never store your original image. Only encrypted biometric features are securely stored on the sovereign ledger for identity verification.',
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
