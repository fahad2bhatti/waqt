import 'package:flutter/material.dart';
import 'package:waqt/app/theme/app_colors.dart';
import 'package:waqt/app/theme/app_text.dart';
import 'package:waqt/core/widgets/app_page.dart';
import 'package:waqt/core/widgets/app_row.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const AppPage(
      children: [
        Text('Settings', style: AppText.title),
        Text('PRAYER TIMES', style: AppText.label),
        Column(
          spacing: 8,
          children: [
            AppRow(
              label: 'Calculation method',
              value: 'Karachi',
              valueColor: AppColors.gold,
            ),
            AppRow(label: 'Asr', value: 'Hanafi', valueColor: AppColors.gold),
            AppRow(label: 'Adjustments', value: '0 min'),
          ],
        ),
        Text('AZAN AND MODE', style: AppText.label),
        Column(
          spacing: 8,
          children: [
            AppRow(label: 'Azan sound', value: 'Makkah'),
            AppRow(label: 'Prayer window', value: '20 min'),
          ],
        ),
        Text('APP', style: AppText.label),
        Column(
          spacing: 8,
          children: [
            AppRow(label: 'Language', value: 'English'),
            AppRow(label: 'Theme', value: 'Dark'),
            AppRow(label: 'Delete all my data', labelColor: AppColors.danger),
          ],
        ),
      ],
    );
  }
}
