import 'package:image_picker/image_picker.dart';

import '../domain/entities/cnic_extraction.dart';
import '../domain/failures/verification_failure.dart';
import '../domain/ocr_result.dart';
import '../domain/repositories/ocr_repository.dart';
import 'cnic_parser.dart';
import 'mlkit_ocr_service.dart';
import 'ocr_result_mapper.dart';

/// On-device CNIC OCR using Google ML Kit and deterministic parsing.
class LocalOcrRepositoryImpl implements OcrRepository {
  LocalOcrRepositoryImpl({
    MlKitOcrService? ocrService,
    CnicParser? parser,
    OcrResultMapper? mapper,
  })  : _ocrService = ocrService ?? const MlKitOcrService(),
        _parser = parser ?? const CnicParser(),
        _mapper = mapper ?? const OcrResultMapper();

  static const String ocrReadFailureMessage =
      'Unable to read the CNIC. Please upload a clearer image.';

  final MlKitOcrService _ocrService;
  final CnicParser _parser;
  final OcrResultMapper _mapper;

  @override
  Future<CnicExtraction> extractFromImage(XFile image) async {
    try {
      final document = await _ocrService.recognize(image);
      if (document.normalizedLines.isEmpty && document.rawLines.isEmpty) {
        throw const VerificationFailure(ocrReadFailureMessage);
      }

      final OcrResult ocrResult = _parser.parseDocument(document);
      final extraction = _mapper.toCnicExtraction(ocrResult);

      final hasAnyField = extraction.fullName.isNotEmpty ||
          extraction.cnicNumber.isNotEmpty ||
          extraction.dateOfBirth.isNotEmpty ||
          extraction.gender.isNotEmpty ||
          extraction.fatherName.isNotEmpty ||
          extraction.issueDate.isNotEmpty ||
          extraction.expiryDate.isNotEmpty;

      if (!hasAnyField) {
        throw const VerificationFailure(ocrReadFailureMessage);
      }

      return extraction;
    } on VerificationFailure {
      rethrow;
    } catch (_) {
      throw const VerificationFailure(ocrReadFailureMessage);
    }
  }
}
