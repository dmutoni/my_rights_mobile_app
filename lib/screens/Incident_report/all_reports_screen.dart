import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../shared/widgets/custom_list.dart';
import '../../provider/incident_report_provider.dart';
import '../../models/incident_report_model.dart';
import '../../shared/widgets/custom_bottom_navbar.dart';
import '../../shared/widgets/custom_app_bar.dart';
import '../../shared/widgets/empty_card.dart';
import '../../core/theme/app_colors.dart';
import 'package:go_router/go_router.dart';

class AllReportsScreen extends ConsumerWidget {
  const AllReportsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reports = ref.watch(userReportsProvider);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(title: 'My Reports'),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
        child: reports.isEmpty
            ? Padding(
                padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.2),
                child: EmptyCard(
                  icon: Icons.description_outlined,
                  title: 'No reports found',
                  description: 'You have not submitted any reports yet.',
                )
            ) : Column(
                children: [
                  Expanded(
                    child: CustomList(
                      items: reports
                          .map((report) => CustomListItem(
                                icon: Icons.description_outlined,
                                title: report.title,
                                subtitle: report.status.name,
                                statusColor:
                                    report.status == IncidentStatus.submitted
                                        ? Colors.green
                                        : report.status ==
                                                IncidentStatus.underReview
                                            ? Colors.orange
                                            : report.status ==
                                                    IncidentStatus.resolved
                                                ? Colors.blue
                                                : Colors.red,
                                onTap: () {
                                  context.go(
                                    '/incident-report/view-report',
                                    extra: report,
                                  );
                                },
                              ))
                          .toList(),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        icon: Icon(Icons.add, color: Theme.of(context).colorScheme.onPrimary),
        label: Text('New Report',
            style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onPrimary)),
        onPressed: () {
          context.go('/incident-report/report-abuse');
        },
      ),
      bottomNavigationBar: const CustomBottomNavBar(),
    );
  }
}
