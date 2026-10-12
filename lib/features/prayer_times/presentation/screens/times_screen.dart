import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:waqt/app/theme/app_colors.dart';
import 'package:waqt/app/theme/app_text.dart';
import 'package:waqt/core/utils/translations.dart';
import 'package:waqt/core/widgets/app_page.dart';
import 'package:waqt/core/widgets/app_row.dart';
import 'package:waqt/features/prayer_times/data/calculation_options.dart';
import 'package:waqt/features/prayer_times/presentation/widgets/week_strip.dart';
import 'package:waqt/features/prayer_times/providers/prayer_times_provider.dart';
import 'package:waqt/features/settings/providers/calculation_provider.dart';

class TimesScreen extends ConsumerWidget {
  const TimesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(translationProvider);
    final times = ref.watch(dayTimesProvider);
    final selected = ref.watch(selectedDateProvider);
    final method = ref.watch(calcMethodProvider);
    final asr = ref.watch(asrProvider);

    return AppPage(
      children: [
        Text(t('prayer_times'), style: AppText.title),
        const WeekStrip(),
        Text(DateFormat('EEEE, d MMMM').format(selected), style: AppText.body),
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
        Text(
          t('times_caption')
              .replaceAll('{method}', t('method_${method.name}'))
              .replaceAll('{asr}', t('asr_${asrLabel(asr).toLowerCase()}')),
          style: AppText.caption,
        ),
      ],
    );
  }
}
