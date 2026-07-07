import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/dio_client.dart';
import '../../data/verification_remote_data_source.dart';
import '../../data/verification_repository_impl.dart';
import '../../domain/entities/cnic_extraction.dart';
import '../../domain/entities/verification_status_result.dart';
import '../../domain/entities/verification_phase.dart';
import '../../domain/failures/verification_failure.dart';
import '../../domain/repositories/verification_repository.dart';
import '../../data/verification_assets.dart';

final verificationRemoteDataSourceProvider =
    Provider<VerificationRemoteDataSource>((ref) {
  return VerificationRemoteDataSource(ref.watch(dioProvider));
});

final verificationRepositoryProvider = Provider<VerificationRepository>(
  (ref) => VerificationRepositoryImpl(
    remoteDataSource: ref.watch(verificationRemoteDataSourceProvider),
  ),
);

/// Shared verification flow state across upload → pending screens.
class VerificationFlowState {
  const VerificationFlowState({
    this.frontUploaded = false,
    this.backUploaded = false,
    this.cnicFrontImageUrl,
    this.cnicBackImageUrl,
    this.isScanning = false,
    this.activeScanStep = ScanPipelineStep.uploadComplete,
    this.extraction,
    this.isSubmitting = false,
    this.errorMessage,
  });

  final bool frontUploaded;
  final bool backUploaded;
  final String? cnicFrontImageUrl;
  final String? cnicBackImageUrl;
  final bool isScanning;
  final ScanPipelineStep activeScanStep;
  final CnicExtraction? extraction;
  final bool isSubmitting;
  final String? errorMessage;

  bool get canContinueUpload => frontUploaded && backUploaded;

  bool get canSubmitVerification =>
      extraction != null &&
      cnicFrontImageUrl != null &&
      cnicBackImageUrl != null;

  VerificationFlowState copyWith({
    bool? frontUploaded,
    bool? backUploaded,
    String? cnicFrontImageUrl,
    String? cnicBackImageUrl,
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
      cnicFrontImageUrl: cnicFrontImageUrl ?? this.cnicFrontImageUrl,
      cnicBackImageUrl: cnicBackImageUrl ?? this.cnicBackImageUrl,
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

  void mockUploadFront() => state = state.copyWith(
        frontUploaded: true,
        cnicFrontImageUrl: VerificationAssets.mockCnicFrontUrl,
        clearError: true,
      );

  void mockUploadBack() => state = state.copyWith(
        backUploaded: true,
        cnicBackImageUrl: VerificationAssets.mockCnicBackUrl,
        clearError: true,
      );

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
        errorMessage: 'Unable to continue verification. Please try again.',
      );
      return false;
    }
  }

  /// Submits the completed verification package to the backend.
  Future<VerificationStatusResult?> submitVerification() async {
    final extraction = state.extraction;
    final frontUrl = state.cnicFrontImageUrl;
    final backUrl = state.cnicBackImageUrl;

    if (extraction == null || frontUrl == null || backUrl == null) {
      state = state.copyWith(
        errorMessage: 'Verification data is incomplete. Please restart the flow.',
      );
      return null;
    }

    state = state.copyWith(isSubmitting: true, clearError: true);
    try {
      final status = await _repository.submitVerification(
        VerificationSubmission(
          cnicNumber: extraction.cnicNumber,
          cnicFrontImageUrl: frontUrl,
          cnicBackImageUrl: backUrl,
        ),
      );
      state = state.copyWith(isSubmitting: false);
      return status;
    } on VerificationFailure catch (error) {
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: error.message,
      );
      return null;
    } catch (_) {
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: 'Unable to submit verification. Please try again.',
      );
      return null;
    }
  }
}

final verificationFlowControllerProvider =
    StateNotifierProvider<VerificationFlowController, VerificationFlowState>(
  (ref) => VerificationFlowController(ref.watch(verificationRepositoryProvider)),
);
