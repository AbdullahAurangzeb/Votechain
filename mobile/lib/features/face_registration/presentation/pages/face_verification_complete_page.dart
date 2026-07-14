// Stitch: Face Registration Complete (ead1a6c3 / identity success)

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../shared/widgets/votechain_page_header.dart';
import '../../../../shared/widgets/votechain_primary_button.dart';
import '../../../../shared/widgets/votechain_secondary_button.dart';
import '../../../../shared/widgets/votechain_surface_card.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_icons.dart';
import '../../../../theme/app_radius.dart';
import '../../../../theme/app_spacing.dart';
import '../../../authentication/domain/entities/auth_user.dart';
import '../../../authentication/presentation/providers/auth_providers.dart';
import '../../../verification/presentation/providers/verification_providers.dart';
import '../../../verification/presentation/verification_routes.dart';
import '../face_registration_routes.dart';
import '../../data/face_registration_assets.dart';
import '../providers/face_registration_providers.dart';

/// Face registration success — proceeds to admin approval pending.
class FaceVerificationCompletePage extends ConsumerWidget {
  const FaceVerificationCompletePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(faceRegistrationFlowControllerProvider);
    final result = state.result;
    final textTheme = Theme.of(context).textTheme;
    final confidence = result?.matchConfidence ?? 0.97;

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
                      imageUrl: FaceRegistrationAssets.completeHero,
                      height: 200,
                      width: double.infinity,
                      fit: BoxFit.contain,
                      placeholder: (_, __) => Container(
                        height: 200,
                        color: AppColors.surfaceContainer,
                        child: const Icon(
                          AppIcons.checkCircleFilled,
                          color: AppColors.primaryDisplay,
                          size: 64,
                        ),
                      ),
                      errorWidget: (_, __, ___) => Container(
                        height: 200,
                        color: AppColors.surfaceContainer,
                        child: const Icon(
                          AppIcons.checkCircleFilled,
                          color: AppColors.primaryDisplay,
                          size: 64,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  VoteChainPageHeader(
                    title: 'Verification Complete',
                    subtitle:
                        'Your face profile has been securely registered. You can now proceed to administrator approval.',
                    maxSubtitleWidth: double.infinity,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  VoteChainSurfaceCard(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              AppIcons.verifiedUser,
                              color: AppColors.primaryDisplay,
                              size: 20,
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            Text('Biometric Match', style: textTheme.labelLarge),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.md,
                            vertical: AppSpacing.xs,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primaryDisplay.withValues(
                              alpha: 0.1,
                            ),
                            borderRadius: AppRadius.pillBorder,
                            border: Border.all(
                              color: AppColors.primaryDisplay.withValues(
                                alpha: 0.2,
                              ),
                            ),
                          ),
                          child: Text(
                            '${(confidence * 100).round()}% Match',
                            style: textTheme.labelLarge?.copyWith(
                              color: AppColors.primaryDisplay,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  if (ref.watch(verificationFlowControllerProvider).errorMessage !=
                      null) ...[
                    Text(
                      ref.watch(verificationFlowControllerProvider).errorMessage!,
                      textAlign: TextAlign.center,
                      style: textTheme.labelMedium?.copyWith(
                        color: AppColors.error,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                  ],
                  VoteChainPrimaryButton(
                    label: 'Continue to Approval',
                    icon: AppIcons.arrowForward,
                    isLoading:
                        ref.watch(verificationFlowControllerProvider).isSubmitting,
                    onPressed: () async {
                      final verificationController = ref.read(
                        verificationFlowControllerProvider.notifier,
                      );
                      final status =
                          await verificationController.submitVerification();
                      if (!context.mounted || status == null) return;

                      final sessionUser = ref.read(authSessionProvider);
                      if (sessionUser != null) {
                        ref.read(authSessionProvider.notifier).setUser(
                              AuthUser(
                                id: sessionUser.id,
                                fullName: sessionUser.fullName,
                                email: sessionUser.email,
                                phone: sessionUser.phone,
                                role: sessionUser.role,
                                approvalStatus: status.approvalStatus,
                                verificationStatus: status.verificationStatus,
                                faceRegistered: status.faceRegistered,
                                cnic: status.cnic,
                              ),
                            );
                      }

                      context.go(VerificationRoutes.pending);
                    },
                  ),
                  const SizedBox(height: AppSpacing.md),
                  if (ref.watch(verificationFlowControllerProvider).errorMessage !=
                      null) ...[
                    VoteChainSecondaryButton(
                      label: 'Fix CNIC Details',
                      onPressed: () => context.go(VerificationRoutes.review),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                  ],
                  VoteChainSecondaryButton(
                    label: 'Register Face Again',
                    onPressed: () =>
                        context.go(FaceRegistrationRoutes.register),
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
