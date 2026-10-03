import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:waqt/app/theme/app_colors.dart';
import 'package:waqt/app/theme/app_text.dart';
import 'package:waqt/core/widgets/app_page.dart';
import 'package:waqt/core/utils/translations.dart';

class AzanScreen extends ConsumerWidget {
  const AzanScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(translationProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: AppPage(
        children: [
          const Spacer(),
          const Text(
            'ALLAHU AKBAR',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w800,
              color: AppColors.gold,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            t('azan_playing'),
            textAlign: TextAlign.center,
            style: AppText.body,
          ),
          const Spacer(),
          Text(
            t('prayer_started'),
            textAlign: TextAlign.center,
            style: AppText.caption,
          ),
          const SizedBox(height: 32),
          FilledButton(
            onPressed: () {
              // Logic to mark as prayed
            },
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.gold,
              foregroundColor: AppColors.background,
              padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
            ),
            child: Text(t('i_prayed'), style: AppText.body),
          ),
          const SizedBox(height: 12),
          OutlinedButton(
            onPressed: () {
              // Logic to stop azan
            },
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: AppColors.gold),
              foregroundColor: AppColors.gold,
              padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
            ),
            child: Text(t('stop_azan'), style: AppText.body),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}
