import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:waqt/app/theme/app_colors.dart';
import 'package:waqt/app/theme/app_text.dart';
import 'package:waqt/core/widgets/app_page.dart';
import 'package:waqt/core/widgets/app_row.dart';
import 'package:waqt/core/utils/translations.dart';
import 'package:waqt/features/settings/providers/azan_sound_provider.dart';

class AzanSoundScreen extends ConsumerWidget {
  const AzanSoundScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(translationProvider);
    final state = ref.watch(azanSoundProvider);
    final notifier = ref.read(azanSoundProvider.notifier);

    final sounds = ['Makkah', 'Madinah', 'Al-Aqsa', 'Short tone'];

    return Scaffold(
      appBar: AppBar(),
      body: AppPage(
        children: [
          Text(t('azan_sound'), style: AppText.title),
          Column(
            spacing: 8,
            children: [
              for (final sound in sounds)
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
