import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:waqt/app/theme/app_colors.dart';
import 'package:waqt/app/theme/app_text.dart';
import 'package:waqt/core/widgets/app_page.dart';
import 'package:waqt/core/widgets/app_row.dart';
import 'package:waqt/core/utils/translations.dart';
import 'package:waqt/features/prayer_times/providers/city_provider.dart';
import 'package:waqt/features/settings/presentation/widgets/delete_data_dialog.dart';
import 'package:waqt/features/settings/providers/adjustments_provider.dart';
import 'package:waqt/features/settings/providers/language_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  Future<void> _deleteAll(BuildContext context, WidgetRef ref) async {
    if (!await confirmDeleteAllData(context)) return;
    await deleteAllData(ref);
    if (context.mounted) context.go('/splash');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(translationProvider);
    final city = ref.watch(cityProvider);
    final adjusted = ref
        .watch(adjustmentsProvider)
        .values
        .any((minutes) => minutes != 0);
    final language = ref.watch(languageProvider);

    return AppPage(
      children: [
        Text(t('settings'), style: AppText.title),
        Text('PRAYER TIMES', style: AppText.label),
        Column(
          spacing: 8,
          children: [
            AppRow(
              label: 'Location',
              value: city.name,
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
        Text('AZAN AND MODE', style: AppText.label),
        Column(
          spacing: 8,
          children: [
            AppRow(
              label: t('azan_sound'),
              value: 'Configure',
              onTap: () => context.push('/alarm-settings'),
            ),
            const AppRow(label: 'Prayer window', value: '20 min'),
            AppRow(
              label: 'Azan protection',
              value: 'Check',
              valueColor: AppColors.gold,
              onTap: () => context.push('/health-check'),
            ),
            AppRow(label: t('qibla'), onTap: () => context.push('/qibla')),
          ],
        ),
        Text('APP', style: AppText.label),
        Column(
          spacing: 8,
          children: [
            AppRow(
              label: t('language'),
              value: language,
              onTap: () => context.push('/language'),
            ),
            const AppRow(label: 'Theme', value: 'Dark'),
            AppRow(
              label: 'Phase 0 Prototype',
              value: 'Debug',
              valueColor: AppColors.gold,
              onTap: () => context.push('/phase0'),
            ),
            AppRow(label: t('about'), onTap: () => context.push('/about')),
            AppRow(
              label: t('delete_data'),
              labelColor: AppColors.danger,
              onTap: () => _deleteAll(context, ref),
            ),
          ],
        ),
      ],
    );
  }
}
