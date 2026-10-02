import 'package:go_router/go_router.dart';
import 'package:waqt/app/shell/app_shell.dart';
import 'package:waqt/features/health_check/presentation/screens/health_check_screen.dart';
import 'package:waqt/features/home/presentation/screens/home_screen.dart';
import 'package:waqt/features/onboarding/presentation/screens/onboarding_screen.dart';
import 'package:waqt/features/onboarding/presentation/screens/splash_screen.dart';
import 'package:waqt/features/prayer_mode/presentation/screens/app_picker_screen.dart';
import 'package:waqt/features/prayer_mode/presentation/screens/overlay_preview_screen.dart';
import 'package:waqt/features/prayer_mode/presentation/screens/prayer_mode_screen.dart';
import 'package:waqt/features/prayer_times/presentation/screens/city_search_screen.dart';
import 'package:waqt/features/prayer_times/presentation/screens/times_screen.dart';
import 'package:waqt/features/qibla/presentation/screens/qibla_screen.dart';
import 'package:waqt/features/settings/presentation/screens/about_screen.dart';
import 'package:waqt/features/settings/presentation/screens/adjustments_screen.dart';
import 'package:waqt/features/settings/presentation/screens/azan_sound_screen.dart';
import 'package:waqt/features/settings/presentation/screens/language_screen.dart';
import 'package:waqt/features/settings/presentation/screens/settings_screen.dart';
import 'package:waqt/features/stats/presentation/screens/stats_screen.dart';
import 'package:waqt/features/tracking/presentation/screens/prayer_log_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/splash',
  routes: [
    GoRoute(path: '/splash', builder: (_, _) => const SplashScreen()),
    GoRoute(path: '/onboarding', builder: (_, _) => const OnboardingScreen()),
    GoRoute(
      path: '/health-check',
      builder: (_, _) => const HealthCheckScreen(),
    ),
    GoRoute(path: '/qibla', builder: (_, _) => const QiblaScreen()),
    GoRoute(path: '/apps', builder: (_, _) => const AppPickerScreen()),
    GoRoute(
      path: '/overlay-preview',
      builder: (_, _) => const OverlayPreviewScreen(),
    ),
    GoRoute(path: '/city-search', builder: (_, _) => const CitySearchScreen()),
    GoRoute(path: '/adjustments', builder: (_, _) => const AdjustmentsScreen()),
    GoRoute(path: '/azan-sound', builder: (_, _) => const AzanSoundScreen()),
    GoRoute(path: '/language', builder: (_, _) => const LanguageScreen()),
    GoRoute(path: '/about', builder: (_, _) => const AboutScreen()),
    GoRoute(path: '/prayer-log', builder: (_, _) => const PrayerLogScreen()),
    StatefulShellRoute.indexedStack(
      builder: (context, state, shell) => AppShell(navigationShell: shell),
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(path: '/home', builder: (_, _) => const HomeScreen()),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(path: '/times', builder: (_, _) => const TimesScreen()),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(path: '/mode', builder: (_, _) => const PrayerModeScreen()),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(path: '/stats', builder: (_, _) => const StatsScreen()),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/settings',
              builder: (_, _) => const SettingsScreen(),
            ),
          ],
        ),
      ],
    ),
  ],
);
