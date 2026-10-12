import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:waqt/app/theme/app_colors.dart';
import 'package:waqt/app/theme/app_text.dart';
import 'package:waqt/core/widgets/app_page.dart';
import 'package:waqt/core/utils/translations.dart';
import 'package:waqt/core/widgets/app_row.dart';
import 'package:waqt/features/stats/presentation/widgets/week_card.dart';
import 'package:waqt/features/stats/providers/stats_provider.dart';
import 'package:waqt/features/tracking/providers/streak_provider.dart';

class StatsScreen extends ConsumerWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(translationProvider);
    final bars = ref.watch(weekBarsProvider);
    final percent = ref.watch(weekPercentProvider);
    final prayers = ref.watch(perPrayerProvider);
    final streak = ref.watch(streakProvider);

    return AppPage(
      children: [
        Text(t('your_week'), style: AppText.title),
        WeekCard(title: t('prayer_consistency'), percent: percent, bars: bars),
        Text(t('per_prayer'), style: AppText.label),
        Column(
          spacing: 8,
          children: [
            for (final (name, count) in prayers)
              AppRow(label: t(name), value: count, valueColor: AppColors.gold),
          ],
        ),
        AppRow(
          label: t('prayer_log'),
          value: '$streak ${t('streak_day')}',
          valueColor: AppColors.gold,
          onTap: () => context.push('/prayer-log'),
        ),
      ],
    );
  }
}
