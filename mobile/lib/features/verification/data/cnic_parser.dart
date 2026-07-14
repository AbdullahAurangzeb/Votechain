import 'dart:math' as math;

import '../domain/ocr_result.dart';
import 'ocr_debug_logger.dart';
import 'recognized_ocr_document.dart';

/// Deterministic Pakistani Smart CNIC parser with multi-line and noise handling.
class CnicParser {
  /// Digit-group pattern allowing common OCR letter confusions in each group.
  static final RegExp _cnicPattern = RegExp(
    r'([0-9OoIiSsBbZz]{5})[\s\-]*([0-9OoIiSsBbZz]{7})[\s\-]*([0-9OoIiLl])',
    caseSensitive: false,
  );
  static final RegExp _looseCnicDigits = RegExp(r'[0-9]{13}');
  static final RegExp _datePattern = RegExp(
    r'\b([0-9OoIiSsBbZz]{1,2})[./\-]([0-9OoIiSsBbZz]{1,2})[./\-]([0-9OoIiSsBbZz]{2,4})\b',
    caseSensitive: false,
  );
  static final RegExp _nameLabelPattern = RegExp(
    r'^(?:NAME|NAAM|FULL\s*NAME|NANE|NAMF)\b\s*[:\-]?\s*(.*)$',
    caseSensitive: false,
  );
  static final RegExp _fatherLabelPattern = RegExp(
    r"^(?:FATHER(?:'S)?\s*NAME|FATHER\s*NAME|FATHERS?\s*NAME|FOTHER\s*NAME|"
    r"FAILHER\s*NAME|S\/O|S\s*\/\s*O|SO)\b\s*[:\-]?\s*(.*)$",
    caseSensitive: false,
  );
  static final RegExp _husbandLabelPattern = RegExp(
    r"^(?:HUSBAND(?:'S)?\s*NAME|HUSBAND\s*NAME|HUSBANDS?\s*NAME|"
    r"W\/O|W\s*\/\s*O|WO)\b\s*[:\-]?\s*(.*)$",
    caseSensitive: false,
  );
  static final RegExp _dobLabelPattern = RegExp(
    r'^(?:DATE\s*OF\s*BIRTH|DALE\s*OF\s*BIRTH|DOTE\s*OF\s*BIRTH|'
    r'D[. ]?O[. ]?B|BIRTH\s*DATE|BIRTH)\b\s*[:\-]?\s*(.*)$',
    caseSensitive: false,
  );
  static final RegExp _issueLabelPattern = RegExp(
    r'^(?:DATE\s*OF\s*ISSUE|DALE\s*OF\s*ISSUE|ISSUE\s*DATE|'
    r'ISSUED(?:\s*ON)?|DOI)\b\s*[:\-]?\s*(.*)$',
    caseSensitive: false,
  );
  static final RegExp _expiryLabelPattern = RegExp(
    r'^(?:DATE\s*OF\s*EXPIRY|DALE\s*OF\s*EXPIRY|EXPIRY\s*DATE|'
    r'EXPIRES?(?:\s*ON)?|VALID\s*UP\s*TO|VALID\s*THRU|DOE)\b\s*[:\-]?\s*(.*)$',
    caseSensitive: false,
  );
  static final RegExp _genderLabelPattern = RegExp(
    r'^(?:GENDER|SEX|GENDFR|GENDEF)\b\s*[:\-]?\s*(.*)$',
    caseSensitive: false,
  );
  static final RegExp _identityLabelPattern = RegExp(
    r'^(?:IDENTITY\s*NUMBER|IDENLITY\s*NUMBER|IDENTITY\s*NUMHER|'
    r'CNIC|NIC|N\.?I\.?C\.?|ID\s*NO(?:\.|MBER)?)\b\s*[:\-]?\s*(.*)$',
    caseSensitive: false,
  );
  static final RegExp _nameLikePattern = RegExp(r"^[A-Z][A-Z\s'.]{1,}$");
  static final RegExp _digitHeavyToken = RegExp(
    r'^[\dOoIiLlSsBbZz\s\-]{5,}$',
    caseSensitive: false,
  );

  static const Set<String> _noiseTokens = {
    'ISLAMIC',
    'REPUBLIC',
    'OF',
    'PAKISTAN',
    'NATIONAL',
    'IDENTITY',
    'CARD',
    'NADRA',
    'GOVERNMENT',
    'HOLDER',
    'HOLDERS',
    'SIGNATURE',
    'SIGN',
    'DATE',
    'ISSUE',
    'EXPIRY',
    'EXPIRES',
    'VALID',
    'UNTIL',
    'THRU',
    'CNIC',
    'NIC',
    'UID',
    'COUNTRY',
    'STAY',
    'PERMANENT',
    'ADDRESS',
    'NUMBER',
    'PAKISTANI',
    'CITIZEN',
    'SMART',
    'CHIP',
    'MACHINE',
    'READABLE',
    'ZONE',
    'BARCODE',
    'QR',
    'CODE',
    'DOCUMENT',
    'GENDER',
    'SEX',
    'BIRTH',
    'NAME',
  };

  static const List<String> _noisePhrases = [
    'ISLAMIC REPUBLIC OF PAKISTAN',
    'NATIONAL IDENTITY CARD',
    'GOVERNMENT OF PAKISTAN',
    'IDENTITY CARD',
    'PAKISTAN NATIONAL',
    'HOLDER SIGNATURE',
    "HOLDER'S SIGNATURE",
    'MACHINE READABLE ZONE',
    'SMART CARD',
    'NADRA',
    'COUNTRY OF STAY',
    'PERMANENT ADDRESS',
  ];

  const CnicParser();

  /// Parses OCR lines into structured CNIC fields.
  OcrResult parse(List<String> rawLines) {
    return parseDocument(
      RecognizedOcrDocument(
        rawLines: rawLines,
        normalizedLines: _normalizeInput(rawLines),
        blocks: const [],
        orderedLines: _normalizeInput(rawLines)
            .map((text) => OcrTextLine(text: text))
            .toList(growable: false),
        rawText: rawLines.join('\n'),
        normalizedText: _normalizeInput(rawLines).join('\n'),
      ),
    );
  }

  /// Parses a full [RecognizedOcrDocument] with debug tracing.
  OcrResult parseDocument(RecognizedOcrDocument document) {
    final positioned = document.linesForParsing
        .map(
          (line) => _PosLine(
            text: line.text.toUpperCase().trim(),
            box: line.boundingBox,
          ),
        )
        .where((line) => line.text.isNotEmpty)
        .toList(growable: false);

    final lines = positioned.map((l) => l.text).toList(growable: false);

    final regexMatches = <String>[];
    final rejected = <String>[];

    final cnic = _extractCnic(lines, positioned, regexMatches, rejected);
    final fatherName = _extractLabeledMultiLineName(
      lines,
      positioned,
      _fatherLabelPattern,
      rejected,
    );
    final husbandName = _extractLabeledMultiLineName(
      lines,
      positioned,
      _husbandLabelPattern,
      rejected,
    );
    final name = _extractName(
      lines,
      positioned,
      fatherName: fatherName,
      husbandName: husbandName,
      rejected: rejected,
    );

    final labeledDob =
        _extractLabeledDate(lines, positioned, _dobLabelPattern, regexMatches);
    final labeledIssue = _extractLabeledDate(
      lines,
      positioned,
      _issueLabelPattern,
      regexMatches,
    );
    final labeledExpiry = _extractLabeledDate(
      lines,
      positioned,
      _expiryLabelPattern,
      regexMatches,
    );

    final dates = _extractAllDates(lines, regexMatches);
    final assigned = _assignDates(
      dates: dates,
      labeledDob: labeledDob,
      labeledIssue: labeledIssue,
      labeledExpiry: labeledExpiry,
    );

    final gender = _extractGender(lines, regexMatches);

    final result = OcrResult(
      name: name,
      fatherName: fatherName,
      husbandName: husbandName,
      cnic: cnic,
      dateOfBirth: assigned.dob,
      gender: gender,
      issueDate: assigned.issue,
      expiryDate: assigned.expiry,
      rawText: document.rawLines,
      normalizedText: document.normalizedLines.isNotEmpty
          ? document.normalizedLines
          : _normalizeInput(document.rawLines),
    );

    OcrDebugLogger.logParseTrace(
      regexMatches: regexMatches,
      rejectedCandidates: rejected,
      result: result,
    );

    return result;
  }

  List<String> _normalizeInput(List<String> rawLines) {
    final out = <String>[];
    for (final line in rawLines) {
      final value = line
          .replaceAll('—', '-')
          .replaceAll('–', '-')
          .replaceAll('|', ' ')
          .replaceAll(RegExp(r'\s+'), ' ')
          .trim();
      if (value.isEmpty) continue;
      if (out.isNotEmpty && out.last.toUpperCase() == value.toUpperCase()) {
        continue;
      }
      out.add(value);
    }
    return out;
  }

  String? _extractCnic(
    List<String> lines,
    List<_PosLine> positioned,
    List<String> regexMatches,
    List<String> rejected,
  ) {
    for (var i = 0; i < lines.length; i++) {
      final line = lines[i];
      final labeled = _identityLabelPattern.firstMatch(line);
      if (labeled != null) {
        final inline = labeled.group(1)?.trim() ?? '';
        final fromInline = _matchCnic(inline);
        if (fromInline != null) {
          regexMatches.add('cnic:label-inline=$fromInline');
          return fromInline;
        }

        final spatial = _spatialValueNear(positioned, i, preferDigits: true);
        final fromSpatial = spatial == null ? null : _matchCnic(spatial);
        if (fromSpatial != null) {
          regexMatches.add('cnic:label-spatial=$fromSpatial');
          return fromSpatial;
        }

        final window = _window(lines, i + 1, 3);
        final fromNext = _matchCnic(window);
        if (fromNext != null) {
          regexMatches.add('cnic:label-next=$fromNext');
          return fromNext;
        }
      }
    }

    // Prefer explicit dashed/spaced forms before loose 13-digit fallback.
    for (var i = 0; i < lines.length; i++) {
      final windows = [
        lines[i],
        if (i + 1 < lines.length) '${lines[i]} ${lines[i + 1]}',
        if (i + 2 < lines.length)
          '${lines[i]} ${lines[i + 1]} ${lines[i + 2]}',
        if (i + 3 < lines.length)
          '${lines[i]} ${lines[i + 1]} ${lines[i + 2]} ${lines[i + 3]}',
      ];
      for (final window in windows) {
        final matched = _matchCnic(window, preferPatterned: true);
        if (matched != null) {
          regexMatches.add('cnic:window=$matched');
          return matched;
        }
      }
    }

    for (var i = 0; i < lines.length; i++) {
      final windows = [
        lines[i],
        if (i + 1 < lines.length) '${lines[i]}${lines[i + 1]}',
        if (i + 2 < lines.length)
          '${lines[i]}${lines[i + 1]}${lines[i + 2]}',
      ];
      for (final window in windows) {
        final matched = _matchCnic(window);
        if (matched != null) {
          regexMatches.add('cnic:concat=$matched');
          return matched;
        }
      }
    }

    rejected.add('cnic:no-13-digit-match');
    return null;
  }

  String? _matchCnic(String text, {bool preferPatterned = false}) {
    final fixed = _applyDigitOcrFixes(_forceDigitHeavyTokens(text));
    final patterned = _cnicPattern.firstMatch(fixed);
    if (patterned != null) {
      final digits = _toDigitsOnly(
        '${patterned.group(1)}${patterned.group(2)}${patterned.group(3)}',
      );
      if (digits.length == 13 && _isPlausibleCnic(digits)) {
        return _formatCnic(digits);
      }
    }

    if (preferPatterned) return null;

    final digitsOnly = _toDigitsOnly(fixed);
    final loose = _looseCnicDigits.firstMatch(digitsOnly);
    if (loose != null && _isPlausibleCnic(loose.group(0)!)) {
      return _formatCnic(loose.group(0)!);
    }
    return null;
  }

  /// Pakistani CNIC area codes are 5 digits starting with 1–9 (not 00000).
  bool _isPlausibleCnic(String digits) {
    if (digits.length != 13) return false;
    if (digits.startsWith('00000')) return false;
    if (!RegExp(r'^[1-9]\d{4}\d{7}\d$').hasMatch(digits)) return false;
    return true;
  }

  String _formatCnic(String digits) =>
      '${digits.substring(0, 5)}-${digits.substring(5, 12)}-${digits.substring(12)}';

  String _toDigitsOnly(String text) =>
      _applyDigitOcrFixes(text).replaceAll(RegExp(r'\D'), '');

  /// When a whole token looks like a CNIC fragment, convert confusable letters.
  String _forceDigitHeavyTokens(String text) {
    return text.split(RegExp(r'\s+')).map((token) {
      if (_digitHeavyToken.hasMatch(token) ||
          RegExp(r'[\dOoIiLlSsBbZz]{4,}[\-]?[\dOoIiLlSsBbZz]*',
                  caseSensitive: false)
              .hasMatch(token)) {
        return token
            .replaceAll(RegExp('[Oo]'), '0')
            .replaceAll(RegExp('[IiLl]'), '1')
            .replaceAll(RegExp('[Ss]'), '5')
            .replaceAll(RegExp('[Bb]'), '8')
            .replaceAll(RegExp('[Zz]'), '2');
      }
      return token;
    }).join(' ');
  }

  String _applyDigitOcrFixes(String text) {
    final buffer = StringBuffer();
    final upper = text.toUpperCase();
    for (var i = 0; i < upper.length; i++) {
      final ch = upper[i];
      final before = i > 0 ? upper[i - 1] : '';
      final after = i + 1 < upper.length ? upper[i + 1] : '';
      final digitContext = _isDigitish(before) || _isDigitish(after);

      switch (ch) {
        case 'O':
          buffer.write(digitContext ? '0' : 'O');
          break;
        case 'I':
        case 'L':
          buffer.write(digitContext ? '1' : ch);
          break;
        case 'S':
          buffer.write(_isDigitish(before) && _isDigitish(after) ? '5' : 'S');
          break;
        case 'B':
          buffer.write(_isDigitish(before) && _isDigitish(after) ? '8' : 'B');
          break;
        case 'Z':
          buffer.write(_isDigitish(before) && _isDigitish(after) ? '2' : 'Z');
          break;
        default:
          buffer.write(ch);
      }
    }
    return buffer.toString();
  }

  bool _isDigitish(String char) =>
      char.isNotEmpty && RegExp(r'[\d\-OoIiLlSsBbZz]').hasMatch(char);

  String? _extractName(
    List<String> lines,
    List<_PosLine> positioned, {
    required String? fatherName,
    required String? husbandName,
    required List<String> rejected,
  }) {
    final labeled = _extractLabeledMultiLineName(
      lines,
      positioned,
      _nameLabelPattern,
      rejected,
    );
    if (labeled != null) return labeled;

    for (var i = 0; i < lines.length; i++) {
      final line = lines[i];
      if (_isNoiseLine(line)) {
        rejected.add('name:noise=$line');
        continue;
      }
      if (_isAnyLabel(line) || _matchCnic(line) != null) continue;
      if (_datePattern.hasMatch(line)) continue;

      final cleaned = _cleanupName(line);
      if (cleaned == null) {
        rejected.add('name:rejected=$line');
        continue;
      }

      final upper = cleaned.toUpperCase();
      if (fatherName != null && upper == fatherName.toUpperCase()) continue;
      if (husbandName != null && upper == husbandName.toUpperCase()) continue;

      final continuation = _collectNameContinuation(lines, i + 1, upper);
      return continuation == null ? cleaned : '$cleaned $continuation';
    }
    return null;
  }

  String? _extractLabeledMultiLineName(
    List<String> lines,
    List<_PosLine> positioned,
    RegExp pattern,
    List<String> rejected,
  ) {
    for (var i = 0; i < lines.length; i++) {
      final match = pattern.firstMatch(lines[i]);
      if (match == null) continue;

      final parts = <String>[];
      final inline = match.group(1)?.trim() ?? '';
      if (inline.isNotEmpty) {
        final cleaned = _cleanupName(inline);
        if (cleaned != null) parts.add(cleaned);
      }

      if (parts.isEmpty) {
        final spatial = _spatialValueNear(positioned, i, preferName: true);
        if (spatial != null) {
          final cleaned = _cleanupName(spatial);
          if (cleaned != null) parts.add(cleaned);
        }
      }

      for (var j = i + 1; j < lines.length && j <= i + 5; j++) {
        final next = lines[j];
        if (_isAnyLabel(next) || _isNoiseLine(next) || _matchCnic(next) != null) {
          break;
        }
        if (_datePattern.hasMatch(next)) break;
        if (_parseGenderValue(next) != null &&
            RegExp(r'^(MALE|FEMALE|M|F)$').hasMatch(next.trim())) {
          break;
        }
        final cleaned = _cleanupName(next);
        if (cleaned == null) {
          rejected.add('name-fragment:rejected=$next');
          // Soft break: skip garbage, keep looking for short continuations.
          if (next.replaceAll(RegExp(r'[^A-Z]'), '').length > 8) break;
          continue;
        }
        parts.add(cleaned);
        if (_joinedNameWordCount(parts) >= 4) break;
      }

      if (parts.isEmpty) continue;
      return _joinNameParts(parts);
    }
    return null;
  }

  String _joinNameParts(List<String> parts) {
    if (parts.isEmpty) return '';
    var joined = parts.first;
    for (var i = 1; i < parts.length; i++) {
      final next = parts[i];
      if (_shouldConcatenateNameFragments(joined, next)) {
        joined = '$joined$next';
      } else {
        joined = '$joined $next';
      }
    }
    return joined
        .split(RegExp(r'\s+'))
        .where((w) => w.isNotEmpty)
        .map((part) {
          final upper = part.toUpperCase();
          return '${upper[0]}${upper.substring(1).toLowerCase()}';
        })
        .join(' ');
  }

  bool _shouldConcatenateNameFragments(String left, String right) {
    final leftToken = left.split(' ').last;
    final rightToken = right.split(' ').first;
    if (leftToken.length <= 5 && rightToken.length <= 5) {
      return true;
    }
    if (leftToken.length <= 6 && rightToken.length <= 3) {
      return true;
    }
    // Mid-word break: previous ends lowercase-ish short stem (OCR uppercase).
    if (leftToken.length <= 7 &&
        rightToken.length <= 4 &&
        !right.contains(' ')) {
      return true;
    }
    return false;
  }

  int _joinedNameWordCount(List<String> parts) {
    return _joinNameParts(parts).split(' ').where((w) => w.isNotEmpty).length;
  }

  String? _collectNameContinuation(
    List<String> lines,
    int start,
    String alreadyUpper,
  ) {
    final parts = <String>[];
    for (var i = start; i < lines.length && i < start + 3; i++) {
      final line = lines[i];
      if (_isAnyLabel(line) || _isNoiseLine(line) || _matchCnic(line) != null) {
        break;
      }
      final cleaned = _cleanupName(line);
      if (cleaned == null) break;
      if (cleaned.toUpperCase() == alreadyUpper) break;
      parts.add(cleaned);
    }
    if (parts.isEmpty) return null;
    return _joinNameParts(parts);
  }

  String? _extractLabeledDate(
    List<String> lines,
    List<_PosLine> positioned,
    RegExp pattern,
    List<String> regexMatches,
  ) {
    for (var i = 0; i < lines.length; i++) {
      final match = pattern.firstMatch(lines[i]);
      if (match == null) continue;

      final inline = match.group(1)?.trim() ?? '';
      final inlineDate = _normalizeDate(inline);
      if (inlineDate != null) {
        regexMatches.add('date:labeled-inline=$inlineDate');
        return inlineDate;
      }

      final spatial = _spatialValueNear(positioned, i, preferDigits: true);
      final spatialDate = spatial == null ? null : _normalizeDate(spatial);
      if (spatialDate != null) {
        regexMatches.add('date:labeled-spatial=$spatialDate');
        return spatialDate;
      }

      final nextWindow = _window(lines, i + 1, 2);
      final nextDate = _normalizeDate(nextWindow);
      if (nextDate != null) {
        regexMatches.add('date:labeled-next=$nextDate');
        return nextDate;
      }
    }
    return null;
  }

  /// Picks OCR text to the right of or immediately below a label using boxes.
  String? _spatialValueNear(
    List<_PosLine> positioned,
    int labelIndex, {
    bool preferDigits = false,
    bool preferName = false,
  }) {
    if (labelIndex < 0 || labelIndex >= positioned.length) return null;
    final label = positioned[labelIndex];
    final labelBox = label.box;
    if (labelBox == null) return null;

    _PosLine? best;
    var bestScore = double.infinity;

    for (var i = 0; i < positioned.length; i++) {
      if (i == labelIndex) continue;
      final candidate = positioned[i];
      final box = candidate.box;
      if (box == null) continue;
      if (_isNoiseLine(candidate.text) || _isAnyLabel(candidate.text)) continue;

      final sameRow = (box.centerY - labelBox.centerY).abs() <=
          math.max(labelBox.height, box.height) * 0.85;
      final toTheRight = box.left >= labelBox.right - 8;
      final below = box.top >= labelBox.top - 4 &&
          box.top <= labelBox.bottom + (labelBox.height * 2.8);
      final alignedX =
          (box.left - labelBox.left).abs() <= labelBox.width * 1.5;

      if (!(sameRow && toTheRight) && !(below && alignedX)) continue;

      if (preferDigits &&
          !_datePattern.hasMatch(candidate.text) &&
          _matchCnic(candidate.text) == null &&
          !_digitHeavyToken.hasMatch(candidate.text.replaceAll(' ', ''))) {
        continue;
      }
      if (preferName && _cleanupName(candidate.text) == null) continue;

      final score = sameRow && toTheRight
          ? (box.left - labelBox.right).abs() +
              (box.centerY - labelBox.centerY).abs() * 0.5
          : (box.top - labelBox.bottom).abs() * 2 +
              (box.left - labelBox.left).abs();

      if (score < bestScore) {
        bestScore = score;
        best = candidate;
      }
    }

    return best?.text;
  }

  List<_ParsedDate> _extractAllDates(
    List<String> lines,
    List<String> regexMatches,
  ) {
    final found = <_ParsedDate>[];
    final seen = <String>{};

    for (var i = 0; i < lines.length; i++) {
      final windows = [
        lines[i],
        if (i + 1 < lines.length) '${lines[i]} ${lines[i + 1]}',
      ];
      for (final window in windows) {
        for (final match in _datePattern.allMatches(window)) {
          final normalized = _normalizeDate(match.group(0)!);
          if (normalized == null || !seen.add(normalized)) continue;
          final parsed = _toComparableDate(normalized);
          if (parsed == null) continue;
          found.add(parsed);
          regexMatches.add('date:found=$normalized');
        }
      }
    }

    found.sort((a, b) => a.sortKey.compareTo(b.sortKey));
    return found;
  }

  _AssignedDates _assignDates({
    required List<_ParsedDate> dates,
    required String? labeledDob,
    required String? labeledIssue,
    required String? labeledExpiry,
  }) {
    var dob = labeledDob;
    var issue = labeledIssue;
    var expiry = labeledExpiry;

    final remaining = dates
        .where(
          (d) =>
              d.formatted != dob &&
              d.formatted != issue &&
              d.formatted != expiry,
        )
        .toList();

    // Smart CNIC: DOB is almost always the oldest date on the card.
    if (dob == null && remaining.isNotEmpty) {
      remaining.sort((a, b) => a.sortKey.compareTo(b.sortKey));
      dob = remaining.removeAt(0).formatted;
    }

    if (issue == null || expiry == null) {
      final left = List<_ParsedDate>.from(remaining)
        ..sort((a, b) => a.sortKey.compareTo(b.sortKey));

      if (issue == null && expiry == null && left.length >= 2) {
        // Issue precedes expiry on Pakistani cards.
        issue = left[0].formatted;
        expiry = left[1].formatted;
      } else {
        if (issue == null && left.isNotEmpty) {
          issue = left.removeAt(0).formatted;
        }
        if (expiry == null && left.isNotEmpty) {
          expiry = left.removeAt(0).formatted;
        }
      }
    }

    if (issue != null && expiry != null) {
      final issueDate = _toComparableDate(issue);
      final expiryDate = _toComparableDate(expiry);
      if (issueDate != null &&
          expiryDate != null &&
          issueDate.sortKey > expiryDate.sortKey) {
        final swap = issue;
        issue = expiry;
        expiry = swap;
      }
    }

    // Guard: DOB should not be after issue date.
    if (dob != null && issue != null) {
      final dobDate = _toComparableDate(dob);
      final issueDate = _toComparableDate(issue);
      if (dobDate != null &&
          issueDate != null &&
          dobDate.sortKey > issueDate.sortKey) {
        // Likely mis-assigned; leave issue and treat chronological swap carefully.
        final swap = dob;
        dob = issue;
        issue = swap;
      }
    }

    return _AssignedDates(dob: dob, issue: issue, expiry: expiry);
  }

  String? _normalizeDate(String value) {
    final match = _datePattern.firstMatch(_applyDigitOcrFixes(
      _forceDigitHeavyTokens(value),
    ));
    if (match == null) return null;

    final day = int.tryParse(_toDigitsOnly(match.group(1)!));
    final month = int.tryParse(_toDigitsOnly(match.group(2)!));
    var year = int.tryParse(_toDigitsOnly(match.group(3)!));
    if (day == null || month == null || year == null) return null;
    if (day < 1 || day > 31 || month < 1 || month > 12) return null;

    if (year < 100) {
      final pivot = (DateTime.now().year % 100) + 12; // allow future expiry
      year += year <= pivot ? 2000 : 1900;
    }
    if (year < 1900 || year > 2100) return null;

    final dd = day.toString().padLeft(2, '0');
    final mm = month.toString().padLeft(2, '0');
    return '$dd.$mm.$year';
  }

  _ParsedDate? _toComparableDate(String formatted) {
    final parts = formatted.split('.');
    if (parts.length != 3) return null;
    final day = int.tryParse(parts[0]);
    final month = int.tryParse(parts[1]);
    final year = int.tryParse(parts[2]);
    if (day == null || month == null || year == null) return null;
    return _ParsedDate(
      formatted: formatted,
      sortKey: year * 10000 + month * 100 + day,
    );
  }

  String? _extractGender(List<String> lines, List<String> regexMatches) {
    for (var i = 0; i < lines.length; i++) {
      final line = lines[i];
      final labelMatch = _genderLabelPattern.firstMatch(line);
      if (labelMatch != null) {
        final inline = labelMatch.group(1) ?? '';
        final fromInline = _parseGenderValue(inline);
        if (fromInline != null) {
          regexMatches.add('gender:labeled=$fromInline');
          return fromInline;
        }
        if (i + 1 < lines.length) {
          final fromNext = _parseGenderValue(lines[i + 1]);
          if (fromNext != null) {
            regexMatches.add('gender:labeled-next=$fromNext');
            return fromNext;
          }
        }
        continue;
      }

      final parsed = _parseGenderValue(line);
      if (parsed != null &&
          (line.contains('GENDER') ||
              line.contains('SEX') ||
              RegExp(r'^(MALE|FEMALE|M|F)$').hasMatch(line.trim()))) {
        regexMatches.add('gender:line=$parsed');
        return parsed;
      }
    }

    for (final line in lines) {
      if (_isNoiseLine(line)) continue;
      final parsed = _parseGenderValue(line);
      if (parsed != null &&
          (line.contains('MALE') || line.contains('FEMALE'))) {
        regexMatches.add('gender:fallback=$parsed');
        return parsed;
      }
    }
    return null;
  }

  String? _parseGenderValue(String value) {
    final upper = value.toUpperCase().trim();
    // Check Female before Male — "FEMALE" contains the substring "MALE".
    if (upper.contains('FEMALE') ||
        RegExp(r'(^|\s|/)F(\s|$|/|:|-)|(^F$)').hasMatch(upper)) {
      return 'Female';
    }
    if (upper.contains('MALE') ||
        RegExp(r'(^|\s|/)M(\s|$|/|:|-)|(^M$)').hasMatch(upper)) {
      return 'Male';
    }
    return null;
  }

  bool _isAnyLabel(String line) {
    return _nameLabelPattern.hasMatch(line) ||
        _fatherLabelPattern.hasMatch(line) ||
        _husbandLabelPattern.hasMatch(line) ||
        _dobLabelPattern.hasMatch(line) ||
        _issueLabelPattern.hasMatch(line) ||
        _expiryLabelPattern.hasMatch(line) ||
        _genderLabelPattern.hasMatch(line) ||
        _identityLabelPattern.hasMatch(line);
  }

  bool _isNoiseLine(String line) {
    final upper = line.toUpperCase().trim();
    if (upper.isEmpty) return true;
    // Digit-only / date / CNIC fragments are never decorative noise.
    if (_matchCnic(upper) != null || _datePattern.hasMatch(upper)) {
      return false;
    }
    if (_digitHeavyToken.hasMatch(upper.replaceAll(' ', ''))) {
      return false;
    }
    for (final phrase in _noisePhrases) {
      if (upper == phrase || upper.contains(phrase)) return true;
    }

    final tokens =
        upper.split(RegExp(r'[^A-Z]+')).where((t) => t.isNotEmpty).toList();
    if (tokens.isEmpty) return true;
    final noiseCount = tokens.where(_noiseTokens.contains).length;
    if (noiseCount == tokens.length) return true;
    if (noiseCount / tokens.length >= 0.6) return true;
    return false;
  }

  String? _cleanupName(String? value) {
    if (value == null) return null;
    final upper = value.toUpperCase().trim();
    if (_isNoiseLine(upper)) return null;
    if (_isAnyLabel(upper) && !_nameLikeWithInline(upper)) return null;

    final cleaned = upper
        .replaceAll(
          RegExp(
            r"^(NAME|FATHER(?:'S)? NAME|HUSBAND(?:'S)? NAME|S\/O|W\/O)\s*[:\-]?\s*",
          ),
          '',
        )
        .replaceAll(RegExp(r"[^A-Z\s']"), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();

    if (cleaned.length < 2) return null;
    final words = cleaned.split(' ').where((w) => w.isNotEmpty).toList();
    if (words.isEmpty) return null;
    if (words.every(_noiseTokens.contains)) return null;
    if (!_nameLikePattern.hasMatch(cleaned) &&
        words.length == 1 &&
        words.first.length < 3) {
      return null;
    }

    return words
        .map((part) => '${part[0]}${part.substring(1).toLowerCase()}')
        .join(' ');
  }

  bool _nameLikeWithInline(String line) {
    for (final pattern in [
      _nameLabelPattern,
      _fatherLabelPattern,
      _husbandLabelPattern,
    ]) {
      final match = pattern.firstMatch(line);
      final inline = match?.group(1)?.trim() ?? '';
      if (inline.isNotEmpty) return true;
    }
    return false;
  }

  String _window(List<String> lines, int start, int count) {
    if (start >= lines.length) return '';
    return lines.skip(start).take(count).join(' ');
  }
}

class _PosLine {
  const _PosLine({
    required this.text,
    this.box,
  });

  final String text;
  final OcrBoundingBox? box;
}

class _ParsedDate {
  const _ParsedDate({
    required this.formatted,
    required this.sortKey,
  });

  final String formatted;
  final int sortKey;
}

class _AssignedDates {
  const _AssignedDates({
    required this.dob,
    required this.issue,
    required this.expiry,
  });

  final String? dob;
  final String? issue;
  final String? expiry;
}
