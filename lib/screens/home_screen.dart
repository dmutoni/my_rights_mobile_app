import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ming_cute_icons/ming_cute_icons.dart';
import 'package:my_rights_mobile_app/provider/course_provider.dart';
import 'package:my_rights_mobile_app/shared/widgets/course_card.dart';
import 'package:my_rights_mobile_app/shared/widgets/custom_app_bar.dart';
import 'package:my_rights_mobile_app/shared/widgets/custom_bottom_navbar.dart';
import 'package:my_rights_mobile_app/shared/widgets/empty_card.dart';
import 'package:my_rights_mobile_app/shared/widgets/progress_card.dart';
import 'package:my_rights_mobile_app/shared/widgets/quick_access_card.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final courseProgressAsync = ref.watch(courseProgressProvider);
    final featuredCoursesAsync = ref.watch(featuredCoursesProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  // Quick Access Section
                  Text(
                    'Quick Access',
                    style: Theme.of(context).appBarTheme.titleTextStyle?.copyWith(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).appBarTheme.foregroundColor
                    ),
                  ),
                  const SizedBox(height: 16),
                  QuickAccessCard(
                    icon: MingCuteIcons.mgc_book_6_line,
                    title: 'Civic Education',
                    description: 'Learn about your rights and responsibilities as a citizen.',
                    onTap: () => {},
                    // onTap: () => context.go(AppRouter.civicEducation),
                  ),
                  QuickAccessCard(
                    icon: MingCuteIcons.mgc_announcement_line,
                    title: 'Report an Issue',
                    description: 'Report incidents of injustice or corruption.',
                    onTap: () => {},
                    // onTap: () => context.go(AppRouter.reportIssue),
                  ),
                  QuickAccessCard(
                    icon: MingCuteIcons.mgc_balance_line,
                    title: 'Legal Aid',
                    description: 'Find legal assistance and resources.',
                    onTap: () => {},
                    // onTap: () => context.go(AppRouter.legalAid),
                  ),
                  const SizedBox(height: 20),
                  // Progress Section
                  Text(
                    'Your Progress',
                    style: Theme.of(context).appBarTheme.titleTextStyle?.copyWith(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).appBarTheme.foregroundColor
                    ),
                  ),
                  const SizedBox(height: 20),
                  courseProgressAsync.when(
                    data: (courseProgress) => ProgressCard(
                      title: 'Course Completion',
                      percentage: courseProgress?.percentage ?? 0.0,
                    ),
                    loading: () => const LinearProgressIndicator(),
                    error: (error, stack) => const Text('Error loading progress'),
                  ),
                  const SizedBox(height: 20),
                  // Featured Courses Section
                  Text(
                    'Featured Courses',
                    style: Theme.of(context).appBarTheme.titleTextStyle?.copyWith(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).appBarTheme.foregroundColor
                    ),
                  ),
                  const SizedBox(height: 20),
                  featuredCoursesAsync.when(
                    data: (courses) {
                      if (courses.isEmpty) {
                        // Show empty state if no featured courses
                        return EmptyCard(
                          icon: MingCuteIcons.mgc_book_6_line,
                          title: 'No Featured Courses',
                          description: 'Featured courses will appear here when available. Check back later for new content!',
                        );
                      }
                      return ConstrainedBox(
                        constraints: BoxConstraints(
                          maxHeight: MediaQuery.of(context).size.height * 0.35, // 35% of screen height
                        ),
                        child: ListView.separated(
                          shrinkWrap: true,
                          scrollDirection: Axis.horizontal,
                          itemCount: courses.length,
                          separatorBuilder: (context, index) => SizedBox(width: 20), // 20 pixels between cards
                          itemBuilder: (context, index) {
                            final course = courses[index];
                            return SizedBox(
                              width: MediaQuery.of(context).size.width * 0.5, // 50% of screen width
                              child: CourseCard(
                              course: course,
                              onTap: () => {},
                              // onTap: () => context.go(AppRouter.courseDetail(course.id)),
                            ));
                          },
                        ),
                      );
                    },
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (error, stack) => Center(child: Text('Error loading courses')),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: const CustomBottomNavBar(),
    );
  }
}
