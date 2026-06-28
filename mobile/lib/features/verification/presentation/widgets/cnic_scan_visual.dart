import 'package:flutter/material.dart';

import '../../../../theme/app_colors.dart';
import '../../domain/entities/verification_phase.dart';
import '../../../../theme/app_radius.dart';
import '../../../../theme/app_spacing.dart';

/// CNIC card mockup with animated laser scan — Stitch AI scanning visual.
class CnicScanVisual extends StatefulWidget {
  const CnicScanVisual({super.key, this.progress = 0.68});

  final double progress;

  @override
  State<CnicScanVisual> createState() => _CnicScanVisualState();
}

class _CnicScanVisualState extends State<CnicScanVisual>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final percent = (widget.progress * 100).round();
    const visualSize = 280.0;
    const ringSize = 220.0;

    return SizedBox(
      width: visualSize,
      height: visualSize,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: const Size(visualSize, visualSize),
            painter: _GlowPainter(),
          ),
          Positioned(
            top: visualSize * 0.26,
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return CustomPaint(
                  size: const Size(180, 110),
                  painter: _CnicCardPainter(laserY: _controller.value),
                );
              },
            ),
          ),
          SizedBox(
            width: ringSize,
            height: ringSize,
            child: CircularProgressIndicator(
              value: widget.progress,
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
                  'PROCESSING',
                  textAlign: TextAlign.center,
                  style: textTheme.labelMedium?.copyWith(
                    color: AppColors.onSurfaceVariant,
                    letterSpacing: 2,
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

class _GlowPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final paint = Paint()
      ..shader = RadialGradient(
        colors: [
          AppColors.brandPrimary.withValues(alpha: 0.15),
          AppColors.brandPrimary.withValues(alpha: 0),
        ],
      ).createShader(Rect.fromCircle(center: center, radius: 140));
    canvas.drawCircle(center, 140, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _CnicCardPainter extends CustomPainter {
  _CnicCardPainter({required this.laserY});

  final double laserY;

  @override
  void paint(Canvas canvas, Size size) {
    final cardRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(10, 0, size.width - 20, size.height),
      AppRadius.defaultBorder.topLeft,
    );

    canvas.drawRRect(
      cardRect,
      Paint()..color = AppColors.surfaceContainerHigh,
    );
    canvas.drawRRect(
      cardRect,
      Paint()
        ..color = AppColors.outlineVariant
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );

    final photoRect = RRect.fromRectAndRadius(
      const Rect.fromLTWH(30, 35, 40, 50),
      const Radius.circular(4),
    );
    canvas.drawRRect(photoRect, Paint()..color = AppColors.surfaceBright);

    for (var i = 0; i < 3; i++) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(85, 40 + i * 18.0, 100 - i * 10.0, 8),
          const Radius.circular(4),
        ),
        Paint()..color = AppColors.surfaceBright,
      );
    }

    final laserTop = laserY * (size.height - 4);
    canvas.drawRect(
      Rect.fromLTWH(0, laserTop, size.width, 2),
      Paint()..color = AppColors.brandPrimary,
    );
    canvas.drawRect(
      Rect.fromLTWH(0, laserTop - 20, size.width, 20),
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.brandPrimary.withValues(alpha: 0),
            AppColors.brandPrimary.withValues(alpha: 0.35),
          ],
        ).createShader(Rect.fromLTWH(0, laserTop - 20, size.width, 20)),
    );
  }

  @override
  bool shouldRepaint(covariant _CnicCardPainter oldDelegate) =>
      oldDelegate.laserY != laserY;
}

/// Bento-style scan step card for AI scanning screen.
class ScanStepCard extends StatelessWidget {
  const ScanStepCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.isComplete,
    required this.isActive,
    this.isPending = false,
  });

  final String title;
  final String subtitle;
  final bool isComplete;
  final bool isActive;
  final bool isPending;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final opacity = isPending ? 0.5 : 1.0;

    return Opacity(
      opacity: opacity,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md + AppSpacing.xs),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainer.withValues(alpha: 0.7),
          borderRadius: AppRadius.cardBorder,
          border: Border(
            left: BorderSide(
              color: isComplete || isActive
                  ? AppColors.primaryDisplay
                  : AppColors.outlineVariant,
              width: 4,
            ),
          ),
        ),
        child: Row(
          children: [
            _StepBadge(isComplete: isComplete, isActive: isActive),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: textTheme.labelLarge?.copyWith(
                      color: isActive
                          ? AppColors.primaryDisplay
                          : AppColors.onSurface,
                      fontWeight: isActive ? FontWeight.w700 : FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    subtitle,
                    style: textTheme.bodySmall?.copyWith(
                      color: isActive
                          ? AppColors.onSurfaceVariant
                          : AppColors.primaryDisplay.withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StepBadge extends StatelessWidget {
  const _StepBadge({required this.isComplete, required this.isActive});

  final bool isComplete;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    if (isComplete) {
      return Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppColors.primaryDisplay.withValues(alpha: 0.2),
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.check_circle,
          color: AppColors.primaryDisplay,
          size: 22,
        ),
      );
    }
    if (isActive) {
      return Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppColors.primaryContainer.withValues(alpha: 0.2),
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Container(
            width: 12,
            height: 12,
            decoration: const BoxDecoration(
              color: AppColors.primaryDisplay,
              shape: BoxShape.circle,
            ),
          ),
        ),
      );
    }
    return Container(
      width: 40,
      height: 40,
      decoration: const BoxDecoration(
        color: AppColors.surfaceContainerHighest,
        shape: BoxShape.circle,
      ),
      child: const Icon(
        Icons.radio_button_unchecked,
        color: AppColors.onSurfaceVariant,
        size: 22,
      ),
    );
  }
}

double scanProgressForStep(ScanPipelineStep step) {
  switch (step) {
    case ScanPipelineStep.uploadComplete:
      return 0.25;
    case ScanPipelineStep.detectingDocument:
      return 0.45;
    case ScanPipelineStep.extractingInformation:
      return 0.68;
    case ScanPipelineStep.faceVerification:
      return 1.0;
  }
}
