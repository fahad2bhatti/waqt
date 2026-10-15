import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:waqt/app/theme/app_text.dart';
import 'package:waqt/core/native/azan_scheduler.dart';
import 'package:waqt/core/utils/translations.dart';
import 'package:waqt/core/widgets/app_page.dart';
import 'package:waqt/core/widgets/info_card.dart';
import 'package:waqt/features/health_check/data/brand_guides.dart';
import 'package:waqt/features/health_check/providers/health_check_provider.dart';
import 'package:waqt/features/settings/providers/language_provider.dart';

class AzanHelpScreen extends ConsumerWidget {
  const AzanHelpScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(translationProvider);
    final urdu = ref.watch(languageProvider) == 'Urdu';
    final maker = ref.watch(manufacturerProvider).value ?? '';
    final guide = guideFor(maker);
    final steps = urdu ? guide.ur : guide.en;

    return Scaffold(
      appBar: AppBar(),
      body: AppPage(
        children: [
          Text(t('azan_help'), style: AppText.title),
          Text(t('azan_help_intro'), style: AppText.body),
          InfoCard(
            title: guide.name,
            titleSize: 20,
            body: [
              for (var i = 0; i < steps.length; i++) '${i + 1}. ${steps[i]}',
            ].join('\n\n'),
          ),
          FilledButton(
            onPressed: () => ref.read(deviceHealthProvider).openBrandSettings(),
            child: Text(t('azan_help_open')),
          ),
          OutlinedButton(
            onPressed: () async {
              try {
                await ref.read(azanSchedulerProvider).scheduleTest(seconds: 60);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(t('azan_help_test_set'))),
                  );
                }
              } catch (e) {
                debugPrint('Error scheduling test azan: $e');
              }
            },
            child: Text(t('azan_help_test')),
          ),
        ],
      ),
    );
  }
}
