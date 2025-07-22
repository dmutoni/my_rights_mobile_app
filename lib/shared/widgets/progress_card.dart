import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_rights_mobile_app/core/theme/app_colors.dart';

class ProgressCard extends ConsumerWidget {
  final String title;
  final num percentage;
  final bool? showPercentage;
  const ProgressCard({super.key, required this.percentage, required this.title, this.showPercentage = true});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title.isNotEmpty) ...[
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).appBarTheme.foregroundColor,
            ),
          ),
          const SizedBox(height: 12),
        ],
        Column(
          children: [
            LinearProgressIndicator(
              borderRadius: BorderRadius.circular(100),
              minHeight: 8,
              value: percentage / 100,
              backgroundColor: AppColors.textSecondary.withValues(alpha: .25),
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
            if (showPercentage == true) ...[
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  '${percentage.toInt()}%',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
              ),
            ],
          ]
        ),
      ],
    );
  }
}
