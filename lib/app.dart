import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/router/router.dart';
import 'core/theme/velvet_theme.dart';
import 'core/theme/font_provider.dart' hide secureStorageProvider;
import 'core/theme/velvet_colors.dart';
import 'core/security/auth_service.dart';
import 'core/notifications/notification_service.dart';
import 'core/services/update_checker_service.dart';
import 'features/project_tracker/presentation/providers/project_provider.dart';
import 'features/research_tracker/presentation/providers/research_provider.dart';
import 'features/job_tracker/presentation/providers/job_provider.dart';
import 'features/ai_agents/domain/agent_gateway.dart';

class VelvetApp extends ConsumerStatefulWidget {
  const VelvetApp({super.key});

  @override
  ConsumerState<VelvetApp> createState() => _VelvetAppState();
}

class _VelvetAppState extends ConsumerState<VelvetApp> {
  @override
  void initState() {
    super.initState();
    // Notification scheduling is safely triggered when vault reaches AuthStatus.unlocked
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _triggerNotificationScheduling(WidgetRef ref) async {
    try {
      final storage = ref.read(secureStorageProvider);
      final username = await storage.getUsername() ?? 'User';
      final projectsRepo = ref.read(projectRepositoryProvider);
      final researchRepo = ref.read(researchRepositoryProvider);
      final jobsRepo = ref.read(jobRepositoryProvider);

      final projects = await projectsRepo.watchProjects().first;
      final activeProjectNames = projects.map((p) => p.name).toList();

      final papers = await researchRepo.watchPapers().first;
      final hasUnpublishedPapers = papers.any((p) => p.status.toLowerCase() != 'published');

      final jobs = await jobsRepo.watchApplications().first;
      final hasActiveJobs = jobs.isNotEmpty;

      final notificationService = ref.read(notificationServiceProvider);
      final agentGateway = ref.read(agentGatewayProvider);

      final startHour = await storage.getNotificationStartHour();
      final endHour = await storage.getNotificationEndHour();

      // Request runtime notification permission (Android 13+ requires this)
      await notificationService.requestPermissions();

      await notificationService.refreshDailySchedules(
        username: username,
        activeProjectNames: activeProjectNames,
        hasUnpublishedPapers: hasUnpublishedPapers,
        hasActiveJobs: hasActiveJobs,
        startHour: startHour,
        endHour: endHour,
        agentGateway: agentGateway,
      );
    } catch (e) {
      debugPrint('Failed to schedule daily notifications: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(authServiceProvider, (previous, next) {
      if (next == AuthStatus.unlocked) {
        _triggerNotificationScheduling(ref);
        ref.read(updateCheckerServiceProvider).checkForUpdate();
      }
    });

    final router = ref.watch(routerProvider);
    final accent = ref.watch(themeAccentProvider);
    final themeMode = ref.watch(appThemeModeProvider);
    final currentFont = ref.watch(appFontProvider);
    
    return MaterialApp.router(
      title: 'Pariyojana',
      debugShowCheckedModeBanner: false,
      themeMode: themeMode,
      theme: VelvetTheme.getTheme(accent, font: currentFont),
      darkTheme: VelvetTheme.getDarkTheme(accent, font: currentFont),
      routerConfig: router,
    );
  }
}
