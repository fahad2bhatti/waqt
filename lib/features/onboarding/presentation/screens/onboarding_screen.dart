import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:waqt/app/theme/app_colors.dart';
import 'package:waqt/app/theme/app_text.dart';
import 'package:waqt/core/storage/prefs.dart';
import 'package:waqt/core/widgets/app_row.dart';
import 'package:waqt/core/widgets/brand_icon.dart';
import 'package:waqt/core/utils/translations.dart';
import 'package:waqt/features/onboarding/data/onboarding_steps.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  int _step = 0;

  void _next() {
    if (_step == onboardingSteps.length - 1) {
      ref.read(prefsProvider).setBool(PrefKeys.onboarded, true);
      context.go('/home');
    } else {
      setState(() => _step++);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = ref.watch(translationProvider);
    final step = onboardingSteps[_step];

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                spacing: 6,
                children: [
                  for (var i = 0; i < onboardingSteps.length; i++)
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: i == _step ? 22 : 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: i == _step ? AppColors.gold : AppColors.line,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                ],
              ),
              const Spacer(),
              const Center(child: BrandIcon()),
              const SizedBox(height: 16),
              Text(
                _translateStepTitle(_step, t),
                textAlign: TextAlign.center,
                style: AppText.title,
              ),
              const SizedBox(height: 16),
              Text(
                _translateStepBody(_step, t),
                textAlign: TextAlign.center,
                style: AppText.body,
              ),
              if (step.rows.isNotEmpty) ...[
                const SizedBox(height: 16),
                Column(
                  spacing: 8,
                  children: [
                    for (final (label, value) in step.rows)
                      AppRow(
                        label: t(label),
                        value: value,
                        valueColor: step.rowColor,
                      ),
                  ],
                ),
              ],
              const Spacer(),
              FilledButton(
                onPressed: _next,
                child: Text(_translateStepPrimary(_step, t)),
              ),
              if (step.secondary != null)
                TextButton(
                  onPressed: step.secondaryRoute == null
                      ? _next
                      : () => context.push(step.secondaryRoute!),
                  child: Text(_translateStepSecondary(_step, t)),
                ),
            ],
          ),
        ),
      ),
    );
  }

  String _translateStepTitle(int step, String Function(String) t) {
    switch (step) {
      case 0: return t('make_time');
      case 1: return t('onboard_2_title');
      case 2: return t('onboard_3_title');
      case 3: return t('onboard_4_title');
      case 4: return t('onboard_5_title');
      default: return '';
    }
  }

  String _translateStepBody(int step, String Function(String) t) {
    switch (step) {
      case 0: return t('onboard_1_body');
      case 1: return t('onboard_2_body');
      case 2: return t('onboard_3_body');
      case 3: return t('onboard_4_body');
      case 4: return t('onboard_5_body');
      default: return '';
    }
  }

  String _translateStepPrimary(int step, String Function(String) t) {
    switch (step) {
      case 0: return t('get_started');
      case 1: return t('onboard_2_primary');
      case 2: return t('onboard_3_primary');
      case 3: return t('onboard_4_primary');
      case 4: return t('onboard_5_primary');
      default: return '';
    }
  }

  String _translateStepSecondary(int step, String Function(String) t) {
    switch (step) {
      case 1: return t('onboard_2_secondary');
      case 3: return t('onboard_4_secondary');
      case 4: return t('onboard_5_secondary');
      default: return '';
    }
  }
}
