import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:waqt/app/theme/app_colors.dart';
import 'package:waqt/features/home/presentation/widgets/next_prayer_card.dart';
import 'package:waqt/features/home/presentation/widgets/prayer_mode_status_card.dart';
import 'package:waqt/features/home/presentation/widgets/prayer_row.dart';
import 'package:waqt/features/home/providers/home_provider.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prayers = ref.watch(todayPrayersProvider);

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
          children: [
            const Text(
              'Faisalabad',
              style: TextStyle(fontSize: 14, color: AppColors.textMuted),
            ),
            const SizedBox(height: 4),
            const Text(
              '30 September 2026',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            const NextPrayerCard(
              name: 'Maghrib',
              time: '6:05 PM',
              countdown: 'Starts in 42 min',
            ),
            const SizedBox(height: 16),
            for (final prayer in prayers) ...[
              PrayerRow(entry: prayer),
              const SizedBox(height: 8),
            ],
            const SizedBox(height: 8),
            const PrayerModeStatusCard(appCount: 4),
          ],
        ),
      ),
    );
  }
}
