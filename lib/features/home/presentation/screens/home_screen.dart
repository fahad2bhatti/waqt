import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:waqt/core/config/features.dart';
import 'package:waqt/app/theme/app_colors.dart';
import 'package:waqt/app/theme/app_text.dart';
import 'package:waqt/core/utils/time_format.dart';
import 'package:waqt/core/widgets/app_page.dart';
import 'package:waqt/features/home/presentation/widgets/next_prayer_card.dart';
import 'package:waqt/features/home/presentation/widgets/prayer_mode_status_card.dart';
import 'package:waqt/features/home/presentation/widgets/prayer_row.dart';
import 'package:waqt/features/home/providers/home_provider.dart';
import 'package:waqt/features/prayer_mode/providers/blocked_apps_provider.dart';
import 'package:waqt/features/prayer_times/providers/city_provider.dart';
import 'package:waqt/features/prayer_times/providers/prayer_times_provider.dart';
import 'package:waqt/features/tracking/providers/prayer_log_provider.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final now = ref.watch(nowProvider).value ?? DateTime.now();
    final next = ref.watch(nextPrayerProvider);
    final prayers = ref.watch(todayPrayersProvider);
    final city = ref.watch(cityProvider);
    final appCount = ref.watch(blockedAppsProvider).length;
    final log = ref.read(prayerLogProvider.notifier);

    return AppPage(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 4,
          children: [
            Text(city.name, style: AppText.body),
            Text(
              DateFormat('d MMMM y').format(now),
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
        NextPrayerCard(
          name: next.name,
          time: formatTime(next.time),
          countdown: formatCountdown(next.time.difference(now)),
        ),
        Column(
          spacing: 8,
          children: [
            for (final prayer in prayers)
              PrayerRow(
                entry: prayer,
                onTap: prayer.started ? () => log.toggle(prayer.logKey) : null,
              ),
          ],
        ),
        if (kPrayerModeEnabled) PrayerModeStatusCard(appCount: appCount),
      ],
    );
  }
}
