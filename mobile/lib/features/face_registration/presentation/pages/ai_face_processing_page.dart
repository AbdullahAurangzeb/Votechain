// Stitch: AI Face Registration - Processing (021b4471)

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../shared/widgets/votechain_form_error.dart';
import '../../../../shared/widgets/votechain_primary_button.dart';
import '../../../../shared/widgets/votechain_secondary_button.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_spacing.dart';
import '../../domain/entities/face_processing_step.dart';
import '../face_registration_routes.dart';
import '../providers/face_registration_providers.dart';
import '../widgets/face_processing_widgets.dart';

/// AI face embedding pipeline — auto-advances on success (mock).
class AiFaceProcessingPage extends ConsumerStatefulWidget {
  const AiFaceProcessingPage({super.key});

  @override
  ConsumerState<AiFaceProcessingPage> createState() =>
      _AiFaceProcessingPageState();
}

class _AiFaceProcessingPageState extends ConsumerState<AiFaceProcessingPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _runPipeline());
  }

  Future<void> _runPipeline() async {
    final controller = ref.read(faceRegistrationFlowControllerProvider.notifier);
    final ok = await controller.runProcessingPipeline();
    if (!mounted) return;
    if (ok) {
      context.go(FaceRegistrationRoutes.liveVerify);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(faceRegistrationFlowControllerProvider);
    final controller = ref.read(faceRegistrationFlowControllerProvider.notifier);
    final textTheme = Theme.of(context).textTheme;
    final progress = state.processingError != null
        ? progressForFaceStep(FaceProcessingStep.checkingDuplicate)
        : (state.processingProgress > 0
            ? state.processingProgress
            : progressForFaceStep(state.activeStep));
    final failed = state.processingError != null;

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
                  const SizedBox(height: AppSpacing.xl),
                  Text(
                    'Creating Secure Face Profile',
                    textAlign: TextAlign.center,
                    style: textTheme.displayMedium,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    'Our AI is securely processing your facial features.',
                    textAlign: TextAlign.center,
                    style: textTheme.bodyLarge?.copyWith(
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xxl),
                  FaceProcessingRing(progress: progress),
                  const SizedBox(height: AppSpacing.xxl),
                  FaceProcessingStepTile(
                    step: FaceProcessingStep.faceDetected,
                    activeStep: state.activeStep,
                    title: 'Face Detected',
                  ),
                  FaceProcessingStepTile(
                    step: FaceProcessingStep.generatingEmbedding,
                    activeStep: state.activeStep,
                    title: 'Generating Face Embedding',
                  ),
                  FaceProcessingStepTile(
                    step: FaceProcessingStep.checkingDuplicate,
                    activeStep: state.activeStep,
                    title: 'Checking Duplicate Registration',
                    isFailed: failed,
                  ),
                  FaceProcessingStepTile(
                    step: FaceProcessingStep.encryptingProfile,
                    activeStep: state.activeStep,
                    title: 'Encrypting Biometric Profile',
                  ),
                  if (failed) ...[
                    const SizedBox(height: AppSpacing.lg),
                    VoteChainFormError(message: state.processingError!),
                    const SizedBox(height: AppSpacing.md),
                    VoteChainSecondaryButton(
                      label: 'Retry Processing',
                      onPressed: () {
                        controller.resetProcessing();
                        _runPipeline();
                      },
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    VoteChainPrimaryButton(
                      label: 'Back to Capture',
                      onPressed: () =>
                          context.go(FaceRegistrationRoutes.register),
                    ),
                  ],
                  const SizedBox(height: AppSpacing.xl),
                  const FacePrivacyNote(),
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
