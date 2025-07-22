import 'package:flutter/material.dart';
import 'package:ming_cute_icons/ming_cute_icons.dart';
import 'package:my_rights_mobile_app/core/theme/app_colors.dart';

class CategoryCard extends StatelessWidget {
  final String title;
  final VoidCallback onTap;

  const CategoryCard({
    super.key,
    required this.title,
    required this.onTap,
  });
  
  IconData getIconByName(String name) {
    switch (name.toLowerCase().trim().replaceAll(' ', '_')) {
      case 'administrative':
        return MingCuteIcons.mgc_building_2_line;
      case 'commercial':
        return MingCuteIcons.mgc_store_2_line;
      case 'constitution':
        return MingCuteIcons.mgc_book_6_line;
      case 'contract':
        return MingCuteIcons.mgc_paper_2_line;
      case 'criminal':
        return MingCuteIcons.mgc_auction_line;
      case 'family':
        return MingCuteIcons.mgc_user_heart_line;
      case 'property':
        return MingCuteIcons.mgc_column_line;
      case 'tort':
        return MingCuteIcons.mgc_balance_line;
      case 'labor':
        return MingCuteIcons.mgc_group_3_line;
      case 'environmental':
        return MingCuteIcons.mgc_leaf_line;
      case 'international':
        return MingCuteIcons.mgc_globe_line;
      default:
        return MingCuteIcons.mgc_grid_line; // Default icon if no match found
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          color: AppColors.secondary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12.0),
          border: Border.all(
            color: AppColors.secondary.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
        child: IntrinsicWidth(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                getIconByName(title),
                size: 18,
                color: Theme.of(context).appBarTheme.foregroundColor,
              ),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).appBarTheme.foregroundColor,
                  ),
                )
              ),
            ],
          ),
        ),
      )
    );
  }
}