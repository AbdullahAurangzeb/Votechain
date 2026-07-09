import 'package:flutter_test/flutter_test.dart';
import 'package:votechain_mobile/features/verification/data/cnic_parser.dart';

void main() {
  const parser = CnicParser();

  test('ignores document headers and extracts person name', () {
    final result = parser.parse([
      'ISLAMIC REPUBLIC OF PAKISTAN',
      'NATIONAL IDENTITY CARD',
      'NAME',
      'ALI RAZA',
      "FATHER NAME",
      'MUHAMMAD RAZA',
      '35201-1234567-1',
      'DATE OF BIRTH',
      '12.03.1998',
      'GENDER',
      'MALE',
    ]);

    expect(result.name, 'Ali Raza');
    expect(result.fatherName, 'Muhammad Raza');
    expect(result.cnic, '35201-1234567-1');
    expect(result.dateOfBirth, '12.03.1998');
    expect(result.gender, 'Male');
  });

  test('does not use republic header as full name', () {
    final result = parser.parse([
      'Islamic Republic of Pakistan',
      'National Identity Card',
      'AHMED KHAN',
      '35202-7654321-9',
    ]);

    expect(result.name, 'Ahmed Khan');
    expect(result.name, isNot(contains('Republic')));
  });

  test('extracts issue and expiry dates from labels', () {
    final result = parser.parse([
      'NAME: SARA ALI',
      '35201-1111111-2',
      'DATE OF ISSUE',
      '01.01.2020',
      'DATE OF EXPIRY',
      '01.01.2030',
    ]);

    expect(result.issueDate, '01.01.2020');
    expect(result.expiryDate, '01.01.2030');
  });

  test('normalizes OCR digit mistakes in CNIC', () {
    final result = parser.parse([
      'NAME JOHN DOE',
      '352O1-1234567-1',
    ]);

    expect(result.cnic, '35201-1234567-1');
  });

  test('leaves uncertain fields empty instead of guessing', () {
    final result = parser.parse([
      'PAKISTAN',
      'NADRA',
      'GOVERNMENT OF PAKISTAN',
    ]);

    expect(result.name, isNull);
    expect(result.cnic, isNull);
    expect(result.dateOfBirth, isNull);
  });
}
