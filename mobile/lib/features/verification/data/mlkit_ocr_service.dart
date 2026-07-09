import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';

/// Runs on-device text recognition using Google ML Kit.
class MlKitOcrService {
  const MlKitOcrService();

  /// Extracts non-empty text lines from an image using ML Kit Latin script OCR.
  Future<List<String>> extractLines(XFile image) async {
    final recognizer = TextRecognizer(script: TextRecognitionScript.latin);

    try {
      final inputImage = InputImage.fromFilePath(image.path);
      final recognizedText = await recognizer.processImage(inputImage);

      return recognizedText.blocks
          .expand((block) => block.lines)
          .map((line) => line.text.trim())
          .where((line) => line.isNotEmpty)
          .toList(growable: false);
    } finally {
      await recognizer.close();
    }
  }
}
