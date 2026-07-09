// Stitch: Review Extracted Information (724d6430)

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../theme/app_colors.dart';
import '../../../../theme/app_icons.dart';
import '../../../../theme/app_radius.dart';
import '../../../../theme/app_spacing.dart';
import '../../../../widgets/votechain_primary_button.dart';
import '../../../../widgets/votechain_read_only_field.dart';
import '../../../../widgets/votechain_secondary_button.dart';
import '../../../../widgets/votechain_surface_card.dart';
import '../../../../shared/widgets/votechain_page_header.dart';
import '../../domain/entities/cnic_extraction.dart';
import '../providers/verification_providers.dart';
import '../../../verification/presentation/verification_routes.dart';
import '../../../face_registration/presentation/face_registration_routes.dart';
import '../widgets/verification_step_header.dart';

/// Review OCR-extracted CNIC fields before admin submission.
class ReviewExtractedInfoPage extends ConsumerWidget {
  const ReviewExtractedInfoPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(verificationFlowControllerProvider);
    final controller = ref.read(verificationFlowControllerProvider.notifier);
    final extraction = state.extraction;
    final textTheme = Theme.of(context).textTheme;

    if (extraction == null) {
      return Scaffold(
        backgroundColor: AppColors.surfaceContainerLowest,
        body: Center(
          child: VoteChainPrimaryButton(
            label: 'Return to Upload',
            onPressed: () => context.go(VerificationRoutes.uploadCnic),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.surfaceContainerLowest,
      appBar: VoteChainAppBar(
        showBack: true,
        onBack: () => context.go(VerificationRoutes.uploadCnic),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.screenHorizontal,
            vertical: AppSpacing.lg,
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const VerificationStepHeader(),
                  const SizedBox(height: AppSpacing.xl),
                  Text(
                    'Confirm Your Information',
                    style: textTheme.headlineMedium,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'Our AI extracted the following details from your CNIC. Please verify them against your physical document.',
                    style: textTheme.bodyMedium?.copyWith(
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  VoteChainSurfaceCard(
                    padding: EdgeInsets.zero,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(AppSpacing.md),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceContainer.withValues(
                              alpha: 0.5,
                            ),
                            border: const Border(
                              bottom: BorderSide(color: AppColors.borderSubtle),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  const Icon(
                                    AppIcons.verifiedUser,
                                    color: AppColors.primaryDisplay,
                                    size: 18,
                                  ),
                                  const SizedBox(width: AppSpacing.sm),
                                  Text(
                                    'Document Analysis',
                                    style: textTheme.labelLarge,
                                  ),
                                ],
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: AppSpacing.md,
                                  vertical: AppSpacing.xs,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.surfaceContainerLow,
                                  borderRadius: AppRadius.pillBorder,
                                  border: Border.all(
                                    color: AppColors.primaryDisplay.withValues(
                                      alpha: 0.2,
                                    ),
                                  ),
                                ),
                                child: Text.rich(
                                  TextSpan(
                                    text: 'OCR Confidence: ',
                                    style: textTheme.labelMedium?.copyWith(
                                      color: AppColors.onSurfaceVariant,
                                    ),
                                    children: [
                                      TextSpan(
                                        text:
                                            '${(extraction.ocrConfidence * 100).round()}%',
                                        style: textTheme.labelLarge?.copyWith(
                                          color: AppColors.primaryDisplay,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(AppSpacing.lg),
                          child: Column(
                            children: [
                              VoteChainReadOnlyField(
                                label: 'Full Name',
                                value: extraction.fullName,
                                onEdit: () => _showEditDialog(
                                  context,
                                  ref,
                                  extraction,
                                  'Full Name',
                                  extraction.fullName,
                                  (v) => extraction.copyWith(fullName: v),
                                ),
                              ),
                              const SizedBox(height: AppSpacing.lg),
                              VoteChainReadOnlyField(
                                label: 'CNIC Number',
                                value: extraction.cnicNumber,
                                onEdit: () => _showEditDialog(
                                  context,
                                  ref,
                                  extraction,
                                  'CNIC Number',
                                  extraction.cnicNumber,
                                  (v) => extraction.copyWith(cnicNumber: v),
                                ),
                              ),
                              const SizedBox(height: AppSpacing.lg),
                              Row(
                                children: [
                                  Expanded(
                                    child: VoteChainReadOnlyField(
                                      label: 'Date of Birth',
                                      value: extraction.dateOfBirth,
                                      onEdit: () => _showEditDialog(
                                        context,
                                        ref,
                                        extraction,
                                        'Date of Birth',
                                        extraction.dateOfBirth,
                                        (v) => extraction.copyWith(dateOfBirth: v),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: AppSpacing.lg),
                                  Expanded(
                                    child: VoteChainReadOnlyField(
                                      label: 'Gender',
                                      value: extraction.gender,
                                      onEdit: () => _showEditDialog(
                                        context,
                                        ref,
                                        extraction,
                                        'Gender',
                                        extraction.gender,
                                        (v) => extraction.copyWith(gender: v),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: AppSpacing.lg),
                              Row(
                                children: [
                                  Expanded(
                                    child: VoteChainReadOnlyField(
                                      label: "Father's/Husband's Name",
                                      value: extraction.fatherName,
                                      onEdit: () => _showEditDialog(
                                        context,
                                        ref,
                                        extraction,
                                        "Father's/Husband's Name",
                                        extraction.fatherName,
                                        (v) => extraction.copyWith(fatherName: v),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: AppSpacing.lg),
                                  Expanded(
                                    child: VoteChainReadOnlyField(
                                      label: 'Issue Date',
                                      value: extraction.issueDate,
                                      onEdit: () => _showEditDialog(
                                        context,
                                        ref,
                                        extraction,
                                        'Issue Date',
                                        extraction.issueDate,
                                        (v) => extraction.copyWith(issueDate: v),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: AppSpacing.lg),
                              VoteChainReadOnlyField(
                                label: 'Expiry Date',
                                value: extraction.expiryDate,
                                onEdit: () => _showEditDialog(
                                  context,
                                  ref,
                                  extraction,
                                  'Expiry Date',
                                  extraction.expiryDate,
                                  (v) => extraction.copyWith(expiryDate: v),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerLow,
                      borderRadius: AppRadius.cardBorder,
                      border: Border.all(color: AppColors.borderSubtle),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          AppIcons.info,
                          size: 20,
                          color: AppColors.onSurfaceVariant,
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Text(
                            'If any information is incorrect, please edit before continuing. This data will be cryptographically hashed and linked to your biometric identity.',
                            style: textTheme.bodySmall?.copyWith(
                              color: AppColors.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ],
                    ),
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
                    label: 'Continue to Verification',
                    icon: AppIcons.arrowForward,
                    isLoading: state.isSubmitting,
                    onPressed: () async {
                      final ok = await controller.submitForReview();
                      if (ok && context.mounted) {
                        context.go(FaceRegistrationRoutes.register);
                      }
                    },
                  ),
                  const SizedBox(height: AppSpacing.md),
                  VoteChainSecondaryButton(
                    label: 'Back',
                    onPressed: () => context.go(VerificationRoutes.uploadCnic),
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

  Future<void> _showEditDialog(
    BuildContext context,
    WidgetRef ref,
    CnicExtraction extraction,
    String fieldLabel,
    String initialValue,
    CnicExtraction Function(String) apply,
  ) async {
    final controller = TextEditingController(text: initialValue);
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit $fieldLabel'),
        content: TextField(
          controller: controller,
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(controller.text),
            child: const Text('Save'),
          ),
        ],
      ),
    );
    if (result != null) {
      ref
          .read(verificationFlowControllerProvider.notifier)
          .updateExtraction(apply(result));
    }
  }
}
