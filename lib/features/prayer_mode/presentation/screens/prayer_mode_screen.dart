import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:waqt/app/theme/app_colors.dart';
import 'package:waqt/app/theme/app_text.dart';
import 'package:waqt/core/widgets/app_page.dart';
import 'package:waqt/core/widgets/app_row.dart';
import 'package:waqt/core/utils/translations.dart';
import 'package:waqt/features/prayer_mode/providers/blocked_apps_provider.dart';

class PrayerModeScreen extends ConsumerStatefulWidget {
  const PrayerModeScreen({super.key});

  @override
  ConsumerState<PrayerModeScreen> createState() => _PrayerModeScreenState();
}

class _PrayerModeScreenState extends ConsumerState<PrayerModeScreen> {
  bool _isActive = false;
  static const _blockerChannel = MethodChannel('com.waqt/prayer_blocker');

  void _toggleService() async {
    try {
      if (_isActive) {
        await _blockerChannel.invokeMethod('stopService');
      } else {
        await _blockerChannel.invokeMethod('startService');
      }
      setState(() => _isActive = !_isActive);
    } catch (e) {
      debugPrint('Error toggling blocker service: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = ref.watch(translationProvider);
    final count = ref.watch(blockedAppsProvider).length;

    return AppPage(
      children: [
        Text(t('mode_title'), style: AppText.title),
        Text(
          t('mode_desc'),
          style: AppText.body,
        ),
        const SizedBox(height: 16),
        SwitchListTile(
          title: Text('Enable Blocker', style: AppText.body),
          subtitle: Text('Block apps in background', style: AppText.caption),
          value: _isActive,
          onChanged: (_) => _toggleService(),
          activeThumbColor: AppColors.gold,
        ),
        const SizedBox(height: 24),
        Text(t('apps_to_pause'), style: AppText.label),
        AppRow(
          label: t('choose_apps'),
          value: '$count selected',
          valueColor: AppColors.gold,
          onTap: () => context.push('/apps'),
        ),
        const SizedBox(height: 16),
        Text(t('prayer_window'), style: AppText.label),
        const AppRow(
          label: 'Duration',
          value: '20 min',
          valueColor: AppColors.gold,
        ),
        AppRow(
          label: t('preview_overlay'),
          onTap: () => context.push('/overlay-preview'),
        ),
        const SizedBox(height: 16),
        Text(t('always_allowed'), style: AppText.caption),
      ],
    );
  }
}
