import 'package:adhan_dart/adhan_dart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:waqt/app/theme/app_colors.dart';
import 'package:waqt/app/theme/app_text.dart';
import 'package:waqt/core/widgets/app_page.dart';
import 'package:waqt/features/prayer_times/data/calculation_options.dart';
import 'package:waqt/features/settings/providers/calculation_provider.dart';

class CalculationScreen extends ConsumerWidget {
  const CalculationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final method = ref.watch(calcMethodProvider);
    final asr = ref.watch(asrProvider);

    return Scaffold(
      appBar: AppBar(),
      body: AppPage(
        children: [
          const Text('Calculation', style: AppText.title),
          const Text(
            'Pakistan defaults are Karachi and Hanafi. Times and Azan '
            'alarms update as soon as you change these.',
            style: AppText.body,
          ),
          const Text('METHOD', style: AppText.label),
          Column(
            spacing: 8,
            children: [
              for (final option in CalcMethod.values)
                _Option(
                  label: option.label,
                  note: option.note,
                  selected: option == method,
                  onTap: () =>
                      ref.read(calcMethodProvider.notifier).select(option),
                ),
            ],
          ),
          const Text('ASR', style: AppText.label),
          Column(
            spacing: 8,
            children: [
              _Option(
                label: 'Hanafi',
                note: 'Later Asr (shadow = 2x object)',
                selected: asr == Madhab.hanafi,
                onTap: () =>
                    ref.read(asrProvider.notifier).select(Madhab.hanafi),
              ),
              _Option(
                label: 'Shafi',
                note: 'Earlier Asr (shadow = 1x object)',
                selected: asr == Madhab.shafi,
                onTap: () =>
                    ref.read(asrProvider.notifier).select(Madhab.shafi),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Option extends StatelessWidget {
  const _Option({
    required this.label,
    required this.note,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final String note;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.gold.withValues(alpha: 0.1)
              : AppColors.card,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? AppColors.gold : AppColors.line,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 4,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(note, style: AppText.caption),
                ],
              ),
            ),
            if (selected) const Icon(Icons.check, color: AppColors.gold),
          ],
        ),
      ),
    );
  }
}
