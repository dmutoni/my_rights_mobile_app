import 'package:flutter/material.dart';
import 'package:my_rights_mobile_app/core/theme/app_colors.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  const CustomAppBar({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      elevation: 0,
      leadingWidth: 72,
      leading: Padding(
        padding: const EdgeInsets.only(left: 16.0),
        child: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(100)
          ),
          child: Center(
            child: Text(
              'MR',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
      title: Text(
        title,
        style: Theme.of(context).appBarTheme.titleTextStyle?.copyWith(
          fontWeight: FontWeight.w800
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 16);
}
