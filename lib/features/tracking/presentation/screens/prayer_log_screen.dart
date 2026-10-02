import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:waqt/app/theme/app_colors.dart';
import 'package:waqt/app/theme/app_text.dart';
import 'package:waqt/core/widgets/app_page.dart';
import 'package:waqt/core/widgets/info_card.dart';
import 'package:waqt/features/prayer_times/providers/prayer_times_provider.dart';
import 'package:waqt/features/tracking/presentation/widgets/month_calendar.dart';
import 'package:waqt/features/tracking/providers/prayer_log_provider.dart';
import 'package:waqt/features/tracking/providers/streak_provider.dart';

class PrayerLogScreen extends ConsumerWidget {
  const PrayerLogScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final today = ref.watch(todayProvider);
    final log = ref.watch(prayerLogProvider);
    final streak = ref.watch(streakProvider);

    return Scaffold(
      appBar: AppBar(),
      body: AppPage(
        children: [
          const Text('Prayer log', style: AppText.title),
          InfoCard(
            title: '$streak day streak',
            body: streak == 0
                ? 'Log all 5 prayers today to start a streak'
                : 'All 5 prayers logged',
          ),
          Text(DateFormat('MMMM y').format(today), style: AppText.caption),
          MonthCalendar(month: today, today: today, log: log),
          const _Legend(),
        ],
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  const _Legend();

  @override
  Widget build(BuildContext context) {
    return const Row(
      spacing: 16,
      children: [
        _LegendItem(color: AppColors.green, label: 'All 5'),
        _LegendItem(color: AppColors.gold, label: 'Some'),
        _LegendItem(color: AppColors.line, label: 'Missed'),
      ],
    );
  }
}

class _LegendItem extends StatelessWidget {
  const _LegendItem({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      spacing: 6,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        Text(label, style: AppText.caption),
      ],
    );
  }
}
