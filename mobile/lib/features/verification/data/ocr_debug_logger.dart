import 'package:flutter/foundation.dart';

import '../domain/ocr_result.dart';
import 'recognized_ocr_document.dart';

/// Development-only OCR diagnostics for Smart CNIC parsing.
abstract final class OcrDebugLogger {
  static void logPreprocess({
    required int originalWidth,
    required int originalHeight,
    required int processedWidth,
    required int processedHeight,
  }) {
    _log([
      '[VoteChain][OCR][Preprocess]',
      '  original: ${originalWidth}x$originalHeight',
      '  processed: ${processedWidth}x$processedHeight',
    ]);
  }

  static void logDocument(RecognizedOcrDocument document) {
    _log([
      '[VoteChain][OCR][Document]',
      '  rawText:',
      ...document.rawLines.map((line) => '    $line'),
      '  normalizedText:',
      ...document.normalizedLines.map((line) => '    $line'),
      '  blocks: ${document.blocks.length}',
    ]);

    for (var b = 0; b < document.blocks.length; b++) {
      final block = document.blocks[b];
      _log(['  block[$b]: ${block.text}']);
      for (var l = 0; l < block.lines.length; l++) {
        final line = block.lines[l];
        _log([
          '    line[$l]: ${line.text}'
          '${line.boundingBox != null ? ' @${line.boundingBox}' : ''}',
        ]);
      }
    }
  }

  static void logParseTrace({
    required List<String> regexMatches,
    required List<String> rejectedCandidates,
    required OcrResult result,
  }) {
    _log([
      '[VoteChain][OCR][Parser]',
      '  regexMatches:',
      ...regexMatches.map((m) => '    $m'),
      '  rejectedCandidates:',
      ...rejectedCandidates.map((c) => '    $c'),
      '  extracted:',
      '    name=${result.name}',
      '    fatherName=${result.fatherName}',
      '    husbandName=${result.husbandName}',
      '    cnic=${result.cnic}',
      '    dateOfBirth=${result.dateOfBirth}',
      '    gender=${result.gender}',
      '    issueDate=${result.issueDate}',
      '    expiryDate=${result.expiryDate}',
      '  missing:',
      ..._missingFields(result).map((f) => '    $f'),
    ]);
  }

  static List<String> _missingFields(OcrResult result) {
    final missing = <String>[];
    if (result.name == null || result.name!.isEmpty) missing.add('name');
    if ((result.fatherName == null || result.fatherName!.isEmpty) &&
        (result.husbandName == null || result.husbandName!.isEmpty)) {
      missing.add('fatherName/husbandName');
    }
    if (result.cnic == null || result.cnic!.isEmpty) missing.add('cnic');
    if (result.dateOfBirth == null || result.dateOfBirth!.isEmpty) {
      missing.add('dateOfBirth');
    }
    if (result.gender == null || result.gender!.isEmpty) missing.add('gender');
    if (result.issueDate == null || result.issueDate!.isEmpty) {
      missing.add('issueDate');
    }
    if (result.expiryDate == null || result.expiryDate!.isEmpty) {
      missing.add('expiryDate');
    }
    return missing;
  }

  static void _log(List<String> lines) {
    if (!kDebugMode) return;
    for (final line in lines) {
      debugPrint(line);
    }
  }
}
