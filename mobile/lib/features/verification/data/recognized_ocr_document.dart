/// Bounding box for an OCR line or element when ML Kit provides coordinates.
class OcrBoundingBox {
  const OcrBoundingBox({
    required this.left,
    required this.top,
    required this.width,
    required this.height,
  });

  final double left;
  final double top;
  final double width;
  final double height;

  double get right => left + width;
  double get bottom => top + height;
  double get centerX => left + (width / 2);
  double get centerY => top + (height / 2);

  @override
  String toString() =>
      '(${left.toStringAsFixed(0)},${top.toStringAsFixed(0)},'
      '${width.toStringAsFixed(0)}x${height.toStringAsFixed(0)})';
}

/// Single OCR word/element inside a line.
class OcrTextElement {
  const OcrTextElement({
    required this.text,
    this.boundingBox,
  });

  final String text;
  final OcrBoundingBox? boundingBox;
}

/// Single OCR line preserved in reading order.
class OcrTextLine {
  const OcrTextLine({
    required this.text,
    this.boundingBox,
    this.elements = const [],
  });

  final String text;
  final OcrBoundingBox? boundingBox;
  final List<OcrTextElement> elements;
}

/// OCR block containing ordered lines.
class OcrTextBlock {
  const OcrTextBlock({
    required this.text,
    required this.lines,
  });

  final String text;
  final List<OcrTextLine> lines;
}

/// Full ML Kit recognition output with raw and normalized forms.
class RecognizedOcrDocument {
  const RecognizedOcrDocument({
    required this.rawLines,
    required this.normalizedLines,
    required this.blocks,
    required this.rawText,
    required this.normalizedText,
    this.orderedLines = const [],
  });

  final List<String> rawLines;
  final List<String> normalizedLines;
  final List<OcrTextBlock> blocks;
  final String rawText;
  final String normalizedText;

  /// Flat reading-order lines with optional geometry for spatial matching.
  final List<OcrTextLine> orderedLines;

  /// Prefer [orderedLines]; fall back to [normalizedLines] / [rawLines].
  List<OcrTextLine> get linesForParsing {
    if (orderedLines.isNotEmpty) return orderedLines;
    final source =
        normalizedLines.isNotEmpty ? normalizedLines : rawLines;
    return source
        .map((text) => OcrTextLine(text: text))
        .toList(growable: false);
  }
}
