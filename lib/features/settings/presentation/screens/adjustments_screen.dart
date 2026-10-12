import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:waqt/app/theme/app_colors.dart';
import 'package:waqt/app/theme/app_text.dart';
import 'package:waqt/core/utils/translations.dart';
import 'package:waqt/core/widgets/app_page.dart';
import 'package:waqt/core/widgets/app_row.dart';
import 'package:waqt/features/settings/providers/adjustments_provider.dart';

class AdjustmentsScreen extends ConsumerWidget {
  const AdjustmentsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(translationProvider);
    final adjustments = ref.watch(adjustmentsProvider);
    final notifier = ref.read(adjustmentsProvider.notifier);

    return Scaffold(
      appBar: AppBar(),
      body: AppPage(
        children: [
          Text(t('adjustments'), style: AppText.title),
          Text(t('adjust_desc'), style: AppText.body),
          Column(
            spacing: 8,
            children: [
              for (final MapEntry(:key, :value) in adjustments.entries)
                AppRow(
                  label: t(key),
                  trailing: Row(
                    spacing: 12,
                    children: [
                      _StepButton(
                        icon: Icons.remove,
                        onPressed: () => notifier.change(key, -1),
                      ),
                      SizedBox(
                        width: 64,
                        child: Text(
                          value > 0
                              ? '+$value ${t('min_short')}'
                              : '$value ${t('min_short')}',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            color: value == 0
                                ? AppColors.textMuted
                                : AppColors.gold,
                          ),
                        ),
                      ),
                      _StepButton(
                        icon: Icons.add,
                        onPressed: () => notifier.change(key, 1),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StepButton extends StatelessWidget {
  const _StepButton({required this.icon, required this.onPressed});

  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      icon: Icon(icon),
      iconSize: 16,
      style: IconButton.styleFrom(
        backgroundColor: AppColors.line,
        foregroundColor: AppColors.textPrimary,
        fixedSize: const Size(32, 32),
        padding: EdgeInsets.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
    );
  }
}
