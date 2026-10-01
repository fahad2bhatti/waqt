import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:waqt/app/theme/app_colors.dart';
import 'package:waqt/app/theme/app_text.dart';
import 'package:waqt/core/widgets/app_page.dart';
import 'package:waqt/features/home/presentation/widgets/next_prayer_card.dart';
import 'package:waqt/features/home/presentation/widgets/prayer_mode_status_card.dart';
import 'package:waqt/features/home/presentation/widgets/prayer_row.dart';
import 'package:waqt/features/home/providers/home_provider.dart';
import 'package:waqt/features/prayer_mode/providers/blocked_apps_provider.dart';
import 'package:waqt/features/prayer_times/providers/city_provider.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prayers = ref.watch(todayPrayersProvider);
    final city = ref.watch(cityProvider);
    final appCount = ref.watch(blockedAppsProvider).length;

    return AppPage(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 4,
          children: [
            Text(city, style: AppText.body),
            const Text(
              '30 September 2026',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
        const NextPrayerCard(
          name: 'Maghrib',
          time: '6:05 PM',
          countdown: 'Starts in 42 min',
        ),
        Column(
          spacing: 8,
          children: [for (final prayer in prayers) PrayerRow(entry: prayer)],
        ),
        PrayerModeStatusCard(appCount: appCount),
      ],
    );
  }
}
