import 'package:flutter/material.dart';
import 'package:waqt/app/theme/app_colors.dart';
import 'package:waqt/features/prayer_times/data/prayer_entry.dart';

class PrayerRow extends StatelessWidget {
  const PrayerRow({super.key, required this.entry});

  final PrayerEntry entry;

  @override
  Widget build(BuildContext context) {
    final isNext = entry.status == PrayerStatus.next;
    final (label, color) = switch (entry.status) {
      PrayerStatus.prayed => ('Prayed', AppColors.green),
      PrayerStatus.next => ('Next', AppColors.gold),
      PrayerStatus.pending => ('Pending', AppColors.textMuted),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: isNext ? AppColors.line : AppColors.card,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              entry.name,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          Text(
            entry.time,
            style: const TextStyle(fontSize: 15, color: AppColors.textPrimary),
          ),
          const SizedBox(width: 12),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
