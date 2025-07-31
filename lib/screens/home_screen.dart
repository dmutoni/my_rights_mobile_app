import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ming_cute_icons/ming_cute_icons.dart';
import 'package:my_rights_mobile_app/core/router/app_router.dart';
import 'package:my_rights_mobile_app/provider/course_provider.dart';
import 'package:my_rights_mobile_app/provider/main_provider.dart';
import 'package:my_rights_mobile_app/shared/widgets/course_card.dart';
import 'package:my_rights_mobile_app/shared/widgets/custom_app_bar.dart';
import 'package:my_rights_mobile_app/shared/widgets/custom_bottom_navbar.dart';
import 'package:my_rights_mobile_app/shared/widgets/empty_card.dart';
import 'package:my_rights_mobile_app/shared/widgets/info_card.dart';
import 'package:my_rights_mobile_app/shared/widgets/quick_access_card.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final featuredCoursesAsync = ref.watch(featuredCoursesProvider);
    final helpfulTipsAsync = ref.watch(helpfulTipsProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
      appBar: CustomAppBar(title: 'MyRights'),
      body: SafeArea(
        child: Column(
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
                      style: Theme.of(context)
                          .appBarTheme
                          .titleTextStyle
                          ?.copyWith(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context)
                                  .appBarTheme
                                  .foregroundColor),
                    ),
                    const SizedBox(height: 20),
                    QuickAccessCard(
                      icon: MingCuteIcons.mgc_book_6_line,
                      title: 'Civic Education',
                      description:
                          'Learn about your rights and responsibilities as a citizen.',
                      onTap: () => {
                        ref
                            .read(selectedBottomNavIndexProvider.notifier)
                            .state = 1,
                        context.go(AppRouter.learn)
                      },
                    ),
                    QuickAccessCard(
                      icon: MingCuteIcons.mgc_announcement_line,
                      title: 'Report an Issue',
                      description:
                          'Report incidents of injustice or corruption.',
                      onTap: () => {
                        ref
                            .read(selectedBottomNavIndexProvider.notifier)
                            .state = 2,
                        context.go(AppRouter.incidentReport)
                      },
                    ),
                    QuickAccessCard(
                      icon: MingCuteIcons.mgc_balance_line,
                      title: 'Legal Aid',
                      description: 'Find legal assistance and resources.',
                      onTap: () => {
                        ref
                            .read(selectedBottomNavIndexProvider.notifier)
                            .state = 3,
                        context.go(AppRouter.aid)
                      },
                    ),
                    const SizedBox(height: 20),
                    // Featured Courses Section
                    Text(
                      'Featured Courses',
                      style: Theme.of(context)
                          .appBarTheme
                          .titleTextStyle
                          ?.copyWith(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context)
                                  .appBarTheme
                                  .foregroundColor),
                    ),
                    const SizedBox(height: 20),
                    featuredCoursesAsync.when(
                      data: (courses) {
                        if (courses.isEmpty) {
                          // Show empty state if no featured courses
                          return EmptyCard(
                            icon: MingCuteIcons.mgc_book_6_line,
                            title: 'No Featured Courses',
                            description:
                                'Featured courses will appear here when available. Check back later for new content!',
                          );
                        }
                        return SizedBox(
                          height: MediaQuery.of(context).size.width *
                              0.75, // 75% of screen height
                          child: ListView.separated(
                            shrinkWrap: true,
                            scrollDirection: Axis.horizontal,
                            itemCount: courses.length,
                            separatorBuilder: (context, index) =>
                                SizedBox(width: 20), // 20 pixels between cards
                            itemBuilder: (context, index) {
                              final course = courses[index];
                              return SizedBox(
                                  width: MediaQuery.of(context).size.width *
                                      0.5, // 50% of screen width
                                  child: CourseCard(
                                    course: course,
                                    onTap: () => context.go(
                                        '${AppRouter.learn}/course/${course.id}'),
                                  ));
                            },
                          ),
                        );
                      },
                      loading: () =>
                          const Center(child: CircularProgressIndicator()),
                      error: (error, stack) =>
                          Center(child: Text('Error loading courses')),
                    ),
                    const SizedBox(height: 20),
                    // Helpful Tips Section
                    Text(
                      'Helpful Tips',
                      style: Theme.of(context)
                          .appBarTheme
                          .titleTextStyle
                          ?.copyWith(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context)
                                  .appBarTheme
                                  .foregroundColor),
                    ),
                    const SizedBox(height: 20),
                    helpfulTipsAsync.when(
                      data: (tips) {
                        if (tips.isEmpty) {
                          // Show empty state if no tips
                          return EmptyCard(
                            icon: MingCuteIcons.mgc_light_line,
                            title: 'No Helpful Tips',
                            description:
                                'Helpful tips will appear here when available. Check back later for new content!',
                          );
                        }
                        return Column(
                          spacing: 16,
                          children: tips
                              .map((tip) => InfoCard(
                                    title: tip.title,
                                    description: tip.description,
                                    imageUrl: tip.imageUrl,
                                  ))
                              .toList(),
                        );
                      },
                      loading: () =>
                          const Center(child: CircularProgressIndicator()),
                      error: (error, stack) =>
                          Center(child: Text('Error loading tips')),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const CustomBottomNavBar(),
    );
  }
}
