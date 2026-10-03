import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:waqt/app/theme/app_colors.dart';
import 'package:waqt/app/theme/app_text.dart';
import 'package:waqt/core/widgets/app_page.dart';
import 'package:waqt/core/utils/translations.dart';
import 'package:waqt/features/settings/providers/language_provider.dart';

class LanguageScreen extends ConsumerWidget {
  const LanguageScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(translationProvider);
    final currentLang = ref.watch(languageProvider);

    return Scaffold(
      appBar: AppBar(),
      body: AppPage(
        children: [
          Text(t('language'), style: AppText.title),
          const SizedBox(height: 24),
          Column(
            spacing: 12,
            children: [
              _LanguageOption(
                label: 'English',
                isSelected: currentLang == 'English',
                onTap: () {
                  ref.read(languageProvider.notifier).select('English');
                  context.pop();
                },
              ),
              _LanguageOption(
                label: 'Urdu (اردو)',
                isSelected: currentLang == 'Urdu',
                onTap: () {
                  ref.read(languageProvider.notifier).select('Urdu');
                  context.pop();
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _LanguageOption extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _LanguageOption({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.gold.withValues(alpha: 0.1)
              : AppColors.card,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.gold : AppColors.line,
            width: 2,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: AppText.body),
            if (isSelected)
              const Icon(Icons.check_circle, color: AppColors.gold),
          ],
        ),
      ),
    );
  }
}
