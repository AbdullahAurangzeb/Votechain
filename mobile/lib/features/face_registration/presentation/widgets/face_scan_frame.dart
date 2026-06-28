import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../../theme/app_colors.dart';
import '../../../../theme/app_radius.dart';
import '../../../../theme/app_spacing.dart';

/// Oval face scan frame with placeholder preview — mock camera.
class FaceScanFrame extends StatelessWidget {
  const FaceScanFrame({
    super.key,
    required this.imageUrl,
    this.isCaptured = false,
    this.isAligned = false,
    this.onTap,
    this.showLiveBadge = false,
    this.label = 'Live Preview',
  });

  final String imageUrl;
  final bool isCaptured;
  final bool isAligned;
  final VoidCallback? onTap;
  final bool showLiveBadge;
  final String label;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 240,
              height: 300,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(120),
                border: Border.all(
                  color: isAligned || isCaptured
                      ? AppColors.primaryDisplay
                      : AppColors.brandSecondary.withValues(alpha: 0.6),
                  width: 3,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryDisplay.withValues(
                      alpha: isAligned ? 0.25 : 0.1,
                    ),
                    blurRadius: 24,
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(117),
                child: Material(
                  color: AppColors.surfaceContainer,
                  child: InkWell(
                    onTap: onTap,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        CachedNetworkImage(
                          imageUrl: imageUrl,
                          fit: BoxFit.cover,
                          placeholder: (_, __) => ColoredBox(
                            color: AppColors.surfaceContainerHigh,
                            child: Icon(
                              Icons.face_outlined,
                              size: 72,
                              color: AppColors.onSurfaceVariant.withValues(
                                alpha: 0.5,
                              ),
                            ),
                          ),
                          errorWidget: (_, __, ___) => ColoredBox(
                            color: AppColors.surfaceContainerHigh,
                            child: Icon(
                              Icons.face_outlined,
                              size: 72,
                              color: AppColors.onSurfaceVariant.withValues(
                                alpha: 0.5,
                              ),
                            ),
                          ),
                        ),
                        if (!isCaptured)
                          Center(
                            child: Icon(
                              Icons.visibility_outlined,
                              size: 40,
                              color: AppColors.onSurface.withValues(alpha: 0.35),
                            ),
                          ),
                        CustomPaint(painter: _CornerBracketPainter()),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            if (showLiveBadge)
              Positioned(
                top: AppSpacing.md,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.xs,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.errorContainer.withValues(alpha: 0.9),
                    borderRadius: AppRadius.pillBorder,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: AppColors.error,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Text(
                        'Live Link Active',
                        style: textTheme.labelMedium?.copyWith(
                          color: AppColors.onPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          label,
          style: textTheme.labelLarge?.copyWith(
            color: AppColors.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _CornerBracketPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.primaryDisplay.withValues(alpha: 0.7)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    const inset = 24.0;
    const len = 28.0;

    canvas.drawLine(
      Offset(inset, inset + len),
      Offset(inset, inset),
      paint,
    );
    canvas.drawLine(
      Offset(inset, inset),
      Offset(inset + len, inset),
      paint,
    );

    canvas.drawLine(
      Offset(size.width - inset - len, inset),
      Offset(size.width - inset, inset),
      paint,
    );
    canvas.drawLine(
      Offset(size.width - inset, inset),
      Offset(size.width - inset, inset + len),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
