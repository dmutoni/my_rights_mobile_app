import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ming_cute_icons/ming_cute_icons.dart';
import 'package:my_rights_mobile_app/core/theme/app_colors.dart';

class CustomBottomNavBar extends ConsumerWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CustomBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      height: 100,
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildNavItem(
            icon: MingCuteIcons.mgc_home_4_line,
            label: 'Home',
            index: 0,
            selectedIndex: currentIndex,
            onTap: () => onTap(0),
          ),
          _buildNavItem(
            icon: MingCuteIcons.mgc_book_6_line,
            label: 'Learn',
            index: 1,
            selectedIndex: currentIndex,
            onTap: () => onTap(1),
          ),
          _buildNavItem(
            icon: MingCuteIcons.mgc_announcement_line,
            label: 'Report',
            index: 2,
            selectedIndex: currentIndex,
            onTap: () => onTap(2),
          ),
          _buildNavItem(
            icon: MingCuteIcons.mgc_balance_line,
            label: 'Aid',
            index: 3,
            selectedIndex: currentIndex,
            onTap: () => onTap(3),
          ),
          _buildNavItem(
            icon: MingCuteIcons.mgc_user_1_line,
            label: 'Profile',
            index: 4,
            selectedIndex: currentIndex,
            onTap: () => onTap(4),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required int index,
    required int selectedIndex,
    required VoidCallback onTap,
  }) {
    final isSelected = index == selectedIndex;
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 12),
          Icon(
            icon,
            color: isSelected ? AppColors.primary : AppColors.secondary,
            size: 24,
          ),
          const SizedBox(height: 12),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? AppColors.primary : AppColors.secondary,
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}
