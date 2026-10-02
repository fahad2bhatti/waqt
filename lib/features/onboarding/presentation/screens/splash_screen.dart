import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:waqt/app/theme/app_text.dart';
import 'package:waqt/core/storage/prefs.dart';
import 'package:waqt/core/widgets/brand_icon.dart';
import 'package:waqt/core/utils/translations.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  late final Timer _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer(const Duration(milliseconds: 1500), () {
      final onboarded =
          ref.read(prefsProvider).getBool(PrefKeys.onboarded) ?? false;
      context.go(onboarded ? '/home' : '/onboarding');
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = ref.watch(translationProvider);

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          spacing: 16,
          children: [
            const BrandIcon(),
            Text(
              t('app_title'),
              style: const TextStyle(fontSize: 40, fontWeight: FontWeight.w700),
            ),
            Text(t('make_time'), style: AppText.body),
          ],
        ),
      ),
    );
  }
}
