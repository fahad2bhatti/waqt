import 'package:flutter/material.dart';
import 'package:waqt/app/theme/app_colors.dart';
import 'package:waqt/app/theme/app_text.dart';

class AppRow extends StatelessWidget {
  const AppRow({
    super.key,
    required this.label,
    this.value,
    this.valueColor = AppColors.textMuted,
    this.labelColor,
    this.trailing,
    this.highlight = false,
  });

  final String label;
  final String? value;
  final Color valueColor;
  final Color? labelColor;
  final Widget? trailing;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 16,
        vertical: trailing == null ? 14 : 9,
      ),
      decoration: BoxDecoration(
        color: highlight ? AppColors.line : AppColors.card,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        spacing: 12,
        children: [
          Expanded(
            child: Text(
              label,
              style: labelColor == null
                  ? AppText.rowLabel
                  : AppText.rowLabel.copyWith(color: labelColor),
            ),
          ),
          if (value != null)
            Text(value!, style: TextStyle(fontSize: 14, color: valueColor)),
          ?trailing,
        ],
      ),
    );
  }
}
