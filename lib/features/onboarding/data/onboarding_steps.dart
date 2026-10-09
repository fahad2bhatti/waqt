import 'package:flutter/material.dart';
import 'package:waqt/core/config/features.dart';
import 'package:waqt/app/theme/app_colors.dart';

class OnboardingStep {
  const OnboardingStep({
    required this.title,
    required this.body,
    required this.primary,
    this.secondary,
    this.secondaryRoute,
    this.rows = const [],
    this.rowColor = AppColors.textMuted,
  });

  final String title;
  final String body;
  final String primary;
  final String? secondary;
  final String? secondaryRoute;
  final List<(String, String)> rows;
  final Color rowColor;
}

const onboardingSteps = [
  OnboardingStep(
    title: 'Make time for prayer',
    body: 'Accurate prayer times and a calm reminder when it matters most.',
    primary: 'Get started',
  ),
  OnboardingStep(
    title: 'Your prayer times',
    body:
        'We calculate Salah times on your phone from your location. Nothing is uploaded.',
    primary: 'Allow location',
    secondary: 'Choose city manually',
    secondaryRoute: '/city-search',
  ),
  OnboardingStep(
    title: 'Calculation settings',
    body: 'Pakistan defaults are selected. You can change these anytime.',
    primary: 'Continue',
    rows: [('Method', 'Karachi'), ('Asr', 'Hanafi'), ('Adjustments', '0 min')],
    rowColor: AppColors.gold,
  ),
  OnboardingStep(
    title: 'Never miss the Azan',
    body:
        'Waqt needs permission for notifications and exact alarms so the Azan plays on time.',
    primary: 'Enable Azan alerts',
    secondary: 'Maybe later',
  ),
  if (kPrayerModeEnabled)
    OnboardingStep(
      title: 'Protect your prayer time',
      body:
          'Prayer Mode covers apps you choose during prayer. Nothing is stored or sent anywhere.',
      primary: 'Enable Prayer Mode',
      secondary: 'Maybe later',
      rows: [('Usage access', 'Off'), ('Display over other apps', 'Off')],
    ),
];
