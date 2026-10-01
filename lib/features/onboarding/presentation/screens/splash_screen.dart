import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:waqt/app/theme/app_text.dart';
import 'package:waqt/core/widgets/brand_icon.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  late final Timer _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer(
      const Duration(milliseconds: 1500),
      () => context.go('/onboarding'),
    );
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          spacing: 16,
          children: [
            BrandIcon(),
            Text(
              'Waqt',
              style: TextStyle(fontSize: 40, fontWeight: FontWeight.w700),
            ),
            Text('Make time for prayer', style: AppText.body),
          ],
        ),
      ),
    );
  }
}
