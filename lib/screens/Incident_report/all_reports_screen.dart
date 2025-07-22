import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../shared/widgets/custom_list.dart';
import '../../provider/auth_provider.dart';
import 'report_abuse_screen.dart';

class AllReportsScreen extends ConsumerWidget {
  const AllReportsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final initials = user?.initials ?? '--';
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
            CustomList(
              items: [
                CustomListItem(
                  icon: Icons.description_outlined,
                  title: 'Incident 1',
                  subtitle: 'Submitted',
                  statusColor: Colors.green,
                  onTap: () {},
                ),
                CustomListItem(
                  icon: Icons.description_outlined,
                  title: 'Incident 2',
                  subtitle: 'Under Review',
                  statusColor: Colors.orange,
                  onTap: () {},
                ),
                CustomListItem(
                  icon: Icons.description_outlined,
                  title: 'Incident 3',
                  subtitle: 'Resolved',
                  statusColor: Colors.blue,
                  onTap: () {},
                ),
              ],
            ),
            const Spacer(),
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
    );
  }
}
