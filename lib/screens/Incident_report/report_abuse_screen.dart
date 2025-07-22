import 'package:flutter/material.dart';
import '../../shared/widgets/custom_list.dart';
import 'report_incident_screen.dart';

class ReportAbuseScreen extends StatelessWidget {
  const ReportAbuseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    void goToForm() {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const ReportIncidentScreen()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Report Abuse',
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
      ),
      backgroundColor: Colors.white,
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
            CustomList(
              items: [
                CustomListItem(
                  icon: Icons.attach_money,
                  title: 'Corruption',
                  onTap: goToForm,
                ),
                CustomListItem(
                  icon: Icons.shield_outlined,
                  title: 'Human Rights Violation',
                  onTap: goToForm,
                ),
                CustomListItem(
                  icon: Icons.people_outline,
                  title: 'Discrimination',
                  onTap: goToForm,
                ),
                CustomListItem(
                  icon: Icons.gavel_outlined,
                  title: 'Abuse of Power',
                  onTap: goToForm,
                ),
                CustomListItem(
                  icon: Icons.help_outline,
                  title: 'Other',
                  onTap: goToForm,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
