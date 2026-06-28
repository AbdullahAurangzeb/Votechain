// Stitch: Verification Pending (a0546a4c)

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../theme/app_colors.dart';
import '../../../../theme/app_icons.dart';
import '../../../../theme/app_radius.dart';
import '../../../../theme/app_spacing.dart';
import '../../../../widgets/votechain_primary_button.dart';
import '../../../../widgets/votechain_secondary_button.dart';
import '../../../../widgets/votechain_surface_card.dart';
import '../../../authentication/presentation/auth_routes.dart';
import '../../../../shared/widgets/votechain_page_header.dart';
import '../../data/verification_assets.dart';
import '../widgets/verification_timeline.dart';

/// Admin review pending state after identity submission (mock).
class VerificationPendingPage extends ConsumerWidget {
  const VerificationPendingPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: AppColors.surfaceContainerLowest,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.screenHorizontal,
            vertical: AppSpacing.xl,
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Column(
                children: [
                  ClipRRect(
                    borderRadius: AppRadius.cardBorder,
                    child: CachedNetworkImage(
                      imageUrl: VerificationAssets.pendingHero,
                      height: 180,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      placeholder: (_, __) => Container(
                        height: 180,
                        color: AppColors.surfaceContainer,
                      ),
                      errorWidget: (_, __, ___) => Container(
                        height: 180,
                        color: AppColors.surfaceContainer,
                        child: const Icon(
                          AppIcons.checkCircleFilled,
                          color: AppColors.primaryDisplay,
                          size: 48,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  VoteChainPageHeader(
                    title: 'Verification Submitted Successfully',
                    subtitle:
                        'Your identity documents have been received. An administrator will review your submission before you can access the voting platform.',
                    maxSubtitleWidth: double.infinity,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg,
                      vertical: AppSpacing.sm,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primaryDisplay.withValues(alpha: 0.1),
                      borderRadius: AppRadius.pillBorder,
                      border: Border.all(
                        color: AppColors.primaryDisplay.withValues(alpha: 0.2),
                      ),
                    ),
                    child: Text(
                      'Within 24 Hours',
                      style: textTheme.labelLarge?.copyWith(
                        color: AppColors.primaryDisplay,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  VoteChainSurfaceCard(
                    child: const VerificationTimeline(),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  VoteChainPrimaryButton(
                    label: 'Return to Login',
                    onPressed: () => context.go(AuthRoutes.login),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  VoteChainSecondaryButton(
                    label: 'Contact Support',
                    icon: AppIcons.mail,
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Support: support@votechain.app (mock)',
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: AppSpacing.lg),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
