import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:waqt/app/router/app_router.dart';
import 'package:waqt/app/theme/app_theme.dart';
import 'package:waqt/features/azan/providers/azan_sync_provider.dart';
import 'package:waqt/features/azan/providers/prayed_sync_provider.dart';

class WaqtApp extends ConsumerWidget {
  const WaqtApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(azanSyncProvider);
    ref.watch(prayedSyncProvider);
    return MaterialApp.router(
      title: 'Waqt',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      themeMode: ThemeMode.dark,
      routerConfig: appRouter,
    );
  }
}
