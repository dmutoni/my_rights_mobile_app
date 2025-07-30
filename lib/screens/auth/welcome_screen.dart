import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:my_rights_mobile_app/core/router/app_router.dart';
import 'package:my_rights_mobile_app/core/theme/app_colors.dart';
import 'package:my_rights_mobile_app/shared/widgets/custom_button.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              const Spacer(),

              // Illustration
              Container(
                height: 250,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: const Color(0xFFF5E6D3),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Image.asset(
                  'assets/images/welcome_screen_avatar.png',
                  fit: BoxFit.cover,
                ),
              ),

              const SizedBox(height: 40),

              // Title
              const Text(
                'Welcome to MyRights',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 16),

              // Description
              const Text(
                'Empowering citizens with legal knowledge\nand access to justice in Rwanda',
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),

              const Spacer(),

              // Buttons
              Column(
                children: [
                  CustomButton(
                    text: 'Login',
                    width: double.infinity,
                    onPressed: () => context.go(AppRouter.login),
                  ),
                  const SizedBox(height: 16),
                  CustomButton(
                    text: 'Sign Up',
                    type: ButtonType.outline,
                    width: double.infinity,
                    onPressed: () => context.go(AppRouter.signup),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Terms and Privacy
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textLight,
                  ),
                  children: [
                    const TextSpan(text: 'By continuing, you agree to our '),
                    TextSpan(
                      text: 'Terms of Service',
                      style: TextStyle(
                        color: AppColors.primary,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                    const TextSpan(text: '\nand '),
                    TextSpan(
                      text: 'Privacy Policy',
                      style: TextStyle(
                        color: AppColors.primary,
                        decoration: TextDecoration.underline,
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
