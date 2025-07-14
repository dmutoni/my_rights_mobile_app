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

  const AuthState({
    this.isAuthenticated = false,
    this.isLoading = false,
    this.error,
    this.user,
    this.isEmailVerified = false,
  });

  AuthState copyWith({
    bool? isAuthenticated,
    bool? isLoading,
    String? error,
    UserModel? user,
    bool? isEmailVerified,
  }) {
    return AuthState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      user: user ?? this.user,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
    );
  }
}

// Auth Notifier with Firebase integration
class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(const AuthState()) {
    // Listen to auth state changes
    FirebaseService.authStateChanges.listen(_onAuthStateChanged);
  }

  // Handle Firebase auth state changes
  void _onAuthStateChanged(User? firebaseUser) async {
    if (firebaseUser != null) {
      // User is signed in, get user document from Firestore
      try {
        final userDoc = await FirebaseService.getUserDocument(firebaseUser.uid);
        if (userDoc != null) {
          state = state.copyWith(
            isAuthenticated: true,
            isLoading: false,
            user: userDoc,
            isEmailVerified: firebaseUser.emailVerified,
          );
        } else {
          // User document doesn't exist, create it
          await FirebaseService.createUserDocument(
            uid: firebaseUser.uid,
            name: firebaseUser.displayName ?? '',
            email: firebaseUser.email ?? '',
          );

          final newUserDoc =
              await FirebaseService.getUserDocument(firebaseUser.uid);
          state = state.copyWith(
            isAuthenticated: true,
            isLoading: false,
            user: newUserDoc,
            isEmailVerified: firebaseUser.emailVerified,
          );
        }
      } catch (e) {
        state = state.copyWith(
          isLoading: false,
          error: 'Failed to load user data: $e',
        );
      }
    } else {
      // User is signed out
      state = const AuthState();
    }
  }

  // Sign up with email and password
  Future<void> signup(String name, String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      // Create Firebase Auth user
      final credential = await FirebaseService.signUpWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Update display name
      await FirebaseService.updateUserProfile(displayName: name);

      // Create user document in Firestore
      await FirebaseService.createUserDocument(
        uid: credential.user!.uid,
        name: name,
        email: email,
      );

      // The auth state will be updated automatically by the listener
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  // Sign in with email and password
  Future<void> login(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      await FirebaseService.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // The auth state will be updated automatically by the listener
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  // Send password reset email
  Future<void> forgotPassword(String email) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      await FirebaseService.sendPasswordResetEmail(email);

      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  // Send email verification
  Future<void> sendEmailVerification() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      await FirebaseService.sendEmailVerification();

      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  // Check email verification status
  Future<void> checkEmailVerification() async {
    try {
      await FirebaseService.reloadUser();

      final isVerified = FirebaseService.isEmailVerified;
      if (isVerified && state.user != null) {
        // Update Firestore document
        await FirebaseService.updateUserDocument(
          uid: state.user!.id,
          data: {'isEmailVerified': true},
        );

        // Update local state
        state = state.copyWith(
          isEmailVerified: true,
          user: state.user!.copyWith(isEmailVerified: true),
        );
      }
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  // Update user profile
  Future<void> updateProfile({
    String? name,
    String? phone,
    String? photoURL,
  }) async {
    if (state.user == null) return;

    state = state.copyWith(isLoading: true, error: null);

    try {
      // Update Firebase Auth profile
      if (name != null) {
        await FirebaseService.updateUserProfile(displayName: name);
      }

      // Update Firestore document
      final updateData = <String, dynamic>{};
      if (name != null) updateData['name'] = name;
      if (phone != null) updateData['phone'] = phone;
      if (photoURL != null) updateData['photoURL'] = photoURL;

      if (updateData.isNotEmpty) {
        await FirebaseService.updateUserDocument(
          uid: state.user!.id,
          data: updateData,
        );

        // Update local state
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

  // Sign out
  Future<void> logout() async {
    try {
      await FirebaseService.signOut();
      // The auth state will be updated automatically by the listener
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  // Delete account
  Future<void> deleteAccount() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      await FirebaseService.deleteAccount();
      // The auth state will be updated automatically by the listener
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  // Clear error
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
