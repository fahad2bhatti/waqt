import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:waqt/app/theme/app_colors.dart';
import 'package:waqt/app/theme/app_text.dart';
import 'package:waqt/core/native/azan_scheduler.dart';
import 'package:waqt/core/widgets/app_page.dart';
import 'package:waqt/core/widgets/app_row.dart';
import 'package:waqt/core/widgets/info_card.dart';
import 'package:waqt/core/utils/translations.dart';
import 'package:waqt/features/health_check/providers/health_check_provider.dart';

class HealthCheckScreen extends ConsumerWidget {
  const HealthCheckScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(translationProvider);
    final checks = ref.watch(healthChecksProvider);
    final lastFired = ref.watch(lastAzanFiredProvider).value;
    final ready = checks.where((check) => check.ok).length;

    return Scaffold(
      appBar: AppBar(),
      body: AppPage(
        children: [
          Text(t('azan_protection'), style: AppText.title),
          Text(t('protection_desc'), style: AppText.body),
          InfoCard(
            title: '$ready of ${checks.length} ${t('health_ready')}',
            body: ready == checks.length ? t('health_ok') : t('health_fix'),
          ),
          Column(
            spacing: 8,
            children: [
              for (final check in checks)
                AppRow(
                  label: check.label,
                  value: check.ok ? t('health_ok') : t('health_not_ok'),
                  valueColor: check.ok ? AppColors.green : AppColors.gold,
                  onTap: check.ok
                      ? null
                      : () => ref
                            .read(deviceHealthProvider)
                            .openSettings(check.permission),
                ),
            ],
          ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: () async {
              try {
                await ref.read(azanSchedulerProvider).scheduleTest(seconds: 10);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Test Azan scheduled for 10s'),
                    ),
                  );
                }
              } catch (e) {
                debugPrint('Error scheduling test azan: $e');
              }
            },
            child: const Text('Test Azan (10 s)'),
          ),
          const SizedBox(height: 16),
          Text(
            formatLastFired(lastFired, DateTime.now()),
            style: AppText.caption,
          ),
        ],
      ),
    );
  }
}
