import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:my_rights_mobile_app/core/router/app_router.dart';
import 'package:my_rights_mobile_app/core/theme/app_colors.dart';
import 'package:my_rights_mobile_app/provider/auth_provider.dart';
import 'package:my_rights_mobile_app/shared/widgets/custom_button.dart';

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

  String? _otpError;

  void _handleCheckEmailVerification() async {
    await ref.read(authProvider.notifier).checkEmailVerification();

    // Check if verification was successful
    final authState = ref.read(authProvider);
    if (authState.isEmailVerified) {
      // Navigate to home or dashboard
      context.go('/home'); // You'll need to add this route
    } else {
      setState(() {
        _otpError =
            'Email not verified yet. Please check your email and click the verification link.';
      });
      // Clear error from provider
      ref.read(authProvider.notifier).clearError();
    }
  }

  void _handleResendVerification() async {
    await ref.read(authProvider.notifier).sendEmailVerification();

    final authState = ref.read(authProvider);
    if (authState.error == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Verification email sent successfully!'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(authState.error!),
            backgroundColor: AppColors.error,
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
                    Icons.email_outlined,
                    size: 40,
                    color: AppColors.primary,
                  ),
                ),

                const SizedBox(height: 24),

                // Title
                const Text(
                  'Verify your email',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),

                const SizedBox(height: 16),

                // Description
                Text(
                  'We have sent a verification link to your email.\nPlease check your email and click the link to verify your account.',
                  style: const TextStyle(
                    fontSize: 16,
                    color: AppColors.textSecondary,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 40),

                // Email verification status
                if (_otpError != null) ...[
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.error.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.error.withValues(
                          alpha: 0.3,
                        ),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.error_outline,
                          color: AppColors.error,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            _otpError!,
                            style: const TextStyle(
                              color: AppColors.error,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                ],

                // Check verification button
                CustomButton(
                  text: 'I\'ve verified my email',
                  width: double.infinity,
                  isLoading: authState.isLoading,
                  onPressed: _handleCheckEmailVerification,
                ),

                const SizedBox(height: 16),

                // Resend verification button
                CustomButton(
                  text: 'Resend verification email',
                  type: ButtonType.outline,
                  width: double.infinity,
                  isLoading: authState.isLoading,
                  onPressed: _handleResendVerification,
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
                          'Verification email sent to ${widget.email}',
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Tips
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.info.withValues(
                      alpha: 0.1,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.info.withValues(
                        alpha: 0.3,
                      ),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: const [
                          Icon(
                            Icons.lightbulb_outline,
                            color: AppColors.info,
                            size: 20,
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Tips:',
                            style: TextStyle(
                              color: AppColors.info,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        '• Check your spam/junk folder\n• Make sure you clicked the verification link\n• The link may take a few minutes to arrive',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                          height: 1.4,
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
