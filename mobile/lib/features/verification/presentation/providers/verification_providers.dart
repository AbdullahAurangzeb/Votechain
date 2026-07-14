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
    this.manuallyEditedFields = const {},
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

  /// Field keys the user changed on review — never overwritten by later OCR.
  final Set<String> manuallyEditedFields;
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
    Set<String>? manuallyEditedFields,
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
      manuallyEditedFields:
          manuallyEditedFields ?? this.manuallyEditedFields,
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

  /// Authenticated user that owns locally persisted verification progress.
  String? _boundUserId;

  /// Binds progress persistence to [userId] for the active session.
  void bindUser(String userId) {
    _boundUserId = userId;
  }

  /// Clears in-memory verification UI state without requiring a prior bind.
  void resetSessionState() {
    _frontImage = null;
    state = const VerificationFlowState();
  }

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
    final userId = _boundUserId;
    if (userId == null || userId.isEmpty) {
      return;
    }

    await _progressStorage.save(
      userId: userId,
      step: step,
      extraction: extraction ?? state.extraction,
      frontUploaded: state.frontUploaded,
      backUploaded: state.backUploaded,
      cnicFrontImageUrl: state.cnicFrontImageUrl,
      cnicBackImageUrl: state.cnicBackImageUrl,
    );
  }

  void resetUploads() {
    resetSessionState();
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

      final merged = _preserveManualEdits(
        ocrExtraction: extraction,
        previous: state.extraction,
        editedFields: state.manuallyEditedFields,
      );

      state = state.copyWith(
        isScanning: false,
        activeScanStep: ScanPipelineStep.faceVerification,
        extraction: merged,
      );
      await _persistProgress(
        step: VerificationLocalStep.ocrCompleted,
        extraction: merged,
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
    final previous = state.extraction;
    final normalized = extraction.withNormalizedCnic();
    final edited = Set<String>.from(state.manuallyEditedFields);
    if (previous != null) {
      if (previous.fullName != normalized.fullName) edited.add('fullName');
      if (previous.fatherName != normalized.fatherName) {
        edited.add('fatherName');
      }
      if (previous.cnicNumber != normalized.cnicNumber) {
        edited.add('cnicNumber');
      }
      if (previous.dateOfBirth != normalized.dateOfBirth) {
        edited.add('dateOfBirth');
      }
      if (previous.gender != normalized.gender) edited.add('gender');
      if (previous.issueDate != normalized.issueDate) edited.add('issueDate');
      if (previous.expiryDate != normalized.expiryDate) {
        edited.add('expiryDate');
      }
    }

    state = state.copyWith(
      extraction: normalized,
      manuallyEditedFields: edited,
      clearError: true,
    );
    unawaited(
      _persistProgress(
        step: VerificationLocalStep.ocrCompleted,
        extraction: normalized,
      ),
    );
  }

  /// Keeps user-edited review fields when OCR runs again.
  CnicExtraction _preserveManualEdits({
    required CnicExtraction ocrExtraction,
    required CnicExtraction? previous,
    required Set<String> editedFields,
  }) {
    if (previous == null || editedFields.isEmpty) return ocrExtraction;

    return ocrExtraction.copyWith(
      fullName: editedFields.contains('fullName')
          ? previous.fullName
          : ocrExtraction.fullName,
      fatherName: editedFields.contains('fatherName')
          ? previous.fatherName
          : ocrExtraction.fatherName,
      cnicNumber: editedFields.contains('cnicNumber')
          ? previous.cnicNumber
          : ocrExtraction.cnicNumber,
      dateOfBirth: editedFields.contains('dateOfBirth')
          ? previous.dateOfBirth
          : ocrExtraction.dateOfBirth,
      gender: editedFields.contains('gender')
          ? previous.gender
          : ocrExtraction.gender,
      issueDate: editedFields.contains('issueDate')
          ? previous.issueDate
          : ocrExtraction.issueDate,
      expiryDate: editedFields.contains('expiryDate')
          ? previous.expiryDate
          : ocrExtraction.expiryDate,
    );
  }

  Future<bool> submitForReview() async {
    final extraction = state.extraction;
    if (extraction == null) return false;

    final normalized = extraction.withNormalizedCnic();
    if (!CnicExtraction.isValidCnic(normalized.cnicNumber)) {
      state = state.copyWith(
        extraction: normalized,
        errorMessage:
            'Enter a valid CNIC in the format 35202-1234567-1 before continuing.',
      );
      return false;
    }

    state = state.copyWith(
      extraction: normalized,
      isSubmitting: true,
      clearError: true,
    );
    try {
      await _repository.submitForAdminReview(normalized);
      state = state.copyWith(isSubmitting: false);
      await _persistProgress(
        step: VerificationLocalStep.facePending,
        extraction: normalized,
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

    final normalized = extraction.withNormalizedCnic();
    if (!CnicExtraction.isValidCnic(normalized.cnicNumber)) {
      state = state.copyWith(
        extraction: normalized,
        errorMessage:
            'CNIC is missing or invalid. Go back and enter your CNIC '
            '(35202-1234567-1) on the review screen.',
      );
      return null;
    }

    state = state.copyWith(
      extraction: normalized,
      isSubmitting: true,
      clearError: true,
    );
    try {
      final status = await _repository.submitVerification(
        VerificationSubmission(
          cnicNumber: normalized.cnicNumber,
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
