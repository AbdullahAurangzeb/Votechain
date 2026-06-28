/// Local verification flow phases (mock OCR pipeline).
enum VerificationPhase {
  upload,
  scanning,
  review,
  pending,
}

enum ScanPipelineStep {
  uploadComplete,
  detectingDocument,
  extractingInformation,
  faceVerification,
}
