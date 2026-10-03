import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:waqt/app/router/app_router.dart';
import 'package:waqt/app/theme/app_theme.dart';
import 'package:waqt/features/azan/providers/azan_sync_provider.dart';
import 'package:waqt/features/azan/providers/prayed_sync_provider.dart';
import 'package:waqt/features/settings/providers/language_provider.dart';

class WaqtApp extends ConsumerStatefulWidget {
  const WaqtApp({super.key});

  @override
  ConsumerState<WaqtApp> createState() => _WaqtAppState();
}

class _WaqtAppState extends ConsumerState<WaqtApp> {
  static const _blockerChannel = MethodChannel('com.waqt/prayer_blocker');

  @override
  void initState() {
    super.initState();

    // Listen for the "onAppBlocked" signal from Native Android
    _blockerChannel.setMethodCallHandler((call) async {
      if (call.method == 'onAppBlocked') {
        // Use the router to push the overlay screen
        appRouter.push('/overlay-preview');
      }
      return null;
    });
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
