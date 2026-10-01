import 'package:flutter/material.dart';
import 'package:waqt/app/theme/app_colors.dart';
import 'package:waqt/core/widgets/app_row.dart';
import 'package:waqt/features/prayer_times/data/prayer_entry.dart';

class PrayerRow extends StatelessWidget {
  const PrayerRow({super.key, required this.entry});

  final PrayerEntry entry;

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (entry.status) {
      PrayerStatus.prayed => ('Prayed', AppColors.green),
      PrayerStatus.next => ('Next', AppColors.gold),
      PrayerStatus.pending => ('Pending', AppColors.textMuted),
    };

    return AppRow(
      label: entry.name,
      highlight: entry.status == PrayerStatus.next,
      trailing: Row(
        spacing: 12,
        children: [
          Text(
            entry.time,
            style: const TextStyle(fontSize: 15, color: AppColors.textPrimary),
          ),
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
