import 'package:go_router/go_router.dart';
import 'package:waqt/app/shell/app_shell.dart';
import 'package:waqt/features/home/presentation/screens/home_screen.dart';
import 'package:waqt/features/prayer_mode/presentation/screens/prayer_mode_screen.dart';
import 'package:waqt/features/prayer_times/presentation/screens/times_screen.dart';
import 'package:waqt/features/settings/presentation/screens/settings_screen.dart';
import 'package:waqt/features/stats/presentation/screens/stats_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/home',
  routes: [
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
