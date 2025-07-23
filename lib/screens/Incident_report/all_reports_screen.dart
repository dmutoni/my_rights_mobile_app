import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../shared/widgets/custom_list.dart';
import '../../provider/auth_provider.dart';
import 'report_abuse_screen.dart';
import '../../provider/incident_report_provider.dart';
import 'view_report_screen.dart';
import '../../models/incident_report_model.dart';
import '../../shared/widgets/custom_bottom_navbar.dart';
import '../../provider/main_provider.dart';

class AllReportsScreen extends ConsumerWidget {
  const AllReportsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final initials = user?.initials ?? '--';
    final reports = ref.watch(userReportsProvider);
    // Set the active tab to 'Report' (index 2)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(selectedBottomNavIndexProvider.notifier).state = 2;
    });
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text('My Reports',
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        leading: Padding(
          padding: const EdgeInsets.all(12.0),
          child: CircleAvatar(
            backgroundColor: Colors.orange,
            child: Text(initials,
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
        child: Column(
          children: [
            if (reports.isEmpty)
              const Expanded(
                child: Center(child: Text('No reports found.')),
              )
            else
              Expanded(
                child: CustomList(
                  items: reports.map((report) => CustomListItem(
                    icon: Icons.description_outlined,
                    title: report.title,
                    subtitle: report.status.name,
                    statusColor: report.status == IncidentStatus.submitted
                        ? Colors.green
                        : report.status == IncidentStatus.underReview
                            ? Colors.orange
                            : report.status == IncidentStatus.resolved
                                ? Colors.blue
                                : Colors.red,
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => ViewReportScreen(report: report),
                        ),
                      );
                    },
                  )).toList(),
                ),
              ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                icon: const Icon(Icons.add),
                label: const Text('New Report',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                        builder: (_) => const ReportAbuseScreen()),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
      bottomNavigationBar: const CustomBottomNavBar(),
    );
  }
}
