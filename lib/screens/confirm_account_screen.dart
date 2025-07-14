import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:my_rights_mobile_app/core/router/app_router.dart';
import 'package:my_rights_mobile_app/core/theme/app_colors.dart';
import 'package:my_rights_mobile_app/provider/auth_provider.dart';
import 'package:my_rights_mobile_app/shared/widgets/custom_button.dart';
import 'package:my_rights_mobile_app/shared/widgets/otp_input_field.dart';

class ConfirmAccountScreen extends ConsumerStatefulWidget {
  final String email;

  const ConfirmAccountScreen({
    super.key,
    required this.email,
  });

  @override
  ConsumerState<ConfirmAccountScreen> createState() =>
      _ConfirmAccountScreenState();
}

class _ConfirmAccountScreenState extends ConsumerState<ConfirmAccountScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String _otp = '';
  String? _otpError;

  void _handleVerifyOTP() async {
    if (_otp.length == 6) {
      setState(() {
        _otpError = null;
      });

      await ref.read(authProvider.notifier).verifyOTP(_otp);

      // Check if verification was successful
      final authState = ref.read(authProvider);
      if (authState.isAuthenticated) {
        // Navigate to home or dashboard
        context.go('/home'); // You'll need to add this route
      } else if (authState.error != null) {
        setState(() {
          _otpError = authState.error;
        });
        // Clear error from provider
        ref.read(authProvider.notifier).clearError();
      }
    } else {
      setState(() {
        _otpError = 'Please enter a valid 6-digit OTP';
      });
    }
  }

  void _handleResendOTP() {
    // Implement resend OTP logic
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('OTP sent successfully!'),
        backgroundColor: AppColors.success,
      ),
    );
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
          onPressed: () => context.go(AppRouter.signup),
        ),
        title: const Text(
          'Confirm Account',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 40),

                // Icon
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.security,
                    size: 40,
                    color: AppColors.primary,
                  ),
                ),

                const SizedBox(height: 24),

                // Title
                const Text(
                  'Verify your account',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),

                const SizedBox(height: 16),

                // Description
                Text(
                  'Use the OTP code we sent to your email to be able to\nchange your password',
                  style: const TextStyle(
                    fontSize: 16,
                    color: AppColors.textSecondary,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 40),

                // OTP Input
                OTPInputField(
                  length: 6,
                  autoFocus: true,
                  enabled: !authState.isLoading,
                  errorText: _otpError,
                  onChanged: (value) {
                    setState(() {
                      _otp = value;
                      _otpError = null;
                    });
                  },
                  onCompleted: (otp) {
                    setState(() {
                      _otp = otp;
                    });
                  },
                ),

                const SizedBox(height: 40),

                // Confirm button
                CustomButton(
                  text: 'Confirm',
                  width: double.infinity,
                  isLoading: authState.isLoading,
                  isEnabled: _otp.length == 6,
                  onPressed: _handleVerifyOTP,
                ),

                const SizedBox(height: 24),

                // Resend OTP
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Didn't receive the code? ",
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 14,
                      ),
                    ),
                    GestureDetector(
                      onTap: authState.isLoading ? null : _handleResendOTP,
                      child: Text(
                        'Resend',
                        style: TextStyle(
                          color: authState.isLoading
                              ? AppColors.textLight
                              : AppColors.primary,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),

                const Spacer(),

                // Email info
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceVariant,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.email_outlined,
                        color: AppColors.textSecondary,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'OTP sent to ${widget.email}',
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
