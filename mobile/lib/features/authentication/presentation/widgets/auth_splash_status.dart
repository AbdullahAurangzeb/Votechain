import 'package:flutter/material.dart';

import '../../../../theme/app_colors.dart';
import '../../../../theme/app_spacing.dart';

/// Splash loading dots + status label — "Establishing Secure Link".
class AuthSplashStatusIndicator extends StatelessWidget {
  const AuthSplashStatusIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: List.generate(3, (index) {
            return Padding(
              padding: EdgeInsets.only(right: index == 2 ? 0 : AppSpacing.xs),
              child: Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: AppColors.primaryDisplay.withValues(
                    alpha: index == 1 ? 0.4 : 0.2,
                  ),
                  shape: BoxShape.circle,
                ),
              ),
            );
          }),
        ),
        const SizedBox(width: AppSpacing.sm + AppSpacing.xs),
        Text(
          'ESTABLISHING SECURE LINK',
          style: textTheme.labelMedium?.copyWith(
            color: AppColors.textSecondary.withValues(alpha: 0.6),
            letterSpacing: 2,
          ),
        ),
      ],
    );
  }
}
