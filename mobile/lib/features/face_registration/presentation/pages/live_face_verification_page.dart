// Stitch: Live Face Verification (64067588)

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../shared/widgets/votechain_form_error.dart';
import '../../../../shared/widgets/votechain_page_header.dart';
import '../../../../shared/widgets/votechain_primary_button.dart';
import '../../../../shared/widgets/votechain_secondary_button.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_icons.dart';
import '../../../../theme/app_spacing.dart';
import '../../data/face_registration_assets.dart';
import '../../domain/entities/face_processing_step.dart';
import '../face_registration_routes.dart';
import '../providers/face_registration_providers.dart';
import '../widgets/face_scan_frame.dart';
import '../widgets/live_verification_widgets.dart';

/// Live face match + liveness check — mock verify with success/failure.
class LiveFaceVerificationPage extends ConsumerWidget {
  const LiveFaceVerificationPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(faceRegistrationFlowControllerProvider);
    final controller = ref.read(faceRegistrationFlowControllerProvider.notifier);
    final textTheme = Theme.of(context).textTheme;
    final isVerifying =
        state.liveStatus == LiveVerificationStatus.verifying;
    final checksMet = state.faceAligned;

    return Scaffold(
      backgroundColor: AppColors.surfaceContainerLowest,
      appBar: VoteChainAppBar(
        showBack: true,
        onBack: () => context.go(FaceRegistrationRoutes.register),
        centerTitle: 'VoteChain | Identity Verification',
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.screenHorizontal,
            vertical: AppSpacing.lg,
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Verify Your Identity',
                    textAlign: TextAlign.center,
                    style: textTheme.headlineMedium,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'Look directly at the camera to authorize your vote.',
                    textAlign: TextAlign.center,
                    style: textTheme.bodyMedium?.copyWith(
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  Center(
                    child: FaceScanFrame(
                      imageUrl: FaceRegistrationAssets.liveVerificationPlaceholder,
                      isAligned: state.faceAligned,
                      showLiveBadge: true,
                      label: 'Live Feed',
                      onTap: controller.mockAlignFace,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  LiveVerificationCheckTile(
                    icon: Icons.center_focus_strong_outlined,
                    label: 'Face centered',
                    isMet: checksMet,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  LiveVerificationCheckTile(
                    icon: Icons.visibility_off_outlined,
                    label: 'Remove glasses',
                    isMet: checksMet,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  LiveVerificationCheckTile(
                    icon: Icons.straighten,
                    label: 'Look straight',
                    isMet: checksMet,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  LiveVerificationCheckTile(
                    icon: Icons.light_mode_outlined,
                    label: 'Good lighting',
                    isMet: checksMet,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Row(
                    children: const [
                      LiveVerificationTrustChip(
                        icon: Icons.verified_user_outlined,
                        label: 'AI Verified',
                      ),
                      SizedBox(width: AppSpacing.sm),
                      LiveVerificationTrustChip(
                        icon: Icons.sensors,
                        label: 'Liveness Detection',
                      ),
                      SizedBox(width: AppSpacing.sm),
                      LiveVerificationTrustChip(
                        icon: Icons.shield_outlined,
                        label: 'Anti-Spoof',
                      ),
                    ],
                  ),
                  if (state.liveErrorMessage != null) ...[
                    const SizedBox(height: AppSpacing.lg),
                    VoteChainFormError(message: state.liveErrorMessage!),
                  ],
                  const SizedBox(height: AppSpacing.xl),
                  VoteChainPrimaryButton(
                    label: 'Verify Identity',
                    icon: AppIcons.faceRetouching,
                    isLoading: isVerifying,
                    loadingLabel: 'Verifying...',
                    onPressed: isVerifying
                        ? null
                        : () async {
                            final ok = await controller.verifyLiveFace();
                            if (ok && context.mounted) {
                              context.go(FaceRegistrationRoutes.complete);
                            }
                          },
                  ),
                  if (state.liveStatus == LiveVerificationStatus.failure) ...[
                    const SizedBox(height: AppSpacing.md),
                    VoteChainSecondaryButton(
                      label: 'Re-align Face',
                      onPressed: controller.resetLiveVerification,
                    ),
                  ],
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    'Your biometric data is encrypted and never stored on-chain.',
                    textAlign: TextAlign.center,
                    style: textTheme.bodySmall?.copyWith(
                      color: AppColors.onSurfaceVariant,
                    ),
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
