import 'package:flutter_test/flutter_test.dart';
import 'package:votechain_mobile/features/verification/data/cnic_parser.dart';
import 'package:votechain_mobile/features/verification/data/ocr_result_mapper.dart';
import 'package:votechain_mobile/features/verification/data/recognized_ocr_document.dart';

void main() {
  const parser = CnicParser();
  const mapper = OcrResultMapper();

  group('Smart CNIC layouts', () {
    test('extracts all core fields from labeled Smart CNIC text', () {
      final result = parser.parse([
        'ISLAMIC REPUBLIC OF PAKISTAN',
        'NATIONAL IDENTITY CARD',
        'Name',
        'Ali Raza',
        'Father Name',
        'Muhammad Raza',
        'Gender',
        'Male',
        'Country of Stay',
        'Pakistan',
        'Identity Number',
        '35201-1234567-1',
        'Date of Birth',
        '12.03.1998',
        'Date of Issue',
        '01.01.2020',
        'Date of Expiry',
        '01.01.2030',
      ]);

      expect(result.name, 'Ali Raza');
      expect(result.fatherName, 'Muhammad Raza');
      expect(result.cnic, '35201-1234567-1');
      expect(result.dateOfBirth, '12.03.1998');
      expect(result.gender, 'Male');
      expect(result.issueDate, '01.01.2020');
      expect(result.expiryDate, '01.01.2030');
      expect(result.name, isNot(contains('Republic')));
    });

    test('merges wrapped father name fragments', () {
      final result = parser.parse([
        'Name',
        'Abdullah Khan',
        'Father Name',
        'Auran',
        'gzeb',
        'Khan',
        '35202-7654321-9',
        'Gender M',
      ]);

      expect(result.name, 'Abdullah Khan');
      expect(result.fatherName, 'Aurangzeb Khan');
      expect(result.cnic, '35202-7654321-9');
      expect(result.gender, 'Male');
    });

    test('extracts husband name when father label is absent', () {
      final result = parser.parse([
        'Name',
        'Sara Ali',
        "Husband's Name",
        'Imran Ali',
        '35201-2222222-2',
        'Gender',
        'F',
      ]);

      expect(result.name, 'Sara Ali');
      expect(result.husbandName, 'Imran Ali');
      expect(result.gender, 'Female');

      final extraction = mapper.toCnicExtraction(result);
      expect(extraction.fatherName, 'Imran Ali');
    });

    test('reconstructs CNIC split across lines and digit OCR mistakes', () {
      final result = parser.parse([
        'NAME JOHN DOE',
        'Identity Number',
        '352O1',
        '1234567-1',
      ]);

      expect(result.cnic, '35201-1234567-1');
    });

    test('supports slash and dash date formats', () {
      final result = parser.parse([
        'NAME SARA ALI',
        '35201-1111111-2',
        'DATE OF BIRTH 15/08/1995',
        'DATE OF ISSUE 01-01-2018',
        'DATE OF EXPIRY 01/01/2028',
      ]);

      expect(result.dateOfBirth, '15.08.1995');
      expect(result.issueDate, '01.01.2018');
      expect(result.expiryDate, '01.01.2028');
    });

    test('assigns unlabeled chronological dates when labels are weak', () {
      final result = parser.parse([
        'NAME AHMED KHAN',
        'FATHER NAME BABAR KHAN',
        '35202-3333333-3',
        'MALE',
        '10.02.1990',
        '20.05.2015',
        '20.05.2025',
      ]);

      expect(result.dateOfBirth, '10.02.1990');
      expect(result.issueDate, '20.05.2015');
      expect(result.expiryDate, '20.05.2025');
    });

    test('ignores NADRA noise and never invents fields', () {
      final result = parser.parse([
        'PAKISTAN',
        'NADRA',
        'SMART CARD',
        'MACHINE READABLE ZONE',
        'GOVERNMENT OF PAKISTAN',
      ]);

      expect(result.name, isNull);
      expect(result.cnic, isNull);
      expect(result.dateOfBirth, isNull);
      expect(result.issueDate, isNull);
      expect(result.expiryDate, isNull);
    });

    test('normalizes spaces in CNIC digits', () {
      final result = parser.parse([
        'NAME TEST USER',
        '35202 1234567 1',
      ]);

      expect(result.cnic, '35202-1234567-1');
    });

    test('handles OCR-garbled date labels (Dale of Birth/Issue)', () {
      final result = parser.parse([
        'Name',
        'Hassan Ali',
        'Father Name',
        'Akbar Ali',
        'Identity Number',
        '35202-9988776-5',
        'Dale of Birth',
        '05.11.1992',
        'Dale of Issue',
        '12.04.2019',
        'Dale of Expiry',
        '12.04.2029',
        'Gender',
        'Male',
      ]);

      expect(result.dateOfBirth, '05.11.1992');
      expect(result.issueDate, '12.04.2019');
      expect(result.expiryDate, '12.04.2029');
      expect(result.cnic, '35202-9988776-5');
    });

    test('resolves 2-digit year pivot for DOB vs future expiry', () {
      final result = parser.parse([
        'NAME ZAIN ABBAS',
        '35201-4455667-8',
        'DATE OF BIRTH 15.08.95',
        'DATE OF ISSUE 01.01.18',
        'DATE OF EXPIRY 01.01.30',
      ]);

      expect(result.dateOfBirth, '15.08.1995');
      expect(result.issueDate, '01.01.2018');
      expect(result.expiryDate, '01.01.2030');
    });

    test('reads S/O father layout and continuous 13-digit CNIC', () {
      final result = parser.parse([
        'ISLAMIC REPUBLIC OF PAKISTAN',
        'Name Bilal Ahmed',
        'S/O Tariq Ahmed',
        '3520212345671',
        'Gender Male',
        '12/03/1998',
        '01/06/2020',
        '01/06/2030',
      ]);

      expect(result.name, 'Bilal Ahmed');
      expect(result.fatherName, 'Tariq Ahmed');
      expect(result.cnic, '35202-1234567-1');
      expect(result.gender, 'Male');
      expect(result.dateOfBirth, '12.03.1998');
      expect(result.issueDate, '01.06.2020');
      expect(result.expiryDate, '01.06.2030');
    });

    test('uses spatial boxes when label and value sit on the same row', () {
      final document = RecognizedOcrDocument(
        rawLines: const [
          'Identity Number 37405-1234567-9',
          'Date of Birth 21.07.1994',
        ],
        normalizedLines: const [
          'Identity Number 37405-1234567-9',
          'Date of Birth 21.07.1994',
        ],
        blocks: const [],
        orderedLines: const [
          OcrTextLine(
            text: 'Identity Number',
            boundingBox: OcrBoundingBox(
              left: 10,
              top: 40,
              width: 120,
              height: 20,
            ),
          ),
          OcrTextLine(
            text: '37405-1234567-9',
            boundingBox: OcrBoundingBox(
              left: 150,
              top: 38,
              width: 160,
              height: 22,
            ),
          ),
          OcrTextLine(
            text: 'Date of Birth',
            boundingBox: OcrBoundingBox(
              left: 10,
              top: 80,
              width: 110,
              height: 20,
            ),
          ),
          OcrTextLine(
            text: '21.07.1994',
            boundingBox: OcrBoundingBox(
              left: 140,
              top: 78,
              width: 100,
              height: 22,
            ),
          ),
        ],
        rawText: 'Identity Number\n37405-1234567-9\nDate of Birth\n21.07.1994',
        normalizedText:
            'Identity Number\n37405-1234567-9\nDate of Birth\n21.07.1994',
      );

      final result = parser.parseDocument(document);
      expect(result.cnic, '37405-1234567-9');
      expect(result.dateOfBirth, '21.07.1994');
    });

    test('mapper leaves missing fields empty and fills present ones', () {
      final result = parser.parse([
        'Name',
        'Only Name',
        '35202-1111111-1',
      ]);
      final extraction = mapper.toCnicExtraction(result);

      expect(extraction.fullName, 'Only Name');
      expect(extraction.cnicNumber, '35202-1111111-1');
      expect(extraction.dateOfBirth, isEmpty);
      expect(extraction.issueDate, isEmpty);
      expect(extraction.expiryDate, isEmpty);
      expect(extraction.fatherName, isEmpty);
    });

    test('collapses duplicated full name and father name phrases', () {
      final result = parser.parse([
        'Name',
        'Ayesha Khan',
        'Ayesha Khan',
        'Father Name',
        'Khalid Mehmood Kh N',
        'Khalid Mehmood Kh N',
        '35202-1234567-1',
        'Gender',
        'Female',
      ]);

      expect(result.name, 'Ayesha Khan');
      expect(result.fatherName, 'Khalid Mehmood Kh N');
      expect(result.gender, 'Female');
      expect(result.cnic, '35202-1234567-1');
    });

    test('collapses duplicated phrase embedded in a single OCR line', () {
      final result = parser.parse([
        'NAME AYSHA KHAN AYSHA KHAN',
        'FATHER NAME BABAR ALI BABAR ALI',
        '35201-9999999-9',
      ]);

      expect(result.name, 'Aysha Khan');
      expect(result.fatherName, 'Babar Ali');
    });

    test('preserves legitimate repeated words inside names', () {
      final result = parser.parse([
        'Name',
        'Abdul Abdul Rahman',
        'Father Name',
        'Muhammad Muhammad Ali',
        '35201-8888888-8',
      ]);

      expect(result.name, 'Abdul Abdul Rahman');
      expect(result.fatherName, 'Muhammad Muhammad Ali');
    });
  });
}
