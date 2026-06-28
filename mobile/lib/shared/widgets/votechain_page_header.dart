import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_icons.dart';
import '../../theme/app_spacing.dart';

/// Centered screen title + subtitle block — auth and onboarding headers.
class VoteChainPageHeader extends StatelessWidget {
  const VoteChainPageHeader({
    super.key,
    required this.title,
    required this.subtitle,
    this.titleColor,
    this.maxSubtitleWidth = 320,
  });

  final String title;
  final String subtitle;
  final Color? titleColor;
  final double maxSubtitleWidth;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      children: [
        Text(
          title,
          textAlign: TextAlign.center,
          style: textTheme.displayMedium?.copyWith(
            color: titleColor ?? AppColors.onSurface,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxSubtitleWidth),
          child: Text(
            subtitle,
            textAlign: TextAlign.center,
            style: textTheme.bodyMedium?.copyWith(
              color: AppColors.onSurfaceVariant,
            ),
          ),
        ),
      ],
    );
  }
}

/// VoteChain top bar with optional back action and brand lockup.
class VoteChainAppBar extends StatelessWidget implements PreferredSizeWidget {
  const VoteChainAppBar({
    super.key,
    this.showBack = false,
    this.onBack,
    this.centerTitle = 'VoteChain',
    this.showBrand = false,
  });

  final bool showBack;
  final VoidCallback? onBack;
  final String centerTitle;
  final bool showBrand;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return AppBar(
      backgroundColor: showBrand
          ? AppColors.surfaceContainerLow.withValues(alpha: 0.8)
          : AppColors.surfaceContainerLowest,
      surfaceTintColor: Colors.transparent,
      leading: showBack
          ? IconButton(
              icon: const Icon(AppIcons.arrowBack),
              onPressed: onBack ?? () => Navigator.of(context).maybePop(),
            )
          : const SizedBox(width: AppSpacing.touchTargetMin),
      title: showBrand
          ? Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(AppIcons.shield, color: AppColors.primaryDisplay),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  'VoteChain',
                  style: textTheme.headlineMedium?.copyWith(
                    color: AppColors.primaryDisplay,
                  ),
                ),
              ],
            )
          : Text(
              centerTitle,
              style: textTheme.headlineSmall,
            ),
      centerTitle: true,
      actions: const [
        SizedBox(width: AppSpacing.touchTargetMin),
      ],
    );
  }
}

/// Backward-compatible aliases for authentication screens.
typedef AuthHeader = VoteChainPageHeader;
typedef AuthTopBar = VoteChainAppBar;
