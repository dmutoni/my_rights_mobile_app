import 'package:flutter/material.dart';
import 'package:my_rights_mobile_app/core/theme/app_colors.dart';
import 'package:my_rights_mobile_app/models/course.dart';

class CourseCard extends StatelessWidget {
  final Course course;
  final VoidCallback onTap;

  const CourseCard({
    super.key,
    required this.course,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    
    // Responsive height calculation based on screen size
    final imageHeight = screenHeight * 0.175; // 17.5% of screen height

    return InkWell(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: screenHeight * 0.01), // 1% of screen height
        decoration: BoxDecoration(
          color: Theme.of(context).appBarTheme.backgroundColor,
          border: Border.all(color: Theme.of(context).appBarTheme.foregroundColor!.withValues(alpha: .05)),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).appBarTheme.foregroundColor!.withValues(alpha: .15),
              blurRadius: 4,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image container with responsive height
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              child: Container(
                height: imageHeight,
                width: double.infinity,
                color: AppColors.textHint,
                child: course.imageUrl.isNotEmpty
                    ? Image.network(
                        course.imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            Container(
                              color: AppColors.textHint,
                              child: const Center(
                                child: Icon(Icons.image, color: AppColors.textHint),
                              ),
                            ),
                      )
                    : const Center(
                        child: Icon(Icons.image, color: AppColors.textHint),
                      ),
              ),
            ),
            
            // Content container
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(screenWidth * 0.04), // 4% of screen width
                child: Column(
                  children: [
                    Text(
                      course.title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).appBarTheme.foregroundColor
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: screenHeight * 0.01), // 1% of screen height
                    Text(
                      course.description,
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.secondary
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
          ],
        )
      ),
    );
  }
}
