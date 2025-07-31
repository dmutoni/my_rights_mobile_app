import 'package:flutter_test/flutter_test.dart';
import 'package:my_rights_mobile_app/core/utils/validators.dart';

void main() {
  group('Validators Tests', () {
    group('Name Validation', () {
      test('should return null for valid names', () {
        final validNames = [
          'John',
          'Jane Doe',
          'Mary-Jane',
          'José',
          'O\'Connor',
          'Jean-Baptiste',
          'Anne Marie',
          '李明', // Chinese characters
          'محمد', // Arabic characters
        ];

        for (final name in validNames) {
          expect(
            Validators.name(name),
            isNull,
            reason: 'Name "$name" should be valid',
          );
        }
      });

      test('should return error for null name', () {
        expect(Validators.name(null), isNotNull);
      });
    });

    group('Phone Number Validation', () {
      test('should return null for valid phone numbers', () {
        final validPhones = [
          '+1234567890',
          '+12345678901',
          '+123456789012345', // Max 15 digits
          '+250781234567', // Rwanda format
          '+1 (555) 123-4567', // US format with formatting
          '0781234567', // Local format
        ];

        for (final phone in validPhones) {
          expect(
            Validators.phone(phone),
            isNull,
            reason: 'Phone "$phone" should be valid',
          );
        }
      });

      test('should return error for null phone', () {
        expect(Validators.phone(null), isNotNull);
      });
    });

    group('Required Field Validation', () {
      test('should return null for non-empty values', () {
        final validValues = [
          'test',
          'a',
          '123',
          ' text ', // Even with spaces
        ];

        for (final value in validValues) {
          expect(
            Validators.required(value),
            isNull,
            reason: 'Value "$value" should be valid',
          );
        }
      });
    });

    group('OTP Validation', () {
      test('should return null for valid 6-digit OTP', () {
        final validOTPs = [
          '123456',
          '000000',
          '999999',
          '012345',
        ];

        for (final otp in validOTPs) {
          expect(
            Validators.otp(otp),
            isNull,
            reason: 'OTP "$otp" should be valid',
          );
        }
      });
    });
  });
}
