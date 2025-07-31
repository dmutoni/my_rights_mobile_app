import 'package:flutter/material.dart';
import 'package:my_rights_mobile_app/core/theme/app_colors.dart';

enum SocialProvider { google, apple }

class SocialAuthButton extends StatelessWidget {
  final SocialProvider provider;
  final VoidCallback? onPressed;
  final bool isLoading;
  final String? customText;
  final double? width;
  final double? height;

  const SocialAuthButton({
    super.key,
    required this.provider,
    this.onPressed,
    this.isLoading = false,
    this.customText,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height ?? 52,
      child: OutlinedButton(
        onPressed: isLoading ? null : onPressed,
        style: OutlinedButton.styleFrom(
          backgroundColor: _getBackgroundColor(),
          foregroundColor: _getTextColor(),
          disabledBackgroundColor: AppColors.textLight.withValues(
            alpha: 0.5,
          ),
          disabledForegroundColor: AppColors.textLight,
          side: BorderSide(
            color: _getBorderColor(),
            width: 1.5,
          ),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: isLoading
            ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  color: _getTextColor(),
                  strokeWidth: 2,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildIcon(),
                  const SizedBox(width: 12),
                  Text(
                    customText ?? _getDefaultText(),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: _getTextColor(),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildIcon() {
    switch (provider) {
      case SocialProvider.google:
        return _buildGoogleIcon();
      case SocialProvider.apple:
        return _buildAppleIcon();
    }
  }

  Widget _buildGoogleIcon() {
    return Container(
      width: 20,
      height: 20,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
      ),
      child: CustomPaint(
        painter: GoogleIconPainter(),
      ),
    );
  }

  Widget _buildAppleIcon() {
    return const Icon(
      Icons.apple,
      size: 20,
      color: Colors.black,
    );
  }

  Color _getBackgroundColor() {
    switch (provider) {
      case SocialProvider.google:
        return Colors.white;
      case SocialProvider.apple:
        return Colors.black;
    }
  }

  Color _getTextColor() {
    switch (provider) {
      case SocialProvider.google:
        return AppColors.textPrimary;
      case SocialProvider.apple:
        return Colors.white;
    }
  }

  Color _getBorderColor() {
    switch (provider) {
      case SocialProvider.google:
        return AppColors.inputBorder;
      case SocialProvider.apple:
        return Colors.black;
    }
  }

  String _getDefaultText() {
    switch (provider) {
      case SocialProvider.google:
        return 'Continue with Google';
      case SocialProvider.apple:
        return 'Continue with Apple';
    }
  }
}

// Custom painter for Google icon
class GoogleIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    // Google G icon simplified representation
    // Blue section
    paint.color = const Color(0xFF4285F4);
    canvas.drawPath(
      Path()
        ..moveTo(size.width * 0.5, size.height * 0.2)
        ..lineTo(size.width * 0.8, size.height * 0.2)
        ..lineTo(size.width * 0.8, size.height * 0.4)
        ..lineTo(size.width * 0.6, size.height * 0.4)
        ..lineTo(size.width * 0.6, size.height * 0.6)
        ..lineTo(size.width * 0.8, size.height * 0.6)
        ..lineTo(size.width * 0.8, size.height * 0.8)
        ..lineTo(size.width * 0.5, size.height * 0.8)
        ..close(),
      paint,
    );

    // Red section
    paint.color = const Color(0xFFEA4335);
    canvas.drawPath(
      Path()
        ..moveTo(size.width * 0.2, size.height * 0.3)
        ..lineTo(size.width * 0.5, size.height * 0.2)
        ..lineTo(size.width * 0.5, size.height * 0.5)
        ..lineTo(size.width * 0.35, size.height * 0.5)
        ..close(),
      paint,
    );

    // Yellow section
    paint.color = const Color(0xFFFBBC05);
    canvas.drawPath(
      Path()
        ..moveTo(size.width * 0.2, size.height * 0.7)
        ..lineTo(size.width * 0.35, size.height * 0.5)
        ..lineTo(size.width * 0.5, size.height * 0.5)
        ..lineTo(size.width * 0.5, size.height * 0.8)
        ..close(),
      paint,
    );

    // Green section
    paint.color = const Color(0xFF34A853);
    canvas.drawPath(
      Path()
        ..moveTo(size.width * 0.2, size.height * 0.3)
        ..lineTo(size.width * 0.35, size.height * 0.5)
        ..lineTo(size.width * 0.2, size.height * 0.7)
        ..close(),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Convenience constructors
class GoogleSignInButton extends SocialAuthButton {
  const GoogleSignInButton({
    super.key,
    super.onPressed,
    super.isLoading,
    super.customText,
    super.width,
    super.height,
  }) : super(
          provider: SocialProvider.google,
        );
}

class AppleSignInButton extends SocialAuthButton {
  const AppleSignInButton({
    super.key,
    super.onPressed,
    super.isLoading,
    super.customText,
    super.width,
    super.height,
  }) : super(
          provider: SocialProvider.apple,
        );
}
