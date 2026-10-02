import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:waqt/app/theme/app_colors.dart';
import 'package:waqt/app/theme/app_text.dart';
import 'package:waqt/features/prayer_times/providers/prayer_times_provider.dart';

const _letters = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

class WeekStrip extends ConsumerWidget {
  const WeekStrip({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final today = ref.watch(todayProvider);
    final selected = ref.watch(selectedDateProvider);
    final weekStart = today.day - (today.weekday - 1);
    final days = [
      for (var i = 0; i < 7; i++)
        DateTime(today.year, today.month, weekStart + i),
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        for (var i = 0; i < 7; i++)
          GestureDetector(
            onTap: () =>
                ref.read(selectedDateProvider.notifier).select(days[i]),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 10),
              decoration: BoxDecoration(
                color: days[i] == selected ? AppColors.hero : AppColors.card,
                borderRadius: BorderRadius.circular(14),
                border: days[i] == selected
                    ? Border.all(color: AppColors.gold, width: 1.5)
                    : null,
              ),
              child: Column(
                spacing: 4,
                children: [
                  Text(
                    _letters[i],
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textMuted,
                    ),
                  ),
                  Text(
                    '${days[i].day}',
                    style: AppText.rowLabel.copyWith(
                      color: days[i] == selected
                          ? AppColors.gold
                          : AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
