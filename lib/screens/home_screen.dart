import 'package:flutter/material.dart';
import 'package:my_rights_mobile_app/core/theme/app_colors.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        backgroundColor: AppColors.primary,
      ),
      body: Center(
        child: Text(
          'Welcome to MyRights!',
          style: TextStyle(
            fontSize: 24,
            color: AppColors.textPrimary,
          ),
        ),
      ),
      backgroundColor: AppColors.background,
    );
  }
}
