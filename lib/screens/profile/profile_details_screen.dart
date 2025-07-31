import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_rights_mobile_app/core/theme/app_colors.dart';
import 'package:my_rights_mobile_app/provider/auth_provider.dart';
import 'package:my_rights_mobile_app/shared/widgets/custom_app_bar.dart';

class ProfileDetailsScreen extends ConsumerStatefulWidget {
  const ProfileDetailsScreen({super.key});

  @override
  ConsumerState<ProfileDetailsScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileDetailsScreen> {
  bool _isLoggingOut = false;

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            'Log Out',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          content: const Text(
            'Are you sure you want to log out?',
            style: TextStyle(
              color: AppColors.textSecondary,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'Cancel',
                style: TextStyle(
                  color: AppColors.textSecondary,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _handleLogout();
              },
              child: const Text(
                'Log Out',
                style: TextStyle(
                  color: AppColors.error,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _handleLogout() async {
    setState(() {
      _isLoggingOut = true;
    });

    try {
      await ref.read(authProvider.notifier).logout();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Logged out successfully'),
            backgroundColor: AppColors.success,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Logout failed: $e'),
            backgroundColor: AppColors.error,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoggingOut = false;
        });
      }
    }
  }

  String _getMemberSinceText() {
    final user = ref.read(authProvider).user;
    if (user?.createdAt != null) {
      final year = user!.createdAt.year;
      return 'Member since $year';
    }
    return 'Member since 2024';
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final user = authState.user;

    return Scaffold(
      backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
      appBar: CustomAppBar(title: 'Profile'),
      body: SafeArea(
        child: Column(
          children: [
            // Profile Header Section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(32),
              child: Column(
                children: [
                  // Profile Picture
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.primary.withOpacity(0.1),
                      border: Border.all(
                        color: AppColors.primary.withOpacity(0.2),
                        width: 3,
                      ),
                    ),
                    child: ClipOval(
                      child: user?.photoURL != null
                          ? Image.network(
                              user!.photoURL!,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return _buildAvatarFallback(user);
                              },
                            )
                          : _buildAvatarFallback(user),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // User Name
                  Text(
                    user?.name ?? 'User Name',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Email
                  Text(
                    user?.email ?? 'user@example.com',
                    style: const TextStyle(
                      fontSize: 16,
                      color: AppColors.textSecondary,
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Member Since
                  Text(
                    _getMemberSinceText(),
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textLight,
                    ),
                  ),
                ],
              ),
            ),

            // Menu Items
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    // Edit Profile
                    _buildMenuItem(
                      icon: Icons.edit_outlined,
                      title: 'Edit Profile',
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Edit Profile coming soon!'),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 8),

                    // Change Language
                    _buildMenuItem(
                      icon: Icons.language_outlined,
                      title: 'Change language',
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Language settings coming soon!'),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 8),

                    // Help
                    _buildMenuItem(
                      icon: Icons.help_outline,
                      title: 'Help',
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Help center coming soon!'),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 8),

                    // Log Out
                    _buildMenuItem(
                      icon: Icons.logout_outlined,
                      title: 'Log Out',
                      isDestructive: true,
                      isLoading: _isLoggingOut,
                      onTap: _isLoggingOut ? null : _showLogoutDialog,
                    ),

                    const Spacer(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatarFallback(user) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.primary,
      ),
      child: Center(
        child: Text(
          user?.initials ?? 'U',
          style: const TextStyle(
            fontSize: 48,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback? onTap,
    bool isDestructive = false,
    bool isLoading = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 16,
          ),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              // Icon
              SizedBox(
                width: 24,
                height: 24,
                child: isLoading
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: isDestructive
                              ? AppColors.error
                              : AppColors.textSecondary,
                        ),
                      )
                    : Icon(
                        icon,
                        size: 24,
                        color: isDestructive
                            ? AppColors.error
                            : AppColors.textSecondary,
                      ),
              ),

              const SizedBox(width: 16),

              // Title
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color:
                        isDestructive ? AppColors.error : AppColors.textPrimary,
                  ),
                ),
              ),

              // Arrow (except for loading states)
              if (!isLoading)
                Icon(
                  Icons.chevron_right,
                  size: 20,
                  color: AppColors.textLight,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
