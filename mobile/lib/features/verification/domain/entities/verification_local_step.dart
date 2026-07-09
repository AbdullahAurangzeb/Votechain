/// Locally persisted verification step before backend submission.
enum VerificationLocalStep {
  upload('upload'),
  ocrCompleted('ocr_completed'),
  facePending('face_pending');

  const VerificationLocalStep(this.storageValue);

  final String storageValue;

  static VerificationLocalStep fromStorage(String? value) {
    return VerificationLocalStep.values.firstWhere(
      (step) => step.storageValue == value,
      orElse: () => VerificationLocalStep.upload,
    );
  }
}
