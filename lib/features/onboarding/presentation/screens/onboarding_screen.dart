import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:waqt/app/theme/app_colors.dart';
import 'package:waqt/app/theme/app_text.dart';
import 'package:waqt/core/storage/prefs.dart';
import 'package:waqt/core/widgets/app_row.dart';
import 'package:waqt/core/widgets/brand_icon.dart';
import 'package:waqt/core/native/device_health.dart';
import 'package:waqt/core/utils/translations.dart';
import 'package:waqt/features/health_check/providers/health_check_provider.dart';
import 'package:waqt/features/onboarding/data/alert_permissions.dart';
import 'package:waqt/features/onboarding/data/onboarding_steps.dart';
import 'package:waqt/features/prayer_times/providers/city_provider.dart';
import 'package:waqt/features/prayer_times/services/location_service.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  int _step = 0;
  bool _busy = false;

  /// Handles one missing Azan permission per tap, in a fixed order, so the
  /// user always sees a single clear request. Android settings pages leave the
  /// app; the status refreshes when the user comes back (permissionsProvider).
  Future<void> _enableAlerts() async {
    if (_busy) return;
    _busy = true;
    try {
      final health = ref.read(deviceHealthProvider);
      final missing = nextMissingAlert(await health.status());
      if (!mounted) return;
      if (missing == null) {
        _next();
        return;
      }
      if (missing == WaqtPermission.notifications) {
        final answer = await health.requestNotifications();
        if (answer == NotificationAnswer.blocked ||
            (answer == NotificationAnswer.granted &&
                (await health.status())[WaqtPermission.notifications] !=
                    true)) {
          await health.openSettings(missing);
        }
      } else {
        await health.openSettings(missing);
      }
      if (mounted) await ref.read(permissionsProvider.notifier).refresh();
    } finally {
      _busy = false;
    }
  }

  /// Detects the nearest supported city. On failure the user stays on this
  /// step and can retry or choose a city manually.
  Future<void> _useLocation() async {
    if (_busy) return;
    _busy = true;
    try {
      final city = await LocationService().detectCity();
      if (!mounted) return;
      if (city == null) {
        final t = ref.read(translationProvider);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(t('location_failed'))));
        return;
      }
      ref.read(cityProvider.notifier).select(city);
      _next();
    } finally {
      _busy = false;
    }
  }

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
    final status = step.requestsAlerts
        ? ref.watch(permissionsProvider).value
        : null;
    final missing = status == null ? null : nextMissingAlert(status);
    final alertsDone = status != null && missing == null;

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
              if (status != null) ...[
                const SizedBox(height: 16),
                Column(
                  spacing: 8,
                  children: [
                    for (final permission in alertPermissions)
                      AppRow(
                        label: t('alert_${permission.name}'),
                        value: status[permission] == true
                            ? t('health_ok')
                            : t('health_not_ok'),
                        valueColor: status[permission] == true
                            ? AppColors.green
                            : AppColors.gold,
                      ),
                  ],
                ),
                if (missing != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    t('alert_hint_${missing.name}'),
                    textAlign: TextAlign.center,
                    style: AppText.caption,
                  ),
                ],
              ],
              const Spacer(),
              FilledButton(
                onPressed: step.requestsAlerts && !alertsDone
                    ? _enableAlerts
                    : step.requestsLocation
                    ? _useLocation
                    : _next,
                child: Text(
                  alertsDone
                      ? t('onboard_3_primary')
                      : _translateStepPrimary(_step, t),
                ),
              ),
              if (step.secondary != null && !alertsDone)
                TextButton(
                  onPressed: step.secondaryRoute == null
                      ? _next
                      : () async {
                          await context.push(step.secondaryRoute!);
                          if (mounted &&
                              ref
                                      .read(prefsProvider)
                                      .getString(PrefKeys.city) !=
                                  null) {
                            _next();
                          }
                        },
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
      case 0:
        return t('make_time');
      case 1:
        return t('onboard_2_title');
      case 2:
        return t('onboard_3_title');
      case 3:
        return t('onboard_4_title');
      case 4:
        return t('onboard_5_title');
      default:
        return '';
    }
  }

  String _translateStepBody(int step, String Function(String) t) {
    switch (step) {
      case 0:
        return t('onboard_1_body');
      case 1:
        return t('onboard_2_body');
      case 2:
        return t('onboard_3_body');
      case 3:
        return t('onboard_4_body');
      case 4:
        return t('onboard_5_body');
      default:
        return '';
    }
  }

  String _translateStepPrimary(int step, String Function(String) t) {
    switch (step) {
      case 0:
        return t('get_started');
      case 1:
        return t('onboard_2_primary');
      case 2:
        return t('onboard_3_primary');
      case 3:
        return t('onboard_4_primary');
      case 4:
        return t('onboard_5_primary');
      default:
        return '';
    }
  }

  String _translateStepSecondary(int step, String Function(String) t) {
    switch (step) {
      case 1:
        return t('onboard_2_secondary');
      case 3:
        return t('onboard_4_secondary');
      case 4:
        return t('onboard_5_secondary');
      default:
        return '';
    }
  }
}
