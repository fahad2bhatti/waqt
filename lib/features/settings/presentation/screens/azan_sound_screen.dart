import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:waqt/app/theme/app_colors.dart';
import 'package:waqt/app/theme/app_text.dart';
import 'package:waqt/core/widgets/app_page.dart';
import 'package:waqt/core/widgets/app_row.dart';
import 'package:waqt/features/settings/providers/azan_sound_provider.dart';

const _sounds = ['Makkah', 'Madinah', 'Al-Aqsa', 'Short tone'];

class AzanSoundScreen extends ConsumerWidget {
  const AzanSoundScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(azanSoundProvider);
    final notifier = ref.read(azanSoundProvider.notifier);

    return Scaffold(
      appBar: AppBar(),
      body: AppPage(
        children: [
          const Text('Azan sound', style: AppText.title),
          Column(
            spacing: 8,
            children: [
              for (final sound in _sounds)
                AppRow(
                  label: sound,
                  value: sound == state.sound ? 'Selected' : 'Select',
                  valueColor: sound == state.sound
                      ? AppColors.gold
                      : AppColors.textMuted,
                  onTap: () => notifier.select(sound),
                ),
            ],
          ),
          AppRow(
            label: 'Different Azan for Fajr',
            trailing: Switch(
              value: state.differentFajr,
              onChanged: notifier.setDifferentFajr,
            ),
          ),
        ],
      ),
    );
  }
}
