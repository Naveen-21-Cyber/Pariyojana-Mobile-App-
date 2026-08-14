import 'dart:io';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:workmanager/workmanager.dart';
import '../database/database.dart';
import '../notifications/notification_service.dart';
import '../security/secure_storage_service.dart';

const String dailyTaskName = 'velvet_daily_maintenance_task';

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    try {
      await BackgroundService.runMaintenanceNow();
      return true;
    } catch (e) {
      return false;
    }
  });
}

class BackgroundService {
  static Future<void> initialize() async {
    await Workmanager().initialize(
      callbackDispatcher,
    );
  }

  static Future<void> registerDailyMaintenance() async {
    await Workmanager().registerPeriodicTask(
      dailyTaskName,
      dailyTaskName,
      frequency: const Duration(hours: 24),
      existingWorkPolicy: ExistingPeriodicWorkPolicy.keep,
    );
  }


  static Future<void> runMaintenanceNow() async {
    final secureStorage = SecureStorageService();
    await performDatabaseBackup(secureStorage);

    final String hexKey = await secureStorage.getOrCreateDatabaseKey();
    final conn = openConnection(hexKey);
    final db = VelvetDatabase(conn);
    final notificationService = NotificationService();
    await notificationService.initialize();

      // Check toggles
      final bool notifyStale = await secureStorage.isNotifyProjectStaleEnabled();
      final bool notifyPaper = await secureStorage.isNotifyResearchPaperEnabled();
      final bool notifyJob = await secureStorage.isNotifyJobApplicationEnabled();
      final bool notifyIdea = await secureStorage.isNotifyIdeaVaultEnabled();

      final now = DateTime.now();

      // Stale Projects Check
      if (notifyStale) {
        final staleProjects = await db.select(db.projects).get();
        int staleCount = 0;
        for (final proj in staleProjects) {
          if (proj.status == 'Active') {
            final checkTime = proj.lastSyncedAt ?? proj.createdAt;
            if (now.difference(checkTime).inDays >= 7) {
              staleCount++;
            }
          }
        }
        if (staleCount > 0) {
          await notificationService.showNotification(
            id: 101,
            title: 'Stale Projects Warning',
            body: '$staleCount active project(s) have not been synced in 7+ days.',
          );
        }
      }

      // Stalled Papers Check
      if (notifyPaper) {
        final stalledPapers = await db.select(db.researchPapers).get();
        int stalledCount = 0;
        for (final paper in stalledPapers) {
          if (paper.status == 'Preliminary Upload') {
            if (now.difference(paper.updatedAt).inDays >= 7) {
              stalledCount++;
            }
          }
        }
        if (stalledCount > 0) {
          await notificationService.showNotification(
            id: 102,
            title: 'Stalled Research Papers',
            body: '$stalledCount research paper(s) are stalled in Preliminary Upload status.',
          );
        }
      }

      // Overdue Job Outreach Check
      if (notifyJob) {
        final applications = await db.select(db.jobApplications).get();
        int overdueCount = 0;
        for (final app in applications) {
          if (app.status == 'Outreach Sent') {
            if (app.followUpDate != null && app.followUpDate!.isBefore(now)) {
              overdueCount++;
            }
          }
        }
        if (overdueCount > 0) {
          await notificationService.showNotification(
            id: 103,
            title: 'Job Follow-up Due',
            body: '$overdueCount job application outreach follow-up(s) are due.',
          );
        }
      }

      // Idea Capture Reminder
      if (notifyIdea) {
        final ideas = await db.select(db.ideas).get();
        bool hasRecentIdea = false;
        for (final idea in ideas) {
          if (now.difference(idea.createdAt).inDays <= 3) {
            hasRecentIdea = true;
            break;
          }
        }
        if (!hasRecentIdea) {
          await notificationService.showNotification(
            id: 104,
            title: 'Capture your thoughts',
            body: 'You haven\'t captured any ideas in the Vault in the last 3 days.',
          );
        }
      }

      await db.close();
  }

  static Future<void> performDatabaseBackup(SecureStorageService secureStorage) async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final dbFile = File('${dbFolder.path}${Platform.pathSeparator}velvet.db');
    final backupDir = Directory('${dbFolder.path}${Platform.pathSeparator}backups');
    await performBackupWithPaths(dbFile: dbFile, backupDir: backupDir);
  }

  static Future<void> performBackupWithPaths({
    required File dbFile,
    required Directory backupDir,
  }) async {
    if (await dbFile.exists()) {
      if (!await backupDir.exists()) {
        await backupDir.create(recursive: true);
      }

      final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
      final suffix = DateTime.now().microsecondsSinceEpoch;
      final backupFile = File('${backupDir.path}${Platform.pathSeparator}velvet_backup_${timestamp}_$suffix.db');
      await dbFile.copy(backupFile.path);

      // Rotation: keep last 7 backups
      final List<FileSystemEntity> files = await backupDir.list().toList();
      final List<File> backupFiles = files
          .whereType<File>()
          .where((file) => file.path.endsWith('.db') && file.path.contains('velvet_backup_'))
          .toList();

      backupFiles.sort((a, b) => a.path.compareTo(b.path));

      if (backupFiles.length > 7) {
        final deleteCount = backupFiles.length - 7;
        for (int i = 0; i < deleteCount; i++) {
          await backupFiles[i].delete();
        }
      }
    }
  }
}
