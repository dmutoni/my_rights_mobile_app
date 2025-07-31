import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:my_rights_mobile_app/models/user_model.dart';
import 'package:my_rights_mobile_app/service/firebase_service.dart';

// Auth State
class AuthState {
  final bool isAuthenticated;
  final bool isLoading;
  final String? error;
  final UserModel? user;
  final bool isEmailVerified;
  final bool isAwaitingOTPVerification;

  const AuthState({
    this.isAuthenticated = false,
    this.isLoading = false,
    this.error,
    this.user,
    this.isEmailVerified = false,
    this.isAwaitingOTPVerification = false,
  });

  AuthState copyWith({
    bool? isAuthenticated,
    bool? isLoading,
    String? error,
    UserModel? user,
    bool? isEmailVerified,
    bool? isAwaitingOTPVerification,
  }) {
    return AuthState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      user: user ?? this.user,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      isAwaitingOTPVerification:
          isAwaitingOTPVerification ?? this.isAwaitingOTPVerification,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(const AuthState()) {
    FirebaseService.authStateChanges.listen(_onAuthStateChanged);
  }

  void _onAuthStateChanged(User? firebaseUser) async {
    print('🔄 Auth state changed: ${firebaseUser?.uid ?? "null"}');
    print('📧 Email: ${firebaseUser?.email ?? "null"}');

    if (firebaseUser != null) {
      // Set loading state and clear previous user data
      state = state.copyWith(
        isLoading: true,
        error: null,
        user: null,
        isAuthenticated: false,
      );

      try {
        print('📄 Fetching user document for UID: ${firebaseUser.uid}');
        final userDoc = await FirebaseService.getUserDocument(firebaseUser.uid);

        if (userDoc != null) {
          // Set the NEW user data
          state = state.copyWith(
            isAuthenticated: userDoc
                .isEmailVerified, // Only authenticated if email is verified
            isLoading: false,
            user: userDoc,
            isEmailVerified: userDoc.isEmailVerified,
            isAwaitingOTPVerification: !userDoc.isEmailVerified,
          );
        } else {
          print('🆕 Creating new user document...');
          await FirebaseService.createUserDocument(
            uid: firebaseUser.uid,
            name: firebaseUser.displayName ?? '',
            email: firebaseUser.email ?? '',
          );

          final newUserDoc =
              await FirebaseService.getUserDocument(firebaseUser.uid);
          print('✅ New user document created: ${newUserDoc?.email}');

          state = state.copyWith(
            isAuthenticated: false, // Not authenticated until email is verified
            isLoading: false,
            user: newUserDoc,
            isEmailVerified: false,
            isAwaitingOTPVerification: true,
          );
        }
      } catch (e) {
        print('❌ Error loading user data: $e');
        state = state.copyWith(
          isLoading: false,
          error: 'Failed to load user data: $e',
          user: null,
          isAuthenticated: false,
        );
      }
    } else {
      print('🚪 User signed out - clearing all data');
      state = const AuthState();
    }

    print(
        '🏁 Final state - Authenticated: ${state.isAuthenticated}, User: ${state.user?.email}, Awaiting OTP: ${state.isAwaitingOTPVerification}');
  }

  Future<void> signup(String name, String email, String password) async {
    print('📝 Starting signup for: $email');
    state = state.copyWith(isLoading: true, error: null);

    try {
      final credential = await FirebaseService.signUpWithEmailAndPassword(
        email: email,
        password: password,
      );

      await FirebaseService.updateUserProfile(displayName: name);

      await FirebaseService.createUserDocument(
        uid: credential.user!.uid,
        name: name,
        email: email,
      );

      // Set state to indicate OTP verification is needed
      state = state.copyWith(
        isLoading: false,
        isAwaitingOTPVerification: true,
        isAuthenticated: false,
      );

      print('✅ Signup completed for: $email, OTP sent');
    } catch (e) {
      print('❌ Signup error: $e');
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> login(String email, String password) async {
    print('🔑 Starting login for: $email');
    state = state.copyWith(isLoading: true, error: null);

    try {
      await FirebaseService.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      print('✅ Login successful for: $email');
      // Auth state will be updated by the listener
    } catch (e) {
      print('❌ Login error: $e');
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  // Verify OTP for email verification
  Future<void> verifyEmailOTP(String email, String otp) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final isValid = await FirebaseService.verifyEmailWithOTP(
        email: email,
        otp: otp,
      );

      if (isValid) {
        print('✅ Email OTP verified successfully');

        // Update local state
        if (state.user != null) {
          state = state.copyWith(
            isLoading: false,
            isAuthenticated: true,
            isEmailVerified: true,
            isAwaitingOTPVerification: false,
            user: state.user!.copyWith(isEmailVerified: true),
          );
        }
      } else {
        print('❌ Invalid email OTP');
        state = state.copyWith(
          isLoading: false,
          error: 'Invalid or expired OTP. Please try again.',
        );
      }
    } catch (e) {
      print('❌ Email OTP verification error: $e');
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> forgotPassword(String email) async {
    print('🔑 Starting forgot password for: $email');
    state = state.copyWith(isLoading: true, error: null);

    try {
      await FirebaseService.sendPasswordResetOTP(email);

      state = state.copyWith(isLoading: false);
      print('✅ Password reset OTP sent for: $email');
    } catch (e) {
      print('❌ Forgot password error: $e');
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  // Resend email verification OTP
  Future<void> resendEmailVerificationOTP(String email) async {
    print('📧 Resending email verification OTP for: $email');
    state = state.copyWith(isLoading: true, error: null);

    try {
      await FirebaseService.resendEmailVerificationOTP(email);

      state = state.copyWith(isLoading: false);
      print('✅ Email verification OTP resent');
    } catch (e) {
      print('❌ Resend OTP error: $e');
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  // Send password reset OTP
  Future<void> sendPasswordResetOTP(String email) async {
    print('🔑 Sending password reset OTP for: $email');
    state = state.copyWith(isLoading: true, error: null);

    try {
      await FirebaseService.sendPasswordResetOTP(email);

      state = state.copyWith(isLoading: false);
      print('✅ Password reset OTP sent');
    } catch (e) {
      print('❌ Password reset OTP error: $e');
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  // Verify password reset OTP
  Future<bool> verifyPasswordResetOTP(String email, String otp) async {
    print('🔍 Verifying password reset OTP for: $email');
    state = state.copyWith(isLoading: true, error: null);

    try {
      final isValid = await FirebaseService.verifyPasswordResetOTP(
        email: email,
        otp: otp,
      );

      state = state.copyWith(isLoading: false);

      if (!isValid) {
        state = state.copyWith(
          error: 'Invalid or expired OTP. Please try again.',
        );
      }

      return isValid;
    } catch (e) {
      print('❌ Password reset OTP verification error: $e');
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return false;
    }
  }

  Future<void> logout() async {
    print('🚪 Starting logout...');
    try {
      await FirebaseService.signOut();
      print('✅ Logout successful');
    } catch (e) {
      print('❌ Logout error: $e');
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> updateProfile({
    String? name,
    String? phone,
    String? photoURL,
  }) async {
    if (state.user == null) return;

    state = state.copyWith(isLoading: true, error: null);

    try {
      if (name != null) {
        await FirebaseService.updateUserProfile(displayName: name);
      }

      final updateData = <String, dynamic>{};
      if (name != null) updateData['name'] = name;
      if (phone != null) updateData['phone'] = phone;
      if (photoURL != null) updateData['photoURL'] = photoURL;

      if (updateData.isNotEmpty) {
        await FirebaseService.updateUserDocument(
          uid: state.user!.id,
          data: updateData,
        );

        state = state.copyWith(
          isLoading: false,
          user: state.user!.copyWith(
            name: name ?? state.user!.name,
            phone: phone ?? state.user!.phone,
            photoURL: photoURL ?? state.user!.photoURL,
          ),
        );
      } else {
        state = state.copyWith(isLoading: false);
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> deleteAccount() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      await FirebaseService.deleteAccount();
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> signInWithGoogle() async {
    print('🔑 Starting Google Sign-In...');
    state = state.copyWith(isLoading: true, error: null);

    try {
      final credential = await FirebaseService.signInWithGoogle();

      print('✅ Google Sign-In successful for: ${credential.user?.email}');
    } catch (e) {
      print('❌ Google Sign-In error: $e');
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

// Provider
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});

// Convenience providers
final isAuthenticatedProvider = Provider<bool>((ref) {
  return ref.watch(authProvider).isAuthenticated;
});

final authLoadingProvider = Provider<bool>((ref) {
  return ref.watch(authProvider).isLoading;
});

final authErrorProvider = Provider<String?>((ref) {
  return ref.watch(authProvider).error;
});

final currentUserProvider = Provider<UserModel?>((ref) {
  return ref.watch(authProvider).user;
});

final isEmailVerifiedProvider = Provider<bool>((ref) {
  return ref.watch(authProvider).isEmailVerified;
});

final isAwaitingOTPVerificationProvider = Provider<bool>((ref) {
  return ref.watch(authProvider).isAwaitingOTPVerification;
});
