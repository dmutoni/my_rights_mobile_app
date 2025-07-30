import 'package:flutter/material.dart';
import '../../shared/widgets/custom_list.dart';
import '../../shared/widgets/custom_bottom_navbar.dart';
import '../../shared/widgets/custom_app_bar.dart';
import '../../shared/widgets/empty_card.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/router/app_router.dart';
import '../../provider/report_type_provider.dart';
import '../../models/report_type.dart';

class ReportAbuseScreen extends ConsumerWidget {
  const ReportAbuseScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reportTypes = ref.watch(reportTypesProvider);
    final isLoading = ref.watch(reportTypeLoadingProvider);
    final error = ref.watch(reportTypeErrorProvider);

    void goToForm(ReportType reportType) {
      context.go(
          '${AppRouter.incidentReport}/report-incident?type=${reportType.id}');
    }

    // Show error if any
    if (error != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error)),
        );
        ref.read(reportTypeProvider.notifier).clearError();
      });
    }

    if (isLoading) {
      return const Scaffold(
        appBar: CustomAppBar(title: 'Report Abuse', showBackButton: true),
        body: Center(child: CircularProgressIndicator()),
        bottomNavigationBar: CustomBottomNavBar(),
      );
    }

    if (reportTypes.isEmpty) {
      return Scaffold(
        appBar: const CustomAppBar(title: 'Report Abuse', showBackButton: true),
        body: const Center(
          child: EmptyCard(
            icon: Icons.report_problem_outlined,
            title: 'No report types available',
            description: 'Please try again later or contact support.',
          ),
        ),
        bottomNavigationBar: const CustomBottomNavBar(),
      );
    }

    return Scaffold(
      appBar: const CustomAppBar(title: 'Report Abuse', showBackButton: true),
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'What type of abuse do you want to report?',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: CustomList(
                items: reportTypes.map((reportType) {
                  return CustomListItem(
                    icon: _getIconFromString(reportType.icon),
                    title: reportType.name,
                    subtitle: reportType.description,
                    onTap: () => goToForm(reportType),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const CustomBottomNavBar(),
    );
  }

  IconData _getIconFromString(String iconName) {
    switch (iconName) {
      case 'attach_money':
        return Icons.attach_money;
      case 'shield_outlined':
        return Icons.shield_outlined;
      case 'people_outline':
        return Icons.people_outline;
      case 'gavel_outlined':
        return Icons.gavel_outlined;
      case 'security':
        return Icons.security;
      case 'eco':
        return Icons.eco;
      case 'work':
        return Icons.work;
      case 'help_outline':
        return Icons.help_outline;
      default:
        return Icons.report_problem_outlined;
    }
  }
}
