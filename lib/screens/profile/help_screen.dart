import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ming_cute_icons/ming_cute_icons.dart';
import 'package:my_rights_mobile_app/core/theme/app_colors.dart';
import 'package:my_rights_mobile_app/shared/widgets/custom_bottom_navbar.dart';

class HelpScreen extends ConsumerWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Help',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),

              // Frequently Asked Questions Section
              _buildSection(
                context,
                title: 'Frequently Asked Questions',
                items: [
                  _buildHelpItem(
                    context,
                    icon: MingCuteIcons.mgc_question_line,
                    title: 'FAQs',
                    description:
                        'Find answers to common questions about the app and its features.',
                    onTap: () => _showFaqsDialog(context),
                  ),
                ],
              ),

              const SizedBox(height: 32),

              // Tutorials Section
              _buildSection(
                context,
                title: 'Tutorials',
                items: [
                  _buildHelpItem(
                    context,
                    icon: MingCuteIcons.mgc_play_line,
                    title: 'App Tutorials',
                    description:
                        'Learn how to use the app\'s features with step-by-step guides.',
                    onTap: () => _showTutorialsDialog(context),
                  ),
                ],
              ),

              const SizedBox(height: 32),

              // Emergency Contacts Section
              _buildSection(
                context,
                title: 'Emergency Contacts',
                items: [
                  _buildHelpItem(
                    context,
                    icon: MingCuteIcons.mgc_phone_line,
                    title: 'Emergency Contacts',
                    description:
                        'Access a list of emergency contacts for immediate assistance.',
                    onTap: () => _showEmergencyContactsDialog(context),
                  ),
                ],
              ),

              const SizedBox(height: 32),

              // User Guide Section
              _buildSection(
                context,
                title: 'User Guide',
                items: [
                  _buildHelpItem(
                    context,
                    icon: MingCuteIcons.mgc_book_6_line,
                    title: 'User Guide',
                    description:
                        'Read the comprehensive user guide for detailed information about the app.',
                    onTap: () => _showUserGuideDialog(context),
                  ),
                ],
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const CustomBottomNavBar(),
    );
  }

  Widget _buildSection(
    BuildContext context, {
    required String title,
    required List<Widget> items,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
        ),
        const SizedBox(height: 16),
        ...items,
      ],
    );
  }

  Widget _buildHelpItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
    required VoidCallback onTap,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      leading: Container(
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          color: const Color(0xFFF2EDEB),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Icon(
          icon,
          color: Colors.black,
          size: 24,
        ),
      ),
      title: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 4),
        child: Text(
          description,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
        ),
      ),
      onTap: onTap,
    );
  }

  void _showFaqsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Frequently Asked Questions'),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Common Questions:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text('• How do I report an incident?'),
              Text('• How can I access educational content?'),
              Text('• What should I do in an emergency?'),
              Text('• How do I update my profile?'),
              Text('• How do I contact support?'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showTutorialsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('App Tutorials'),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Available Tutorials:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text('• Getting Started Guide'),
              Text('• How to Report Incidents'),
              Text('• Navigating the App'),
              Text('• Using Educational Content'),
              Text('• Emergency Features'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showEmergencyContactsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Emergency Contacts'),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Emergency Numbers:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text('• Police: 911'),
              Text('• Ambulance: 911'),
              Text('• Fire Department: 911'),
              Text('• Domestic Violence Hotline: 1-800-799-7233'),
              Text('• National Suicide Prevention: 988'),
              SizedBox(height: 16),
              Text(
                'Local Resources:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text('• Legal Aid Services'),
              Text('• Community Support Groups'),
              Text('• Mental Health Resources'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showUserGuideDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('User Guide'),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'User Guide Contents:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text('• Introduction to MyRights'),
              Text('• Understanding Your Rights'),
              Text('• How to Use the App'),
              Text('• Reporting Incidents'),
              Text('• Educational Content'),
              Text('• Safety Features'),
              Text('• Privacy and Security'),
              Text('• Troubleshooting'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
