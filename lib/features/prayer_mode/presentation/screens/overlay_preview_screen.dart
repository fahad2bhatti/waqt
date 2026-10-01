import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:waqt/app/theme/app_colors.dart';
import 'package:waqt/app/theme/app_text.dart';

class OverlayPreviewScreen extends StatelessWidget {
  const OverlayPreviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.overlayBackground,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: 20,
            children: [
              const Spacer(),
              const Text(
                'MAGHRIB',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.gold,
                ),
              ),
              const Text(
                "It's prayer time",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const Text(
                'Maghrib has started. Have you prayed?',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: AppColors.textMuted),
              ),
              FilledButton(
                onPressed: () => context.pop(),
                child: const Text('I prayed'),
              ),
              OutlinedButton(
                onPressed: () => context.pop(),
                child: const Text('Allow 5 minutes'),
              ),
              OutlinedButton(
                onPressed: () => context.pop(),
                child: const Text('Not yet'),
              ),
              const Text(
                'Instagram is paused until 6:25 PM',
                textAlign: TextAlign.center,
                style: AppText.caption,
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}
