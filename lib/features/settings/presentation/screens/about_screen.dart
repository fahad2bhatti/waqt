import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:waqt/app/theme/app_colors.dart';
import 'package:waqt/app/theme/app_text.dart';
import 'package:waqt/core/config/features.dart';
import 'package:waqt/core/utils/translations.dart';
import 'package:waqt/core/widgets/app_page.dart';
import 'package:waqt/core/widgets/app_row.dart';
import 'package:waqt/core/widgets/info_card.dart';

const _appVersion = '1.0.0';

class AboutScreen extends ConsumerWidget {
  const AboutScreen({super.key});

  Future<void> _open(BuildContext context, Uri uri, String errorText) async {
    var opened = false;
    try {
      opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      opened = false;
    }
    if (!opened && context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(errorText)));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(translationProvider);

    return Scaffold(
      appBar: AppBar(),
      body: AppPage(
        children: [
          Text(t('about'), style: AppText.title),
          InfoCard(
            title: t('about_data_title'),
            body: t('about_data_body'),
            titleSize: 18,
          ),
          Column(
            spacing: 8,
            children: [
              AppRow(label: t('version'), value: _appVersion),
              if (kFeedbackEmail.isNotEmpty)
                AppRow(
                  label: t('send_feedback'),
                  value: t('open'),
                  valueColor: AppColors.gold,
                  onTap: () => _open(
                    context,
                    Uri.parse('mailto:$kFeedbackEmail?subject=Waqt%20feedback'),
                    t('link_error'),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
