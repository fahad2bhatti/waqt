import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:waqt/app/theme/app_colors.dart';
import 'package:waqt/app/theme/app_text.dart';
import 'package:waqt/core/widgets/app_page.dart';
import 'package:waqt/core/widgets/app_row.dart';
import 'package:waqt/features/stats/presentation/widgets/week_card.dart';
import 'package:waqt/features/stats/providers/stats_provider.dart';
import 'package:waqt/features/tracking/providers/streak_provider.dart';

class StatsScreen extends ConsumerWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bars = ref.watch(weekBarsProvider);
    final percent = ref.watch(weekPercentProvider);
    final prayers = ref.watch(perPrayerProvider);
    final streak = ref.watch(streakProvider);

    return AppPage(
      children: [
        const Text('Your week', style: AppText.title),
        WeekCard(percent: percent, bars: bars),
        const Text('PER PRAYER', style: AppText.label),
        Column(
          spacing: 8,
          children: [
            for (final (name, count) in prayers)
              AppRow(label: name, value: count, valueColor: AppColors.gold),
          ],
        ),
        AppRow(
          label: 'Prayer log',
          value: '$streak day streak',
          valueColor: AppColors.gold,
          onTap: () => context.push('/prayer-log'),
        ),
      ],
    );
  }
}
