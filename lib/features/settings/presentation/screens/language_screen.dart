import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:waqt/app/theme/app_colors.dart';
import 'package:waqt/app/theme/app_text.dart';
import 'package:waqt/core/widgets/app_page.dart';
import 'package:waqt/core/widgets/app_row.dart';
import 'package:waqt/features/settings/providers/language_provider.dart';

const _languages = ['English', 'Urdu'];

class LanguageScreen extends ConsumerWidget {
  const LanguageScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(languageProvider);
    final notifier = ref.read(languageProvider.notifier);

    return Scaffold(
      appBar: AppBar(),
      body: AppPage(
        children: [
          const Text('Language', style: AppText.title),
          Column(
            spacing: 8,
            children: [
              for (final language in _languages)
                AppRow(
                  label: language,
                  value: language == selected ? 'Selected' : null,
                  valueColor: AppColors.gold,
                  onTap: () => notifier.select(language),
                ),
              const AppRow(label: 'Arabic', value: 'Coming soon'),
            ],
          ),
        ],
      ),
    );
  }
}
