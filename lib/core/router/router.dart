import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../security/auth_service.dart';
import '../analytics/analytics_service.dart';
import '../providers/feature_toggles_provider.dart';
import '../../features/presentation/navigation_shell.dart';

import '../../features/idea_vault/presentation/screens/idea_vault_screen.dart';
import '../../features/project_tracker/presentation/screens/projects_screen.dart';
import '../../features/project_tracker/presentation/screens/project_detail_screen.dart';
import '../../features/research_tracker/presentation/screens/research_screen.dart';
import '../../features/research_tracker/presentation/screens/research_detail_screen.dart';
import '../../features/job_tracker/presentation/screens/jobs_screen.dart';
import '../../features/job_tracker/presentation/screens/job_detail_screen.dart';
import '../../features/settings/presentation/settings_screen.dart';
import '../../features/auth/presentation/screens/splash_screen.dart';
import '../../features/auth/presentation/screens/pin_setup_screen.dart';
import '../../features/auth/presentation/screens/pin_login_screen.dart';
import '../../features/hacker_news/presentation/screens/hn_feed_screen.dart';
import '../../features/ai_agents/presentation/screens/mitnick_chat_screen.dart';
import '../../features/command_center/presentation/screens/command_center_screen.dart';
import '../../features/idea_vault/presentation/screens/camera_capture_screen.dart';
import '../../features/auth/presentation/screens/onboarding_screen.dart';
import '../../features/analytics/presentation/analytics_dashboard_screen.dart';
import '../../features/achievements/presentation/achievement_badges_screen.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');

class RiverpodRouterRefreshListenable extends ChangeNotifier {
  RiverpodRouterRefreshListenable(Ref ref) {
    ref.listen(authServiceProvider, (_, __) {
      notifyListeners();
    });
  }
}

final routerProvider = Provider<GoRouter>((ref) {
  final refreshListenable = RiverpodRouterRefreshListenable(ref);

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/splash',
    refreshListenable: refreshListenable,
    redirect: (context, state) {
      final status = ref.read(authServiceProvider);
      final location = state.uri.toString();

      // Never redirect away from /splash — allow the cinematic 3D splash screen to initialize and navigate naturally
      if (location == '/splash') {
        return null;
      }

      // First-launch onboarding check (synchronous via SharedPreferences provider)
      final prefs = ref.read(sharedPreferencesProvider);
      final onboardingDone = prefs.getBool('velvet_onboarding_complete') ?? false;

      if (!onboardingDone) {
        if (location != '/onboarding') {
          return '/onboarding';
        }
        return null;
      }

      if (status == AuthStatus.onboarding) {
        // Allow user to voluntarily navigate to /pin_login (already have account)
        if (location != '/pin_setup' && location != '/pin_login') return '/pin_setup';
      } else if (status == AuthStatus.locked) {
        // Allow user to voluntarily navigate to /pin_setup (new vault setup)
        if (location != '/pin_login' && location != '/pin_setup') return '/pin_login';
      } else if (status == AuthStatus.unlocked) {
        if (location == '/pin_login' || location == '/pin_setup' || location == '/onboarding') {
          return '/ideas';
        }
      }
      return null;
    },
    routes: [
      GoRoute(
        path: '/onboarding',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/splash',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/pin_setup',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const PinSetupScreen(),
      ),
      GoRoute(
        path: '/pin_login',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const PinLoginScreen(),
      ),
      GoRoute(
        path: '/camera_capture',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const CameraCaptureScreen(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return NavigationShell(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/ideas',
                builder: (context, state) => const IdeaVaultScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/projects',
                builder: (context, state) => const ProjectsScreen(),
                routes: [
                  GoRoute(
                    path: ':id',
                    parentNavigatorKey: _rootNavigatorKey,
                    builder: (context, state) {
                      final id = int.parse(state.pathParameters['id']!);
                      return ProjectDetailScreen(projectId: id);
                    },
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/research',
                builder: (context, state) => const ResearchScreen(),
                routes: [
                  GoRoute(
                    path: ':id',
                    parentNavigatorKey: _rootNavigatorKey,
                    builder: (context, state) {
                      final id = int.parse(state.pathParameters['id']!);
                      return ResearchDetailScreen(paperId: id);
                    },
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/jobs',
                builder: (context, state) => const JobsScreen(),
                routes: [
                  GoRoute(
                    path: ':id',
                    parentNavigatorKey: _rootNavigatorKey,
                    builder: (context, state) {
                      final id = int.parse(state.pathParameters['id']!);
                      return JobDetailScreen(jobId: id);
                    },
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: '/settings',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: '/command_center',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const CommandCenterScreen(),
      ),
      GoRoute(
        path: '/hn',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const HnFeedScreen(),
      ),
      GoRoute(
        path: '/mitnick',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const MitnickChatScreen(),
      ),
      GoRoute(
        path: '/analytics',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const AnalyticsDashboardScreen(),
      ),
      GoRoute(
        path: '/achievements',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const AchievementBadgesScreen(),
      ),
    ],
  );
});
