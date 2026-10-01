import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:waqt/app/theme/app_colors.dart';
import 'package:waqt/app/theme/app_text.dart';
import 'package:waqt/core/widgets/app_page.dart';
import 'package:waqt/core/widgets/app_row.dart';
import 'package:waqt/features/prayer_mode/data/available_apps.dart';
import 'package:waqt/features/prayer_mode/providers/blocked_apps_provider.dart';

class PrayerModeScreen extends ConsumerWidget {
  const PrayerModeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final blocked = ref.watch(blockedAppsProvider);
    final notifier = ref.read(blockedAppsProvider.notifier);

    return AppPage(
      children: [
        const Text('Prayer Mode', style: AppText.title),
        const Text(
          'Pause distracting apps during prayer time.',
          style: AppText.body,
        ),
        const Text('APPS TO PAUSE', style: AppText.label),
        Column(
          spacing: 8,
          children: [
            for (final app in availableApps)
              AppRow(
                label: app,
                trailing: Switch(
                  value: blocked.contains(app),
                  onChanged: (_) => notifier.toggle(app),
                ),
              ),
          ],
        ),
        const Text('PRAYER WINDOW', style: AppText.label),
        const AppRow(
          label: 'Duration',
          value: '20 min',
          valueColor: AppColors.gold,
        ),
        const Text('Always allowed: Phone, SMS, Maps', style: AppText.caption),
      ],
    );
  }
}
