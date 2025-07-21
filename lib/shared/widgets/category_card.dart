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
      case 'education':
        return MingCuteIcons.mgc_book_5_line;
      case 'health':
        return MingCuteIcons.mgc_first_aid_kit_line;
      case 'employment':
        return MingCuteIcons.mgc_building_1_line;
      case 'housing':
        return MingCuteIcons.mgc_home_3_line;
      case 'constitutional_law':
        return MingCuteIcons.mgc_book_6_line;
      case 'dispute_resolution':
        return MingCuteIcons.mgc_group_2_line;
      case 'tax_law':
        return MingCuteIcons.mgc_balance_line;
      case 'property_law':
        return MingCuteIcons.mgc_column_line;
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
                size: 24,
                color: Theme.of(context).appBarTheme.foregroundColor,
              ),
              const SizedBox(width: 12),
              Flexible(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
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