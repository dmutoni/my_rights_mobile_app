import 'package:flutter/material.dart';
import 'package:my_rights_mobile_app/core/theme/app_colors.dart';
import 'package:my_rights_mobile_app/models/quiz.dart';
import 'package:my_rights_mobile_app/shared/widgets/custom_button.dart';

class QuizResultScreen extends StatelessWidget {
  final int score;
  final int totalQuestions;
  final int correctAnswers;
  final bool passed;
  final String courseId;
  final String lessonId;
  final List<Quiz>? questions;
  final Map<int, int>? selectedAnswers;
  final VoidCallback? onRetry;
  final VoidCallback? onContinue;
  final VoidCallback? onDownloadCertificate;
  final VoidCallback? onViewAnswers;

  const QuizResultScreen({
    super.key,
    required this.score,
    required this.totalQuestions,
    required this.correctAnswers,
    required this.passed,
    required this.courseId,
    required this.lessonId,
    this.questions,
    this.selectedAnswers,
    this.onRetry,
    this.onContinue,
    this.onDownloadCertificate,
    this.onViewAnswers,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).appBarTheme.foregroundColor!.withValues(alpha: .75),
      body: Center(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 20),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Theme.of(context).appBarTheme.backgroundColor,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Close button
              Align(
                alignment: Alignment.topRight,
                child: IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close, color: AppColors.textSecondary),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ),
              
              // Results header
              Text(
                'Results',
                style: Theme.of(context).appBarTheme.titleTextStyle!.copyWith(fontSize: 20),
              ),
              
              const SizedBox(height: 40),
              
              // Success or Failure Icon
              Container(
                width: 100,
                height: 100,
                padding: const EdgeInsets.only(top: 10),
                decoration: passed ? BoxDecoration(
                  color: AppColors.success.withValues(alpha: .25),
                  shape: BoxShape.circle,
                ): null,
                child: passed ? Stack(
                  alignment: Alignment.center,
                  children: [
                    // Background papers
                    Positioned(
                      top: 10,
                      left: 20,
                      child: Container(
                        width: 40,
                        height: 50,
                        decoration: BoxDecoration(
                          color: AppColors.success.withValues(alpha: .25),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: AppColors.success.withValues(alpha: .25), width: 2),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 15,
                      left: 25,
                      child: Container(
                        width: 40,
                        height: 50,
                        decoration: BoxDecoration(
                          color: AppColors.success.withValues(alpha: .25),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: AppColors.success.withValues(alpha: .25), width: 2),
                        ),
                      ),
                    ),
                    // Main paper with checkmark
                    Container(
                      width: 40,
                      height: 50,
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: AppColors.success, width: 2),
                      ),
                      child: Icon(
                        Icons.check,
                        color: AppColors.success,
                        size: 24,
                      ),
                    ),
                  ],
                ) : CustomPaint(
                  painter: SadFacePainter(),
                ),
              ),
              
              const SizedBox(height: 32),
              
              // Title
              Text(
                passed 
                    ? 'Congratulations, you passed!'
                    : 'Oops, you failed! Better luck next time!',
                style: Theme.of(context).appBarTheme.titleTextStyle!.copyWith(
                  fontSize: 24,
                  color: passed ? AppColors.success : AppColors.textPrimary
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 16),
              
              // Score description
              Text(
                passed 
                    ? 'You scored $score% on the quiz. You can now download your certificate.'
                    : 'You scored $score% on the quiz. You need to score 60% to pass and earn a certificate. You can repeat the quiz to master your learning.',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 40),
              
              // Action buttons
              if (passed) ...[
                // Single button for success
                CustomButton(
                  width: double.infinity,
                  text: 'Download Certificate',
                  onPressed: onDownloadCertificate,
                  backgroundColor: AppColors.success,
                ),
                const SizedBox(height: 12),
                CustomButton(
                  text: 'Continue Learning',
                  onPressed: onContinue,
                  type: ButtonType.text,
                  textColor: AppColors.success,
                ),
              ] else ...[
                // Single button for failure
                CustomButton(
                  width: double.infinity,
                  text: 'Repeat Quiz',
                  onPressed: onRetry,
                  backgroundColor: AppColors.error,
                ),
                const SizedBox(height: 12),
                CustomButton(
                  text: 'View Answers',
                  onPressed: onViewAnswers,
                  type: ButtonType.text,
                  textColor: AppColors.error,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
class SadFacePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.error
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6;

    final fillPaint = Paint()
      ..color = AppColors.error
      ..style = PaintingStyle.fill;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 3;

    // Draw circle outline
    canvas.drawCircle(center, radius, paint);

    // Draw eyes
    canvas.drawCircle(
      Offset(center.dx - 15, center.dy - 10),
      4,
      fillPaint,
    );
    canvas.drawCircle(
      Offset(center.dx + 15, center.dy - 10),
      4,
      fillPaint,
    );

    // Draw sad mouth (upside down arc)
    final mouthRect = Rect.fromCenter(
      center: Offset(center.dx, center.dy + 20),
      width: 30,
      height: 20,
    );
    canvas.drawArc(
      mouthRect,
      0, // Start angle
      -3.14, // Sweep angle (180 degrees)
      false,
      paint,
    );

    // Draw tear
    final tearPaint = Paint()
      ..color = AppColors.info
      ..style = PaintingStyle.fill;

    final tearPath = Path();
    tearPath.moveTo(center.dx + 20, center.dy - 5);
    tearPath.quadraticBezierTo(
      center.dx + 25, center.dy,
      center.dx + 20, center.dy + 8,
    );
    tearPath.quadraticBezierTo(
      center.dx + 15, center.dy,
      center.dx + 20, center.dy - 5,
    );
    tearPath.close();

    canvas.drawPath(tearPath, tearPaint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
