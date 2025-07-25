import 'package:flutter/material.dart';
import 'package:my_rights_mobile_app/core/theme/app_colors.dart';
import '../../shared/widgets/custom_list.dart';
import '../../models/incident_report_model.dart';
import '../../shared/widgets/custom_bottom_navbar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../shared/widgets/custom_app_bar.dart';

class ViewReportScreen extends ConsumerWidget {
  final IncidentReport report;
  const ViewReportScreen({super.key, required this.report});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: CustomAppBar(title: report.title),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: ListView(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Report Summary',
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: report.status == IncidentStatus.submitted
                        ? AppColors.success
                        : report.status == IncidentStatus.underReview
                            ? AppColors.warning
                            : report.status == IncidentStatus.resolved
                                ? AppColors.info
                                : AppColors.error,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(report.status.name, style: const TextStyle(color: AppColors.surface)),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Incident Type: ${report.title}'),
                Text('Location: ${report.location}'),
              ],
            ),
            const SizedBox(height: 8),
            Text('Date: ${report.date.toLocal().toString().split(' ')[0]}'),
            const SizedBox(height: 16),
            const Text('Details',
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(report.description),
            const SizedBox(height: 16),
            const Text('Evidence',
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            CustomList(
              items: [
                if (report.photoUrls.isNotEmpty)
                  CustomListItem(
                    icon: Icons.photo_library_outlined,
                    title: 'Photo Evidence',
                    onTap: () {},
                  ),
                if (report.videoUrls.isNotEmpty)
                  CustomListItem(
                    icon: Icons.videocam_outlined,
                    title: 'Video Evidence',
                    onTap: () {},
                  ),
                if (report.audioUrls.isNotEmpty)
                  CustomListItem(
                    icon: Icons.mic_none_outlined,
                    title: 'Audio Evidence',
                    onTap: () {},
                  ),
              ],
            ),
            const SizedBox(height: 16),
            if (report.photoUrls.isNotEmpty)
              Container(
                height: 160,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  image: DecorationImage(
                    image: NetworkImage(report.photoUrls.first),
                    fit: BoxFit.cover,
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
