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
    this.onTap,
  });

  final String label;
  final String? value;
  final Color valueColor;
  final Color? labelColor;
  final Widget? trailing;
  final bool highlight;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: highlight ? AppColors.line : AppColors.card,
      borderRadius: BorderRadius.circular(12),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: 16,
            vertical: trailing == null ? 14 : 9,
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
        ),
      ),
    );
  }
}
