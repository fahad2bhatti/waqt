import 'package:flutter/material.dart';
import 'package:waqt/app/router/app_router.dart';
import 'package:waqt/app/theme/app_theme.dart';

class WaqtApp extends StatelessWidget {
  const WaqtApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Waqt',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      themeMode: ThemeMode.dark,
      routerConfig: appRouter,
    );
  }
}
