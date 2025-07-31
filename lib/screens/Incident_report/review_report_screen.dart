import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../shared/widgets/custom_button.dart';
import '../../provider/incident_report_provider.dart';
import 'confirm_submit_dialog.dart';
import '../../models/incident_report_model.dart';
import '../../shared/widgets/custom_bottom_navbar.dart';
import '../../shared/widgets/custom_app_bar.dart';
import 'package:go_router/go_router.dart';
import '../../core/router/app_router.dart';
import '../../shared/widgets/empty_card.dart';
import '../../shared/widgets/audio_panel.dart';
import '../../shared/widgets/video_panel.dart';

class ReviewReportScreen extends ConsumerWidget {
  const ReviewReportScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final report = ref.watch(currentReportProvider);
    final notifier = ref.read(incidentReportProvider.notifier);
    if (report == null) {
      return const Scaffold(
        body: Center(
          child: EmptyCard(
            icon: Icons.description_outlined,
            title: 'No report to review.',
            description:
                'There is no report available for review at this time.',
          ),
        ),
        bottomNavigationBar: CustomBottomNavBar(),
      );
    }

    return Scaffold(
      appBar: const CustomAppBar(title: 'Review Report', showBackButton: true),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: ListView(
          children: [
            const Text('Report Summary',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                    'Incident Type: ${report.description.length > 20 ? '${report.description.substring(0, 20)}...' : report.description}'),
              ],
            ),
            Text('Location: ${report.location}'),
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
            if (report.photoUrls.isNotEmpty)
              ...report.photoUrls.map((url) => Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(url, height: 160, fit: BoxFit.cover),
                    ),
                  )),
            if (report.videoUrls.isNotEmpty)
              ...report.videoUrls.map((url) => Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: VideoPanel(videoUrl: url),
                  )),
            if (report.audioUrls.isNotEmpty)
              ...report.audioUrls.map((url) => Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: AudioPanel(
                      audioUrl: url,
                      title: 'Audio Evidence',
                    ),
                  )),
            if (report.photoUrls.isEmpty &&
                report.videoUrls.isEmpty &&
                report.audioUrls.isEmpty)
              const Text('No evidence attached.'),
            const SizedBox(height: 32),
            Row(
              children: [
                Expanded(
                  child: CustomButton(
                    text: 'Edit',
                    type: ButtonType.secondary,
                    onPressed: () {
                      context.go('${AppRouter.incidentReport}/report-incident');
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: CustomButton(
                    text: 'Submit',
                    onPressed: () async {
                      final confirmed = await showDialog<bool>(
                        context: context,
                        builder: (ctx) => ConfirmSubmitDialog(
                          onSubmit: () => Navigator.of(ctx).pop(true),
                          onCancel: () => Navigator.of(ctx).pop(false),
                        ),
                      );
                      if (confirmed == true && context.mounted) {
                        await notifier.updateReportStatus(
                            report.id, IncidentStatus.submitted);
                        if (context.mounted) {
                          context.go(
                              '${AppRouter.incidentReport}/submission-confirmation');
                        }
                      }
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      bottomNavigationBar: const CustomBottomNavBar(),
    );
  }
}
