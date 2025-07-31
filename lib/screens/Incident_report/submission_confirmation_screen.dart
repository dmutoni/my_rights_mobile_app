import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../shared/widgets/custom_button.dart';
import '../../provider/incident_report_provider.dart';
import 'package:go_router/go_router.dart';
import '../../core/router/app_router.dart';
import '../../shared/widgets/custom_app_bar.dart';
import '../../shared/widgets/empty_card.dart';

class SubmissionConfirmationScreen extends ConsumerWidget {
  const SubmissionConfirmationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final report = ref.watch(currentReportProvider);
    // Set the active tab to 'Report' (index 2)
    if (report == null) {
      return const Scaffold(
        body: Center(
          child: EmptyCard(
            icon: Icons.description_outlined,
            title: 'No submission found.',
            description:
                'There is no submission available to confirm at this time.',
          ),
        ),
      );
    }
    return Scaffold(
      appBar: const CustomAppBar(
          title: 'Submission Confirmation', showBackButton: true),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 32),
            const Text(
              'Your submission has been received',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
            const SizedBox(height: 16),
            const Text(
              'Thank you for your submission. Your case has been successfully submitted and is now under review. You will receive updates via email and SMS.',
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Tracking Number:'),
                Text(report.trackingNumber,
                    style: const TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Status:'),
                Text(report.status.name,
                    style: const TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 32),
            CustomButton(
              width: 150,
              text: 'Back',
              onPressed: () {
                ref.read(incidentReportProvider.notifier).clearCurrentReport();
                context.go(AppRouter.incidentReport);
              },
            ),
          ],
        ),
      ),
    );
  }
}
