import 'package:image_picker/image_picker.dart';

import '../entities/cnic_extraction.dart';

/// Contract for on-device CNIC OCR extraction (no backend calls).
abstract interface class OcrRepository {
  Future<CnicExtraction> extractFromImage(XFile image);
}
