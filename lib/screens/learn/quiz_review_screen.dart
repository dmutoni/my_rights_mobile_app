import 'package:flutter/material.dart';
import 'package:ming_cute_icons/ming_cute_icons.dart';
import 'package:my_rights_mobile_app/core/theme/app_colors.dart';
import 'package:my_rights_mobile_app/models/quiz.dart';

class QuizReviewScreen extends StatelessWidget {
  final List<Quiz> questions;
  final Map<int, int> selectedAnswers;
  final String courseId;
  final String lessonId;

  const QuizReviewScreen({
    super.key,
    required this.questions,
    required this.selectedAnswers,
    required this.courseId,
    required this.lessonId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Quiz Review'),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        foregroundColor: Theme.of(context).appBarTheme.foregroundColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => {
            Navigator.of(context).pop(), // Close result screen
            Navigator.of(context).pop(), // Back to lesson
            Navigator.of(context).pop() // Back to course
          },
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: questions.length,
        itemBuilder: (context, index) {
          final question = questions[index];
          final selectedAnswer = selectedAnswers[index];
          final isCorrect = selectedAnswer == question.answer;

          return Container(
            margin: const EdgeInsets.only(bottom: 24),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isCorrect ? AppColors.success.withValues(alpha: .1) : AppColors.error.withValues(alpha: .1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isCorrect ? AppColors.success.withValues(alpha: .5) : AppColors.error.withValues(alpha: .5),
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Question header
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: isCorrect ? AppColors.success : AppColors.error,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'Question ${index + 1}',
                        style: const TextStyle(
                          color: AppColors.surface,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Icon(
                      isCorrect ? MingCuteIcons.mgc_check_circle_fill : MingCuteIcons.mgc_close_circle_line,
                      color: isCorrect ? AppColors.success : AppColors.error,
                      size: 24,
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Question text
                Text(
                  question.question,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),

                const SizedBox(height: 16),

                // Answer options
                ...question.options.asMap().entries.map((entry) {
                  final optionIndex = entry.key;
                  final optionText = entry.value;
                  final isSelected = selectedAnswer == optionIndex;
                  final isCorrectAnswer = optionIndex == question.answer;

                  Color backgroundColor = AppColors.inputFill;
                  Color borderColor = AppColors.inputBorder;
                  Color textColor = AppColors.textPrimary;

                  if (isCorrectAnswer) {
                    backgroundColor = Colors.green[100]!;
                    borderColor = Colors.green[400]!;
                    textColor = Colors.green[700]!;
                  } else if (isSelected && !isCorrectAnswer) {
                    backgroundColor = Colors.red[100]!;
                    borderColor = Colors.red[400]!;
                    textColor = Colors.red[700]!;
                  }

                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: backgroundColor,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: borderColor, width: 1),
                    ),
                    child: Row(
                      children: [
                        if (isCorrectAnswer)
                          Icon(Icons.check, color: Colors.green[600], size: 20)
                        else if (isSelected && !isCorrectAnswer)
                          Icon(Icons.close, color: Colors.red[600], size: 20)
                        else
                          const SizedBox(width: 20),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            '$optionText',
                            style: TextStyle(
                              color: textColor,
                              fontWeight: (isSelected || isCorrectAnswer) 
                                  ? FontWeight.w600 
                                  : FontWeight.normal,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }),

                const SizedBox(height: 12),

                // Explanation
                if (question.explanation.isNotEmpty) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.info.withValues(alpha: .5), width: 1),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.info_outline, color: AppColors.info, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            question.explanation,
                            style: TextStyle(
                              color: Colors.blue[700],
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}
