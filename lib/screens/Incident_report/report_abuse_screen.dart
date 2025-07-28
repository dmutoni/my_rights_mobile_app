import 'package:flutter/material.dart';
import '../../shared/widgets/custom_list.dart';
import '../../shared/widgets/custom_bottom_navbar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/router/app_router.dart';
import '../../provider/report_type_provider.dart';
import '../../shared/widgets/empty_card.dart';

class ReportAbuseScreen extends ConsumerWidget {
  const ReportAbuseScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reportTypesAsync = ref.watch(reportTypesProvider);

    void goToForm(String reportType) {
      // Pass the selected report type to the form
      context.go('${AppRouter.incidentReport}/report-incident',
          extra: reportType);
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Report Abuse',
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
      ),
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
              child: reportTypesAsync.when(
                data: (reportTypes) {
                  if (reportTypes.isEmpty) {
                    return const EmptyCard(
                      icon: Icons.help_outline,
                      title: 'No report types available',
                      description: 'Please try again later or contact support.',
                    );
                  }

                  return CustomList(
                    items: reportTypes
                        .map((reportType) => CustomListItem(
                              icon: reportType.icon,
                              title: reportType.displayName,
                              subtitle: reportType.description,
                              onTap: () => goToForm(reportType.name),
                            ))
                        .toList(),
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stackTrace) => EmptyCard(
                  icon: Icons.error_outline,
                  title: 'Error loading report types',
                  description: 'Please try again later: $error',
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const CustomBottomNavBar(),
    );
  }
}
