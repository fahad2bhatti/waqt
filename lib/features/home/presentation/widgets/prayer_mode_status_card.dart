import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:waqt/app/theme/app_colors.dart';
import 'package:waqt/app/theme/app_text.dart';
import 'package:waqt/core/native/device_health.dart';
import 'package:waqt/features/health_check/providers/health_check_provider.dart';

class PrayerModeStatusCard extends ConsumerWidget {
  const PrayerModeStatusCard({super.key, required this.appCount});

  final int appCount;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final blocker = ref.watch(prayerModeBlockerProvider);
    if (blocker == null) return _ActiveCard(appCount: appCount);

    return _InactiveCard(
      message: blocker == WaqtPermission.usageAccess
          ? 'Usage access is off. Turn it on to pause your apps during prayer.'
          : 'Display over other apps is off. Turn it on to show the prayer screen.',
      onFix: () => ref.read(deviceHealthProvider).openSettings(blocker),
    );
  }
}

class _ActiveCard extends StatelessWidget {
  const _ActiveCard({required this.appCount});

  final int appCount;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: const BoxDecoration(
              color: AppColors.green,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 10),
          Text(
            'Prayer Mode is on  |  $appCount apps',
            style: const TextStyle(fontSize: 15, color: AppColors.textPrimary),
          ),
        ],
      ),
    );
  }
}

class _InactiveCard extends StatelessWidget {
  const _InactiveCard({required this.message, required this.onFix});

  final String message;
  final VoidCallback onFix;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.gold, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 6,
        children: [
          const Text(
            'Prayer Mode is inactive',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppColors.gold,
            ),
          ),
          Text(message, style: AppText.caption),
          GestureDetector(
            onTap: onFix,
            behavior: HitTestBehavior.opaque,
            child: const Padding(
              padding: EdgeInsets.symmetric(vertical: 4),
              child: Text(
                'Fix now',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.green,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
