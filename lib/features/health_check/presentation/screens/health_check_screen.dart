import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:waqt/app/theme/app_colors.dart';
import 'package:waqt/app/theme/app_text.dart';
import 'package:waqt/core/widgets/app_page.dart';
import 'package:waqt/core/widgets/app_row.dart';
import 'package:waqt/core/widgets/info_card.dart';
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
          InfoCard(
            title: '$ready of ${checks.length} ready',
            body: 'Fix the rest for reliable Azan.',
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
