import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:my_rights_mobile_app/core/router/app_router.dart';
import 'package:my_rights_mobile_app/core/theme/app_colors.dart';
import 'package:my_rights_mobile_app/core/utils/validators.dart';
import 'package:my_rights_mobile_app/provider/auth_provider.dart';
import 'package:my_rights_mobile_app/shared/widgets/custom_button.dart';
import 'package:my_rights_mobile_app/shared/widgets/custom_text_fields.dart';

class SignupScreen extends ConsumerStatefulWidget {
  const SignupScreen({super.key});

  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _handleSignup() async {
    if (_formKey.currentState?.validate() ?? false) {
      await ref.read(authProvider.notifier).signup(
            _nameController.text,
            _emailController.text,
            _passwordController.text,
          );

      final authState = ref.read(authProvider);

      // Check if signup was successful (OTP sent)
      if (authState.isAwaitingOTPVerification && authState.error == null) {
        // Navigate to OTP verification screen
        if (mounted) {
          context
              .go('${AppRouter.confirmAccount}?email=${_emailController.text}');
        }
      } else if (authState.error != null) {
        // Show error message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(authState.error!),
              backgroundColor: AppColors.error,
              duration: const Duration(seconds: 4),
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => context.go(AppRouter.welcome),
        ),
        title: const Text(
          'Sign Up',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 20),

                // Description
                const Text(
                  'Sign up now to access all legal knowledge and\naccess to justice in Rwanda',
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.textSecondary,
                    height: 1.5,
                  ),
                ),

                const SizedBox(height: 32),

                // Name field
                CustomTextField(
                  label: 'Name',
                  hint: 'Enter your full name',
                  controller: _nameController,
                  validator: Validators.name,
                  textCapitalization: TextCapitalization.words,
                ),

                const SizedBox(height: 20),

                // Email field
                CustomTextField(
                  label: 'Email',
                  hint: 'Enter your email',
                  controller: _emailController,
                  type: TextFieldType.email,
                  validator: Validators.email,
                ),

                const SizedBox(height: 20),

                // Password field
                CustomTextField(
                  label: 'Password',
                  hint: 'Create a password',
                  controller: _passwordController,
                  type: TextFieldType.password,
                  validator: Validators.strongPassword,
                ),

                const SizedBox(height: 20),

                // Confirm password field
                CustomTextField(
                  label: 'Confirm Password',
                  hint: 'Confirm your password',
                  controller: _confirmPasswordController,
                  type: TextFieldType.password,
                  validator: (value) => Validators.confirmPassword(
                    value,
                    _passwordController.text,
                  ),
                ),

                const SizedBox(height: 32),

                // Sign up button
                CustomButton(
                  text: 'Sign Up',
                  width: double.infinity,
                  isLoading: authState.isLoading,
                  onPressed: _handleSignup,
                ),

                const SizedBox(height: 32),

                // Login link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Already have an account? ",
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 14,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => context.go(AppRouter.login),
                      child: const Text(
                        'Login',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),

                // Add some bottom padding for better UX
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
