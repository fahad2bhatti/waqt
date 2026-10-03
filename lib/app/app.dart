import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:waqt/app/router/app_router.dart';
import 'package:waqt/app/theme/app_theme.dart';
import 'package:waqt/features/azan/providers/azan_bridge.dart';
import 'package:waqt/features/azan/providers/azan_sync_provider.dart';
import 'package:waqt/features/azan/providers/prayed_sync_provider.dart';
import 'package:waqt/features/settings/providers/language_provider.dart';

class WaqtApp extends ConsumerStatefulWidget {
  const WaqtApp({super.key});

  @override
  ConsumerState<WaqtApp> createState() => _WaqtAppState();
}

class _WaqtAppState extends ConsumerState<WaqtApp> {
  @override
  void initState() {
    super.initState();
    AzanBridge.init(ref, onOpen: () => appRouter.push('/azan'));
  }

  @override
  Widget build(BuildContext context) {
    final language = ref.watch(languageProvider);
    ref.watch(azanSyncProvider);
    ref.watch(prayedSyncProvider);

    return MaterialApp.router(
      title: 'Waqt',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      themeMode: ThemeMode.dark,
      routerConfig: appRouter,
      locale: language == 'Urdu' ? const Locale('ur') : const Locale('en'),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('en'), Locale('ur')],
    );
  }
}
