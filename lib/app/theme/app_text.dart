import 'package:flutter/material.dart';
import 'package:waqt/app/theme/app_colors.dart';

abstract final class AppText {
  static const title = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );
  static const rowLabel = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );
  static const label = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: AppColors.textMuted,
  );
  static const body = TextStyle(fontSize: 14, color: AppColors.textMuted);
  static const caption = TextStyle(fontSize: 13, color: AppColors.textMuted);
}
