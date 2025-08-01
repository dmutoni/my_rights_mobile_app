import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ming_cute_icons/ming_cute_icons.dart';
import 'package:my_rights_mobile_app/core/router/app_router.dart';
import 'package:my_rights_mobile_app/core/theme/app_colors.dart';
import 'package:my_rights_mobile_app/provider/auth_provider.dart';
import 'package:my_rights_mobile_app/provider/main_provider.dart';
import 'package:my_rights_mobile_app/shared/widgets/custom_app_bar.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final user = authState.user;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: CustomAppBar(title: 'Profile'),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),

              // Profile Picture Section
              _buildProfilePicture(context, user),

              const SizedBox(height: 24),

              // User Information
              _buildUserInfo(context, user),

              const SizedBox(height: 40),

              // Settings Options
              _buildSettingsOptions(context, ref),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfilePicture(BuildContext context, user) {
    return Center(
      child: Container(
        width: 120,
        height: 120,
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(60),
        ),
        child: Center(
          child: Text(
            'DM',
            style: TextStyle(
              fontSize: 48,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildUserInfo(BuildContext context, user) {
    return Column(
      children: [
        Text(
          user?.displayName ?? 'User Name',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
        ),
        const SizedBox(height: 8),
        Text(
          user?.email ?? 'user@example.com',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: AppColors.textSecondary,
              ),
        ),
        const SizedBox(height: 8),
        Text(
          'Member since ${user?.createdAt.year ?? DateTime.now().year}',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
        ),
      ],
    );
  }

  Widget _buildSettingsOptions(BuildContext context, WidgetRef ref) {
    final currentLanguage = ref.watch(languageProvider);

    return Column(
      children: [
        _buildSettingsItem(
          context,
          icon: MingCuteIcons.mgc_edit_line,
          title: 'Edit Profile',
          onTap: () => _showEditProfileDialog(context, ref),
        ),
        const SizedBox(height: 16),
        _buildSettingsItem(
          context,
          icon: MingCuteIcons.mgc_globe_2_fill,
          title: 'Change language',
          subtitle: _getLanguageDisplayName(currentLanguage),
          onTap: () => _showLanguageDialog(context, ref),
        ),
        const SizedBox(height: 16),
        _buildSettingsItem(
          context,
          icon: MingCuteIcons.mgc_question_line,
          title: 'Help',
          onTap: () => _showHelpDialog(context),
        ),
        const SizedBox(height: 16),
        _buildSettingsItem(
          context,
          icon: MingCuteIcons.mgc_arrow_right_line,
          title: 'Log Out',
          onTap: () => _showLogoutDialog(context, ref),
        ),
      ],
    );
  }

  Widget _buildSettingsItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      leading: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: AppColors.inputBorder,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          color: AppColors.textPrimary,
          size: 24,
        ),
      ),
      title: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            )
          : null,
      onTap: onTap,
    );
  }

  String _getLanguageDisplayName(Language language) {
    switch (language) {
      case Language.english:
        return 'English';
      case Language.french:
        return 'Français';
      case Language.kinyarwanda:
        return 'Kinyarwanda';
    }
  }

  void _showEditProfileDialog(BuildContext context, WidgetRef ref) {
    context.push('/profile/edit-profile');
  }

  void _showLanguageDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => Consumer(
        builder: (context, ref, child) {
          final currentLanguage = ref.watch(languageProvider);

          return AlertDialog(
            title: const Text('Change Language'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Select your preferred language:',
                  style: TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 20),
                _buildLanguageOption(
                  context,
                  Language.english,
                  'English',
                  currentLanguage,
                  (language) {
                    ref.read(languageProvider.notifier).setLanguage(language);
                  },
                ),
                const SizedBox(height: 12),
                _buildLanguageOption(
                  context,
                  Language.french,
                  'Français',
                  currentLanguage,
                  (language) {
                    ref.read(languageProvider.notifier).setLanguage(language);
                  },
                ),
                const SizedBox(height: 12),
                _buildLanguageOption(
                  context,
                  Language.kinyarwanda,
                  'Kinyarwanda',
                  currentLanguage,
                  (language) {
                    ref.read(languageProvider.notifier).setLanguage(language);
                  },
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Language saved successfully!'),
                      backgroundColor: AppColors.primary,
                    ),
                  );
                },
                child: const Text(
                  'Save',
                  style: TextStyle(color: AppColors.primary),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildLanguageOption(
    BuildContext context,
    Language language,
    String label,
    Language currentLanguage,
    Function(Language) onTap,
  ) {
    final isSelected = currentLanguage == language;
    return InkWell(
      onTap: () => onTap(language),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.inputBorder,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Radio<Language>(
              value: language,
              groupValue: currentLanguage,
              onChanged: (value) => onTap(language),
              activeColor: AppColors.primary,
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight:
                        isSelected ? FontWeight.w600 : FontWeight.normal,
                    color:
                        isSelected ? AppColors.primary : AppColors.textPrimary,
                  ),
            ),
            const Spacer(),
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: AppColors.primary,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }

  void _showHelpDialog(BuildContext context) {
    context.push(AppRouter.help);
  }

  void _showLogoutDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ref.read(authProvider.notifier).logout();
              context.go(AppRouter.welcome);
            },
            child: const Text(
              'Logout',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }
}
