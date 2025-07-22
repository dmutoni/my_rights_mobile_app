import 'package:flutter/material.dart';
import 'package:my_rights_mobile_app/core/theme/app_colors.dart';

class EmptyCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  const EmptyCard({super.key, required this.icon, required this.title, required this.description});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(height: 20),
        // Empty state icon
        Container(
          width: MediaQuery.of(context).size.width * 0.2,
          height: MediaQuery.of(context).size.width * 0.2,
          decoration: BoxDecoration(
            color: AppColors.background,
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            size: MediaQuery.of(context).size.width * 0.1, // 10% of screen width
            color: AppColors.textHint,
          ),
        ),
        SizedBox(height: MediaQuery.of(context).size.height * 0.02), // 2% of screen height
        // Empty state title
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: MediaQuery.of(context).size.height * 0.01), // 1% of screen height
        // Empty state description
        Text(
          description,
          style: TextStyle(
            fontSize: 14,
            color: AppColors.textLight,
          ),
          textAlign: TextAlign.center,
          maxLines: 3,
        ),
        SizedBox(height: 20)
      ],
    );
  }
}
