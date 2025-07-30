import 'package:flutter/material.dart';
import 'package:my_rights_mobile_app/core/theme/app_colors.dart';

class InfoCard extends StatelessWidget {
  final String title;
  final String description;
  final String imageUrl;
  final VoidCallback? onTap;
  const InfoCard({super.key, required this.title, required this.description, required this.imageUrl, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).appBarTheme.backgroundColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Theme.of(context).appBarTheme.foregroundColor!.withValues(alpha: .05)),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).appBarTheme.foregroundColor!.withValues(alpha: .15),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).appBarTheme.foregroundColor,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textLight
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                imageUrl,
                width: 80,
                height: 80,
                fit: BoxFit.cover,
              ),
            ),
          ],
        ),
      )
    );
  }
}
