import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:waqt/app/theme/app_colors.dart';
import 'package:waqt/app/theme/app_text.dart';
import 'package:waqt/core/widgets/app_page.dart';
import 'package:waqt/core/widgets/app_row.dart';
import 'package:waqt/features/health_check/providers/health_check_provider.dart';

class HealthCheckScreen extends ConsumerWidget {
  const HealthCheckScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final checks = ref.watch(healthChecksProvider);
    final ready = checks.where((check) => check.$2).length;

    return Scaffold(
      appBar: AppBar(),
      body: AppPage(
        children: [
          const Text('Azan protection', style: AppText.title),
          const Text(
            'Everything Waqt needs to reach you on time.',
            style: AppText.body,
          ),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.hero,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 4,
              children: [
                Text(
                  '$ready of ${checks.length} ready',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: AppColors.gold,
                  ),
                ),
                const Text(
                  'Fix the rest for reliable Azan.',
                  style: AppText.body,
                ),
              ],
            ),
          ),
          Column(
            spacing: 8,
            children: [
              for (final (name, ok) in checks)
                AppRow(
                  label: name,
                  value: ok ? 'On' : 'Fix',
                  valueColor: ok ? AppColors.green : AppColors.gold,
                ),
            ],
          ),
          const Text('Last Azan fired: today, 4:45 AM', style: AppText.caption),
        ],
      ),
    );
  }
}
