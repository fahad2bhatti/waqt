import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:waqt/app/theme/app_colors.dart';
import 'package:waqt/app/theme/app_text.dart';
import 'package:waqt/core/widgets/app_page.dart';
import 'package:waqt/core/widgets/app_row.dart';
import 'package:waqt/features/prayer_times/providers/city_provider.dart';
import 'package:waqt/features/settings/providers/adjustments_provider.dart';
import 'package:waqt/features/settings/providers/azan_sound_provider.dart';
import 'package:waqt/features/settings/providers/language_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final city = ref.watch(cityProvider);
    final adjusted = ref
        .watch(adjustmentsProvider)
        .values
        .any((minutes) => minutes != 0);
    final sound = ref.watch(azanSoundProvider).sound;
    final language = ref.watch(languageProvider);

    return AppPage(
      children: [
        const Text('Settings', style: AppText.title),
        const Text('PRAYER TIMES', style: AppText.label),
        Column(
          spacing: 8,
          children: [
            AppRow(
              label: 'Location',
              value: city,
              valueColor: AppColors.gold,
              onTap: () => context.push('/city-search'),
            ),
            const AppRow(
              label: 'Calculation method',
              value: 'Karachi',
              valueColor: AppColors.gold,
            ),
            const AppRow(
              label: 'Asr',
              value: 'Hanafi',
              valueColor: AppColors.gold,
            ),
            AppRow(
              label: 'Adjustments',
              value: adjusted ? 'Custom' : '0 min',
              onTap: () => context.push('/adjustments'),
            ),
          ],
        ),
        const Text('AZAN AND MODE', style: AppText.label),
        Column(
          spacing: 8,
          children: [
            AppRow(
              label: 'Azan sound',
              value: sound,
              onTap: () => context.push('/azan-sound'),
            ),
            const AppRow(label: 'Prayer window', value: '20 min'),
            AppRow(
              label: 'Azan protection',
              value: 'Check',
              valueColor: AppColors.gold,
              onTap: () => context.push('/health-check'),
            ),
            AppRow(label: 'Qibla', onTap: () => context.push('/qibla')),
          ],
        ),
        const Text('APP', style: AppText.label),
        Column(
          spacing: 8,
          children: [
            AppRow(
              label: 'Language',
              value: language,
              onTap: () => context.push('/language'),
            ),
            const AppRow(label: 'Theme', value: 'Dark'),
            AppRow(label: 'About', onTap: () => context.push('/about')),
            const AppRow(
              label: 'Delete all my data',
              labelColor: AppColors.danger,
            ),
          ],
        ),
      ],
    );
  }
}
