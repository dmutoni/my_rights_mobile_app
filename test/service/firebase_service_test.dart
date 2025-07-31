import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:my_rights_mobile_app/service/firebase_service.dart';
import 'firebase_service_test.mocks.dart';

// Generate mocks using build_runner
@GenerateMocks([
  FirebaseAuth,
  FirebaseFirestore,
  User,
  UserCredential,
  CollectionReference,
  DocumentReference,
  DocumentSnapshot,
  QuerySnapshot,
  QueryDocumentSnapshot,
  Query,
])
void main() {
  group('FirebaseService Tests', () {
    group('OTP Verification', () {
      test('verifyOTP should return false for expired OTP', () async {
        // Arrange
        const email = 'test@example.com';
        const otp = '123456';
        const purpose = 'email_verification';

        final mockQuerySnapshot = MockQuerySnapshot<Map<String, dynamic>>();
        final mockQueryDocumentSnapshot =
            MockQueryDocumentSnapshot<Map<String, dynamic>>();

        when(mockQuerySnapshot.docs).thenReturn([mockQueryDocumentSnapshot]);
        when(mockQueryDocumentSnapshot.data()).thenReturn({
          'otp': otp,
          'email': email,
          'purpose': purpose,
          'expiresAt': Timestamp.fromDate(
              DateTime.now().subtract(Duration(minutes: 5))), // Expired
          'isUsed': false,
        });

        final mockQuery = MockQuery<Map<String, dynamic>>();
        final mockCollection = MockCollectionReference<Map<String, dynamic>>();

        when(mockCollection.where('email', isEqualTo: email))
            .thenReturn(mockQuery);
        when(mockQuery.where('otp', isEqualTo: otp)).thenReturn(mockQuery);
        when(mockQuery.where('purpose', isEqualTo: purpose))
            .thenReturn(mockQuery);
        when(mockQuery.where('isUsed', isEqualTo: false)).thenReturn(mockQuery);
        when(mockQuery.orderBy('createdAt', descending: true))
            .thenReturn(mockQuery);
        when(mockQuery.limit(1)).thenReturn(mockQuery);
        when(mockQuery.get()).thenAnswer((_) async => mockQuerySnapshot);

        // Act
        final result = await FirebaseService.verifyOTP(
          email: email,
          otp: otp,
          purpose: purpose,
        );

        // Assert
        expect(result, isFalse);
      });
    });
  });

  group('FirebaseService Tests', () {
    // Test the error handling method
    group('Authentication Error Handling', () {
      test('should return correct error message for weak-password', () {
        final exception = FirebaseAuthException(code: 'weak-password');
        final result = FirebaseService.handleAuthException(exception);
        expect(result, equals('The password provided is too weak.'));
      });

      test('should return correct error message for email-already-in-use', () {
        final exception = FirebaseAuthException(code: 'email-already-in-use');
        final result = FirebaseService.handleAuthException(exception);
        expect(result, equals('The account already exists for that email.'));
      });

      test('should return correct error message for invalid-credential', () {
        final exception = FirebaseAuthException(code: 'invalid-credential');
        final result = FirebaseService.handleAuthException(exception);
        expect(result, equals('Invalid credentials, Please try again.'));
      });

      test('should return custom message when provided for unknown error', () {
        final exception = FirebaseAuthException(
          code: 'unknown-error',
          message: 'Custom error message',
        );
        final result = FirebaseService.handleAuthException(exception);
        expect(result, equals('Custom error message'));
      });

      test('should return default message for unknown error without message',
          () {
        final exception = FirebaseAuthException(code: 'unknown-error');
        final result = FirebaseService.handleAuthException(exception);
        expect(result, equals('An unknown error occurred.'));
      });
    });
  });
}
