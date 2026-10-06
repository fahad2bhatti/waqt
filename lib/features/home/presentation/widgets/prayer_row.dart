import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:waqt/app/theme/app_colors.dart';
import 'package:waqt/core/utils/translations.dart';
import 'package:waqt/core/widgets/app_row.dart';
import 'package:waqt/features/prayer_times/data/prayer_entry.dart';

class PrayerRow extends ConsumerWidget {
  const PrayerRow({super.key, required this.entry, this.onTap});

  final PrayerEntry entry;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(translationProvider);
    final next = entry.status == PrayerStatus.next;

    return AppRow(
      label: t(entry.name),
      highlight: next,
      onTap: onTap,
      trailing: Row(
        spacing: 12,
        children: [
          Text(
            entry.time,
            style: const TextStyle(fontSize: 15, color: AppColors.textPrimary),
          ),
          if (next)
            const Text(
              'Next',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.gold,
              ),
            ),
          _TickBox(
            checked: entry.status == PrayerStatus.prayed,
            enabled: entry.started,
          ),
        ],
      ),
    );
  }
}

class _TickBox extends StatelessWidget {
  const _TickBox({required this.checked, required this.enabled});

  final bool checked;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final border = checked
        ? AppColors.green
        : AppColors.textMuted.withValues(alpha: enabled ? 1 : 0.4);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      width: 26,
      height: 26,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: checked ? AppColors.green : Colors.transparent,
        border: Border.all(color: border, width: 2),
      ),
      child: checked
          ? const Icon(Icons.check, size: 16, color: AppColors.background)
          : null,
    );
  }
}
