import 'package:image_picker/image_picker.dart';

import '../../domain/entities/cnic_extraction.dart';
import '../../domain/repositories/ocr_repository.dart';

/// Coordinates local OCR extraction for the verification presentation flow.
class OcrController {
  const OcrController(this._ocrRepository);

  final OcrRepository _ocrRepository;

  Future<CnicExtraction> extractFromImage(XFile image) {
    return _ocrRepository.extractFromImage(image);
  }
}
