import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:velvet/core/background/background_service.dart';

void main() {
  group('Phase 4 - Notifications and Database Rotation Tests', () {
    late Directory tempDir;
    late File dbFile;
    late Directory backupDir;

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp('velvet_test_');
      dbFile = File('${tempDir.path}${Platform.pathSeparator}velvet.db');
      await dbFile.writeAsString('dummy db content');
      backupDir = Directory('${tempDir.path}${Platform.pathSeparator}backups');
    });

    tearDown(() async {
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
    });

    test('performBackupWithPaths creates backups and rotates to keep exactly 7', () async {
      // Run backup 10 times
      for (int i = 0; i < 10; i++) {
        await Future.delayed(const Duration(milliseconds: 2));
        await BackgroundService.performBackupWithPaths(
          dbFile: dbFile,
          backupDir: backupDir,
        );
      }

      // Check files in backup directory
      final files = await backupDir.list().toList();
      final backupFiles = files
          .whereType<File>()
          .where((file) => file.path.endsWith('.db') && file.path.contains('velvet_backup_'))
          .toList();

      // Assert rotation keeps exactly 7
      expect(backupFiles.length, 7);

      // Verify the backups contain the content
      for (final f in backupFiles) {
        expect(await f.readAsString(), 'dummy db content');
      }
    });
  });
}
