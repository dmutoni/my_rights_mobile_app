import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../shared/widgets/custom_list.dart';
import '../../provider/incident_report_provider.dart';
import '../../models/incident_report_model.dart';
import '../../shared/widgets/custom_app_bar.dart';
import '../../shared/widgets/empty_card.dart';
import '../../core/theme/app_colors.dart';
import 'package:go_router/go_router.dart';
import '../../core/router/app_router.dart';
import '../../provider/auth_provider.dart';

class AllReportsScreen extends ConsumerWidget {
  const AllReportsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reports = ref.watch(userReportsProvider);
    final authState = ref.watch(authProvider);

    // Debug: Print current user info
    if (authState.user != null) {
      print('Current user ID: ${authState.user!.id}');
      print('Current user name: ${authState.user!.name}');
    } else {
      print('No user authenticated');
    }

    // Debug: Print reports info
    print('AllReportsScreen: Found ${reports.length} reports');
    for (int i = 0; i < reports.length; i++) {
      print(
          'Report $i: ${reports[i].title} (ID: ${reports[i].id}, UserID: ${reports[i].userId})');
    }

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: const CustomAppBar(
        title: 'My Reports',
        showBackButton: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
        child: reports.isEmpty
            ? Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: MediaQuery.of(context).size.width * 0.2),
                child: EmptyCard(
                  icon: Icons.description_outlined,
                  title: 'No reports found',
                  description: 'You have not submitted any reports yet.',
                ))
            : SingleChildScrollView(
                child: Column(
                  children: [
                    CustomList(
                      items: reports
                          .map((report) => CustomListItem(
                                icon: Icons.description_outlined,
                                title: report.title,
                                subtitle: report.status.name,
                                statusColor:
                                    report.status == IncidentStatus.submitted
                                        ? AppColors.success
                                        : report.status ==
                                                IncidentStatus.underReview
                                            ? AppColors.warning
                                            : report.status ==
                                                    IncidentStatus.resolved
                                                ? AppColors.info
                                                : AppColors.error,
                                onTap: () {
                                  ref
                                      .read(incidentReportProvider.notifier)
                                      .setSelectedReport(report);
                                  context.go(
                                    '${AppRouter.incidentReport}/view-report',
                                    extra: report,
                                  );
                                },
                              ))
                          .toList(),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        icon: Icon(Icons.add, color: Theme.of(context).colorScheme.onPrimary),
        label: Text('New Report',
            style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onPrimary)),
        onPressed: () {
          context.go('${AppRouter.incidentReport}/report-abuse');
        },
      ),
    );
  }
}
