import 'package:flutter/material.dart';
import 'package:my_rights_mobile_app/core/theme/app_colors.dart';
import 'package:my_rights_mobile_app/provider/incident_report_provider.dart';
import '../../models/incident_report_model.dart';
import '../../shared/widgets/custom_bottom_navbar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../shared/widgets/custom_app_bar.dart';
import '../../provider/report_type_provider.dart';
import '../../shared/widgets/audio_panel.dart';
import '../../shared/widgets/video_panel.dart';

class ViewReportScreen extends ConsumerWidget {
  const ViewReportScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final report = ref.read(incidentReportProvider.notifier).selectedReport;

    final reportType =
        ref.watch(reportTypeByIdProvider(report?.reportTypeId ?? ''));

    return Scaffold(
      appBar: CustomAppBar(title: report?.title ?? '', showBackButton: true),
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
                    color: report?.status == IncidentStatus.submitted
                        ? AppColors.success
                        : report?.status == IncidentStatus.underReview
                            ? AppColors.warning
                            : report?.status == IncidentStatus.resolved
                                ? AppColors.info
                                : AppColors.error,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(report?.status.name ?? '',
                      style: const TextStyle(color: AppColors.surface)),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Display report type
            if (reportType != null)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue[200]!),
                ),
                child: Row(
                  children: [
                    Icon(
                      _getIconFromString(reportType.icon),
                      color: Colors.blue[700],
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      reportType.name,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.blue[700],
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Incident Type: ${report?.title}'),
                Text('Location: ${report?.location}'),
              ],
            ),
            const SizedBox(height: 8),
            Text('Date: ${report?.date.toLocal().toString().split(' ')[0]}'),
            const SizedBox(height: 16),
            const Text('Details',
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(report?.description ?? ''),
            const SizedBox(height: 16),
            const Text('Evidence',
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            if (report?.photoUrls.isNotEmpty ?? false)
              ...report!.photoUrls.map((url) => Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(url, height: 160, fit: BoxFit.cover),
                    ),
                  )),
            if (report?.videoUrls.isNotEmpty ?? false)
              ...report!.videoUrls.map((url) => Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: VideoPanel(videoUrl: url),
                  )),
            if (report?.audioUrls.isNotEmpty ?? false)
              ...report!.audioUrls.map((url) => Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: AudioPanel(
                      audioUrl: url,
                      title: 'Audio Evidence',
                    ),
                  )),
            if ((report?.photoUrls.isEmpty ?? true) &&
                (report?.videoUrls.isEmpty ?? true) &&
                (report?.audioUrls.isEmpty ?? true))
              const Text('No evidence attached.'),
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
