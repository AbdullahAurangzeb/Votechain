import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/network/dio_client.dart';
import '../../data/verification_remote_data_source.dart';
import '../../data/verification_repository_impl.dart';
import '../../domain/entities/cnic_extraction.dart';
import '../../domain/entities/verification_status_result.dart';
import '../../domain/entities/verification_phase.dart';
import '../../domain/failures/verification_failure.dart';
import '../../domain/repositories/verification_repository.dart';
import '../../data/local_ocr_repository_impl.dart';
import '../../data/verification_assets.dart';
import '../../data/verification_progress_storage.dart';
import '../../domain/entities/verification_local_step.dart';
import '../controllers/ocr_controller.dart';
import 'ocr_providers.dart';

final verificationProgressStorageProvider =
    Provider<VerificationProgressStorage>((_) => VerificationProgressStorage());

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
  VerificationFlowController(
    this._repository,
    this._ocrController,
    this._progressStorage,
  ) : super(const VerificationFlowState());

  final VerificationRepository _repository;
  final OcrController _ocrController;
  final VerificationProgressStorage _progressStorage;
  final ImagePicker _imagePicker = ImagePicker();
  XFile? _frontImage;

  Future<void> pickFrontImage(ImageSource source) async {
    final image = await _imagePicker.pickImage(
      source: source,
      imageQuality: 85,
    );
    if (image == null) return;

    _frontImage = image;
    state = state.copyWith(
      frontUploaded: true,
      cnicFrontImageUrl: VerificationAssets.mockCnicFrontUrl,
      clearError: true,
    );
    await _persistProgress(step: VerificationLocalStep.upload);
  }

  Future<void> pickBackImage(ImageSource source) async {
    final image = await _imagePicker.pickImage(
      source: source,
      imageQuality: 85,
    );
    if (image == null) return;

    state = state.copyWith(
      backUploaded: true,
      cnicBackImageUrl: VerificationAssets.mockCnicBackUrl,
      clearError: true,
    );
    await _persistProgress(step: VerificationLocalStep.upload);
  }

  Future<void> restoreSavedProgress(VerificationSavedProgress? saved) async {
    if (saved == null) return;

    state = state.copyWith(
      frontUploaded: saved.frontUploaded,
      backUploaded: saved.backUploaded,
      cnicFrontImageUrl: saved.cnicFrontImageUrl,
      cnicBackImageUrl: saved.cnicBackImageUrl,
      extraction: saved.extraction,
    );
  }

  Future<void> clearSavedProgress() => _progressStorage.clear();

  Future<void> _persistProgress({
    required VerificationLocalStep step,
    CnicExtraction? extraction,
  }) async {
    await _progressStorage.save(
      step: step,
      extraction: extraction ?? state.extraction,
      frontUploaded: state.frontUploaded,
      backUploaded: state.backUploaded,
      cnicFrontImageUrl: state.cnicFrontImageUrl,
      cnicBackImageUrl: state.cnicBackImageUrl,
    );
  }

  void resetUploads() {
    _frontImage = null;
    state = const VerificationFlowState();
    unawaited(_progressStorage.clear());
  }

  Future<void> runScanPipeline() async {
    final frontImage = _frontImage;
    if (frontImage == null) {
      state = state.copyWith(
        isScanning: false,
        errorMessage: 'CNIC front image is missing. Please upload again.',
      );
      return;
    }

    state = state.copyWith(
      isScanning: true,
      activeScanStep: ScanPipelineStep.uploadComplete,
      clearError: true,
    );

    state = state.copyWith(activeScanStep: ScanPipelineStep.detectingDocument);
    if (!mounted) return;

    state = state.copyWith(activeScanStep: ScanPipelineStep.extractingInformation);

    try {
      final extraction = await _ocrController.extractFromImage(frontImage);
      if (!mounted) return;

      state = state.copyWith(
        isScanning: false,
        activeScanStep: ScanPipelineStep.faceVerification,
        extraction: extraction,
      );
      await _persistProgress(
        step: VerificationLocalStep.ocrCompleted,
        extraction: extraction,
      );
    } on VerificationFailure catch (error) {
      if (!mounted) return;
      state = state.copyWith(
        isScanning: false,
        errorMessage: error.message,
      );
    } catch (_) {
      if (!mounted) return;
      state = state.copyWith(
        isScanning: false,
        errorMessage: LocalOcrRepositoryImpl.ocrReadFailureMessage,
      );
    }
  }

  void updateExtraction(CnicExtraction extraction) {
    state = state.copyWith(extraction: extraction);
    unawaited(
      _persistProgress(
        step: VerificationLocalStep.ocrCompleted,
        extraction: extraction,
      ),
    );
  }

  Future<bool> submitForReview() async {
    final extraction = state.extraction;
    if (extraction == null) return false;

    state = state.copyWith(isSubmitting: true, clearError: true);
    try {
      await _repository.submitForAdminReview(extraction);
      state = state.copyWith(isSubmitting: false);
      await _persistProgress(
        step: VerificationLocalStep.facePending,
        extraction: extraction,
      );
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
      await _progressStorage.clear();
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
  (ref) => VerificationFlowController(
    ref.watch(verificationRepositoryProvider),
    ref.watch(ocrControllerProvider),
    ref.watch(verificationProgressStorageProvider),
  ),
);
