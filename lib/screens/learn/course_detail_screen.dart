import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ming_cute_icons/ming_cute_icons.dart';
import 'package:my_rights_mobile_app/core/router/app_router.dart';
import 'package:my_rights_mobile_app/core/theme/app_colors.dart';
import 'package:my_rights_mobile_app/provider/course_provider.dart';
import 'package:my_rights_mobile_app/provider/main_provider.dart';
import 'package:my_rights_mobile_app/shared/widgets/custom_list.dart';
import 'package:my_rights_mobile_app/shared/widgets/empty_card.dart';
import 'package:my_rights_mobile_app/shared/widgets/progress_card.dart';

class CourseDetailScreen extends ConsumerWidget {
  final String courseId;

  const CourseDetailScreen({super.key, required this.courseId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final course = ref.watch(courseDetailProvider(courseId));
    final lessonsAsync = ref.watch(courseLessonsProvider(courseId));
    
    // Initialize progress data
    ref.watch(progressInitializationProvider);
    
    // Calculate overall progress (average)
    double overallProgress = 0;
    
    return Scaffold(
      backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Theme.of(context).appBarTheme.foregroundColor),
          onPressed: () => {
            ref.read(selectedBottomNavIndexProvider.notifier).state = 1,
            Navigator.of(context).pop(),
          },
        ),
        title: Text(
          course?.title ?? 'Course Details',
          style: TextStyle(
            color: Theme.of(context).appBarTheme.foregroundColor,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Courses Section
                    if (course == null)
                      EmptyCard(
                        icon: MingCuteIcons.mgc_book_6_line,
                        title: 'No Course Details',
                        description: 'Course details will appear here when available. Check back later for new content!',
                      )
                    else 
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Course Image and Title
                          Container(
                            height: MediaQuery.of(context).size.height * 0.4, // 40% of screen height
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                image: NetworkImage(course.imageUrl),
                                fit: BoxFit.cover,
                              ),
                            ),
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.transparent,
                                    Theme.of(context).appBarTheme.foregroundColor!.withValues(alpha: .5),
                                  ],
                                ),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(20),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      course.title,
                                      style: TextStyle(
                                        color: Theme.of(context).appBarTheme.backgroundColor,
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                // Course Description
                                Text(
                                  course.description,
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Theme.of(context).appBarTheme.foregroundColor,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                // Lessons Section
                                Text(
                                  'Lessons',
                                  style: Theme.of(context).appBarTheme.titleTextStyle!.copyWith(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w800,
                                    color: Theme.of(context).appBarTheme.foregroundColor,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                // Lessons List
                                lessonsAsync.when(
                                  data: (lessons) {
                                    // Calculate progress for each lesson
                                    final startedLessons = ref.watch(startedLessonsProvider);
                                    List<num> lessonProgresses = [];
                                    for (var lesson in lessons) {
                                      final isStarted = startedLessons.contains(lesson.id);
                                      
                                      // Initialize and get current chapter for this lesson
                                      ref.watch(currentChapterInitProvider(lesson.id));
                                      final currentChapter = ref.watch(currentChapterProvider(lesson.id));
                                      final totalChapters = ref.watch(
                                        lessonChaptersProvider((courseId: courseId, lessonId: lesson.id))
                                      ).when(
                                        data: (chapters) => chapters.length,
                                        loading: () => 1,
                                        error: (error, stack) => 1,
                                      );
                                      final progress = isStarted ? totalChapters == 0 ? 0 : (((currentChapter + 1) / totalChapters) * 100) : 0;
                                      lessonProgresses.add(progress);
                                    }

                                    overallProgress = lessonProgresses.isNotEmpty ? lessonProgresses.reduce((a, b) => a + b) / lessonProgresses.length : 0;

                                    return ListView.builder(
                                      shrinkWrap: true,
                                      physics: const NeverScrollableScrollPhysics(),
                                      itemCount: lessons.length,
                                      itemBuilder: (context, index) {
                                        final lesson = lessons[index];
                                        
                                        // Initialize and get current chapter for this lesson
                                        ref.watch(currentChapterInitProvider(lesson.id));
                                        final currentChapter = ref.watch(currentChapterProvider(lesson.id));
                                        final totalChapters = ref.watch(lessonChaptersProvider((courseId: courseId, lessonId: lesson.id))).when(
                                          data: (chapters) => chapters.length,
                                          loading: () => 1,
                                          error: (error, stack) => 1,
                                        );
                                        final startedLessons = ref.watch(startedLessonsProvider);
                                        final isStarted = startedLessons.contains(lesson.id);
                                        final progress = isStarted ? totalChapters == 0 ? 0 : (((currentChapter + 1) / totalChapters) * 100) : 0;
                                        
                                        return Padding(
                                          padding: const EdgeInsets.only(right: 4.0),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              // Lesson Item
                                              CustomListItem(
                                                icon: MingCuteIcons.mgc_book_6_line,
                                                title: lesson.title,
                                                subtitle: lesson.description,
                                                onTap: () => {
                                                  // Add lesson to started lessons and save
                                                  ref.read(startedLessonsProvider.notifier).addLesson(lesson.id),
                                                  context.push('${AppRouter.learn}/course/${course.id}/lesson/${lesson.id}'),
                                                },
                                              ),
                                              // Add the estimated time if available
                                              Padding(
                                                padding: const EdgeInsets.only(left: 56.0, bottom: 8.0, right: 16.0),
                                                child: Row(
                                                  crossAxisAlignment: CrossAxisAlignment.center,
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  children: [
                                                    Row(
                                                      crossAxisAlignment: CrossAxisAlignment.center,
                                                      children: [
                                                        Icon(
                                                          Icons.access_time,
                                                          size: 14,
                                                          color: Theme.of(context).textTheme.bodySmall?.color?.withValues(alpha: 0.6),
                                                        ),
                                                        const SizedBox(width: 4),
                                                        Text(
                                                          '${lesson.estimatedDurationMinutes} min',
                                                          style: TextStyle(
                                                            fontSize: 12,
                                                            color: Theme.of(context).textTheme.bodySmall?.color?.withValues(alpha: 0.6),
                                                          ),
                                                        ),
                                                        if (progress > 0 && progress < 100) ...[
                                                          const SizedBox(width: 16),
                                                          Text(
                                                            '$totalChapters ${totalChapters == 1 ? 'chapter' : 'chapters'}',
                                                            style: TextStyle(
                                                              fontSize: 12,
                                                              color: Theme.of(context).textTheme.bodySmall?.color?.withValues(alpha: 0.6),
                                                            ),
                                                          ),
                                                        ]
                                                      ]
                                                    ),
                                                    const SizedBox(width: 8),
                                                    if (progress >= 100) ...[
                                                      Row(
                                                        crossAxisAlignment: CrossAxisAlignment.center,
                                                        children: [
                                                          Icon(
                                                            MingCuteIcons.mgc_checks_line,
                                                            color: AppColors.success
                                                          ),
                                                          const SizedBox(width: 4),
                                                          Text(
                                                            'Completed',
                                                            style: TextStyle(
                                                              fontSize: 12,
                                                              fontWeight: FontWeight.w800,
                                                              color: AppColors.success,
                                                            ),
                                                          )
                                                        ]
                                                      )
                                                    ] else if (progress != 0) ...[
                                                      Text(
                                                        '${progress.round()}%',
                                                        style: TextStyle(
                                                          fontSize: 12,
                                                          fontWeight: FontWeight.w600,
                                                          color: AppColors.primary
                                                        ),
                                                      )
                                                    ]
                                                  ],
                                                ),
                                              ),
                                            ],
                                          )
                                        );
                                      },
                                    );
                                  },
                                  loading: () => const Center(child: CircularProgressIndicator()),
                                  error: (error, stack) => Center(child: Text('Error loading lessons')),
                                ),
                                const SizedBox(height: 16),
                                // Overall Progress
                                ProgressCard(
                                  title: 'Overall Progress',
                                  percentage: overallProgress,
                                ),
                                const SizedBox(height: 16),
                              ],
                            )
                          )
                        ],
                      )
                  ]
                )
              )
            )
          ]
        )
      )
    );
  }
}
