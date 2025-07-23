import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ming_cute_icons/ming_cute_icons.dart';
import 'package:my_rights_mobile_app/core/router/app_router.dart';
import 'package:my_rights_mobile_app/provider/course_provider.dart';
import 'package:my_rights_mobile_app/shared/widgets/empty_card.dart';

class CourseDetailScreen extends ConsumerWidget {
  final String courseId;

  const CourseDetailScreen({super.key, required this.courseId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final courseAsync = ref.watch(courseDetailProvider(courseId));

    return Scaffold(
      backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Theme.of(context).appBarTheme.foregroundColor),
          onPressed: () => context.go(AppRouter.learn),
        ),
        title: Text(
          courseAsync.when(
            data: (course) => course?.title ?? 'Course Details',
            error: (Object error, StackTrace stackTrace) => 'Error',
            loading: () => 'Loading...',
          ),
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
                    const SizedBox(height: 20),
                    // Courses Section
                    courseAsync.when(
                      data: (course) {
                        if (course == null) {
                          return EmptyCard(
                            icon: MingCuteIcons.mgc_book_6_line,
                            title: 'No Course Details',
                            description: 'Course details will appear here when available. Check back later for new content!',
                          );
                        }
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Course Image and Title
                            Container(
                              height: MediaQuery.of(context).size.height * 0.3, // 30% of screen height
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
                                ],
                              )
                            )
                          ],
                        );
                      },
                      loading: () => const Center(child: CircularProgressIndicator()),
                      error: (error, stack) => Center(child: Text('Error')),
                    ),
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
