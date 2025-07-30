import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_rights_mobile_app/core/theme/app_colors.dart';
import 'package:my_rights_mobile_app/core/utils/download_certificate.dart';
import 'package:my_rights_mobile_app/provider/auth_provider.dart';
import 'package:my_rights_mobile_app/provider/course_provider.dart';
import 'package:my_rights_mobile_app/screens/learn/quiz_review_screen.dart';
import 'package:my_rights_mobile_app/screens/learn/quiz_results_screen.dart';
import 'package:my_rights_mobile_app/shared/widgets/custom_button.dart';
import 'package:my_rights_mobile_app/shared/widgets/progress_card.dart';

class QuizScreen extends ConsumerWidget {
  final String courseId;
  final String lessonId;

  const QuizScreen({super.key, required this.courseId, required this.lessonId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final quizAsync = ref.watch(lessonQuizProvider((courseId: courseId, lessonId: lessonId)));
    final currentQuestionIndex = ref.watch(currentQuestionProvider);
    final selectedAnswers = ref.watch(selectedAnswersProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.close, color: Theme.of(context).appBarTheme.foregroundColor),
          onPressed: () => Navigator.of(context).pop()
        ),
        title: Text(
          'Quiz',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: quizAsync.when(
        data: (questions) {
          if (questions.isEmpty) {
            return const Center(child: Text('No quiz questions found'));
          }

          if (currentQuestionIndex >= questions.length) {
            return const Center(child: Text('Quiz completed'));
          }

          final question = questions[currentQuestionIndex];

          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Question Progress
                  ProgressCard(
                    percentage: ((currentQuestionIndex + 1) / questions.length) * 100,
                    title: 'Question ${currentQuestionIndex + 1}/${questions.length}',
                    showPercentage: false,
                  ),
                
                  const SizedBox(height: 32),
                  
                  // Question Text
                  Text(
                    question.question,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: Theme.of(context).appBarTheme.foregroundColor,
                    ),
                  ),
                  
                  const SizedBox(height: 20),

                  // Answer Options
                  Expanded(
                    child: ListView.separated(
                      separatorBuilder: (context, index) => SizedBox(height: 24), // 24 pixels between options
                      itemCount: question.options.length,
                      itemBuilder: (context, index) {
                        final isSelected = selectedAnswers[currentQuestionIndex] == index;
                        return InkWell(
                          onTap: () {
                            final newAnswers = Map<int, int>.from(selectedAnswers);
                            newAnswers[currentQuestionIndex] = index;
                            ref.read(selectedAnswersProvider.notifier).state = newAnswers;
                          },
                          child: Row(
                            children: [
                              Container(
                                width: 24,
                                height: 24,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: isSelected 
                                        ? AppColors.primary
                                        : AppColors.textHint,
                                    width: 2,
                                  ),
                                  color: isSelected 
                                      ? AppColors.primary
                                      : Colors.transparent,
                                ),
                                child: isSelected ? const Icon(
                                  Icons.circle,
                                  color: AppColors.surface,
                                  size: 12,
                                )
                                : null,
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Text(
                                  '${question.options[index]}',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: isSelected 
                                        ? AppColors.primary
                                        : AppColors.textPrimary,
                                    fontWeight: isSelected 
                                        ? FontWeight.w600 
                                        : FontWeight.normal,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  
                  // Next Button
                  CustomButton(
                    text: currentQuestionIndex < questions.length - 1 ? 'Next' : 'Finish',
                    width: double.infinity,
                    backgroundColor: selectedAnswers[currentQuestionIndex] != null 
                        ? AppColors.primary 
                        : AppColors.primary.withValues(alpha: .5),
                    disabledBackgroundColor: AppColors.primary.withValues(alpha: .5),
                    onPressed: selectedAnswers[currentQuestionIndex] != null ? () {
                      int correctAnswers = 0;
                      for (int i = 0; i < questions.length; i++) {
                        final question = questions[i];
                        final selectedAnswer = selectedAnswers[i];
                        if (selectedAnswer != null && selectedAnswer == question.answer) {
                          correctAnswers++;
                        }
                      }
                      final score = (correctAnswers / questions.length * 100).round();
                      if (currentQuestionIndex < questions.length - 1) {
                        ref.read(currentQuestionProvider.notifier).state = currentQuestionIndex + 1;
                      } else {
                        // Quiz completed
                        Navigator.of(context).push(
                          PageRouteBuilder(
                            pageBuilder: (context, animation, secondaryAnimation) => QuizResultScreen(
                              score: score,
                              totalQuestions: questions.length,
                              correctAnswers: correctAnswers,
                              passed: score >= 60,
                              courseId: courseId,
                              lessonId: lessonId,
                              onRetry: () {
                                Navigator.of(context).pop(); // Close result screen
                                // Reset quiz state and restart
                                ref.read(currentQuestionProvider.notifier).state = 0;
                                ref.read(selectedAnswersProvider.notifier).state = {};
                              },
                              onContinue: () {
                                Navigator.of(context).pop(); // Close result screen
                                Navigator.of(context).pop(); // Back to lesson
                                Navigator.of(context).pop(); // Back to course
                              },
                              onDownloadCertificate: () async {
                                final user = ref.read(currentUserProvider);
                                final course = ref.watch(courseDetailProvider(courseId));
                                final timestamp = DateTime.now().millisecondsSinceEpoch;
                                final random = (timestamp % 10000).toString().padLeft(4, '0');
                                final certificateId = 'CERT-$timestamp-$random';
                                
                                await downloadCertificateToPhone(
                                  context: context,
                                  certificateData: {
                                    'userId': user?.id,
                                    'courseId': courseId,
                                    'lessonId': lessonId,
                                    'userName': user?.name,
                                    'courseName': course.value?.title ?? 'Unknown Course',
                                    'score': score,
                                    'completionDate': DateTime.now().toIso8601String(),
                                    'certificateId': certificateId,
                                  },
                                );
                                Navigator.of(context).pop(); // Close result screen
                              },
                              onViewAnswers: () {
                                Navigator.of(context).pop(); // Close result screen
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => QuizReviewScreen(
                                      questions: questions,
                                      selectedAnswers: selectedAnswers,
                                      courseId: courseId,
                                      lessonId: lessonId,
                                    ),
                                  ),
                                );
                              },
                            ),
                            transitionDuration: const Duration(milliseconds: 300),
                            transitionsBuilder: (context, animation, secondaryAnimation, child) {
                              return FadeTransition(
                                opacity: animation,
                                child: ScaleTransition(
                                  scale: Tween<double>(begin: 0.8, end: 1.0).animate(
                                    CurvedAnimation(parent: animation, curve: Curves.easeOutBack),
                                  ),
                                  child: child,
                                ),
                              );
                            },
                            opaque: false, // Allows the semi-transparent background
                          )
                        );
                      
                      }
                    } : null,
                  )
                ]
              ),
            )
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
    );
  }
}
