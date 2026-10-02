import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:waqt/app/theme/app_colors.dart';
import 'package:waqt/app/theme/app_text.dart';
import 'package:waqt/core/storage/prefs.dart';
import 'package:waqt/features/prayer_mode/providers/blocked_apps_provider.dart';
import 'package:waqt/features/prayer_times/providers/city_provider.dart';
import 'package:waqt/features/settings/providers/adjustments_provider.dart';
import 'package:waqt/features/settings/providers/azan_sound_provider.dart';
import 'package:waqt/features/settings/providers/language_provider.dart';
import 'package:waqt/features/tracking/providers/prayer_log_provider.dart';

/// Shows the "Delete all data?" dialog. Returns true if the user confirmed.
Future<bool> confirmDeleteAllData(BuildContext context) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (_) => const _DeleteDataDialog(),
  );
  return confirmed ?? false;
}

/// Wipes everything stored on the device and resets in-memory state.
Future<void> deleteAllData(WidgetRef ref) async {
  await ref.read(prefsProvider).clear();
  ref
    ..invalidate(cityProvider)
    ..invalidate(adjustmentsProvider)
    ..invalidate(azanSoundProvider)
    ..invalidate(languageProvider)
    ..invalidate(blockedAppsProvider)
    ..invalidate(prayerLogProvider);
}

class _DeleteDataDialog extends StatelessWidget {
  const _DeleteDataDialog();

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.card,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 12,
          children: [
            const Text(
              'Delete all data?',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const Text(
              'Your prayer log, settings and blocked apps will be removed '
              'from this device. This cannot be undone.',
              style: AppText.body,
            ),
            const SizedBox(height: 4),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.danger,
                foregroundColor: AppColors.background,
              ),
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Delete'),
            ),
            OutlinedButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
          ],
        ),
      ),
    );
  }
}
