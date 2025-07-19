import 'package:flutter/material.dart';
import 'package:ming_cute_icons/ming_cute_icons.dart';
import 'package:my_rights_mobile_app/shared/widgets/custom_app_bar.dart';
import 'package:my_rights_mobile_app/shared/widgets/custom_bottom_navbar.dart';
import 'package:my_rights_mobile_app/shared/widgets/quick_access_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  // Quick Access Section
                  Text(
                    'Quick Access',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).appBarTheme.foregroundColor
                    ),
                  ),
                  const SizedBox(height: 16),
                  QuickAccessCard(
                    icon: MingCuteIcons.mgc_book_line,
                    title: 'Civic Education',
                    description: 'Learn about your rights and responsibilities as a citizen.',
                    onTap: () => {},
                    // onTap: () => context.go(AppRouter.civicEducation),
                  ),
                  QuickAccessCard(
                    icon: Icons.report_problem,
                    title: 'Report an Issue',
                    description: 'Report incidents of injustice or corruption.',
                    onTap: () => {},
                    // onTap: () => context.go(AppRouter.reportIssue),
                  ),
                  QuickAccessCard(
                    icon: Icons.balance,
                    title: 'Legal Aid',
                    description: 'Find legal assistance and resources.',
                    onTap: () => {},
                    // onTap: () => context.go(AppRouter.legalAid),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: const CustomBottomNavBar(),
    );
  }
}
