import 'package:flutter/material.dart';
import 'package:waqt/app/theme/app_colors.dart';
import 'package:waqt/app/theme/app_text.dart';

class WeekStrip extends StatefulWidget {
  const WeekStrip({super.key});

  @override
  State<WeekStrip> createState() => _WeekStripState();
}

class _WeekStripState extends State<WeekStrip> {
  static const _days = [
    ('M', 28),
    ('T', 29),
    ('W', 30),
    ('T', 1),
    ('F', 2),
    ('S', 3),
    ('S', 4),
  ];

  int _selected = 2;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        for (var i = 0; i < _days.length; i++)
          GestureDetector(
            onTap: () => setState(() => _selected = i),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 10),
              decoration: BoxDecoration(
                color: i == _selected ? AppColors.hero : AppColors.card,
                borderRadius: BorderRadius.circular(14),
                border: i == _selected
                    ? Border.all(color: AppColors.gold, width: 1.5)
                    : null,
              ),
              child: Column(
                spacing: 4,
                children: [
                  Text(
                    _days[i].$1,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textMuted,
                    ),
                  ),
                  Text(
                    '${_days[i].$2}',
                    style: AppText.rowLabel.copyWith(
                      color: i == _selected
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
