import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ming_cute_icons/ming_cute_icons.dart';
import 'package:my_rights_mobile_app/core/router/app_router.dart';
import 'package:my_rights_mobile_app/core/theme/app_colors.dart';
import 'package:my_rights_mobile_app/provider/main_provider.dart';

class CustomBottomNavBar extends ConsumerWidget {
  const CustomBottomNavBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedIndex = ref.watch(selectedBottomNavIndexProvider);

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
            selectedIndex: selectedIndex,
            onTap: () => {
              ref.read(selectedBottomNavIndexProvider.notifier).state = 0,
              context.go(AppRouter.home),
            },
          ),
          _buildNavItem(
            icon: MingCuteIcons.mgc_book_6_line,
            label: 'Learn',
            index: 1,
            selectedIndex: selectedIndex,
            onTap: () => {
              ref.read(selectedBottomNavIndexProvider.notifier).state = 1,
              context.go(AppRouter.learn),
            },
          ),
          _buildNavItem(
            icon: MingCuteIcons.mgc_announcement_line,
            label: 'Report',
            index: 2,
            selectedIndex: selectedIndex,
            onTap: () => {
              ref.read(selectedBottomNavIndexProvider.notifier).state = 2,
              context.go(AppRouter.report),
            },
          ),
          _buildNavItem(
            icon: MingCuteIcons.mgc_balance_line,
            label: 'Aid',
            index: 3,
            selectedIndex: selectedIndex,
            onTap: () => {
              ref.read(selectedBottomNavIndexProvider.notifier).state = 3,
              context.go(AppRouter.aid),
            },
          ),
          _buildNavItem(
            icon: MingCuteIcons.mgc_user_1_line,
            label: 'Profile',
            index: 4,
            selectedIndex: selectedIndex,
            onTap: () => {
              ref.read(selectedBottomNavIndexProvider.notifier).state = 4,
              context.go(AppRouter.profile),
            },
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
