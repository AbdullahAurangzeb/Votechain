import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/mock/mock_face_registration_repository.dart';
import '../../domain/entities/face_processing_step.dart';
import '../../domain/entities/face_registration_result.dart';
import '../../domain/repositories/face_registration_repository.dart';

final faceRegistrationRepositoryProvider =
    Provider<FaceRegistrationRepository>(
  (ref) => MockFaceRegistrationRepository(),
);

/// Shared face registration flow state (mock pipeline).
class FaceRegistrationFlowState {
  const FaceRegistrationFlowState({
    this.isCaptured = false,
    this.isProcessing = false,
    this.processingProgress = 0,
    this.activeStep = FaceProcessingStep.faceDetected,
    this.result,
    this.processingError,
    this.faceAligned = false,
    this.liveStatus = LiveVerificationStatus.idle,
    this.liveErrorMessage,
    this.verificationAttempts = 0,
    this.simulateDuplicateFailure = false,
  });

  final bool isCaptured;
  final bool isProcessing;
  final double processingProgress;
  final FaceProcessingStep activeStep;
  final FaceRegistrationResult? result;
  final String? processingError;
  final bool faceAligned;
  final LiveVerificationStatus liveStatus;
  final String? liveErrorMessage;
  final int verificationAttempts;
  final bool simulateDuplicateFailure;

  FaceRegistrationFlowState copyWith({
    bool? isCaptured,
    bool? isProcessing,
    double? processingProgress,
    FaceProcessingStep? activeStep,
    FaceRegistrationResult? result,
    String? processingError,
    bool? faceAligned,
    LiveVerificationStatus? liveStatus,
    String? liveErrorMessage,
    int? verificationAttempts,
    bool? simulateDuplicateFailure,
    bool clearProcessingError = false,
    bool clearLiveError = false,
  }) {
    return FaceRegistrationFlowState(
      isCaptured: isCaptured ?? this.isCaptured,
      isProcessing: isProcessing ?? this.isProcessing,
      processingProgress: processingProgress ?? this.processingProgress,
      activeStep: activeStep ?? this.activeStep,
      result: result ?? this.result,
      processingError:
          clearProcessingError ? null : processingError ?? this.processingError,
      faceAligned: faceAligned ?? this.faceAligned,
      liveStatus: liveStatus ?? this.liveStatus,
      liveErrorMessage:
          clearLiveError ? null : liveErrorMessage ?? this.liveErrorMessage,
      verificationAttempts: verificationAttempts ?? this.verificationAttempts,
      simulateDuplicateFailure:
          simulateDuplicateFailure ?? this.simulateDuplicateFailure,
    );
  }
}

class FaceRegistrationFlowController
    extends StateNotifier<FaceRegistrationFlowState> {
  FaceRegistrationFlowController(this._repository)
      : super(const FaceRegistrationFlowState());

  final FaceRegistrationRepository _repository;

  void mockCaptureFace() {
    state = state.copyWith(isCaptured: true, clearProcessingError: true);
  }

  void mockAlignFace() {
    state = state.copyWith(faceAligned: true, clearLiveError: true);
  }

  void toggleSimulateDuplicateFailure(bool value) {
    final mock = _repository;
    if (mock is MockFaceRegistrationRepository) {
      mock.setSimulateDuplicateFailure(value);
    }
    state = state.copyWith(simulateDuplicateFailure: value);
  }

  Future<bool> runProcessingPipeline() async {
    state = state.copyWith(
      isProcessing: true,
      processingProgress: 0.12,
      activeStep: FaceProcessingStep.faceDetected,
      clearProcessingError: true,
    );

    await Future<void>.delayed(const Duration(milliseconds: 700));
    if (!mounted) return false;
    state = state.copyWith(
      processingProgress: 0.35,
      activeStep: FaceProcessingStep.generatingEmbedding,
    );

    await Future<void>.delayed(const Duration(milliseconds: 900));
    if (!mounted) return false;
    state = state.copyWith(
      processingProgress: 0.62,
      activeStep: FaceProcessingStep.checkingDuplicate,
    );

    try {
      final result = await _repository.processFaceEmbedding();
      if (!mounted) return false;

      state = state.copyWith(
        processingProgress: 0.82,
        activeStep: FaceProcessingStep.encryptingProfile,
      );

      await Future<void>.delayed(const Duration(milliseconds: 800));
      if (!mounted) return false;

      state = state.copyWith(
        isProcessing: false,
        processingProgress: 1,
        result: result,
      );
      return true;
    } on FaceRegistrationException catch (e) {
      state = state.copyWith(
        isProcessing: false,
        processingError: e.message,
      );
      return false;
    } catch (_) {
      state = state.copyWith(
        isProcessing: false,
        processingError: 'Face processing failed. Please try again.',
      );
      return false;
    }
  }

  Future<bool> verifyLiveFace() async {
    state = state.copyWith(
      liveStatus: LiveVerificationStatus.verifying,
      clearLiveError: true,
    );

    final aligned = state.faceAligned;
    final success = await _repository.verifyLiveFace(faceAligned: aligned);
    if (!mounted) return false;

    if (success) {
      state = state.copyWith(liveStatus: LiveVerificationStatus.success);
      return true;
    }

    final attempts = state.verificationAttempts + 1;
    state = state.copyWith(
      liveStatus: LiveVerificationStatus.failure,
      verificationAttempts: attempts,
      liveErrorMessage: aligned
          ? 'Liveness check failed. Please try again.'
          : 'Face not centered. Align your face inside the frame and retry.',
    );
    return false;
  }

  void resetLiveVerification() {
    state = state.copyWith(
      liveStatus: LiveVerificationStatus.idle,
      faceAligned: false,
      clearLiveError: true,
    );
  }

  void resetProcessing() {
    state = state.copyWith(
      isProcessing: false,
      processingProgress: 0,
      activeStep: FaceProcessingStep.faceDetected,
      clearProcessingError: true,
    );
  }
}

final faceRegistrationFlowControllerProvider = StateNotifierProvider<
    FaceRegistrationFlowController, FaceRegistrationFlowState>(
  (ref) => FaceRegistrationFlowController(
    ref.watch(faceRegistrationRepositoryProvider),
  ),
);

double progressForFaceStep(FaceProcessingStep step) {
  switch (step) {
    case FaceProcessingStep.faceDetected:
      return 0.35;
    case FaceProcessingStep.generatingEmbedding:
      return 0.55;
    case FaceProcessingStep.checkingDuplicate:
      return 0.72;
    case FaceProcessingStep.encryptingProfile:
      return 0.82;
  }
}
