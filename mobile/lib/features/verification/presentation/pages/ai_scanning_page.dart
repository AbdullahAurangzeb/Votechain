// Stitch: AI Identity Verification - Scanning (b03026d5)

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../shared/widgets/votechain_page_header.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_spacing.dart';
import '../../domain/entities/verification_phase.dart';
import '../providers/verification_providers.dart';
import '../verification_routes.dart';
import '../widgets/cnic_scan_visual.dart';

/// AI scanning animation — auto-advances to review when OCR completes.
class AiScanningPage extends ConsumerStatefulWidget {
  const AiScanningPage({super.key});

  @override
  ConsumerState<AiScanningPage> createState() => _AiScanningPageState();
}

class _AiScanningPageState extends ConsumerState<AiScanningPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _startScan());
  }

  Future<void> _startScan() async {
    final controller = ref.read(verificationFlowControllerProvider.notifier);
    await controller.runScanPipeline();
    if (!mounted) return;
    final flowState = ref.read(verificationFlowControllerProvider);
    if (flowState.extraction != null) {
      context.go(VerificationRoutes.review);
    } else if (flowState.errorMessage != null) {
      context.go(VerificationRoutes.uploadCnic);
    }
  }

  bool _stepComplete(ScanPipelineStep step, ScanPipelineStep active) =>
      step.index < active.index;

  bool _stepActive(ScanPipelineStep step, ScanPipelineStep active) =>
      step == active;

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(verificationFlowControllerProvider);
    final activeStep = state.activeScanStep;
    final textTheme = Theme.of(context).textTheme;
    final progress = scanProgressForStep(activeStep);

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
            vertical: AppSpacing.xl,
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Column(
                children: [
                  const SizedBox(height: AppSpacing.xl),
                  Text(
                    'Scanning Your CNIC',
                    textAlign: TextAlign.center,
                    style: textTheme.displayMedium,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    'Please wait while our AI securely extracts your identity information.',
                    textAlign: TextAlign.center,
                    style: textTheme.bodyLarge?.copyWith(
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xxl),
                  CnicScanVisual(progress: progress),
                  const SizedBox(height: AppSpacing.xxl),
                  ScanStepCard(
                    title: 'Upload Complete',
                    subtitle: 'Securely tunnelled',
                    isComplete: _stepComplete(
                      ScanPipelineStep.uploadComplete,
                      activeStep,
                    ),
                    isActive: _stepActive(
                      ScanPipelineStep.uploadComplete,
                      activeStep,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  ScanStepCard(
                    title: 'Detecting Document',
                    subtitle: 'CNIC Front recognized',
                    isComplete: _stepComplete(
                      ScanPipelineStep.detectingDocument,
                      activeStep,
                    ),
                    isActive: _stepActive(
                      ScanPipelineStep.detectingDocument,
                      activeStep,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  ScanStepCard(
                    title: 'Extracting Information',
                    subtitle: 'Scanning biometric data...',
                    isComplete: _stepComplete(
                      ScanPipelineStep.extractingInformation,
                      activeStep,
                    ),
                    isActive: _stepActive(
                      ScanPipelineStep.extractingInformation,
                      activeStep,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  ScanStepCard(
                    title: 'Face Verification',
                    subtitle: 'Pending',
                    isComplete: _stepComplete(
                      ScanPipelineStep.faceVerification,
                      activeStep,
                    ),
                    isActive: _stepActive(
                      ScanPipelineStep.faceVerification,
                      activeStep,
                    ),
                    isPending: activeStep.index <
                        ScanPipelineStep.faceVerification.index,
                  ),
                  const SizedBox(height: AppSpacing.xl),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
