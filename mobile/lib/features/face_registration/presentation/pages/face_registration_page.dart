// Stitch: Face Registration - Step 3 (faacfbda)

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../shared/widgets/votechain_page_header.dart';
import '../../../../shared/widgets/votechain_primary_button.dart';
import '../../../../shared/widgets/votechain_scroll_form.dart';
import '../../../../shared/widgets/votechain_step_indicator.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_icons.dart';
import '../../../../theme/app_spacing.dart';
import '../../data/face_registration_assets.dart';
import '../../../verification/presentation/verification_routes.dart';
import '../face_registration_routes.dart';
import '../providers/face_registration_providers.dart';
import '../widgets/face_guideline_tile.dart';
import '../widgets/face_scan_frame.dart';

/// Face capture onboarding — mock preview only (step 3 of 4).
class FaceRegistrationPage extends ConsumerWidget {
  const FaceRegistrationPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(faceRegistrationFlowControllerProvider);
    final controller = ref.read(faceRegistrationFlowControllerProvider.notifier);
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: AppColors.surfaceContainerLowest,
      appBar: VoteChainAppBar(
        showBack: true,
        onBack: () => context.go(VerificationRoutes.review),
        showBrand: true,
      ),
      body: VoteChainScrollForm(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const VoteChainStepIndicator(
              currentStep: 3,
              totalSteps: 4,
              stepLabel: 'Identity Verification',
            ),
            const SizedBox(height: AppSpacing.xl),
            Text(
              'Register Your Face',
              style: textTheme.headlineMedium,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Your facial profile will be securely used for voter verification.',
              style: textTheme.bodyLarge?.copyWith(
                color: AppColors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            Center(
              child: FaceScanFrame(
                imageUrl: FaceRegistrationAssets.capturePlaceholder,
                isCaptured: state.isCaptured,
                onTap: controller.mockCaptureFace,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            const FaceGuidelineTile(
              icon: Icons.remove_red_eye_outlined,
              label: 'Look directly at the camera',
            ),
            const SizedBox(height: AppSpacing.sm),
            const FaceGuidelineTile(
              icon: Icons.visibility_off_outlined,
              label: 'Remove glasses if possible',
            ),
            const SizedBox(height: AppSpacing.sm),
            const FaceGuidelineTile(
              icon: Icons.light_mode_outlined,
              label: 'Ensure good lighting',
            ),
            const SizedBox(height: AppSpacing.sm),
            const FaceGuidelineTile(
              icon: Icons.center_focus_strong_outlined,
              label: 'Keep face inside the frame',
            ),
            const SizedBox(height: AppSpacing.lg),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: const [
                FaceTrustBadge(label: 'Stored Securely'),
                FaceTrustBadge(label: 'AI Face Recognition'),
                FaceTrustBadge(label: 'Used Only For Voting'),
              ],
            ),
            const SizedBox(height: AppSpacing.xl),
            VoteChainPrimaryButton(
              label: 'Capture Face',
              icon: AppIcons.face,
              onPressed: state.isCaptured
                  ? () => context.go(FaceRegistrationRoutes.processing)
                  : controller.mockCaptureFace,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'By proceeding, you agree to encrypted biometric processing.',
              textAlign: TextAlign.center,
              style: textTheme.bodySmall?.copyWith(
                color: AppColors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            TextButton(
              onPressed: () => controller.toggleSimulateDuplicateFailure(
                !state.simulateDuplicateFailure,
              ),
              child: Text(
                state.simulateDuplicateFailure
                    ? 'Test mode: duplicate failure ON'
                    : 'Test mode: duplicate failure OFF',
                style: textTheme.labelMedium?.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
          ],
        ),
      ),
    );
  }
}
