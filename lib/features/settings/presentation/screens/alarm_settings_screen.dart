import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:waqt/app/theme/app_colors.dart';
import 'package:waqt/app/theme/app_text.dart';
import 'package:waqt/core/widgets/app_page.dart';
import 'package:waqt/core/widgets/app_row.dart';
import 'package:waqt/core/utils/translations.dart';
import 'package:waqt/features/settings/providers/azan_sound_provider.dart';

class AlarmSettingsScreen extends ConsumerWidget {
  const AlarmSettingsScreen({super.key});

  static const _phase0Channel = MethodChannel('com.waqt/phase0');

  Future<void> _scheduleTest(int seconds) async {
    try {
      await _phase0Channel.invokeMethod('scheduleAlarm', seconds);
    } catch (e) {
      debugPrint("Error: $e");
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(translationProvider);
    final soundState = ref.watch(azanSoundProvider);
    final soundNotifier = ref.read(azanSoundProvider.notifier);

    final sounds = ['Makkah', 'Madinah', 'Al-Aqsa', 'Short tone'];

    return Scaffold(
      appBar: AppBar(),
      body: AppPage(
        children: [
          Text(t('azan_sound'), style: AppText.title),
          const SizedBox(height: 16),
          
          // Sound Selection
          Column(
            spacing: 8,
            children: [
              for (final sound in sounds)
                AppRow(
                  label: sound,
                  value: sound == soundState.sound ? 'Selected' : 'Select',
                  valueColor: sound == soundState.sound ? AppColors.gold : AppColors.textMuted,
                  onTap: () => soundNotifier.select(sound),
                ),
            ],
          ),
          
          const SizedBox(height: 24),
          Text('Additional Options', style: AppText.label),
          Column(
            spacing: 8,
            children: [
              AppRow(
                label: 'Different Azan for Fajr',
                trailing: Switch(
                  value: soundState.differentFajr,
                  onChanged: soundNotifier.setDifferentFajr,
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),
          Text('Debug Tests', style: AppText.label),
          Column(
            spacing: 12,
            children: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.card,
                  foregroundColor: AppColors.textPrimary,
                  minimumSize: const Size(double.infinity, 50),
                ),
                onPressed: () => _scheduleTest(30),
                child: const Text("Test Alarm (30 Seconds)"),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.card,
                  foregroundColor: AppColors.textPrimary,
                  minimumSize: const Size(double.infinity, 50),
                ),
                onPressed: () => _scheduleTest(600),
                child: const Text("Test Alarm (10 Minutes)"),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
