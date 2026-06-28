/// Mock face registration AI pipeline steps.
enum FaceProcessingStep {
  faceDetected,
  generatingEmbedding,
  checkingDuplicate,
  encryptingProfile,
}

/// Live face verification outcome (mock).
enum LiveVerificationStatus {
  idle,
  verifying,
  success,
  failure,
}
