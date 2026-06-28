import 'package:flutter/material.dart';

import '../../../../theme/app_colors.dart';
import '../../../../theme/app_spacing.dart';

/// Admin approval timeline on verification pending screen.
class VerificationTimeline extends StatelessWidget {
  const VerificationTimeline({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      children: [
        _TimelineItem(
          title: 'Personal Information',
          subtitle: 'Completed',
          isComplete: true,
          showLine: true,
          textTheme: textTheme,
        ),
        _TimelineItem(
          title: 'OCR Verification',
          subtitle: 'Completed',
          isComplete: true,
          showLine: true,
          textTheme: textTheme,
        ),
        _TimelineItem(
          title: 'Face Registration',
          subtitle: 'Completed',
          isComplete: true,
          showLine: true,
          textTheme: textTheme,
        ),
        _TimelineItem(
          title: 'Waiting for Admin Approval',
          subtitle: 'Our agents are validating your data integrity',
          isComplete: false,
          isPending: true,
          showLine: false,
          textTheme: textTheme,
        ),
      ],
    );
  }
}

class _TimelineItem extends StatelessWidget {
  const _TimelineItem({
    required this.title,
    required this.subtitle,
    required this.isComplete,
    required this.showLine,
    required this.textTheme,
    this.isPending = false,
  });

  final String title;
  final String subtitle;
  final bool isComplete;
  final bool isPending;
  final bool showLine;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              if (isComplete)
                CircleAvatar(
                  radius: 12,
                  backgroundColor: AppColors.primaryDisplay,
                  child: const Icon(
                    Icons.check,
                    size: 14,
                    color: AppColors.onPrimary,
                  ),
                )
              else
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.surfaceContainerHighest,
                    border: Border.all(color: AppColors.primaryDisplay, width: 2),
                  ),
                  child: Center(
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: AppColors.primaryDisplay,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ),
              if (showLine)
                Expanded(
                  child: Container(
                    width: 2,
                    margin: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
                    color: isComplete
                        ? AppColors.primaryDisplay
                        : AppColors.outlineVariant,
                  ),
                ),
            ],
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: showLine ? AppSpacing.lg : 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: textTheme.labelLarge?.copyWith(
                      color: isPending
                          ? AppColors.onSurface
                          : AppColors.primaryDisplay,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    subtitle,
                    style: textTheme.bodySmall?.copyWith(
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
