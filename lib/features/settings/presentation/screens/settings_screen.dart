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
import 'package:waqt/core/config/features.dart';
import 'package:waqt/features/prayer_times/data/calculation_options.dart';
import 'package:waqt/features/settings/providers/adjustments_provider.dart';
import 'package:waqt/features/settings/providers/calculation_provider.dart';

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
    final method = ref.watch(calcMethodProvider);
    final asr = ref.watch(asrProvider);

    return AppPage(
      children: [
        Text(t('settings'), style: AppText.title),
        Text(t('section_prayer_times'), style: AppText.label),
        Column(
          spacing: 8,
          children: [
            AppRow(
              label: t('location'),
              value: city.name,
              valueColor: AppColors.gold,
              onTap: () => context.push('/city-search'),
            ),
            AppRow(
              label: t('calc_method'),
              value: t('method_${method.name}'),
              valueColor: AppColors.gold,
              onTap: () => context.push('/calculation'),
            ),
            AppRow(
              label: t('Asr'),
              value: t('asr_${asrLabel(asr).toLowerCase()}'),
              valueColor: AppColors.gold,
              onTap: () => context.push('/calculation'),
            ),
            AppRow(
              label: t('adjustments'),
              value: adjusted ? t('custom') : '0 ${t('min_short')}',
              onTap: () => context.push('/adjustments'),
            ),
          ],
        ),
        Text(t('section_azan_mode'), style: AppText.label),
        Column(
          spacing: 8,
          children: [
            AppRow(
              label: t('azan_sound'),
              value: t('configure'),
              onTap: () => context.push('/alarm-settings'),
            ),
            if (kPrayerModeEnabled)
              const AppRow(label: 'Prayer window', value: '20 min'),
            AppRow(
              label: t('azan_protection'),
              value: t('check'),
              valueColor: AppColors.gold,
              onTap: () => context.push('/health-check'),
            ),
            AppRow(label: t('qibla'), onTap: () => context.push('/qibla')),
          ],
        ),
        Text(t('section_app'), style: AppText.label),
        Column(
          spacing: 8,
          children: [
            AppRow(
              label: t('language'),
              value: t('lang_name'),
              onTap: () => context.push('/language'),
            ),
            AppRow(label: t('about'), onTap: () => context.push('/about')),
            AppRow(label: t('terms'), onTap: () => context.push('/terms')),
            AppRow(label: t('privacy'), onTap: () => context.push('/privacy')),
            AppRow(
              label: t('licenses'),
              onTap: () => showLicensePage(
                context: context,
                applicationName: 'Waqt',
                applicationVersion: '1.0.1',
              ),
            ),
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
