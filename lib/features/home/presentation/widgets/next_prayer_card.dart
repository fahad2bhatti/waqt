import 'package:flutter/material.dart';
import 'package:waqt/app/theme/app_colors.dart';

class NextPrayerCard extends StatelessWidget {
  const NextPrayerCard({
    super.key,
    required this.title,
    required this.name,
    required this.time,
    required this.countdown,
  });

  final String title;
  final String name;
  final String time;
  final String countdown;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.hero,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.gold,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            name,
            style: const TextStyle(
              fontSize: 40,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            time,
            style: const TextStyle(fontSize: 22, color: AppColors.gold),
          ),
          const SizedBox(height: 6),
          Text(
            countdown,
            style: const TextStyle(fontSize: 14, color: AppColors.textMuted),
          ),
        ],
      ),
    );
  }
}
