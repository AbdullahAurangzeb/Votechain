// Stitch: Identity Verification - Upload CNIC (b3a022d3)

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../theme/app_colors.dart';
import '../../../../theme/app_icons.dart';
import '../../../../theme/app_spacing.dart';
import '../../../../widgets/votechain_primary_button.dart';
import '../../../../shared/widgets/votechain_page_header.dart' show VoteChainAppBar;
import '../providers/verification_providers.dart';
import '../verification_routes.dart';
import '../widgets/cnic_upload_card.dart';
import '../widgets/verification_security_tile.dart';
import '../widgets/verification_step_header.dart';

/// Upload CNIC front/back — step 2 of 4.
class UploadCnicPage extends ConsumerWidget {
  const UploadCnicPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(verificationFlowControllerProvider);
    final controller = ref.read(verificationFlowControllerProvider.notifier);
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: AppColors.surfaceContainerLowest,
      appBar: const VoteChainAppBar(showBrand: true),
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
                  const VerificationStepHeader(),
                  const SizedBox(height: AppSpacing.xl),
                  Text(
                    'Verify Your Identity',
                    style: textTheme.headlineMedium,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'Upload clear images of your CNIC to verify your identity before participating in elections. This process is fully automated and encrypted.',
                    style: textTheme.bodyLarge?.copyWith(
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  const VerificationSecurityTile(
                    icon: AppIcons.lock,
                    title: 'End-to-End Encrypted',
                    subtitle: 'Your data is secured using AES-256 encryption.',
                  ),
                  const SizedBox(height: AppSpacing.md),
                  const VerificationSecurityTile(
                    icon: AppIcons.documentScanner,
                    title: 'AI OCR Processing',
                    subtitle: 'Automated character recognition for speed.',
                  ),
                  const SizedBox(height: AppSpacing.md),
                  const VerificationSecurityTile(
                    icon: AppIcons.verifiedUser,
                    title: 'Personal Data Protected',
                    subtitle: 'Compliant with global privacy standards.',
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  CnicUploadCard(
                    title: 'Front Side of CNIC',
                    isUploaded: state.frontUploaded,
                    onCameraTap: () =>
                        controller.pickFrontImage(ImageSource.camera),
                    onGalleryTap: () =>
                        controller.pickFrontImage(ImageSource.gallery),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  CnicUploadCard(
                    title: 'Back Side of CNIC',
                    isUploaded: state.backUploaded,
                    onCameraTap: () =>
                        controller.pickBackImage(ImageSource.camera),
                    onGalleryTap: () =>
                        controller.pickBackImage(ImageSource.gallery),
                  ),
                  if (state.errorMessage != null) ...[
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      state.errorMessage!,
                      style: textTheme.labelMedium?.copyWith(
                        color: AppColors.error,
                      ),
                    ),
                  ],
                  const SizedBox(height: AppSpacing.xl),
                  VoteChainPrimaryButton(
                    label: 'Continue',
                    icon: AppIcons.arrowForward,
                    onPressed: state.canContinueUpload
                        ? () => context.go(VerificationRoutes.scanning)
                        : null,
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
