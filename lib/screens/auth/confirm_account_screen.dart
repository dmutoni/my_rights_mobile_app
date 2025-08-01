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
  String _otp = '';
  String? _otpError;
  // Add a key to force rebuild the OTP widget when needed
  Key _otpWidgetKey = UniqueKey();

  void _handleVerifyOTP() async {
    if (_otp.length == 6) {
      setState(() {
        _otpError = null;
      });

      await ref.read(authProvider.notifier).verifyEmailOTP(widget.email, _otp);

      // Check if verification was successful
      final authState = ref.read(authProvider);
      if (authState.isAuthenticated && authState.isEmailVerified) {
        // Navigate to home
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.white),
                  SizedBox(width: 8),
                  Text('Email verified successfully!'),
                ],
              ),
              backgroundColor: AppColors.success,
              duration: Duration(seconds: 2),
            ),
          );
          context.go(AppRouter.home);
        }
      } else if (authState.error != null) {
        setState(() {
          _otpError = authState.error;
          // Force rebuild OTP widget to clear it
          _otpWidgetKey = UniqueKey();
          _otp = '';
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

  void _handleResendOTP() async {
    await ref
        .read(authProvider.notifier)
        .resendEmailVerificationOTP(widget.email);

    final authState = ref.read(authProvider);
    if (authState.error == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                Icon(Icons.email, color: Colors.white),
                SizedBox(width: 8),
                Text('OTP sent successfully!'),
              ],
            ),
            backgroundColor: AppColors.success,
            duration: Duration(seconds: 3),
          ),
        );
      }
      // Clear current OTP and error, force rebuild widget
      setState(() {
        _otp = '';
        _otpError = null;
        _otpWidgetKey = UniqueKey();
      });
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(authState.error!),
            backgroundColor: AppColors.error,
            duration: const Duration(seconds: 3),
          ),
        );
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
          onPressed: () => context.go(AppRouter.signup),
        ),
        title: const Text(
          'Verify Account',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 40),

              // Icon
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.email_outlined,
                  size: 40,
                  color: AppColors.primary,
                ),
              ),

              const SizedBox(height: 24),

              // Title
              const Text(
                'Check your email',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),

              const SizedBox(height: 16),

              // Description
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: const TextStyle(
                    fontSize: 16,
                    color: AppColors.textSecondary,
                    height: 1.5,
                  ),
                  children: [
                    const TextSpan(text: 'We sent a verification code to\n'),
                    TextSpan(
                      text: widget.email,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 40),

              // OTP Input using your existing widget
              OTPInputField(
                key: _otpWidgetKey, // Use the key to force rebuild when needed
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

              // Verify button
              CustomButton(
                text: 'Verify Email',
                width: double.infinity,
                isLoading: authState.isLoading,
                isEnabled: _otp.length == 6,
                onPressed: _handleVerifyOTP,
              ),

              const SizedBox(height: 24),

              // Resend OTP section
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
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Email display
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
                        'Code sent to ${widget.email}',
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
    );
  }
}
