import 'package:flutter/material.dart';
import 'package:waqt/app/theme/app_colors.dart';
import 'package:waqt/app/theme/app_text.dart';

class WeekCard extends StatelessWidget {
  const WeekCard({super.key, required this.percent, required this.bars});

  final int percent;
  final List<(String, double)> bars;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 12,
        children: [
          const Text('Prayer consistency', style: AppText.caption),
          Text(
            '$percent%',
            style: const TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.w700,
              color: AppColors.gold,
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              for (final (day, height) in bars)
                Column(
                  spacing: 6,
                  children: [
                    Container(
                      width: 28,
                      height: height,
                      decoration: BoxDecoration(
                        color: AppColors.green,
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    Text(
                      day,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ],
      ),
    );
  }
}
