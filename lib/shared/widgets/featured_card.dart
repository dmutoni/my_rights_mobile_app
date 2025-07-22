import 'package:flutter/material.dart';
import 'package:my_rights_mobile_app/core/theme/app_colors.dart';

class FeaturedCard extends StatelessWidget {
  final String title;
  final String description;
  final String imageUrl;
  final VoidCallback onTap;

  const FeaturedCard({
    super.key, 
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.onTap,
  });
  
  @override
  Widget build(BuildContext context) {
    final double cardWidth = MediaQuery.of(context).size.width * 0.5; // 50% of screen width
    return GestureDetector(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          // Background Image
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.network(
              imageUrl,
              width: cardWidth,
              height: cardWidth,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Container(
                  width: cardWidth,
                  height: cardWidth,
                  color: AppColors.textHint.withValues(alpha: .75),
                  child: Center(
                    child: CircularProgressIndicator(
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded / (loadingProgress.expectedTotalBytes ?? 1)
                          : null,
                    ),
                  ),
                );
              },
              errorBuilder: (context, error, stackTrace){
                return Container(
                  width: cardWidth,
                  height: cardWidth,
                  color: AppColors.textHint.withValues(alpha: .75),
                  child: Center(
                    child: Icon(
                      Icons.error_outline,
                      color: AppColors.error,
                      size: 48,
                    ),
                  ),
                );
                }
              ),
            ),
          const SizedBox(height: 16),
          // Content to have same width as image
          SizedBox(
            width: cardWidth,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: Theme.of(context).appBarTheme.foregroundColor,
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    color: AppColors.secondary,
                    fontSize: 14,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ]
            )
          )
        ],
      ),
    );
  }
}
