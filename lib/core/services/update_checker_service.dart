import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:open_file/open_file.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
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
  final bool hasApkAsset;
  final DateTime? releaseDate;

  const UpdateInfo({
    required this.currentVersion,
    required this.latestVersion,
    required this.title,
    required this.releaseNotes,
    required this.downloadUrl,
    required this.isUpdateAvailable,
    this.hasApkAsset = false,
    this.releaseDate,
  });
}

final updateCheckerServiceProvider = Provider<UpdateCheckerService>((ref) {
  return UpdateCheckerService(ref);
});

class UpdateCheckerService {
  static const String _repoOwner = 'Naveen-21-Cyber';
  static const String _repoName = 'Pariyojana-Mobile-App-';
  static const String _lastNotifiedVersionKey = 'last_notified_update_version';

  final Ref _ref;
  final Dio _dio;
  final FlutterSecureStorage _storage;

  UpdateCheckerService(this._ref)
      : _dio = Dio(BaseOptions(
          connectTimeout: const Duration(seconds: 8),
          receiveTimeout: const Duration(seconds: 30),
          headers: {'Accept': 'application/vnd.github.v3+json'},
        )),
        _storage = const FlutterSecureStorage();

  /// Returns the live app version from pubspec.yaml (via package_info_plus).
  static Future<String> currentAppVersion() async {
    try {
      final info = await PackageInfo.fromPlatform();
      if (info.version.isNotEmpty) return info.version;
    } catch (_) {}
    return '1.1.1';
  }

  /// Check GitHub Releases API for the latest published version.
  Future<UpdateInfo?> checkForUpdate({bool notifyUserIfAvailable = true}) async {
    final appVersion = await currentAppVersion();
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

        // Find APK asset for in-app direct install
        String downloadUrl = htmlUrl;
        bool hasApk = false;
        if (data['assets'] is List && (data['assets'] as List).isNotEmpty) {
          for (final asset in data['assets'] as List) {
            final assetUrl = asset['browser_download_url'] as String?;
            if (assetUrl != null && assetUrl.endsWith('.apk')) {
              downloadUrl = assetUrl;
              hasApk = true;
              break;
            }
          }
        }

        final isAvailable = _compareVersions(tagName, appVersion) > 0;

        final updateInfo = UpdateInfo(
          currentVersion: appVersion,
          latestVersion: tagName.isNotEmpty ? tagName : appVersion,
          title: name,
          releaseNotes: body,
          downloadUrl: downloadUrl,
          isUpdateAvailable: isAvailable,
          hasApkAsset: hasApk,
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
    return UpdateInfo(
      currentVersion: appVersion,
      latestVersion: appVersion,
      title: 'Up to Date',
      releaseNotes: 'You are running the latest version of Pariyojana (v$appVersion).',
      downloadUrl: 'https://github.com/$_repoOwner/$_repoName/releases',
      isUpdateAvailable: false,
    );
  }

  /// Dispatches a local system notification informing the user of the new update.
  Future<void> _dispatchUpdateNotification(UpdateInfo info) async {
    try {
      final notifService = _ref.read(notificationServiceProvider);
      await notifService.showNotification(
        id: 99901,
        title: '🚀 New Update v${info.latestVersion} Available!',
        body: 'Pariyojana v${info.latestVersion} is ready. Tap to download and install — no store needed!',
        payload: 'update:${info.downloadUrl}',
      );
    } catch (e) {
      debugPrint('Error dispatching update notification: $e');
    }
  }

  /// Compares two semver strings: returns 1 if v1 > v2, -1 if v1 < v2, 0 if equal.
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

  // ─── In-App OTA Download + Install ──────────────────────────────────────────

  /// Downloads the APK to the cache directory and triggers the Android installer.
  /// Shows a progress dialog inside the app — user never leaves.
  static Future<void> downloadAndInstall(
    BuildContext context,
    UpdateInfo info,
  ) async {
    if (!info.hasApkAsset) {
      // Fall back to browser if no APK asset exists
      final uri = Uri.parse(info.downloadUrl);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
      return;
    }

    // Show the download progress dialog
    if (!context.mounted) return;
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => _OtaDownloadDialog(info: info),
    );
  }

  /// Displays the in-app Update Prompt Dialog with the OTA install flow.
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
                // ── Header ───────────────────────────────────────────────────
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
                                  style: const TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: VelvetColors.mint,
                                  ),
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

                // ── Release title ─────────────────────────────────────────────
                Text(
                  info.title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: VelvetColors.textPrimary(context),
                  ),
                ),
                const SizedBox(height: 8),

                // ── Release notes ─────────────────────────────────────────────
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
                          : '• Latest security hardening and engine optimizations.\n'
                              '• In-app OTA updates — install without leaving the app.\n'
                              '• Offline-first SQLite performance enhancements.',
                      style: TextStyle(
                        fontSize: 12,
                        height: 1.4,
                        color: VelvetColors.textSecondary(context),
                      ),
                    ),
                  ),
                ),

                // ── OTA badge (if APK is directly available) ──────────────────
                if (info.hasApkAsset) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: VelvetColors.mint.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: VelvetColors.mint.withValues(alpha: 0.3)),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.bolt_rounded, size: 14, color: VelvetColors.mint),
                        SizedBox(width: 4),
                        Text(
                          'Direct install — no Play Store or browser needed',
                          style: TextStyle(
                            fontSize: 11,
                            color: VelvetColors.mint,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 20),

                // ── Action buttons ────────────────────────────────────────────
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
                          style: TextStyle(
                            color: VelvetColors.textSecondary(context),
                            fontWeight: FontWeight.bold,
                          ),
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
                        icon: Icon(
                          info.hasApkAsset
                              ? Icons.download_for_offline_rounded
                              : Icons.open_in_browser_rounded,
                          size: 18,
                        ),
                        label: Text(
                          info.hasApkAsset ? 'Install Update' : 'Download Update',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        onPressed: () async {
                          Navigator.pop(dialogCtx);
                          if (context.mounted) {
                            await downloadAndInstall(context, info);
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

// ─── OTA Download Progress Dialog ────────────────────────────────────────────

class _OtaDownloadDialog extends StatefulWidget {
  final UpdateInfo info;
  const _OtaDownloadDialog({required this.info});

  @override
  State<_OtaDownloadDialog> createState() => _OtaDownloadDialogState();
}

class _OtaDownloadDialogState extends State<_OtaDownloadDialog> {
  double _progress = 0;
  String _statusText = 'Preparing download…';
  bool _isCancelled = false;
  bool _isDone = false;
  bool _hasFailed = false;
  CancelToken? _cancelToken;

  @override
  void initState() {
    super.initState();
    _startDownload();
  }

  @override
  void dispose() {
    _cancelToken?.cancel('Dialog closed');
    super.dispose();
  }

  Future<void> _startDownload() async {
    final dio = Dio(BaseOptions(
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(minutes: 10),
    ));
    _cancelToken = CancelToken();

    try {
      final tempDir = await getTemporaryDirectory();
      final apkPath = '${tempDir.path}/pariyojana_update_v${widget.info.latestVersion}.apk';

      // Clean up any previous partial download
      final existing = File(apkPath);
      if (existing.existsSync()) existing.deleteSync();

      setState(() => _statusText = 'Downloading v${widget.info.latestVersion}…');

      await dio.download(
        widget.info.downloadUrl,
        apkPath,
        cancelToken: _cancelToken,
        onReceiveProgress: (received, total) {
          if (!mounted || _isCancelled) return;
          if (total > 0) {
            setState(() {
              _progress = received / total;
              final mb = (received / 1024 / 1024).toStringAsFixed(1);
              final totalMb = (total / 1024 / 1024).toStringAsFixed(1);
              _statusText = 'Downloading… $mb / $totalMb MB';
            });
          }
        },
      );

      if (_isCancelled) return;

      setState(() {
        _isDone = true;
        _statusText = 'Download complete! Launching installer…';
        _progress = 1.0;
      });

      await Future<void>.delayed(const Duration(milliseconds: 600));

      // Trigger Android package installer with explicit APK MIME type
      final result = await OpenFile.open(
        apkPath,
        type: 'application/vnd.android.package-archive',
      );

      if (!mounted) return;

      // Close the download dialog immediately so user is not blocked
      Navigator.pop(context);

      if (result.type != ResultType.done && mounted) {
        // Fallback: If open_file failed to launch installer, launch via browser/file launcher
        GlassSnackBar.show(context, 'Opening download link in browser…');
        final uri = Uri.parse(widget.info.downloadUrl);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        }
      }
    } on DioException catch (e) {
      if (CancelToken.isCancel(e) || _isCancelled) return;
      if (mounted) {
        setState(() {
          _hasFailed = true;
          _statusText = 'Download failed. Check your connection and try again.';
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _hasFailed = true;
          _statusText = 'Unexpected error: $e';
        });
      }
    }
  }

  void _cancel() {
    _isCancelled = true;
    _cancelToken?.cancel('User cancelled');
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 28, vertical: 40),
      child: Container(
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          color: VelvetColors.cardSurface(context),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: VelvetColors.coralPeach.withValues(alpha: 0.35), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: VelvetColors.coralPeach.withValues(alpha: 0.12),
              blurRadius: 32,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Icon ──────────────────────────────────────────────────────
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    VelvetColors.coralPeach,
                    VelvetColors.coralPeach.withValues(alpha: 0.6),
                  ],
                ),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _isDone
                    ? Icons.check_circle_outline_rounded
                    : _hasFailed
                        ? Icons.error_outline_rounded
                        : Icons.download_for_offline_rounded,
                color: Colors.white,
                size: 32,
              ),
            ),
            const SizedBox(height: 20),

            // ── Title ─────────────────────────────────────────────────────
            Text(
              _isDone
                  ? 'Update Ready!'
                  : _hasFailed
                      ? 'Download Failed'
                      : 'Installing v${widget.info.latestVersion}',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: VelvetColors.textPrimary(context),
              ),
            ),
            const SizedBox(height: 8),

            // ── Status text ───────────────────────────────────────────────
            Text(
              _statusText,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: VelvetColors.textSecondary(context),
                height: 1.4,
              ),
            ),
            const SizedBox(height: 20),

            // ── Progress bar ──────────────────────────────────────────────
            if (!_hasFailed) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: _isDone ? 1.0 : (_progress > 0 ? _progress : null),
                  minHeight: 8,
                  backgroundColor: VelvetColors.border(context),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    _isDone ? VelvetColors.mint : VelvetColors.coralPeach,
                  ),
                ),
              ),
              const SizedBox(height: 6),
              if (_progress > 0 && !_isDone)
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    '${(_progress * 100).toStringAsFixed(0)}%',
                    style: TextStyle(
                      fontSize: 11,
                      color: VelvetColors.textSecondary(context),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
            const SizedBox(height: 20),

            // ── Cancel / Retry button ─────────────────────────────────────
            if (!_isDone)
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    side: BorderSide(color: VelvetColors.border(context)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  onPressed: _hasFailed ? () => Navigator.pop(context) : _cancel,
                  child: Text(
                    _hasFailed ? 'Close' : 'Cancel',
                    style: TextStyle(
                      color: VelvetColors.textSecondary(context),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
