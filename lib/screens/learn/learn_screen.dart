import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ming_cute_icons/ming_cute_icons.dart';
import 'package:my_rights_mobile_app/core/router/app_router.dart';
import 'package:my_rights_mobile_app/provider/course_provider.dart';
import 'package:my_rights_mobile_app/shared/widgets/category_card.dart';
import 'package:my_rights_mobile_app/shared/widgets/custom_app_bar.dart';
import 'package:my_rights_mobile_app/shared/widgets/empty_card.dart';
import 'package:my_rights_mobile_app/shared/widgets/featured_card.dart';

class LearnScreen extends ConsumerWidget {
  const LearnScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final courses = ref.watch(coursesProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
      appBar: CustomAppBar(title: 'Learn'),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 20),
                      // Explore Section
                      Text(
                        'Explore',
                        style: Theme.of(context).appBarTheme.titleTextStyle?.copyWith(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).appBarTheme.foregroundColor,
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Featured Cards for Learning
                      if (courses.courses.isEmpty) ...[
                        EmptyCard(
                          icon: MingCuteIcons.mgc_compass_3_line,
                          title: 'Nothing to Explore',
                          description: 'Courses will appear here when available. Check back later for new content!',
                        )
                      ] else ...[
                        SizedBox(
                          height: MediaQuery.of(context).size.width * 0.85, // image + text
                          child: ListView.separated(
                            shrinkWrap: true,
                            scrollDirection: Axis.horizontal,
                            itemCount: ((courses.courses.toList()..shuffle(Random())).take(3).toList()).length,
                            separatorBuilder: (context, index) => const SizedBox(width: 20),
                            itemBuilder: (context, index) {
                              final course = ((courses.courses.toList()..shuffle(Random())).take(3).toList())[index];
                              return FeaturedCard(
                                title: course.title,
                                description: course.description,
                                imageUrl: course.imageUrl,
                                onTap: () {
                                  // Navigate to course
                                  context.go('${AppRouter.learn}/course/${course.id}');
                                },
                              );
                            }
                          )
                        ),
                      ],
                      const SizedBox(height: 20),
                      // Course Category Section
                      Text(
                        'Categories',
                        style: Theme.of(context).appBarTheme.titleTextStyle?.copyWith(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).appBarTheme.foregroundColor,
                        ),
                      ),
                      const SizedBox(height: 20),
                      if (courses.categories.isEmpty) ...[
                        EmptyCard(
                          icon: MingCuteIcons.mgc_grid_line,
                          title: 'No Categories',
                          description: 'Categories will appear here when available. Check back later for new content!',
                        )
                      ] else ...[
                        GridView.count(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          crossAxisCount: 3,
                          mainAxisSpacing: 12,
                          crossAxisSpacing: 12,
                          childAspectRatio: 2.25,
                          children: courses.categories.map((category) {
                            return CategoryCard(
                              title: category.name,
                              onTap: () {
                                // Navigate to category courses
                                context.go('${AppRouter.learn}/category/${category.id}');
                              },
                            );
                          }).toList(),
                        ),
                      ],
                      const SizedBox(height: 20),
                    ],
                  ),
              )),
            ),
          ],
        ),
      ),
    );
  }
}
