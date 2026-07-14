import 'package:flutter_test/flutter_test.dart';
import 'package:votechain_mobile/features/verification/domain/entities/cnic_extraction.dart';

void main() {
  group('CnicExtraction', () {
    test('normalizes 13 digits to dashed format', () {
      expect(
        CnicExtraction.normalizeCnic('3520212345671'),
        '35202-1234567-1',
      );
    });

    test('accepts already dashed CNIC values', () {
      expect(
        CnicExtraction.isValidCnic('35202-1234567-1'),
        isTrue,
      );
    });

    test('rejects empty and incomplete CNIC values', () {
      expect(CnicExtraction.isValidCnic(''), isFalse);
      expect(CnicExtraction.isValidCnic('123'), isFalse);
      expect(CnicExtraction.isValidCnic('35202-1234567'), isFalse);
    });
  });
}
