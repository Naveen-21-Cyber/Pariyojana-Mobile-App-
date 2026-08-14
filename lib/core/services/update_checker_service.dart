import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:url_launcher/url_launcher.dart';
import '../theme/velvet_colors.dart';
import '../notifications/notification_service.dart';
import '../../shared_widgets/glass_snackbar.dart';

class UpdateInfo {
  final String currentVersion;
  final String latestVersion;
  final String title;
  final String releaseNotes;
  final String downloadUrl;
  final bool isUpdateAvailable;
  final DateTime? releaseDate;

  const UpdateInfo({
    required this.currentVersion,
    required this.latestVersion,
    required this.title,
    required this.releaseNotes,
    required this.downloadUrl,
    required this.isUpdateAvailable,
    this.releaseDate,
  });
}

final updateCheckerServiceProvider = Provider<UpdateCheckerService>((ref) {
  return UpdateCheckerService(ref);
});

class UpdateCheckerService {
  static const String currentAppVersion = '1.0.0';
  static const String _repoOwner = 'Naveen-21-Cyber';
  static const String _repoName = 'Pariyojana-Mobile-App-';
  static const String _lastNotifiedVersionKey = 'last_notified_update_version';

  final Ref _ref;
  final Dio _dio;
  final FlutterSecureStorage _storage;

  UpdateCheckerService(this._ref)
      : _dio = Dio(BaseOptions(
          connectTimeout: const Duration(seconds: 8),
          receiveTimeout: const Duration(seconds: 8),
          headers: {'Accept': 'application/vnd.github.v3+json'},
        )),
        _storage = const FlutterSecureStorage();

  /// Check GitHub Releases API for the latest published version
  Future<UpdateInfo?> checkForUpdate({bool notifyUserIfAvailable = true}) async {
    try {
      final customRepo = await _storage.read(key: 'custom_update_repo');
      final repoPath = (customRepo != null && customRepo.contains('/'))
          ? customRepo.trim()
          : '$_repoOwner/$_repoName';

      final response = await _dio.get<Map<String, dynamic>>(
        'https://api.github.com/repos/$repoPath/releases/latest',
      );

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data!;
        final tagName = (data['tag_name'] as String? ?? '').replaceAll('v', '').trim();
        final name = (data['name'] as String? ?? 'New Update Available').trim();
        final body = (data['body'] as String? ?? 'Performance improvements and bug fixes.').trim();
        final htmlUrl = (data['html_url'] as String? ?? 'https://github.com/$_repoOwner/$_repoName/releases').trim();
        final publishedAtStr = data['published_at'] as String?;
        final publishedAt = publishedAtStr != null ? DateTime.tryParse(publishedAtStr) : null;

        // Check if there are binary assets (APK) attached
        String downloadUrl = htmlUrl;
        if (data['assets'] is List && (data['assets'] as List).isNotEmpty) {
          for (final asset in data['assets'] as List) {
            final assetUrl = asset['browser_download_url'] as String?;
            if (assetUrl != null && assetUrl.endsWith('.apk')) {
              downloadUrl = assetUrl;
              break;
            }
          }
        }

        final isAvailable = _compareVersions(tagName, currentAppVersion) > 0;

        final updateInfo = UpdateInfo(
          currentVersion: currentAppVersion,
          latestVersion: tagName.isNotEmpty ? tagName : currentAppVersion,
          title: name,
          releaseNotes: body,
          downloadUrl: downloadUrl,
          isUpdateAvailable: isAvailable,
          releaseDate: publishedAt,
        );

        if (isAvailable && notifyUserIfAvailable) {
          final lastNotified = await _storage.read(key: _lastNotifiedVersionKey);
          if (lastNotified != tagName) {
            await _storage.write(key: _lastNotifiedVersionKey, value: tagName);
            await _dispatchUpdateNotification(updateInfo);
          }
        }

        return updateInfo;
      }
    } catch (e) {
      debugPrint('UpdateCheckerService check error: $e');
    }
    return const UpdateInfo(
      currentVersion: currentAppVersion,
      latestVersion: currentAppVersion,
      title: 'Up to Date',
      releaseNotes: 'You are running the latest version of Pariyojana (v1.0.0).',
      downloadUrl: 'https://github.com/Naveen-21-Cyber/Pariyojana-Mobile-App-/releases',
      isUpdateAvailable: false,
    );
  }

  /// Dispatches a local system notification informing the user of the new update
  Future<void> _dispatchUpdateNotification(UpdateInfo info) async {
    try {
      final notifService = _ref.read(notificationServiceProvider);
      await notifService.showNotification(
        id: 99901,
        title: '🚀 New Update v${info.latestVersion} Available!',
        body: 'A new release of Pariyojana is ready: ${info.title}. Tap to download and install.',
        payload: 'update:${info.downloadUrl}',
      );
    } catch (e) {
      debugPrint('Error dispatching update notification: $e');
    }
  }

  /// Compares two semver strings: returns 1 if v1 > v2, -1 if v1 < v2, 0 if equal
  int _compareVersions(String v1, String v2) {
    if (v1.isEmpty || v2.isEmpty) return 0;
    final parts1 = v1.split('.').map((e) => int.tryParse(RegExp(r'\d+').stringMatch(e) ?? '0') ?? 0).toList();
    final parts2 = v2.split('.').map((e) => int.tryParse(RegExp(r'\d+').stringMatch(e) ?? '0') ?? 0).toList();

    while (parts1.length < 3) {
      parts1.add(0);
    }
    while (parts2.length < 3) {
      parts2.add(0);
    }

    for (var i = 0; i < 3; i++) {
      if (parts1[i] > parts2[i]) return 1;
      if (parts1[i] < parts2[i]) return -1;
    }
    return 0;
  }

  /// Displays the in-app Update Prompt Dialog
  static void showUpdateDialog(BuildContext context, UpdateInfo info) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (dialogCtx) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: VelvetColors.cardSurface(context),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: VelvetColors.coralPeach.withValues(alpha: 0.4), width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: VelvetColors.coralPeach.withValues(alpha: 0.15),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [VelvetColors.coralPeach, VelvetColors.coralPeach.withValues(alpha: 0.7)],
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(Icons.system_update_alt_rounded, color: Colors.white, size: 24),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                'Update Available',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                  color: VelvetColors.textPrimary(context),
                                ),
                              ),
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: VelvetColors.mint.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  'v${info.latestVersion}',
                                  style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: VelvetColors.mint),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Current: v${info.currentVersion}',
                            style: TextStyle(fontSize: 11, color: VelvetColors.textSecondary(context)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  info.title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: VelvetColors.textPrimary(context),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  constraints: const BoxConstraints(maxHeight: 180),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: VelvetColors.inputFill(context),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: VelvetColors.border(context)),
                  ),
                  child: SingleChildScrollView(
                    child: Text(
                      info.releaseNotes.isNotEmpty
                          ? info.releaseNotes
                          : '• Latest security updates and engine optimizations.\n• Adaptive dark mode improvements.\n• Offline-first SQLite database performance enhancements.',
                      style: TextStyle(fontSize: 12, height: 1.4, color: VelvetColors.textSecondary(context)),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          side: BorderSide(color: VelvetColors.border(context)),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        onPressed: () => Navigator.pop(dialogCtx),
                        child: Text(
                          'Later',
                          style: TextStyle(color: VelvetColors.textSecondary(context), fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: VelvetColors.coralPeach,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          elevation: 3,
                        ),
                        icon: const Icon(Icons.download_rounded, size: 18),
                        label: const Text('Download Update', style: TextStyle(fontWeight: FontWeight.bold)),
                        onPressed: () async {
                          Navigator.pop(dialogCtx);
                          final uri = Uri.parse(info.downloadUrl);
                          if (await canLaunchUrl(uri)) {
                            await launchUrl(uri, mode: LaunchMode.externalApplication);
                          } else {
                            if (context.mounted) {
                              GlassSnackBar.show(context, 'Could not open download link: ${info.downloadUrl}');
                            }
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
