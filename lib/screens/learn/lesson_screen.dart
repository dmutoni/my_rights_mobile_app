import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ming_cute_icons/ming_cute_icons.dart';
import 'package:my_rights_mobile_app/core/router/app_router.dart';
import 'package:my_rights_mobile_app/core/theme/app_colors.dart';
import 'package:my_rights_mobile_app/provider/course_provider.dart';
import 'package:my_rights_mobile_app/shared/widgets/audio_panel.dart';
import 'package:my_rights_mobile_app/shared/widgets/video_panel.dart';
import 'package:my_rights_mobile_app/shared/widgets/custom_button.dart';
import 'package:my_rights_mobile_app/shared/widgets/empty_card.dart';
import 'package:my_rights_mobile_app/shared/widgets/progress_card.dart';

class LessonScreen extends ConsumerWidget {
  final String courseId;
  final String lessonId;

  const LessonScreen({super.key, required this.courseId, required this.lessonId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chaptersAsync = ref.watch(lessonChaptersProvider((courseId: courseId, lessonId: lessonId)));
    final currentChapterIndex = ref.watch(currentChapterProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Theme.of(context).appBarTheme.foregroundColor),
          onPressed: () => {
            // check if we have a previous chapter
            if (currentChapterIndex > 0) {
              // Go to previous chapter
              ref.read(currentChapterProvider.notifier).state = currentChapterIndex - 1
            } else {
              // Go back to course overview
              context.go('${AppRouter.learn}/course/$courseId')
            }
          },
        ),
        title: Text(
          chaptersAsync.when(
            data: (chapters) => chapters.isNotEmpty ? chapters.first.title : 'Lesson',
            error: (Object error, StackTrace stackTrace) => 'Error',
            loading: () => 'Loading...',
          ),
          style: TextStyle(
            color: Theme.of(context).appBarTheme.foregroundColor,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: chaptersAsync.when(
        data: (chapters) {
          if (chapters.isEmpty) {
            return const Center(child: Text('No chapters found'));
          }

          final chapter = currentChapterIndex < chapters.length 
              ? chapters[currentChapterIndex] 
              : null;

          return SafeArea(
            child: Column(
              children: [
                Expanded(child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                    const SizedBox(height: 16),
                    // Lesson Title and Progress
                    ProgressCard(
                      percentage: chapters.isNotEmpty ? ((currentChapterIndex + 1) / chapters.length) * 100 : 0, 
                      title: '${currentChapterIndex + 1}/${chapters.length}',
                      showPercentage: false
                    ),
                  
                    const SizedBox(height: 20),

                    // Chapter Content
                    if (chapter != null && chapter.content != null) ...[
                                            // Images Section
                      if (chapter.content!.images.isNotEmpty) ...[
                        for (final image in chapter.content!.images) ...[
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.network(
                              image.url,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => Container(
                                height: 200,
                                color: AppColors.textHint.withValues(alpha: .5),
                                child: Center(
                                  child: Icon(Icons.image, color: AppColors.textSecondary, size: 32),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            image.caption,
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.textSecondary,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                          const SizedBox(height: 20),
                        ],
                      ],
                      // Content Text
                      Text(
                        chapter.content!.text,
                        style: const TextStyle(
                          fontSize: 16,
                          height: 1.6,
                          color: Colors.black87,
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Audio Section
                      if (chapter.content!.audioUrl != null && chapter.content!.audioUrl!.isNotEmpty) ...[
                        const Text(
                          'Audio',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 12),
                        AudioPanel(audioUrl: chapter.content!.audioUrl!, title: chapter.title),
                        const SizedBox(height: 24),
                      ],

                      // Video Section
                      if (chapter.content!.videoUrl != null && chapter.content!.videoUrl!.isNotEmpty) ...[
                        const Text(
                          'Video',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 12),
                        VideoPanel(videoUrl: chapter.content!.videoUrl!),
                        const SizedBox(height: 24),
                      ],
                      // Key Points
                      if (chapter.content!.keyPoints.isNotEmpty) ...[
                        const Text(
                          'Key Points',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary
                          ),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: .1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.primary.withValues(alpha: .5)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: chapter.content!.keyPoints.map((point) => 
                              Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      width: 6,
                                      height: 6,
                                      margin: const EdgeInsets.only(top: 8, right: 12),
                                      decoration: BoxDecoration(
                                        color: AppColors.primary,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    Expanded(
                                      child: Text(
                                        point,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          height: 1.5,
                                          color: AppColors.textPrimary
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ).toList(),
                          ),
                        ),
                      ],
                      const SizedBox(height: 32),
                    ]
                    else ...[
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.2),
                        child: EmptyCard(
                          icon: MingCuteIcons.mgc_book_6_line, 
                          title: 'No Chapter Content', 
                          description: 'Chapter content will appear here when available. Check back later for new content!'
                        ),
                      ),
                    ],
                  ])
                ),         
                ),
                // Next Button
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: CustomButton(
                    text: 'Next',
                    width: double.infinity,
                    onPressed: () => {
                    if (currentChapterIndex < chapters.length - 1) {
                      // Go to next chapter
                      ref.read(currentChapterProvider.notifier).state = currentChapterIndex + 1
                    } else {
                      // Go to quiz
                      ref.read(currentQuestionProvider.notifier).state = 0,
                      ref.read(selectedAnswersProvider.notifier).state = {},
                      context.go('${AppRouter.learn}/course/$courseId/lesson/$lessonId/quiz'),
                    }
                  }
                ),
              ),
            ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
    );
  }
}