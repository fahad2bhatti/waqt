import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:waqt/app/theme/app_colors.dart';
import 'package:waqt/app/theme/app_text.dart';
import 'package:waqt/core/widgets/app_page.dart';
import 'package:waqt/core/widgets/app_row.dart';
import 'package:waqt/features/prayer_times/presentation/widgets/week_strip.dart';
import 'package:waqt/features/prayer_times/providers/prayer_times_provider.dart';

class TimesScreen extends ConsumerWidget {
  const TimesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final times = ref.watch(dayTimesProvider);

    return AppPage(
      children: [
        const Text('Prayer times', style: AppText.title),
        const WeekStrip(),
        const Text('Wednesday, 30 September', style: AppText.body),
        Column(
          spacing: 8,
          children: [
            for (final (name, time) in times)
              AppRow(
                label: name,
                value: time,
                valueColor: AppColors.textPrimary,
              ),
          ],
        ),
        const Text('Karachi method, Hanafi Asr', style: AppText.caption),
      ],
    );
  }
}
