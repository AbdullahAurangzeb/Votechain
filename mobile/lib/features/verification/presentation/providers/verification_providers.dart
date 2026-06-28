import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/mock/mock_verification_repository.dart';
import '../../domain/entities/cnic_extraction.dart';
import '../../domain/entities/verification_phase.dart';
import '../../domain/repositories/verification_repository.dart';

final verificationRepositoryProvider = Provider<VerificationRepository>(
  (ref) => MockVerificationRepository(),
);

/// Shared verification flow state across upload → pending screens.
class VerificationFlowState {
  const VerificationFlowState({
    this.frontUploaded = false,
    this.backUploaded = false,
    this.isScanning = false,
    this.activeScanStep = ScanPipelineStep.uploadComplete,
    this.extraction,
    this.isSubmitting = false,
    this.errorMessage,
  });

  final bool frontUploaded;
  final bool backUploaded;
  final bool isScanning;
  final ScanPipelineStep activeScanStep;
  final CnicExtraction? extraction;
  final bool isSubmitting;
  final String? errorMessage;

  bool get canContinueUpload => frontUploaded && backUploaded;

  VerificationFlowState copyWith({
    bool? frontUploaded,
    bool? backUploaded,
    bool? isScanning,
    ScanPipelineStep? activeScanStep,
    CnicExtraction? extraction,
    bool? isSubmitting,
    String? errorMessage,
    bool clearError = false,
  }) {
    return VerificationFlowState(
      frontUploaded: frontUploaded ?? this.frontUploaded,
      backUploaded: backUploaded ?? this.backUploaded,
      isScanning: isScanning ?? this.isScanning,
      activeScanStep: activeScanStep ?? this.activeScanStep,
      extraction: extraction ?? this.extraction,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }
}

class VerificationFlowController extends StateNotifier<VerificationFlowState> {
  VerificationFlowController(this._repository) : super(const VerificationFlowState());

  final VerificationRepository _repository;

  void mockUploadFront() =>
      state = state.copyWith(frontUploaded: true, clearError: true);

  void mockUploadBack() =>
      state = state.copyWith(backUploaded: true, clearError: true);

  void resetUploads() => state = const VerificationFlowState();

  Future<void> runScanPipeline() async {
    state = state.copyWith(
      isScanning: true,
      activeScanStep: ScanPipelineStep.uploadComplete,
      clearError: true,
    );

    await Future<void>.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;
    state = state.copyWith(activeScanStep: ScanPipelineStep.detectingDocument);

    await Future<void>.delayed(const Duration(milliseconds: 900));
    if (!mounted) return;
    state = state.copyWith(activeScanStep: ScanPipelineStep.extractingInformation);

    final extraction = await _repository.simulateOcrExtraction();
    if (!mounted) return;

    state = state.copyWith(
      isScanning: false,
      activeScanStep: ScanPipelineStep.faceVerification,
      extraction: extraction,
    );
  }

  void updateExtraction(CnicExtraction extraction) {
    state = state.copyWith(extraction: extraction);
  }

  Future<bool> submitForReview() async {
    final extraction = state.extraction;
    if (extraction == null) return false;

    state = state.copyWith(isSubmitting: true, clearError: true);
    try {
      await _repository.submitForAdminReview(extraction);
      state = state.copyWith(isSubmitting: false);
      return true;
    } catch (_) {
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: 'Unable to submit verification. Please try again.',
      );
      return false;
    }
  }
}

final verificationFlowControllerProvider =
    StateNotifierProvider<VerificationFlowController, VerificationFlowState>(
  (ref) => VerificationFlowController(ref.watch(verificationRepositoryProvider)),
);
