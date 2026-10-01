import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:waqt/app/theme/app_colors.dart';
import 'package:waqt/app/theme/app_text.dart';
import 'package:waqt/core/widgets/app_row.dart';
import 'package:waqt/core/widgets/brand_icon.dart';
import 'package:waqt/features/onboarding/data/onboarding_steps.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  int _step = 0;

  void _next() {
    if (_step == onboardingSteps.length - 1) {
      context.go('/home');
    } else {
      setState(() => _step++);
    }
  }

  @override
  Widget build(BuildContext context) {
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
                step.title,
                textAlign: TextAlign.center,
                style: AppText.title,
              ),
              const SizedBox(height: 16),
              Text(step.body, textAlign: TextAlign.center, style: AppText.body),
              if (step.rows.isNotEmpty) ...[
                const SizedBox(height: 16),
                Column(
                  spacing: 8,
                  children: [
                    for (final (label, value) in step.rows)
                      AppRow(
                        label: label,
                        value: value,
                        valueColor: step.rowColor,
                      ),
                  ],
                ),
              ],
              const Spacer(),
              FilledButton(onPressed: _next, child: Text(step.primary)),
              if (step.secondary != null)
                TextButton(onPressed: _next, child: Text(step.secondary!)),
            ],
          ),
        ),
      ),
    );
  }
}
