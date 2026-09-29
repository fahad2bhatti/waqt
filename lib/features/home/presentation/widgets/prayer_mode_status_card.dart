import 'package:flutter/material.dart';
import 'package:waqt/app/theme/app_colors.dart';

class PrayerModeStatusCard extends StatelessWidget {
  const PrayerModeStatusCard({super.key, required this.appCount});

  final int appCount;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: const BoxDecoration(
              color: AppColors.green,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 10),
          Text(
            'Prayer Mode is on  |  $appCount apps',
            style: const TextStyle(fontSize: 15, color: AppColors.textPrimary),
          ),
        ],
      ),
    );
  }
}
