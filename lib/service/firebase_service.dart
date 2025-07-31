import 'dart:math';

import 'dart:developer' as log;

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:my_rights_mobile_app/core/utils/email_sender.dart';
import 'package:my_rights_mobile_app/models/user_model.dart';

class FirebaseService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get current user
  static User? get currentUser => _auth.currentUser;

  // Get current user ID
  static String? get currentUserId => _auth.currentUser?.uid;

  // Auth state stream
  static Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Generate 6-digit OTP
  static String _generateOTP() {
    final random = Random();
    String otp = '';
    for (int i = 0; i < 6; i++) {
      otp += random.nextInt(10).toString();
    }
    return otp;
  }

  // Store OTP in Firestore with expiration
  static Future<void> _storeOTP({
    required String email,
    required String otp,
    required String purpose, // 'email_verification' or 'password_reset'
  }) async {
    try {
      final otpDoc = {
        'otp': otp,
        'email': email,
        'purpose': purpose,
        'createdAt': FieldValue.serverTimestamp(),
        'expiresAt': Timestamp.fromDate(
          DateTime.now().add(const Duration(minutes: 10)), // 10 minutes expiry
        ),
        'isUsed': false,
      };

      await _firestore.collection('otps').add(otpDoc);
    } catch (e) {
      throw Exception('Failed to store OTP: $e');
    }
  }

  // Verify OTP
  static Future<bool> verifyOTP({
    required String email,
    required String otp,
    required String purpose,
  }) async {
    try {
      final query = await _firestore
          .collection('otps')
          .where('email', isEqualTo: email)
          .where('otp', isEqualTo: otp)
          .where('purpose', isEqualTo: purpose)
          .where('isUsed', isEqualTo: false)
          .orderBy('createdAt', descending: true)
          .limit(1)
          .get();

      if (query.docs.isEmpty) {
        return false;
      }

      final otpDoc = query.docs.first;
      final data = otpDoc.data();
      final expiresAt = (data['expiresAt'] as Timestamp).toDate();

      if (DateTime.now().isAfter(expiresAt)) {
        return false;
      }

      // Mark OTP as used
      await otpDoc.reference.update({'isUsed': true});
      return true;
    } catch (e) {
      return false;
    }
  }

  // Send OTP via email (simulated - in production you'd use a real email service)
  static Future<void> _sendOTPEmail({
    required String email,
    required String otp,
    required String purpose,
  }) async {
    try {
      await GmailService.sendOTP(
        email: email,
        otp: otp,
        purpose: purpose,
      );
    } catch (e) {
      rethrow;
    }
  }

  // Sign up with email and password
  static Future<UserCredential> signUpWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Generate and send OTP for email verification
      final otp = _generateOTP();
      await _storeOTP(
        email: email,
        otp: otp,
        purpose: 'email_verification',
      );

      await _sendOTPEmail(
        email: email,
        otp: otp,
        purpose: 'email_verification',
      );

      log.log('✅ User account created and OTP sent');
      return credential;
    } on FirebaseAuthException catch (e) {
      log.log('❌ Firebase Auth Exception: ${e.code} - ${e.message}');
      throw handleAuthException(e);
    } catch (e) {
      log.log('❌ General exception: $e');
      throw Exception('Signup failed: $e');
    }
  }

  // Sign in with email and password
  static Future<UserCredential> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      log.log('🔑 Starting signInWithEmailAndPassword...');
      log.log('📧 Email: "$email"');
      log.log('🔒 Password provided: ${password.isNotEmpty}');

      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      log.log('✅ signInWithEmailAndPassword successful');
      log.log('👤 User: ${credential.user?.email}');
      return credential;
    } on FirebaseAuthException catch (e) {
      log.log('❌ FirebaseAuthException Code: ${e.code}');
      log.log('❌ FirebaseAuthException Message: ${e.message}');
      throw handleAuthException(e);
    } catch (e) {
      log.log('❌ Unknown exception: $e');
      log.log('❌ Exception type: ${e.runtimeType}');
      throw Exception('Sign in failed: $e');
    }
  }

  // Verify email with OTP
  static Future<bool> verifyEmailWithOTP({
    required String email,
    required String otp,
  }) async {
    try {
      final isValid = await verifyOTP(
        email: email,
        otp: otp,
        purpose: 'email_verification',
      );

      if (isValid) {
        // Update user's email verification status in Firestore
        final user = _auth.currentUser;
        if (user != null) {
          await updateUserDocument(
            uid: user.uid,
            data: {'isEmailVerified': true},
          );
        }
      }

      return isValid;
    } catch (e) {
      log.log('❌ Error verifying email with OTP: $e');
      throw Exception('Email verification failed: $e');
    }
  }

  // Resend OTP for email verification
  static Future<void> resendEmailVerificationOTP(String email) async {
    try {
      final otp = _generateOTP();
      await _storeOTP(
        email: email,
        otp: otp,
        purpose: 'email_verification',
      );

      await _sendOTPEmail(
        email: email,
        otp: otp,
        purpose: 'email_verification',
      );

      log.log('✅ Email verification OTP resent');
    } catch (e) {
      log.log('❌ Error resending OTP: $e');
      throw Exception('Failed to resend OTP: $e');
    }
  }

  // Send password reset OTP
  static Future<void> sendPasswordResetOTP(String email) async {
    try {
      // Check if user exists
      final methods = await _auth.fetchSignInMethodsForEmail(email);
      if (methods.isEmpty) {
        throw Exception('No account found with this email address');
      }

      final otp = _generateOTP();
      await _storeOTP(
        email: email,
        otp: otp,
        purpose: 'password_reset',
      );

      await _sendOTPEmail(
        email: email,
        otp: otp,
        purpose: 'password_reset',
      );

      log.log('✅ Password reset OTP sent');
    } catch (e) {
      log.log('❌ Error sending password reset OTP: $e');
      if (e.toString().contains('No account found')) {
        rethrow;
      }
      throw Exception('Failed to send password reset OTP: $e');
    }
  }

  // Verify password reset OTP
  static Future<bool> verifyPasswordResetOTP({
    required String email,
    required String otp,
  }) async {
    try {
      return await verifyOTP(
        email: email,
        otp: otp,
        purpose: 'password_reset',
      );
    } catch (e) {
      log.log('❌ Error verifying password reset OTP: $e');
      throw Exception('Password reset verification failed: $e');
    }
  }

  // Reset password with new password (after OTP verification)
  static Future<void> resetPasswordWithOTP({
    required String email,
    required String otp,
    required String newPassword,
  }) async {
    try {
      // First verify the OTP
      final isValidOTP = await verifyPasswordResetOTP(
        email: email,
        otp: otp,
      );

      if (!isValidOTP) {
        throw Exception('Invalid or expired OTP');
      }

      // For Firebase Auth, we need to use sendPasswordResetEmail
      // Or implement a custom solution with admin SDK
      // For now, we'll send a password reset email as fallback
      await _auth.sendPasswordResetEmail(email: email);

      log.log('✅ Password reset email sent');
    } catch (e) {
      log.log('❌ Error resetting password: $e');
      throw Exception('Password reset failed: $e');
    }
  }

  static Future<UserCredential> signInWithGoogle() async {
    try {
      log.log('🔑 Starting Google Sign-In...');

      // Initialize Google Sign-In
      final GoogleSignIn googleSignIn = GoogleSignIn.instance;

      // Trigger the authentication flow
      final GoogleSignInAccount googleUser = await googleSignIn.authenticate();

      log.log('✅ Google account selected: ${googleUser.email}');

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth = googleUser.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.idToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with the Google credential
      final userCredential = await _auth.signInWithCredential(credential);

      // Check if user document exists, create if not
      final userDoc = await getUserDocument(userCredential.user!.uid);
      if (userDoc == null) {
        await createUserDocument(
          uid: userCredential.user!.uid,
          name: userCredential.user?.displayName ?? '',
          email: userCredential.user?.email ?? '',
        );

        // Mark as email verified since Google handles email verification
        await updateUserDocument(
          uid: userCredential.user!.uid,
          data: {'isEmailVerified': true},
        );
      }

      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw handleAuthException(e);
    } catch (e) {
      throw Exception('Google Sign-In failed: $e');
    }
  }

  // Sign out
  static Future<void> signOut() async {
    await _auth.signOut();
  }

  // Send password reset email
  static Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw handleAuthException(e);
    }
  }

  // Send email verification
  static Future<void> sendEmailVerification() async {
    try {
      await _auth.currentUser?.sendEmailVerification();
    } on FirebaseAuthException catch (e) {
      throw handleAuthException(e);
    }
  }

  // Reload user to get updated email verification status
  static Future<void> reloadUser() async {
    await _auth.currentUser?.reload();
  }

  // Create user document in Firestore
  static Future<void> createUserDocument({
    required String uid,
    required String name,
    required String email,
  }) async {
    try {
      final userModel = UserModel(
        id: uid,
        name: name,
        email: email,
        isEmailVerified: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await _firestore.collection('users').doc(uid).set(userModel.toJson());
    } catch (e) {
      throw Exception('Failed to create user document: $e');
    }
  }

  // Get user document from Firestore
  static Future<UserModel?> getUserDocument(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        return UserModel.fromJson(doc.data()!, documentId: doc.id);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get user document: $e');
    }
  }

  // Update user document
  static Future<void> updateUserDocument({
    required String uid,
    required Map<String, dynamic> data,
  }) async {
    try {
      await _firestore.collection('users').doc(uid).update({
        ...data,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to update user document: $e');
    }
  }

  // Update user profile
  static Future<void> updateUserProfile({
    String? displayName,
    String? photoURL,
  }) async {
    try {
      await _auth.currentUser?.updateDisplayName(displayName);
      if (photoURL != null) {
        await _auth.currentUser?.updatePhotoURL(photoURL);
      }
    } catch (e) {
      throw Exception('Failed to update user profile: $e');
    }
  }

  static Future<void> deleteAccount() async {
    try {
      final uid = _auth.currentUser?.uid;
      if (uid != null) {
        await _firestore.collection('users').doc(uid).delete();

        await _auth.currentUser?.delete();
      }
    } catch (e) {
      throw Exception('Failed to delete account: $e');
    }
  }

  // Check if email is verified
  static bool get isEmailVerified => _auth.currentUser?.emailVerified ?? false;

  // Handle Firebase Auth exceptions
  static String handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'weak-password':
        return 'The password provided is too weak.';
      case 'email-already-in-use':
        return 'The account already exists for that email.';
      case 'invalid-credential':
        return 'Invalid credentials, Please try again.';
      case 'user-not-found':
        return 'No user found for that email.';
      case 'wrong-password':
        return 'Wrong password provided for that user.';
      case 'invalid-email':
        return 'The email address is badly formatted.';
      case 'user-disabled':
        return 'This user account has been disabled.';
      case 'too-many-requests':
        return 'Too many requests. Try again later.';
      case 'operation-not-allowed':
        return 'This operation is not allowed.';
      case 'network-request-failed':
        return 'Network error. Please check your internet connection.';
      case 'requires-recent-log.login':
        return 'This operation requires recent authentication. Please sign in again.';
      default:
        return e.message ?? 'An unknown error occurred.';
    }
  }

  static CollectionReference get usersCollection =>
      _firestore.collection('users');

  static Future<void> addDocument({
    required String collection,
    required Map<String, dynamic> data,
  }) async {
    try {
      await _firestore.collection(collection).add(data);
    } catch (e) {
      throw Exception('Failed to add document: $e');
    }
  }

  static Future<void> updateDocument({
    required String collection,
    required String docId,
    required Map<String, dynamic> data,
  }) async {
    try {
      await _firestore.collection(collection).doc(docId).update(data);
    } catch (e) {
      throw Exception('Failed to update document: $e');
    }
  }

  static Future<void> deleteDocument({
    required String collection,
    required String docId,
  }) async {
    try {
      await _firestore.collection(collection).doc(docId).delete();
    } catch (e) {
      throw Exception('Failed to delete document: $e');
    }
  }

  static Stream<QuerySnapshot<Map<String, dynamic>>> getCollectionStream(
      String collection) {
    return _firestore.collection(collection).snapshots();
  }

  static Future<QuerySnapshot<Map<String, dynamic>>> getCollection(
      String collection) {
    return _firestore.collection(collection).get();
  }

  static Stream<DocumentSnapshot<Map<String, dynamic>>> getDocument({
    required String collection,
    required String docId,
  }) {
    return _firestore.collection(collection).doc(docId).snapshots();
  }

  static Stream<QuerySnapshot<Map<String, dynamic>>> getDocumentOrdered({
    required String collection,
    required String orderByField,
  }) {
    return _firestore.collection(collection).orderBy(orderByField).snapshots();
  }

  static Stream<QuerySnapshot<Map<String, dynamic>>> getDocumentQuery({
    required String collection,
    required String field,
    required dynamic value,
  }) {
    return _firestore
        .collection(collection)
        .where(field, isEqualTo: value)
        .snapshots();
  }

  static Stream<QuerySnapshot<Map<String, dynamic>>> getDocumentArrayQuery({
    required String collection,
    required String field,
    required dynamic value,
  }) {
    return _firestore
        .collection(collection)
        .where(field, arrayContains: value)
        .snapshots();
  }

  static Stream<QuerySnapshot<Map<String, dynamic>>> getInnerDocument({
    required String collection,
    required String docId,
    required String innerCollection,
    String? innerDocId,
    String? anotherCollection,
    String? orderByField,
  }) {
    if (anotherCollection != null &&
        innerDocId != null &&
        orderByField != null) {
      return _firestore
          .collection(collection)
          .doc(docId)
          .collection(innerCollection)
          .doc(innerDocId)
          .collection(anotherCollection)
          .orderBy(orderByField)
          .snapshots();
    } else if (anotherCollection != null && innerDocId != null) {
      return _firestore
          .collection(collection)
          .doc(docId)
          .collection(innerCollection)
          .doc(innerDocId)
          .collection(anotherCollection)
          .snapshots();
    } else if (orderByField != null) {
      return _firestore
          .collection(collection)
          .doc(docId)
          .collection(innerCollection)
          .orderBy(orderByField)
          .snapshots();
    } else {
      return _firestore
          .collection(collection)
          .doc(docId)
          .collection(innerCollection)
          .snapshots();
    }
  }
  static Stream<QuerySnapshot<Map<String, dynamic>>> getDocumentQueryRange({
    required String collection,
    required String field,
    required dynamic value,
  }) {
    return _firestore.collection(collection).where(field, isGreaterThanOrEqualTo: value).where(field, isLessThanOrEqualTo: value + '\uf8ff').snapshots();
  }

  static getDocumentStream(String s, String lawyerId) {}
}

