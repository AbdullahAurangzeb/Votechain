import '../domain/ocr_result.dart';

/// Deterministic parser for Pakistani CNIC text with preprocessing and noise filtering.
class CnicParser {
  static final RegExp _cnicDigitsPattern = RegExp(r'\d{5}[\s\-]?\d{7}[\s\-]?\d');
  static final RegExp _datePattern = RegExp(
    r'\b(\d{1,2}[./\-]\d{1,2}[./\-]\d{2,4}|\d{1,2}\s+[A-Z]{3,9}\s+\d{4})\b',
    caseSensitive: false,
  );
  static final RegExp _nameLabelPattern = RegExp(
    r'^(?:NAME|NAAM|FULL\s*NAME)\s*[:\-]?\s*(.*)$',
    caseSensitive: false,
  );
  static final RegExp _fatherLabelPattern = RegExp(
    r"^(?:FATHER(?:'S)?\s*NAME|HUSBAND(?:'S)?\s*NAME|S\/O|D\/O|W\/O)\s*[:\-]?\s*(.*)$",
    caseSensitive: false,
  );
  static final RegExp _dobLabelPattern = RegExp(
    r'^(?:DATE\s*OF\s*BIRTH|DOB|BIRTH\s*DATE)\s*[:\-]?\s*(.*)$',
    caseSensitive: false,
  );
  static final RegExp _issueLabelPattern = RegExp(
    r'^(?:DATE\s*OF\s*ISSUE|ISSUE\s*DATE|ISSUED(?:\s*ON)?)\s*[:\-]?\s*(.*)$',
    caseSensitive: false,
  );
  static final RegExp _expiryLabelPattern = RegExp(
    r'^(?:DATE\s*OF\s*EXPIRY|EXPIRY\s*DATE|EXPIRES?(?:\s*ON)?|VALID\s*UP\s*TO|VALID\s*THRU)\s*[:\-]?\s*(.*)$',
    caseSensitive: false,
  );
  static final RegExp _genderLabelPattern = RegExp(
    r'^(?:GENDER|SEX)\s*[:\-]?\s*(.*)$',
    caseSensitive: false,
  );
  static final RegExp _identityLabelPattern = RegExp(
    r'^(?:IDENTITY\s*NUMBER|CNIC|NIC|N\.?I\.?C)\s*[:\-]?\s*(.*)$',
    caseSensitive: false,
  );
  static final RegExp _nameLikePattern = RegExp(r"^[A-Z][A-Z\s'.]{2,}$");

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
  };

  const CnicParser();

  /// Parses preprocessed OCR lines into structured CNIC fields.
  OcrResult parse(List<String> rawLines) {
    final lines = _preprocessLines(rawLines);
    final joined = lines.join(' ');

    final cnic = _extractCnic(joined, lines);
    final fatherName = _extractFatherName(lines);
    final name = _extractName(lines, fatherName: fatherName);
    final dateOfBirth = _extractLabeledDate(lines, _dobLabelPattern) ?? _extractUnlabeledDate(lines, exclude: []);
    final issueDate = _extractLabeledDate(lines, _issueLabelPattern);
    final expiryDate = _extractLabeledDate(lines, _expiryLabelPattern);
    final gender = _extractGender(lines);

    return OcrResult(
      name: name,
      cnic: cnic,
      dateOfBirth: dateOfBirth,
      gender: gender,
      fatherName: fatherName,
      issueDate: issueDate,
      expiryDate: expiryDate,
      rawText: rawLines,
    );
  }

  List<String> _preprocessLines(List<String> rawLines) {
    final trimmed = rawLines
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty)
        .map(_normalizePunctuation)
        .toList();

    final deduped = <String>[];
    for (final line in trimmed) {
      final upper = line.toUpperCase();
      if (deduped.isEmpty || deduped.last.toUpperCase() != upper) {
        deduped.add(line);
      }
    }

    return deduped
        .map((line) => line.replaceAll(RegExp(r'\s+'), ' ').trim())
        .where((line) => line.isNotEmpty)
        .map((line) => line.toUpperCase())
        .toList(growable: false);
  }

  String _normalizePunctuation(String line) {
    return line
        .replaceAll('—', '-')
        .replaceAll('–', '-')
        .replaceAll('|', ' ')
        .replaceAll('  ', ' ');
  }

  String _applyCnicOcrFixes(String text) {
    var result = text.toUpperCase();
    result = result.replaceAllMapped(RegExp(r'[O]'), (m) {
      final index = m.start;
      final before = index > 0 ? result[index - 1] : '';
      final after = index + 1 < result.length ? result[index + 1] : '';
      if (_isDigitContext(before) || _isDigitContext(after)) return '0';
      return 'O';
    });
    result = result.replaceAllMapped(RegExp(r'[I]'), (m) {
      final index = m.start;
      final before = index > 0 ? result[index - 1] : '';
      final after = index + 1 < result.length ? result[index + 1] : '';
      if (_isDigitContext(before) || _isDigitContext(after)) return '1';
      return 'I';
    });
    result = result.replaceAllMapped(RegExp(r'[S]'), (m) {
      final index = m.start;
      final before = index > 0 ? result[index - 1] : '';
      final after = index + 1 < result.length ? result[index + 1] : '';
      if (_isDigitContext(before) && _isDigitContext(after)) return '5';
      return 'S';
    });
    result = result.replaceAllMapped(RegExp(r'[B]'), (m) {
      final index = m.start;
      final before = index > 0 ? result[index - 1] : '';
      final after = index + 1 < result.length ? result[index + 1] : '';
      if (_isDigitContext(before) && _isDigitContext(after)) return '8';
      return 'B';
    });
    return result;
  }

  bool _isDigitContext(String char) =>
      char.isNotEmpty && RegExp(r'[\d\-]').hasMatch(char);

  String? _extractCnic(String joined, List<String> lines) {
    final fixedJoined = _applyCnicOcrFixes(joined);
    final fromJoined = _matchCnic(fixedJoined);
    if (fromJoined != null) return fromJoined;

    for (final line in lines) {
      final labeled = _identityLabelPattern.firstMatch(line);
      if (labeled != null) {
        final value = labeled.group(1)?.trim() ?? '';
        if (value.isNotEmpty) {
          final matched = _matchCnic(_applyCnicOcrFixes(value));
          if (matched != null) return matched;
        }
      }
      final matched = _matchCnic(_applyCnicOcrFixes(line));
      if (matched != null) return matched;
    }
    return null;
  }

  String? _matchCnic(String text) {
    final match = _cnicDigitsPattern.firstMatch(text);
    if (match == null) return null;
    final digits = match.group(0)!.replaceAll(RegExp(r'\D'), '');
    if (digits.length != 13) return null;
    return '${digits.substring(0, 5)}-${digits.substring(5, 12)}-${digits.substring(12)}';
  }

  String? _extractFatherName(List<String> lines) {
    return _extractLabeledName(lines, _fatherLabelPattern);
  }

  String? _extractName(List<String> lines, {String? fatherName}) {
    final labeled = _extractLabeledName(lines, _nameLabelPattern);
    if (labeled != null) return labeled;

    for (final line in lines) {
      if (_isNoiseLine(line)) continue;
      if (_cnicDigitsPattern.hasMatch(line)) continue;
      if (_datePattern.hasMatch(line)) continue;
      if (_fatherLabelPattern.hasMatch(line)) continue;
      if (_genderLabelPattern.hasMatch(line)) continue;
      if (_issueLabelPattern.hasMatch(line)) continue;
      if (_expiryLabelPattern.hasMatch(line)) continue;
      if (_dobLabelPattern.hasMatch(line)) continue;
      if (line.length < 5) continue;

      final cleaned = _cleanupName(line);
      if (cleaned == null) continue;
      if (fatherName != null && cleaned.toUpperCase() == fatherName.toUpperCase()) {
        continue;
      }
      return cleaned;
    }
    return null;
  }

  String? _extractLabeledName(List<String> lines, RegExp pattern) {
    for (var i = 0; i < lines.length; i++) {
      final line = lines[i];
      final match = pattern.firstMatch(line);
      if (match == null) continue;

      final inline = match.group(1)?.trim() ?? '';
      if (inline.isNotEmpty) {
        final cleaned = _cleanupName(inline);
        if (cleaned != null) return cleaned;
      }

      if (i + 1 < lines.length) {
        final nextLine = lines[i + 1];
        if (!_isNoiseLine(nextLine) && !_cnicDigitsPattern.hasMatch(nextLine)) {
          final cleaned = _cleanupName(nextLine);
          if (cleaned != null) return cleaned;
        }
      }
    }
    return null;
  }

  String? _extractLabeledDate(List<String> lines, RegExp pattern) {
    for (var i = 0; i < lines.length; i++) {
      final line = lines[i];
      final match = pattern.firstMatch(line);
      if (match == null) continue;

      final inline = match.group(1)?.trim() ?? '';
      final inlineDate = _normalizeDate(inline);
      if (inlineDate != null) return inlineDate;

      if (i + 1 < lines.length) {
        final nextDate = _normalizeDate(lines[i + 1]);
        if (nextDate != null) return nextDate;
      }
    }
    return null;
  }

  String? _extractUnlabeledDate(List<String> lines, {required List<String> exclude}) {
    for (final line in lines) {
      if (exclude.contains(line)) continue;
      if (_isNoiseLine(line)) continue;
      final date = _normalizeDate(line);
      if (date != null) return date;
    }
    return null;
  }

  String? _normalizeDate(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return null;
    final match = _datePattern.firstMatch(trimmed.toUpperCase());
    if (match == null) return null;
    return match.group(1)?.replaceAll('/', '.').replaceAll('-', '.');
  }

  String? _extractGender(List<String> lines) {
    for (final line in lines) {
      final labelMatch = _genderLabelPattern.firstMatch(line);
      if (labelMatch != null) {
        final value = labelMatch.group(1)?.trim().toUpperCase() ?? '';
        final fromLabel = _parseGenderValue(value);
        if (fromLabel != null) return fromLabel;
      }

      final fromLine = _parseGenderValue(line);
      if (fromLine != null) return fromLine;
    }
    return null;
  }

  String? _parseGenderValue(String value) {
    final upper = value.toUpperCase();
    if (upper.contains('FEMALE') || RegExp(r'\bF\b').hasMatch(upper)) {
      return 'Female';
    }
    if (upper.contains('MALE') || RegExp(r'\bM\b').hasMatch(upper)) {
      return 'Male';
    }
    return null;
  }

  bool _isNoiseLine(String line) {
    final upper = line.toUpperCase().trim();
    if (upper.isEmpty) return true;

    final noisePhrases = [
      'ISLAMIC REPUBLIC OF PAKISTAN',
      'NATIONAL IDENTITY CARD',
      'GOVERNMENT OF PAKISTAN',
      'IDENTITY CARD',
      'PAKISTAN NATIONAL',
      'HOLDER SIGNATURE',
      "HOLDER'S SIGNATURE",
    ];
    for (final phrase in noisePhrases) {
      if (upper.contains(phrase)) return true;
    }

    final tokens = upper.split(RegExp(r'[^A-Z]+')).where((t) => t.isNotEmpty);
    if (tokens.isEmpty) return true;

    final noiseCount = tokens.where(_noiseTokens.contains).length;
    if (noiseCount == tokens.length) return true;
    if (noiseCount > 0 && noiseCount / tokens.length >= 0.6) return true;

    if (!_nameLikePattern.hasMatch(upper) &&
        !_cnicDigitsPattern.hasMatch(upper) &&
        !_datePattern.hasMatch(upper) &&
        !_fatherLabelPattern.hasMatch(upper) &&
        !_nameLabelPattern.hasMatch(upper)) {
      return tokens.every(_noiseTokens.contains);
    }

    return false;
  }

  String? _cleanupName(String? value) {
    if (value == null) return null;

    final upper = value.toUpperCase().trim();
    if (_isNoiseLine(upper)) return null;

    final cleaned = upper
        .replaceAll(RegExp(r"[^A-Z\s']"), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();

    if (cleaned.length < 3) return null;

    final words = cleaned.split(' ').where((part) => part.isNotEmpty).toList();
    if (words.isEmpty) return null;
    if (words.every(_noiseTokens.contains)) return null;

    return words
        .map((part) => '${part[0]}${part.substring(1).toLowerCase()}')
        .join(' ');
  }
}
