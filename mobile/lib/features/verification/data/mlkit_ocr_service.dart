import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';

import 'cnic_image_preprocessor.dart';
import 'ocr_debug_logger.dart';
import 'recognized_ocr_document.dart';

/// Runs on-device text recognition using Google ML Kit after image preprocessing.
class MlKitOcrService {
  const MlKitOcrService({
    CnicImagePreprocessor? preprocessor,
  }) : _preprocessor = preprocessor ?? const CnicImagePreprocessor();

  final CnicImagePreprocessor _preprocessor;

  /// Extracts ordered OCR content from a CNIC image.
  Future<RecognizedOcrDocument> recognize(XFile image) async {
    final preprocessed = await _preprocessor.preprocess(image);
    final recognizer = TextRecognizer(script: TextRecognitionScript.latin);

    try {
      final inputImage = InputImage.fromFilePath(preprocessed.file.path);
      final recognizedText = await recognizer.processImage(inputImage);
      final document = _toDocument(recognizedText);
      OcrDebugLogger.logDocument(document);
      return document;
    } finally {
      await recognizer.close();
    }
  }

  /// Backward-compatible line extraction used by older call sites/tests.
  Future<List<String>> extractLines(XFile image) async {
    final document = await recognize(image);
    return document.normalizedLines;
  }

  RecognizedOcrDocument _toDocument(RecognizedText recognizedText) {
    final blocks = <OcrTextBlock>[];
    final allLines = <OcrTextLine>[];

    final sortedBlocks = [...recognizedText.blocks]
      ..sort((a, b) => _compareBoxes(a.boundingBox, b.boundingBox, 14));

    for (final block in sortedBlocks) {
      final sortedLines = [...block.lines]
        ..sort((a, b) => _compareBoxes(a.boundingBox, b.boundingBox, 8));

      final ocrLines = <OcrTextLine>[];
      for (final line in sortedLines) {
        final text = line.text.trim();
        if (text.isEmpty) continue;

        final box = line.boundingBox;
        final elements = line.elements
            .map(
              (el) => OcrTextElement(
                text: el.text.trim(),
                boundingBox: OcrBoundingBox(
                  left: el.boundingBox.left.toDouble(),
                  top: el.boundingBox.top.toDouble(),
                  width: el.boundingBox.width.toDouble(),
                  height: el.boundingBox.height.toDouble(),
                ),
              ),
            )
            .where((el) => el.text.isNotEmpty)
            .toList(growable: false);

        final ocrLine = OcrTextLine(
          text: text,
          boundingBox: OcrBoundingBox(
            left: box.left.toDouble(),
            top: box.top.toDouble(),
            width: box.width.toDouble(),
            height: box.height.toDouble(),
          ),
          elements: elements,
        );
        ocrLines.add(ocrLine);
        allLines.add(ocrLine);
      }

      if (ocrLines.isEmpty) continue;
      blocks.add(
        OcrTextBlock(
          text: block.text.trim(),
          lines: List.unmodifiable(ocrLines),
        ),
      );
    }

    // Global reading order across blocks prevents scrambled field assignment.
    allLines.sort(
      (a, b) => _compareOcrBoxes(a.boundingBox, b.boundingBox, 10),
    );

    final rawLineTexts =
        allLines.map((line) => line.text).toList(growable: false);
    final mergedRaw = _mergeWrappedFragments(rawLineTexts);
    final mergedLines = _mergeWrappedOcrLines(allLines);
    final normalized = _normalizeLines(mergedRaw);

    return RecognizedOcrDocument(
      rawLines: List.unmodifiable(mergedRaw),
      normalizedLines: List.unmodifiable(normalized),
      blocks: List.unmodifiable(blocks),
      orderedLines: List.unmodifiable(mergedLines),
      rawText: mergedRaw.join('\n'),
      normalizedText: normalized.join('\n'),
    );
  }

  int _compareBoxes(dynamic a, dynamic b, double rowThreshold) {
    final topDiff = a.top - b.top;
    if (topDiff.abs() > rowThreshold) return topDiff < 0 ? -1 : 1;
    final leftDiff = a.left - b.left;
    return leftDiff < 0 ? -1 : leftDiff > 0 ? 1 : 0;
  }

  int _compareOcrBoxes(
    OcrBoundingBox? a,
    OcrBoundingBox? b,
    double rowThreshold,
  ) {
    if (a == null && b == null) return 0;
    if (a == null) return 1;
    if (b == null) return -1;
    final topDiff = a.top - b.top;
    if (topDiff.abs() > rowThreshold) return topDiff < 0 ? -1 : 1;
    final leftDiff = a.left - b.left;
    return leftDiff < 0 ? -1 : leftDiff > 0 ? 1 : 0;
  }

  List<OcrTextLine> _mergeWrappedOcrLines(List<OcrTextLine> lines) {
    if (lines.isEmpty) return const [];

    final merged = <OcrTextLine>[];
    for (final line in lines) {
      final trimmed = line.text.trim();
      if (trimmed.isEmpty) continue;

      if (merged.isEmpty) {
        merged.add(line);
        continue;
      }

      final previous = merged.last;
      if (_shouldMergeNameFragments(previous.text, trimmed) ||
          _shouldMergeDigitFragments(previous.text, trimmed)) {
        final joiner = _shouldMergeDigitFragments(previous.text, trimmed)
            ? ''
            : (_shouldConcatenateWithoutSpace(previous.text, trimmed)
                ? ''
                : ' ');
        merged[merged.length - 1] = OcrTextLine(
          text: '${previous.text}$joiner$trimmed',
          boundingBox: previous.boundingBox,
          elements: [...previous.elements, ...line.elements],
        );
      } else {
        merged.add(line);
      }
    }
    return merged;
  }

  List<String> _mergeWrappedFragments(List<String> lines) {
    if (lines.isEmpty) return const [];

    final merged = <String>[];
    for (final line in lines) {
      final trimmed = line.trim();
      if (trimmed.isEmpty) continue;

      if (merged.isEmpty) {
        merged.add(trimmed);
        continue;
      }

      final previous = merged.last;
      if (_shouldMergeNameFragments(previous, trimmed)) {
        final joiner =
            _shouldConcatenateWithoutSpace(previous, trimmed) ? '' : ' ';
        merged[merged.length - 1] = '$previous$joiner$trimmed';
      } else if (_shouldMergeDigitFragments(previous, trimmed)) {
        merged[merged.length - 1] = '$previous$trimmed';
      } else {
        merged.add(trimmed);
      }
    }
    return merged;
  }

  bool _shouldConcatenateWithoutSpace(String left, String right) {
    final leftLetters = left.replaceAll(RegExp(r'[^A-Za-z]'), '');
    final rightLetters = right.replaceAll(RegExp(r'[^A-Za-z]'), '');
    if (leftLetters.isEmpty || rightLetters.isEmpty) return false;
    final leftToken = leftLetters.split(RegExp(r'\s+')).last;
    final rightToken = rightLetters.split(RegExp(r'\s+')).first;
    return leftToken.length <= 5 && rightToken.length <= 5;
  }

  bool _shouldMergeNameFragments(String left, String right) {
    final leftLetters = left.replaceAll(RegExp(r'[^A-Za-z]'), '');
    final rightLetters = right.replaceAll(RegExp(r'[^A-Za-z]'), '');
    if (leftLetters.isEmpty || rightLetters.isEmpty) return false;
    if (RegExp(r'\d').hasMatch(left) || RegExp(r'\d').hasMatch(right)) {
      return false;
    }

    final leftLooksBroken = leftLetters.length <= 4 ||
        (!left.trim().contains(' ') && leftLetters.length <= 6);
    final rightLooksBroken = (rightLetters.length <= 5 &&
            rightLetters == rightLetters.toLowerCase()) ||
        rightLetters.length <= 4;

    return leftLooksBroken && rightLooksBroken;
  }

  /// Joins split CNIC pieces like "35202-" + "1234567-1".
  bool _shouldMergeDigitFragments(String left, String right) {
    final leftDigits = left.replaceAll(RegExp(r'[^0-9OoIiSsBbZz]'), '');
    final rightDigits = right.replaceAll(RegExp(r'[^0-9OoIiSsBbZz]'), '');
    if (leftDigits.isEmpty || rightDigits.isEmpty) return false;

    final combined = leftDigits.length + rightDigits.length;
    if (combined > 14) return false;

    final leftIsDigitHeavy =
        RegExp(r'^[\dOoIiSsBbZz\s\-]+$', caseSensitive: false).hasMatch(left.trim());
    final rightIsDigitHeavy =
        RegExp(r'^[\dOoIiSsBbZz\s\-]+$', caseSensitive: false).hasMatch(right.trim());

    return leftIsDigitHeavy &&
        rightIsDigitHeavy &&
        leftDigits.length <= 8 &&
        rightDigits.length <= 8;
  }

  List<String> _normalizeLines(List<String> lines) {
    final normalized = <String>[];
    for (final line in lines) {
      final value = line
          .replaceAll('—', '-')
          .replaceAll('–', '-')
          .replaceAll('|', ' ')
          .replaceAll(RegExp(r'[^\S\r\n]+'), ' ')
          .trim();
      if (value.isEmpty) continue;

      final upper = value.toUpperCase();
      if (normalized.isNotEmpty && normalized.last.toUpperCase() == upper) {
        continue;
      }
      normalized.add(value);
    }
    return normalized;
  }
}
