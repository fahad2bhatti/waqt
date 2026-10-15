import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:waqt/app/theme/app_colors.dart';
import 'package:waqt/app/theme/app_text.dart';
import 'package:waqt/core/legal/legal_text.dart';
import 'package:waqt/core/storage/prefs.dart';
import 'package:waqt/core/widgets/app_row.dart';
import 'package:waqt/core/widgets/brand_icon.dart';

/// Shown before anything else until the user accepts the current terms.
class AgreementScreen extends ConsumerStatefulWidget {
  const AgreementScreen({super.key});

  @override
  ConsumerState<AgreementScreen> createState() => _AgreementScreenState();
}

class _AgreementScreenState extends ConsumerState<AgreementScreen> {
  bool _agreed = false;

  Future<void> _accept() async {
    final prefs = ref.read(prefsProvider);
    await prefs.setString(PrefKeys.termsAccepted, kTermsVersion);
    if (!mounted) return;
    final onboarded = prefs.getBool(PrefKeys.onboarded) ?? false;
    context.go(onboarded ? '/home' : '/onboarding');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Directionality(
          textDirection: TextDirection.ltr,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      spacing: 12,
                      children: [
                        const SizedBox(height: 24),
                        const Center(child: BrandIcon()),
                        const SizedBox(height: 4),
                        const Text(
                          'Before you start',
                          textAlign: TextAlign.center,
                          style: AppText.title,
                        ),
                        const Text(
                          'Please read and accept our terms to use Waqt. '
                          'Your prayer history and settings stay on your phone.',
                          textAlign: TextAlign.center,
                          style: AppText.body,
                        ),
                        const SizedBox(height: 8),
                        AppRow(
                          label: 'Terms & Conditions',
                          value: 'Read',
                          valueColor: AppColors.gold,
                          onTap: () => context.push('/terms'),
                        ),
                        AppRow(
                          label: 'Privacy Policy',
                          value: 'Read',
                          valueColor: AppColors.gold,
                          onTap: () => context.push('/privacy'),
                        ),
                      ],
                    ),
                  ),
                ),
                CheckboxListTile(
                  value: _agreed,
                  onChanged: (value) =>
                      setState(() => _agreed = value ?? false),
                  controlAffinity: ListTileControlAffinity.leading,
                  contentPadding: EdgeInsets.zero,
                  activeColor: AppColors.gold,
                  checkColor: AppColors.background,
                  title: const Text(
                    'I have read and agree to the Terms & Conditions and '
                    'Privacy Policy.',
                    style: AppText.body,
                  ),
                ),
                const SizedBox(height: 8),
                FilledButton(
                  onPressed: _agreed ? _accept : null,
                  child: const Text('Agree and continue'),
                ),
                TextButton(
                  onPressed: () => SystemNavigator.pop(),
                  child: const Text('Decline and exit'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
