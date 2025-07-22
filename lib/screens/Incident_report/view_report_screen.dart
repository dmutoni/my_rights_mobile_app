import 'package:flutter/material.dart';
import '../../shared/widgets/custom_list.dart';

class ViewReportScreen extends StatelessWidget {
  const ViewReportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Incident Report'),
      ),
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
                    color: Colors.orange,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text('Under Review',
                      style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text('Incident Type: Land Dispute'),
                Text('Location: Kigali'),
              ],
            ),
            const SizedBox(height: 8),
            const Text('Date: 2024-01-15'),
            const SizedBox(height: 16),
            const Text('Details',
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text(
                'The dispute involves a disagreement over land boundaries between two neighboring properties. The issue has been ongoing for several months, causing significant tension between the parties involved. Both parties claim ownership based on historical documents and local agreements, leading to conflicting interpretations of the land boundaries.'),
            const SizedBox(height: 16),
            const Text('Evidence',
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            CustomList(
              items: [
                CustomListItem(
                  icon: Icons.photo_library_outlined,
                  title: 'Photo Evidence',
                  onTap: () {},
                ),
                CustomListItem(
                  icon: Icons.videocam_outlined,
                  title: 'Video Evidence',
                  onTap: () {},
                ),
                CustomListItem(
                  icon: Icons.mic_none_outlined,
                  title: 'Audio Evidence',
                  onTap: () {},
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              height: 160,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                image: const DecorationImage(
                  image: AssetImage('assets/images/welcome_screen_avatar.png'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
