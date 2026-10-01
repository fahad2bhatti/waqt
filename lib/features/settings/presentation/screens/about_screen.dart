import 'package:flutter/material.dart';
import 'package:waqt/app/theme/app_colors.dart';
import 'package:waqt/app/theme/app_text.dart';
import 'package:waqt/core/widgets/app_page.dart';
import 'package:waqt/core/widgets/app_row.dart';
import 'package:waqt/core/widgets/info_card.dart';

const _appVersion = '1.0.0';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: AppPage(
        children: [
          const Text('About', style: AppText.title),
          const InfoCard(
            title: 'Your data stays on this device',
            body:
                'Location, blocked apps and prayer history are never uploaded.',
            titleSize: 18,
          ),
          Column(
            spacing: 8,
            children: [
              const AppRow(label: 'Version', value: _appVersion),
              const AppRow(
                label: 'Privacy policy',
                value: 'Open',
                valueColor: AppColors.gold,
              ),
              AppRow(
                label: 'Licenses',
                value: 'Open',
                valueColor: AppColors.gold,
                onTap: () => showLicensePage(
                  context: context,
                  applicationName: 'Waqt',
                  applicationVersion: _appVersion,
                ),
              ),
              const AppRow(
                label: 'Send feedback',
                value: 'Open',
                valueColor: AppColors.gold,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
