import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ming_cute_icons/ming_cute_icons.dart';
import 'package:my_rights_mobile_app/core/router/app_router.dart';
import 'package:my_rights_mobile_app/provider/course_provider.dart';
import 'package:my_rights_mobile_app/shared/widgets/empty_card.dart';
import 'package:my_rights_mobile_app/shared/widgets/info_card.dart';

class CategoryCoursesScreen extends ConsumerWidget {
  final String categoryId;

  const CategoryCoursesScreen({super.key, required this.categoryId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoryAsync = ref.watch(categoriesProvider);
    final categoryCoursesAsync = ref.watch(coursesByCategoryProvider(categoryId));

    return Scaffold(
      backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Theme.of(context).appBarTheme.foregroundColor),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          '${
            categoryAsync.when(
              data: (data) => data.firstWhere((category) => category.id == categoryId).name, 
              error: (Object error, StackTrace stackTrace) {  }, 
              loading: () {  }
            )
          } Courses',
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
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    // Courses Section
                    categoryCoursesAsync.when(
                      data: (courses) {
                        if (courses.isEmpty) {
                          // No courses available in this category
                          return Padding(
                            padding: EdgeInsets.symmetric(vertical: MediaQuery.of(context).size.height * 0.2),
                            child: EmptyCard(
                              icon: MingCuteIcons.mgc_compass_3_line,
                              title: 'No Courses Available',
                              description: 'There are no courses available in this category at the moment.',
                            ),
                          );
                        }
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${courses.length} ${courses.length == 1 ? 'Course' : 'Courses'}',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Theme.of(context).appBarTheme.foregroundColor
                              ),
                            ),
                            const SizedBox(height: 12),
                            SizedBox(
                              height: MediaQuery.of(context).size.width * 0.75, // 75% of screen height
                              child: ListView.separated(
                                shrinkWrap: true,
                                itemCount: courses.length,
                                separatorBuilder: (context, index) => SizedBox(width: 20), // 20 pixels between cards
                                itemBuilder: (context, index) {
                                  final course = courses[index];
                                  return SizedBox(
                                    width: MediaQuery.of(context).size.width * 0.5, // 50% of screen width
                                    child: InfoCard(
                                    title: course.title,
                                    description: course.description,
                                    imageUrl: course.imageUrl,
                                    onTap: () => context.go('${AppRouter.learn}/course/${course.id}'),
                                  ));
                                },
                              ),
                            ),
                          ],
                        );
                      },
                      loading: () => Padding(
                        padding: EdgeInsets.symmetric(vertical: MediaQuery.of(context).size.height * 0.2),
                        child: const Center(child: CircularProgressIndicator()),
                      ),
                      error: (error, stack) => Padding(
                        padding: EdgeInsets.symmetric(vertical: MediaQuery.of(context).size.height * 0.2),
                        child: Center(child: Text('Error loading courses')),
                      ),
                    ),
                  ],
                ),
              )
            ),
          ],
        ),
      ),
    );
  }
}
