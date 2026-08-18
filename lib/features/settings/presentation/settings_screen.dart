import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_logo_provider.dart';
import '../../../../core/theme/font_provider.dart' hide secureStorageProvider;
import '../../../../core/providers/feature_toggles_provider.dart';
import '../../../core/theme/velvet_colors.dart';
import '../../../core/security/auth_service.dart';
import '../../../core/i18n/app_translation.dart';
import '../../../shared_widgets/clay_card.dart';
import '../../../shared_widgets/glass_section_header.dart';
import '../../../shared_widgets/app_introduction_sheet.dart';
import 'package:velvet/core/sounds/sound_service.dart';
import '../../../core/haptics/haptic_service.dart';
import 'package:velvet/core/backup/google_backup_service.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../shared_widgets/glass_snackbar.dart';
import '../../../shared_widgets/gita_shloka_dialog.dart';
import 'widgets/github_connection_card.dart';
import 'widgets/ai_keys_byok_card.dart';
import '../../../shared_widgets/cyber_command_launcher.dart';
import '../../../shared_widgets/animated_theme_switcher.dart';
import '../../../shared_widgets/pariyojana_blueprint_header.dart';
import '../../../shared_widgets/help_pariyojana_grow_badge.dart';
import '../../../../core/profile/user_profile_provider.dart';
import '../../../shared_widgets/anti_forensics_dialog.dart';
import '../../../shared_widgets/workspace_tab_guide_modal.dart';
import '../../../../core/services/update_checker_service.dart';


class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _biometricsEnabled = false;
  bool _notifyIdea = true;
  bool _notifyProject = true;
  bool _notifyPaper = true;
  bool _notifyJob = true;
  int _startHour = 9;
  int _endHour = 22;
  bool _isLoading = false;
  bool _isGoogleSignedIn = false;
  String? _googleUserEmail;
  bool _googleSyncLoading = false;

  @override
  void initState() {
    super.initState();
    // Instant sync from SharedPreferences (0ms delay)
    try {
      final prefs = ref.read(sharedPreferencesProvider);
      _biometricsEnabled = prefs.getBool('velvet_biometrics_enabled') ?? false;
      _notifyIdea = prefs.getBool('velvet_notify_idea_vault') ?? true;
      _notifyProject = prefs.getBool('velvet_notify_project_stale') ?? true;
      _notifyPaper = prefs.getBool('velvet_notify_research_paper') ?? true;
      _notifyJob = prefs.getBool('velvet_notify_job_application') ?? true;
      _isGoogleSignedIn = prefs.getBool('velvet_google_signed_in') ?? false;
      _googleUserEmail = prefs.getString('velvet_google_user_email');
      _startHour = prefs.getInt('pariyojana_notif_start_hour') ?? 9;
      _endHour = prefs.getInt('pariyojana_notif_end_hour') ?? 22;
    } catch (_) {}
    _loadSettings();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _loadSettings() async {
    try {
      final secureStorage = ref.read(secureStorageProvider);
      final backupService = ref.read(googleBackupServiceProvider);
      final prefs = ref.read(sharedPreferencesProvider);

      final results = await Future.wait([
        secureStorage.isBiometricsEnabled(),
        secureStorage.isNotifyIdeaVaultEnabled(),
        secureStorage.isNotifyProjectStaleEnabled(),
        secureStorage.isNotifyResearchPaperEnabled(),
        secureStorage.isNotifyJobApplicationEnabled(),
        backupService.isUserSignedIn(),
        backupService.getUserEmail(),
        secureStorage.getNotificationStartHour(),
        secureStorage.getNotificationEndHour(),
      ]);

      if (mounted) {
        setState(() {
          _biometricsEnabled = results[0] as bool;
          _notifyIdea = results[1] as bool;
          _notifyProject = results[2] as bool;
          _notifyPaper = results[3] as bool;
          _notifyJob = results[4] as bool;
          _isGoogleSignedIn = results[5] as bool;
          _googleUserEmail = results[6] as String?;
          _startHour = results[7] as int;
          _endHour = results[8] as int;
          _isLoading = false;
        });

        // Sync to SharedPreferences for zero-lag subsequent loads
        unawaited(prefs.setBool('velvet_biometrics_enabled', _biometricsEnabled));
        unawaited(prefs.setBool('velvet_notify_idea_vault', _notifyIdea));
        unawaited(prefs.setBool('velvet_notify_project_stale', _notifyProject));
        unawaited(prefs.setBool('velvet_notify_research_paper', _notifyPaper));
        unawaited(prefs.setBool('velvet_notify_job_application', _notifyJob));
        unawaited(prefs.setBool('velvet_google_signed_in', _isGoogleSignedIn));
        if (_googleUserEmail != null) {
          unawaited(prefs.setString('velvet_google_user_email', _googleUserEmail!));
        }
        unawaited(prefs.setInt('pariyojana_notif_start_hour', _startHour));
        unawaited(prefs.setInt('pariyojana_notif_end_hour', _endHour));
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showIntroGuideSheet() {
    showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const AppIntroductionSheet(),
    );
  }

  void _showTechnicalSecurityModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final isDark = Theme.of(ctx).brightness == Brightness.dark;
        return Container(
          height: MediaQuery.of(ctx).size.height * 0.78,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: isDark ? VelvetColors.darkSurface : VelvetColors.cream,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(width: 36, height: 4, decoration: BoxDecoration(color: VelvetColors.border(ctx), borderRadius: BorderRadius.circular(2))),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Icon(Icons.shield_rounded, color: VelvetColors.coralPeach, size: 24),
                  const SizedBox(width: 10),
                  Text(
                    'Privacy & Technical Security 🔒',
                    style: TextStyle(fontFamily: GoogleFonts.outfit().fontFamily, fontSize: 18, fontWeight: FontWeight.bold, color: VelvetColors.textPrimary(ctx)),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text('Zero-Knowledge local encryption architecture specifications.', style: TextStyle(fontSize: 12, color: VelvetColors.textSecondary(ctx))),
              const SizedBox(height: 18),
              Expanded(
                child: ListView(
                  children: [
                    _buildSecSpecItem(ctx, '🗄️ SQLCipher 256-bit DB Encryption', 'All sqlite tables (ideas, projects, papers, jobs) encrypted at rest with SQLCipher 256-bit AES-CBC key.'),
                    _buildSecSpecItem(ctx, '🔑 Android KeyStore & Hardware Security Module (HSM)', 'Session keys wrapped inside Android TEE / StrongBox Hardware Security Module via flutter_secure_storage.'),
                    _buildSecSpecItem(ctx, '🛡️ DRM Digital Rights Protection & Memory Hygiene', 'Sensitive memory buffers zeroed immediately after use. FLAG_SECURE prevents screenshot capture on vault screens.'),
                    _buildSecSpecItem(ctx, '🔐 RSA-2048 Session Key Backup Wrapping', 'Cloud backups encrypted with RSA-2048 public key before reaching Google Drive AppData folder.'),
                    _buildSecSpecItem(ctx, '🆔 Google Auth & Zero-Telemetry Guarantee', 'OAuth2 token authentication restricted to app-private storage. Zero telemetry, zero analytics tracking, zero ads.'),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSecSpecItem(BuildContext ctx, String title, String desc) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: ClayCard(
        color: VelvetColors.surface(ctx),
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: VelvetColors.textPrimary(ctx))),
            const SizedBox(height: 4),
            Text(desc, style: TextStyle(fontSize: 11.5, color: VelvetColors.textSecondary(ctx), height: 1.45)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: VelvetColors.iconColor(context)),
          onPressed: () => context.pop(),
        ),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: Theme.of(context).brightness == Brightness.dark
                      ? const [
                          VelvetColors.darkBg,
                          VelvetColors.darkSurface,
                          VelvetColors.darkBg,
                        ]
                      : const [
                          VelvetColors.cream,
                          Color(0xFFF6ECE1),
                          Color(0xFFFFF2EE),
                        ],
                ),
              ),
            ),
          ),
          SafeArea(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: VelvetColors.coralPeach),
                  )
                : SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 12),
                        TranslatedText(
                          'Settings & System Matrix ⚙️',
                          style: Theme.of(context).textTheme.displayMedium,
                        ),
                        const SizedBox(height: 6),
                        TranslatedText(
                          'Executive configuration, cryptographic vault & AI orchestrator.',
                          style: TextStyle(
                            color: VelvetColors.textSecondary(context),
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // ── 1. Executive Profile & Digital Identity ───────────────
                        const _EditableUserProfileCard(),
                        const SizedBox(height: 24),

                        // ── 2. Digital Identity & Cloud Sync ──────────────────────
                        const GlassSectionHeader(
                          title: 'Digital Identity & Cloud Sync',
                          icon: Icons.cloud_sync_rounded,
                        ),
                        const SizedBox(height: 12),
                        _buildGoogleCloudSyncCard(context),
                        const SizedBox(height: 14),
                        const AiKeysByokCard(),
                        const SizedBox(height: 14),
                        const GitHubConnectionCard(),
                        const SizedBox(height: 24),

                        // ── 3. Interface, Typography & Audio Experience ───────────
                        const GlassSectionHeader(
                          title: 'Interface, Typography & Audio',
                          icon: Icons.palette_rounded,
                        ),
                        const SizedBox(height: 12),
                        _buildMasterSoundCard(context),
                        const SizedBox(height: 14),
                        _buildThemeAccentCard(context),
                        const SizedBox(height: 14),
                        _buildTypographySelector(context),
                        const SizedBox(height: 12),
                        _buildAppLogoSelector(context),
                        const SizedBox(height: 12),
                        _buildVadyaMusicSection(context),
                        const SizedBox(height: 12),
                        _buildOptionalFeatureToggles(context),
                        const SizedBox(height: 24),

                        // ── 4. Cryptographic Vault & Threat Defense ───────────────
                        const GlassSectionHeader(
                          title: 'Cryptographic Vault & Threat Defense',
                          icon: Icons.security_rounded,
                        ),
                        const SizedBox(height: 12),
                        _buildSecurityPill(context),
                        const SizedBox(height: 12),
                        _buildBiometricUnlockTile(context),
                        const SizedBox(height: 12),
                        _buildSettingItem(
                          context,
                          icon: Icons.gavel_rounded,
                          title: 'Anti-Forensics & Reverse Engineering Shield 🛡️',
                          subtitle: 'RSA-2048 integrity seal, Frida / Hook detection & zero-knowledge RAM scrub',
                          onTap: () => AntiForensicsDialog.show(context),
                          trailing: Icon(Icons.arrow_forward_ios_rounded, size: 14, color: VelvetColors.iconColor(context)),
                        ),
                        const SizedBox(height: 12),
                        _buildSettingItem(
                          context,
                          icon: Icons.shield_rounded,
                          title: 'Privacy & Technical Security Architecture 🔒',
                          subtitle: 'Inspect encryption standards, SQLCipher, DRM & RAM hygiene specs',
                          onTap: () => _showTechnicalSecurityModal(context),
                          trailing: Icon(Icons.arrow_forward_ios_rounded, size: 14, color: VelvetColors.iconColor(context)),
                        ),
                        const SizedBox(height: 12),
                        _buildBatteryExemptionTile(context),
                        const SizedBox(height: 12),
                        _buildNotificationSettings(context),
                        const SizedBox(height: 24),

                        // ── 5. Executive Blueprint & Workspace Guides ─────────────
                        const GlassSectionHeader(
                          title: 'Executive Blueprint & Deep Feature Guides',
                          icon: Icons.auto_stories_rounded,
                        ),
                        const SizedBox(height: 12),
                        _buildIntroGuideCard(context),
                        const SizedBox(height: 12),
                        _buildWorkspacePillarsGuideCard(context),
                        const SizedBox(height: 24),

                        // ── 6. Wisdom, Culture & Security Tools ────────
                        const GlassSectionHeader(
                          title: 'Wisdom, Culture & Security Tools',
                          icon: Icons.shield_rounded,
                        ),
                        const SizedBox(height: 12),
                        _buildGitaGuidanceSection(context),
                        const SizedBox(height: 12),
                        _buildLanguageSettingItem(context),
                        const SizedBox(height: 20),
                        const _DeveloperInfoCard(),
                        const SizedBox(height: 20),
                        _buildVaultLogoutCard(context),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // Helper Section Builders
  // ─────────────────────────────────────────────────────────────────────────────

  Widget _buildGoogleCloudSyncCard(BuildContext context) {
    return ClayCard(
      color: VelvetColors.cardSurface(context),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.cloud_upload_outlined,
                  color: VelvetColors.iconColor(context), size: 24),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Google Cloud Sync & Encrypted Drive Backup',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: VelvetColors.textPrimary(context)),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _isGoogleSignedIn
                          ? 'Linked to $_googleUserEmail'
                          : 'Backup database to Google Drive AppData folder',
                      style: TextStyle(
                          fontSize: 12,
                          color: VelvetColors.textSecondary(context)),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.spaceBetween,
            children: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: VelvetColors.surface(context),
                  foregroundColor: VelvetColors.textPrimary(context),
                  elevation: 1,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: VelvetColors.border(context)),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                ),
                onPressed: _googleSyncLoading
                    ? null
                    : () async {
                        setState(() => _googleSyncLoading = true);
                        final backupService = ref.read(googleBackupServiceProvider);
                        try {
                          if (_isGoogleSignedIn) {
                            final confirm = await showDialog<bool>(
                              context: context,
                              builder: (context) => AlertDialog(
                                backgroundColor: VelvetColors.surface(context),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                title: Text('Sign Out?', style: TextStyle(color: VelvetColors.textPrimary(context), fontWeight: FontWeight.bold)),
                                content: Text('Disconnect from Google Drive backups? Local database changes will not sync.', style: TextStyle(color: VelvetColors.textPrimary(context))),
                                actions: [
                                  OutlinedButton(
                                    style: OutlinedButton.styleFrom(foregroundColor: VelvetColors.textPrimary(context)),
                                    onPressed: () => Navigator.of(context).pop(false),
                                    child: const Text('Cancel'),
                                  ),
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(backgroundColor: VelvetColors.coralPeach, foregroundColor: Colors.white),
                                    onPressed: () => Navigator.of(context).pop(true),
                                    child: const Text('Yes, Sign Out'),
                                  ),
                                ],
                              ),
                            );
                            if (confirm != true) return;

                            await backupService.signOut();
                            setState(() {
                              _isGoogleSignedIn = false;
                              _googleUserEmail = null;
                            });
                            if (context.mounted) {
                              GlassSnackBar.show(context, 'Signed out of Google account. 👋');
                            }
                          } else {
                            try {
                              final success = await backupService.signIn();
                              if (success) {
                                final email = await backupService.getUserEmail();
                                setState(() {
                                  _isGoogleSignedIn = true;
                                  _googleUserEmail = email;
                                });
                                if (context.mounted) {
                                  GlassSnackBar.show(context, 'Successfully signed in with Google! 🎉');
                                }
                              } else {
                                if (context.mounted) {
                                  GlassSnackBar.show(context, 'Sign-in cancelled. Try again.');
                                }
                              }
                            } catch (signInError) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: const Text('Google Sign-In needs SHA-1 registered in Firebase. Tap to use email instead.'),
                                    action: SnackBarAction(
                                      label: 'Use Email',
                                      onPressed: () => _showSettingsFallbackEmailDialog(context, backupService),
                                    ),
                                    duration: const Duration(seconds: 6),
                                  ),
                                );
                              }
                            }
                          }
                        } catch (e) {
                          if (context.mounted) {
                            GlassSnackBar.show(context, 'Auth error: $e ⚠️');
                          }
                        } finally {
                          setState(() => _googleSyncLoading = false);
                        }
                      },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (!_isGoogleSignedIn) ...[
                      Platform.environment.containsKey('FLUTTER_TEST')
                          ? Icon(Icons.g_mobiledata, color: VelvetColors.textPrimary(context), size: 18)
                          : SvgPicture.network(
                              'https://www.vectorlogo.zone/logos/google/google-icon.svg',
                              width: 18,
                              height: 18,
                              placeholderBuilder: (BuildContext context) => const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(strokeWidth: 1.5, color: Colors.blue),
                              ),
                            ),
                      const SizedBox(width: 8),
                    ],
                    Text(
                      _isGoogleSignedIn ? 'Sign Out' : 'Sign In with Google',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: VelvetColors.textPrimary(context)),
                    ),
                  ],
                ),
              ),
              if (_isGoogleSignedIn) ...[
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: VelvetColors.periwinkle,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  ),
                  icon: _googleSyncLoading
                      ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Icon(Icons.sync, size: 16),
                  label: const Text('Sync Now'),
                  onPressed: _googleSyncLoading
                      ? null
                      : () async {
                          setState(() => _googleSyncLoading = true);
                          final backupService = ref.read(googleBackupServiceProvider);
                          try {
                            final success = await backupService.backupDatabaseToDrive();
                            if (success) {
                              if (context.mounted) {
                                GlassSnackBar.show(context, 'Database backup synced successfully! ☁️');
                              }
                            } else {
                              if (context.mounted) {
                                GlassSnackBar.show(context, 'Cloud sync failed. Check settings. ⚠️');
                              }
                            }
                          } catch (e) {
                            if (context.mounted) {
                              GlassSnackBar.show(context, 'Sync failed: $e ⚠️');
                            }
                          } finally {
                            setState(() => _googleSyncLoading = false);
                          }
                        },
                ),
              ] else ...[
                Text(
                  'Sign in with Google first to enable sync →',
                  style: TextStyle(fontSize: 11, color: VelvetColors.textSecondary(context), fontStyle: FontStyle.italic),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMasterSoundCard(BuildContext context) {
    return Consumer(
      builder: (context, ref, _) {
        final isSoundEnabled = ref.watch(masterSoundEnabledProvider);
        return ClayCard(
          color: VelvetColors.surface(context),
          padding: const EdgeInsets.all(18),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Icon(
                      isSoundEnabled ? Icons.volume_up_rounded : Icons.volume_off_rounded,
                      color: isSoundEnabled ? VelvetColors.coralPeach : VelvetColors.textSecondary(context),
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Master App Audio & Voice AI',
                            style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.bold, color: VelvetColors.textPrimary(context)),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            isSoundEnabled ? 'All music, Pariyojana voice & UI sounds ENABLED' : 'App audio, music & voice sounds MUTED',
                            style: TextStyle(fontSize: 10.5, color: VelvetColors.textSecondary(context)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Switch.adaptive(
                value: isSoundEnabled,
                activeThumbColor: VelvetColors.coralPeach,
                onChanged: (val) {
                  ref.read(masterSoundEnabledProvider.notifier).state = val;
                  GlassSnackBar.show(context, val ? '🔊 Sound FX Enabled' : 'Sound FX Disabled');
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildThemeAccentCard(BuildContext context) {
    return Consumer(
      builder: (context, ref, _) {
        final activeAccent = ref.watch(themeAccentProvider);
        final accentColor = VelvetColors.getAccentColor(activeAccent);
        return ClayCard(
          color: VelvetColors.surface(context),
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: accentColor.withValues(alpha: 0.18),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.palette_rounded, size: 20, color: accentColor),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Theme Color Accent 🎨',
                          style: TextStyle(
                            fontFamily: GoogleFonts.outfit().fontFamily,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: VelvetColors.textPrimary(context),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Personalize Pariyojana workspace visual accent',
                          style: TextStyle(
                            fontFamily: GoogleFonts.outfit().fontFamily,
                            fontSize: 11,
                            color: VelvetColors.textSecondary(context),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Consumer(
                    builder: (context, ref, _) {
                      final currentThemeMode = ref.watch(appThemeModeProvider);
                      final isDark = currentThemeMode == ThemeMode.dark;
                      return AnimatedThemeSwitcher(
                        isDarkMode: isDark,
                        onChanged: (toDark) {
                          ref.read(hapticServiceProvider).lightTap();
                          ref.read(appThemeModeProvider.notifier).setMode(toDark ? ThemeMode.dark : ThemeMode.light);
                          if (toDark) {
                            ref.read(themeAccentProvider.notifier).setAccent(ThemeAccent.cyberObsidian);
                          } else {
                            ref.read(themeAccentProvider.notifier).setAccent(ThemeAccent.velvetCocoa);
                          }
                          GlassSnackBar.show(context, toDark ? '🌙 Dark Mode Activated' : '☀️ Light Mode Activated');
                        },
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                alignment: WrapAlignment.start,
                children: [
                  _buildThemeChip(ref, ThemeAccent.velvetCocoa, 'Velvet Coral 🌸', VelvetColors.coralPeach, activeAccent == ThemeAccent.velvetCocoa),
                  _buildThemeChip(ref, ThemeAccent.sunsetOrange, 'Sunset Orange 🍊', const Color(0xFFFF6D00), activeAccent == ThemeAccent.sunsetOrange),
                  _buildThemeChip(ref, ThemeAccent.pureWhite, 'Pure White 🏳️', const Color(0xFFF8FAFC), activeAccent == ThemeAccent.pureWhite),
                  _buildThemeChip(ref, ThemeAccent.warmLatte, 'Warm Latte ☕', const Color(0xFFD7CCC8), activeAccent == ThemeAccent.warmLatte),
                  _buildThemeChip(ref, ThemeAccent.cyberObsidian, 'Cyber Cyan ⚡', const Color(0xFF00E5FF), activeAccent == ThemeAccent.cyberObsidian),
                  _buildThemeChip(ref, ThemeAccent.vedicGold, 'Vedic Gold ⚜️', const Color(0xFFD4AF37), activeAccent == ThemeAccent.vedicGold),
                  _buildThemeChip(ref, ThemeAccent.emeraldMint, 'Emerald Mint 🌿', const Color(0xFF10B981), activeAccent == ThemeAccent.emeraldMint),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTypographySelector(BuildContext context) {
    return Consumer(
      builder: (context, ref, _) {
        final currentFont = ref.watch(appFontProvider);
        return _buildSettingItem(
          context,
          icon: Icons.font_download_rounded,
          title: 'App Font & Typography 🔤✨',
          subtitle: 'Custom typography for full app (${currentFont.displayName})',
          onTap: () {
            FocusManager.instance.primaryFocus?.unfocus();
            _showFontPickerSheet(context, ref);
          },
          trailing: GestureDetector(
            onTap: () {
              FocusManager.instance.primaryFocus?.unfocus();
              _showFontPickerSheet(context, ref);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: VelvetColors.periwinkle.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: VelvetColors.periwinkle),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.text_format_rounded, size: 14, color: VelvetColors.iconColor(context)),
                  const SizedBox(width: 4),
                  Text(
                    currentFont.displayName,
                    style: TextStyle(color: VelvetColors.textPrimary(context), fontWeight: FontWeight.bold, fontSize: 11),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAppLogoSelector(BuildContext context) {
    return _buildSettingItem(
      context,
      icon: Icons.auto_awesome_mosaic_rounded,
      title: 'Dynamic App Logo & Icon Switcher 🎨🔥',
      subtitle: 'Personalize launcher icon aesthetic (Cocoa, Cyber, Gold, Sunset, White)',
      trailing: GestureDetector(
        onTap: () => _showAppLogoPicker(context, ref),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: VelvetColors.coralPeach.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: VelvetColors.coralPeach),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(AppLogoHelper.getLogoIcon(ref.watch(appLogoProvider)), size: 14, color: VelvetColors.iconColor(context)),
              const SizedBox(width: 4),
              Text(
                AppLogoHelper.getLogoName(ref.watch(appLogoProvider)),
                style: TextStyle(color: VelvetColors.textPrimary(context), fontWeight: FontWeight.bold, fontSize: 11),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVadyaMusicSection(BuildContext context) {
    return Column(
      children: [
        _buildSettingItem(
          context,
          icon: Icons.music_note_rounded,
          title: 'Vadya Music Player 🎵',
          subtitle: 'Ambient instrumental music while working (Default OFF)',
          trailing: Consumer(
            builder: (context, ref, _) {
              final musicAsync = ref.watch(vadyaMusicProvider);
              final isMusicEnabled = musicAsync.valueOrNull ?? false;
              return Switch.adaptive(
                value: isMusicEnabled,
                activeThumbColor: VelvetColors.coralPeach,
                onChanged: (val) {
                  ref.read(vadyaMusicProvider.notifier).toggle(val);
                  ref.read(vadyaMusicEnabledProvider.notifier).state = val;
                },
              );
            },
          ),
        ),
        Consumer(
          builder: (context, ref, _) {
            final musicAsync = ref.watch(vadyaMusicProvider);
            final isMusicEnabled = musicAsync.valueOrNull ?? false;
            if (!isMusicEnabled) return const SizedBox.shrink();
            final volAsync = ref.watch(vadyaVolumeProvider);
            final volume = volAsync.valueOrNull ?? 0.7;
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
              child: Row(
                children: [
                  const Icon(Icons.volume_down_rounded, size: 18, color: VelvetColors.coralPeach),
                  Expanded(
                    child: Slider(
                      value: volume,
                      min: 0.0,
                      max: 1.0,
                      divisions: 10,
                      activeColor: VelvetColors.coralPeach,
                      inactiveColor: VelvetColors.coralPeach.withValues(alpha: 0.25),
                      onChanged: (val) {
                        ref.read(vadyaVolumeProvider.notifier).setVolume(val);
                        ref.read(soundServiceProvider).setMusicVolume(val);
                      },
                    ),
                  ),
                  const Icon(Icons.volume_up_rounded, size: 18, color: VelvetColors.coralPeach),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () => ref.read(soundServiceProvider).playRandomSong(),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(colors: [VelvetColors.coralPeach, VelvetColors.periwinkle]),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Text('▶ New Song', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildOptionalFeatureToggles(BuildContext context) {
    return Builder(
      builder: (context) {
        final toggles = ref.watch(featureTogglesProvider);
        return Column(
          children: [
            _buildSettingItem(
              context,
              icon: Icons.terminal_rounded,
              title: 'Command Centre Terminal 💻',
              subtitle: 'Enable OS companion command terminal shell (Default: OFF)',
              onTap: () => CyberCommandLauncher.show(context),
              trailing: Switch(
                value: toggles.isCmdCentreEnabled,
                onChanged: (val) {
                  ref.read(featureTogglesProvider.notifier).setCmdCentreEnabled(val);
                  GlassSnackBar.show(context, val ? '💻 Command Terminal Enabled' : 'Command Terminal Disabled');
                },
                activeThumbColor: VelvetColors.coralPeach,
                activeTrackColor: VelvetColors.coralPeach.withValues(alpha: 0.5),
              ),
            ),
            const SizedBox(height: 12),
            _buildSettingItem(
              context,
              icon: Icons.psychology_rounded,
              title: 'Mitnick AI Assistant 🧠',
              subtitle: 'Enable autonomous AI agent assistant chat (Default: OFF)',
              trailing: Switch(
                value: toggles.isMitnickAiEnabled,
                onChanged: (val) {
                  ref.read(featureTogglesProvider.notifier).setMitnickAiEnabled(val);
                  GlassSnackBar.show(context, val ? '🧠 Mitnick AI Assistant Enabled' : 'Mitnick AI Disabled');
                },
                activeThumbColor: VelvetColors.coralPeach,
                activeTrackColor: VelvetColors.coralPeach.withValues(alpha: 0.5),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSecurityPill(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: VelvetColors.periwinkle.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: VelvetColors.periwinkle.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.speed_rounded, color: VelvetColors.periwinkle, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Performance & Privacy Commitment: Pariyojana executes heavy encryption, SQLCipher DB indexing, and AI operations asynchronously on secondary background threads. App responsiveness remains 100% fast and smooth.',
              style: TextStyle(fontSize: 10.5, color: VelvetColors.textPrimary(context).withValues(alpha: 0.8), height: 1.35),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBiometricUnlockTile(BuildContext context) {
    return _buildSettingItem(
      context,
      icon: Icons.fingerprint,
      title: 'Biometric Unlock',
      subtitle: 'Gate vault behind fingerprint or PIN unlock',
      trailing: Switch(
        value: _biometricsEnabled,
        onChanged: (val) async {
          final secureStorage = ref.read(secureStorageProvider);
          await secureStorage.setBiometricsEnabled(val);
          setState(() => _biometricsEnabled = val);
          if (context.mounted) {
            GlassSnackBar.show(context, val ? '🔒 Biometric Unlock Enabled' : 'Biometric Unlock Disabled');
          }
        },
        activeThumbColor: VelvetColors.coralPeach,
        activeTrackColor: VelvetColors.coralPeach.withValues(alpha: 0.5),
      ),
    );
  }

  Widget _buildBatteryExemptionTile(BuildContext context) {
    return _buildSettingItem(
      context,
      icon: Icons.battery_saver_rounded,
      title: 'Unrestricted Background Execution 🔋⚡',
      subtitle: 'Allow Pariyojana AI agents to fetch & process data uninterrupted',
      trailing: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: VelvetColors.coralPeach,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        onPressed: () async {
          const MethodChannel channel = MethodChannel('com.navii.velvet/icon');
          try {
            await channel.invokeMethod('openBatterySettings');
            if (context.mounted) GlassSnackBar.show(context, 'Opened Android Battery Exemption Settings ⚡');
          } catch (_) {
            if (context.mounted) GlassSnackBar.show(context, 'Background execution active for Pariyojana ⚡');
          }
        },
        child: const Text('Grant ⚡', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildNotificationSettings(BuildContext context) {
    return Column(
      children: [
        _buildSettingItem(
          context,
          icon: Icons.lightbulb_outline,
          title: 'Idea Vault Reminders',
          subtitle: 'Nudge when no new ideas captured in 3 days',
          trailing: Switch(
            value: _notifyIdea,
            onChanged: (val) async {
              final secureStorage = ref.read(secureStorageProvider);
              await secureStorage.setNotifyIdeaVault(val);
              setState(() => _notifyIdea = val);
              if (context.mounted) GlassSnackBar.show(context, val ? '💡 Idea Vault Reminders Enabled' : 'Idea Reminders Disabled');
            },
            activeThumbColor: VelvetColors.coralPeach,
            activeTrackColor: VelvetColors.coralPeach.withValues(alpha: 0.5),
          ),
        ),
        const SizedBox(height: 12),
        _buildSettingItem(
          context,
          icon: Icons.warning_amber_rounded,
          title: 'Project Stale Alerts',
          subtitle: 'Nudge when active projects stagnate for 7+ days',
          trailing: Switch(
            value: _notifyProject,
            onChanged: (val) async {
              final secureStorage = ref.read(secureStorageProvider);
              await secureStorage.setNotifyProjectStale(val);
              setState(() => _notifyProject = val);
              if (context.mounted) GlassSnackBar.show(context, val ? '⚠️ Project Stale Alerts Enabled' : 'Project Alerts Disabled');
            },
            activeThumbColor: VelvetColors.coralPeach,
            activeTrackColor: VelvetColors.coralPeach.withValues(alpha: 0.5),
          ),
        ),
        const SizedBox(height: 12),
        _buildSettingItem(
          context,
          icon: Icons.assignment_late_outlined,
          title: 'Research Paper Stall Alerts',
          subtitle: 'Nudge when papers stall in Preliminary Upload',
          trailing: Switch(
            value: _notifyPaper,
            onChanged: (val) async {
              final secureStorage = ref.read(secureStorageProvider);
              await secureStorage.setNotifyResearchPaper(val);
              setState(() => _notifyPaper = val);
              if (context.mounted) GlassSnackBar.show(context, val ? '📄 Research Stall Alerts Enabled' : 'Research Alerts Disabled');
            },
            activeThumbColor: VelvetColors.coralPeach,
            activeTrackColor: VelvetColors.coralPeach.withValues(alpha: 0.5),
          ),
        ),
        const SizedBox(height: 12),
        _buildSettingItem(
          context,
          icon: Icons.mail_outline,
          title: 'Job Follow-up Nudges',
          subtitle: 'Nudge when outreach follow-ups are due',
          trailing: Switch(
            value: _notifyJob,
            onChanged: (val) async {
              final secureStorage = ref.read(secureStorageProvider);
              await secureStorage.setNotifyJobApplication(val);
              setState(() => _notifyJob = val);
              if (context.mounted) GlassSnackBar.show(context, val ? '📬 Job Follow-up Alerts Enabled' : 'Job Follow-up Disabled');
            },
            activeThumbColor: VelvetColors.coralPeach,
            activeTrackColor: VelvetColors.coralPeach.withValues(alpha: 0.5),
          ),
        ),
        const SizedBox(height: 12),
        _buildSettingItem(
          context,
          icon: Icons.access_time_filled_rounded,
          title: 'Notification Time Window',
          subtitle: 'Daily quiet hours & alert schedule (${_formatHour(_startHour)} – ${_formatHour(_endHour)})',
          trailing: GestureDetector(
            onTap: () => _showNotificationTimePicker(context),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: VelvetColors.coralPeach.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: VelvetColors.coralPeach.withValues(alpha: 0.4)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${_formatHour(_startHour)} – ${_formatHour(_endHour)}',
                    style: TextStyle(color: VelvetColors.textPrimary(context), fontWeight: FontWeight.w600, fontSize: 12),
                  ),
                  const SizedBox(width: 4),
                  Icon(Icons.edit_rounded, color: VelvetColors.iconColor(context), size: 14),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildIntroGuideCard(BuildContext context) {
    return ClayCard(
      color: VelvetColors.periwinkle.withValues(alpha: 0.7),
      padding: const EdgeInsets.all(20.0),
      child: Row(
        children: [
          Icon(Icons.auto_awesome_motion_rounded, size: 36, color: VelvetColors.iconColor(context)),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Executive App Blueprint & Philosophy Deck 🚀',
                  style: TextStyle(
                    fontFamily: GoogleFonts.outfit().fontFamily,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: VelvetColors.textPrimary(context),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '5-Slide Visual Carousel covering system pillars, Sacred Gita philosophy, and power controls.',
                  style: TextStyle(fontSize: 11.5, color: VelvetColors.textSecondary(context)),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.arrow_forward_ios_rounded, size: 18, color: VelvetColors.iconColor(context)),
            onPressed: _showIntroGuideSheet,
          ),
        ],
      ),
    );
  }

  Widget _buildWorkspacePillarsGuideCard(BuildContext context) {
    return ClayCard(
      color: VelvetColors.cardSurface(context),
      padding: const EdgeInsets.all(20.0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: VelvetColors.coralPeach.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.menu_book_rounded, size: 26, color: VelvetColors.coralPeach),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Workspace Pillars & Deep Feature Guide 📚',
                  style: TextStyle(
                    fontFamily: GoogleFonts.outfit().fontFamily,
                    fontSize: 14.5,
                    fontWeight: FontWeight.bold,
                    color: VelvetColors.textPrimary(context),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Explore all 24 core capabilities across Ideas, Projects, Research & 5-Stage Job Tracker.',
                  style: TextStyle(fontSize: 11.5, color: VelvetColors.textSecondary(context)),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.arrow_forward_ios_rounded, size: 18, color: VelvetColors.iconColor(context)),
            onPressed: () => WorkspaceTabGuideModal.show(context),
          ),
        ],
      ),
    );
  }





  Widget _buildGitaGuidanceSection(BuildContext context) {
    return _buildSettingItem(
      context,
      icon: Icons.wb_sunny_rounded,
      title: 'Bhagavad Gita Startup Shloka 🕉️',
      subtitle: 'Display sacred Gita guidance & reflection when app opens',
      trailing: Consumer(
        builder: (context, ref, _) {
          final isEnabled = ref.watch(gitaShlokaEnabledProvider);
          return Switch.adaptive(
            value: isEnabled,
            activeThumbColor: VelvetColors.coralPeach,
            onChanged: (val) {
              ref.read(gitaShlokaEnabledProvider.notifier).toggle(val);
            },
          );
        },
      ),
    );
  }

  Widget _buildLanguageSettingItem(BuildContext context) {
    return _buildSettingItem(
      context,
      icon: Icons.language,
      title: 'App Language & Localization',
      subtitle: 'Switch via Google Translate (${kSupportedLanguages.length} languages)',
      trailing: GestureDetector(
        onTap: () => _showLanguagePicker(context, ref),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: VelvetColors.coralPeach.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: VelvetColors.coralPeach.withValues(alpha: 0.4)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _getCurrentLanguageName(ref.watch(languageProvider)),
                style: TextStyle(
                  color: VelvetColors.textPrimary(context),
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
              const SizedBox(width: 4),
              Icon(Icons.arrow_drop_down, color: VelvetColors.iconColor(context), size: 18),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVaultLogoutCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.redAccent.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.redAccent.withValues(alpha: 0.35),
          width: 1.2,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.redAccent.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.logout_rounded, color: Colors.redAccent, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Log Out of Vault',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: VelvetColors.textPrimary(context)),
                ),
                const SizedBox(height: 2),
                Text(
                  'Lock local database and sign out of active session',
                  style: TextStyle(fontSize: 11, color: VelvetColors.textSecondary(context)),
                ),
              ],
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            ),
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  backgroundColor: VelvetColors.surface(ctx),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  title: Row(
                    children: [
                      const Icon(Icons.logout_rounded, color: Color(0xFFEF4444)),
                      const SizedBox(width: 10),
                      Text('Log Out of Vault?', style: TextStyle(fontWeight: FontWeight.bold, color: VelvetColors.textPrimary(ctx))),
                    ],
                  ),
                  content: Text(
                    'This will lock your encrypted vault and end your session. You will need your Master PIN to enter.',
                    style: TextStyle(fontSize: 13, color: VelvetColors.textPrimary(ctx).withValues(alpha: 0.8)),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, false),
                      child: Text('Cancel', style: TextStyle(color: VelvetColors.textSecondary(ctx))),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFEF4444),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: () => Navigator.pop(ctx, true),
                      child: const Text('Log Out', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              );

              if (confirm == true && context.mounted) {
                await ref.read(authServiceProvider.notifier).logout();
                await ref.read(userProfileProvider.notifier).clearProfile();
                try { await ref.read(googleBackupServiceProvider).signOut(); } catch (_) {}
                if (context.mounted) {
                  GoRouter.of(context).go('/login');
                }
              }
            },
            child: const Text('Log Out', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return ClayCard(
      color: VelvetColors.surface(context),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      onTap: onTap,
      child: Row(
        children: [
          Icon(icon, color: VelvetColors.iconColor(context), size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TranslatedText(
                  title,
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: VelvetColors.textPrimary(context)),
                ),
                const SizedBox(height: 2),
                TranslatedText(
                  subtitle,
                  style: TextStyle(
                      fontSize: 12,
                      color: VelvetColors.textSecondary(context)),
                ),
              ],
            ),
          ),
          if (trailing != null) trailing,
        ],
      ),
    );
  }

  String _formatHour(int hour) {
    if (hour == 0) return '12 AM';
    if (hour == 12) return '12 PM';
    if (hour < 12) return '$hour AM';
    return '${hour - 12} PM';
  }

  void _showNotificationTimePicker(BuildContext context) {
    int tempStart = _startHour;
    int tempEnd = _endHour;

    showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) {
          return Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: VelvetColors.surface(context),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.access_time_rounded, color: VelvetColors.coralPeach, size: 24),
                    const SizedBox(width: 10),
                    Text(
                      'Notification Quiet Hours',
                      style: TextStyle(
                        fontFamily: GoogleFonts.outfit().fontFamily,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: VelvetColors.textPrimary(context),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  'Set the active time window for hourly project and career reminders.',
                  style: TextStyle(fontSize: 12, color: VelvetColors.textSecondary(context)),
                ),
                const SizedBox(height: 20),

                // Start Hour Selector
                InkWell(
                  onTap: () async {
                    final picked = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay(hour: tempStart, minute: 0),
                    );
                    if (picked != null) {
                      setModalState(() => tempStart = picked.hour);
                    }
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: VelvetColors.cardSurface(context),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: VelvetColors.border(context)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.wb_sunny_outlined, size: 20, color: VelvetColors.coralPeach),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Start Active Hours', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: VelvetColors.textPrimary(context))),
                                const SizedBox(height: 2),
                                Text('Tap to choose start time', style: TextStyle(fontSize: 10, color: VelvetColors.textSecondary(context))),
                              ],
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: VelvetColors.coralPeach.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: VelvetColors.coralPeach.withValues(alpha: 0.4)),
                          ),
                          child: Text(
                            _formatHour(tempStart),
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: VelvetColors.coralPeach),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // End Hour Selector
                InkWell(
                  onTap: () async {
                    final picked = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay(hour: tempEnd, minute: 0),
                    );
                    if (picked != null) {
                      setModalState(() => tempEnd = picked.hour);
                    }
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: VelvetColors.cardSurface(context),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: VelvetColors.border(context)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.nightlight_round, size: 20, color: VelvetColors.periwinkle),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('End Active Hours', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: VelvetColors.textPrimary(context))),
                                const SizedBox(height: 2),
                                Text('Tap to choose quiet time', style: TextStyle(fontSize: 10, color: VelvetColors.textSecondary(context))),
                              ],
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: VelvetColors.periwinkle.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: VelvetColors.periwinkle.withValues(alpha: 0.4)),
                          ),
                          child: Text(
                            _formatHour(tempEnd),
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: VelvetColors.periwinkle),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Save button
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: VelvetColors.coralPeach,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    onPressed: () async {
                      final storage = ref.read(secureStorageProvider);
                      await storage.setNotificationStartHour(tempStart);
                      await storage.setNotificationEndHour(tempEnd);
                      setState(() {
                        _startHour = tempStart;
                        _endHour = tempEnd;
                      });
                      if (context.mounted) {
                        Navigator.pop(context);
                        GlassSnackBar.show(context, '⏰ Notification schedule updated! (${_formatHour(tempStart)} – ${_formatHour(tempEnd)})');
                      }
                    },
                    child: const Text('Save Schedule ⏰', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }



  String _getCurrentLanguageName(String code) {
    try {
      return kSupportedLanguages.firstWhere((l) => l.code == code).nativeName;
    } catch (_) {
      return 'English';
    }
  }

  void _showLanguagePicker(BuildContext context, WidgetRef ref) {
    final currentCode = ref.read(languageProvider);
    showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.65,
        maxChildSize: 0.9,
        minChildSize: 0.4,
        builder: (_, controller) => Container(
          decoration: BoxDecoration(
            color: VelvetColors.surface(context),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: VelvetColors.border(context),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Choose Language',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: VelvetColors.textPrimary(context)),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: ListView.builder(
                  controller: controller,
                  itemCount: kSupportedLanguages.length,
                  itemBuilder: (_, i) {
                    final lang = kSupportedLanguages[i];
                    final isSelected = lang.code == currentCode &&
                        lang.nativeName == _getCurrentLanguageName(currentCode);
                    return ListTile(
                      title: Text(
                        lang.nativeName,
                        style: TextStyle(
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.w600,
                          color: isSelected
                              ? VelvetColors.coralPeach
                              : VelvetColors.textPrimary(context),
                          fontSize: 16,
                        ),
                      ),
                      subtitle: Text(
                        lang.name,
                        style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: isSelected
                                ? VelvetColors.coralPeach.withValues(alpha: 0.95)
                                : VelvetColors.textSecondary(context)),
                      ),
                      trailing: isSelected
                          ? const Icon(Icons.check_circle,
                              color: VelvetColors.coralPeach)
                          : null,
                      onTap: () {
                        ref
                            .read(languageProvider.notifier)
                            .changeLanguage(lang.code);
                        Navigator.pop(ctx);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildThemeChip(WidgetRef ref, ThemeAccent accent, String label, Color color, bool isSelected) {
    return InkWell(
      onTap: () {
        ref.read(hapticServiceProvider).lightTap();
        ref.read(themeAccentProvider.notifier).setAccent(accent);
        GlassSnackBar.show(context, '🎨 Theme Accent: $label');
      },
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.2) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isSelected ? color : VelvetColors.border(context), width: isSelected ? 1.8 : 1.0),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontFamily: GoogleFonts.outfit().fontFamily,
                fontSize: 10.5,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: VelvetColors.textPrimary(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAppLogoPicker(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      backgroundColor: VelvetColors.surface(context),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) {
        final currentLogo = ref.watch(appLogoProvider);
        return SizedBox(
          height: 480,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: VelvetColors.border(context),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text('Select Dynamic App Logo & Theme 🎨🔥', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: VelvetColors.textPrimary(context))),
                const SizedBox(height: 4),
                Text('Personalize the app icon aesthetic across Pariyojana workspace.', style: TextStyle(fontSize: 11.5, color: VelvetColors.textSecondary(context))),
                const SizedBox(height: 18),
                Expanded(
                  child: GridView.builder(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 2.2,
                    ),
                    itemCount: AppLogoStyle.values.length,
                    itemBuilder: (context, index) {
                      final style = AppLogoStyle.values[index];
                      final isSelected = style == currentLogo;
                      return GestureDetector(
                        onTap: () async {
                          await HapticFeedback.selectionClick();
                          await ref.read(appLogoProvider.notifier).setStyle(style);
                          if (context.mounted) Navigator.pop(context);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: isSelected ? VelvetColors.coralPeach.withValues(alpha: 0.15) : VelvetColors.surface(context),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: isSelected ? VelvetColors.coralPeach : VelvetColors.border(context),
                              width: isSelected ? 2 : 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: VelvetColors.coralPeach.withValues(alpha: 0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(AppLogoHelper.getLogoIcon(style), color: VelvetColors.iconColor(context), size: 18),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  AppLogoHelper.getLogoName(style),
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                    color: isSelected ? VelvetColors.coralPeach : VelvetColors.textPrimary(context),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showSettingsFallbackEmailDialog(BuildContext ctx, GoogleBackupService backupService) {
    final emailController = TextEditingController();
    showDialog(
      context: ctx,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: VelvetColors.surface(ctx),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Google Auth Assist 🔑', style: TextStyle(fontWeight: FontWeight.bold, color: VelvetColors.textPrimary(ctx))),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Google Play Services needs the app SHA-1 registered in Firebase. Enter your Gmail to link your account locally:',
              style: TextStyle(fontSize: 12, color: VelvetColors.textSecondary(ctx)),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              autofocus: true,
              style: TextStyle(color: VelvetColors.textPrimary(ctx)),
              decoration: InputDecoration(
                hintText: 'user@gmail.com',
                labelText: 'Google Email',
                prefixIcon: const Icon(Icons.email_outlined, size: 18, color: VelvetColors.coralPeach),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              emailController.dispose();
              Navigator.pop(dialogCtx);
            },
            child: Text('Cancel', style: TextStyle(color: VelvetColors.textSecondary(ctx))),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: VelvetColors.coralPeach,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () async {
              final email = emailController.text.trim();
              if (email.isNotEmpty && email.contains('@')) {
                await backupService.simulateSignIn(email);
                if (mounted) {
                  setState(() {
                    _isGoogleSignedIn = true;
                    _googleUserEmail = email;
                  });
                }
                emailController.dispose();
                if (dialogCtx.mounted) {
                  Navigator.pop(dialogCtx);
                  GlassSnackBar.show(ctx, '✅ Signed in as $email (local mode)');
                }
              }
            },
            child: const Text('Sign In With Email'),
          ),
        ],
      ),
    );
  }

}

class _UserProfileCard extends ConsumerWidget {
  const _UserProfileCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ClayCard(
      color: VelvetColors.surface(context),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.terminal_rounded, color: VelvetColors.coralPeach, size: 20),
              const SizedBox(width: 8),
              Text(
                'About Developer ⚡',
                style: TextStyle(fontFamily: GoogleFonts.outfit().fontFamily, fontSize: 14, fontWeight: FontWeight.bold, color: VelvetColors.textPrimary(context)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: VelvetColors.surface(context).withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: VelvetColors.border(context)),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: VelvetColors.coralPeach.withValues(alpha: 0.2),
                  child: const Text(
                    'NT',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: VelvetColors.coralPeach),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Naveen Telasang',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: VelvetColors.textPrimary(context)),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Security Researcher & Mobile Developer',
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: VelvetColors.textSecondary(context)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              InkWell(
                onTap: () async {
                  await HapticFeedback.vibrate();
                  final uri = Uri.parse('https://github.com/Naveen-21-Cyber');
                  await launchUrl(uri, mode: LaunchMode.externalApplication);
                },
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: VelvetColors.textPrimary(context).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.code_rounded, size: 14, color: VelvetColors.textPrimary(context)),
                      const SizedBox(width: 6),
                      Text(
                        'GitHub',
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: VelvetColors.textPrimary(context), decoration: TextDecoration.underline),
                      ),
                    ],
                  ),
                ),
              ),
              InkWell(
                onTap: () async {
                  await HapticFeedback.vibrate();
                  final uri = Uri.parse('https://cyberbuddy.gt.tc/');
                  await launchUrl(uri, mode: LaunchMode.externalApplication);
                },
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.teal.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.language_rounded, size: 14, color: Colors.teal),
                      SizedBox(width: 6),
                      Text(
                        'CyberBuddy',
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.teal, decoration: TextDecoration.underline),
                      ),
                    ],
                  ),
                ),
              ),
              InkWell(
                onTap: () async {
                  await HapticFeedback.vibrate();
                  final uri = Uri.parse('https://naveencyber.gt.tc/');
                  await launchUrl(uri, mode: LaunchMode.externalApplication);
                },
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: VelvetColors.coralPeach.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.security_rounded, size: 14, color: VelvetColors.coralPeach),
                      SizedBox(width: 6),
                      Text(
                        'NaveenCyber',
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: VelvetColors.coralPeach, decoration: TextDecoration.underline),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DeveloperInfoCard extends ConsumerWidget {
  const _DeveloperInfoCard();

  Widget _buildVersionItem(BuildContext context, WidgetRef ref) {
    return ClayCard(
      color: VelvetColors.surface(context),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        children: [
          Row(
            children: [
              Icon(Icons.info_outline_rounded, color: VelvetColors.iconColor(context), size: 24),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TranslatedText(
                      'Version & Updates',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: VelvetColors.textPrimary(context)),
                    ),
                    const SizedBox(height: 2),
                    TranslatedText(
                      'Pariyojana v1.1.0 (Production Release)',
                      style: TextStyle(
                          fontSize: 12,
                          color: VelvetColors.textSecondary(context)),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: VelvetColors.coralPeach.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'v1.1.0',
                  style: TextStyle(
                    fontFamily: GoogleFonts.jetBrainsMono().fontFamily,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    color: VelvetColors.coralPeach,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: VelvetColors.coralPeach,
              foregroundColor: Colors.white,
              minimumSize: const Size.fromHeight(40),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 2,
            ),
            icon: const Icon(Icons.sync_rounded, size: 16),
            label: const Text('Check for Updates 🚀', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
            onPressed: () async {
              GlassSnackBar.show(context, 'Checking GitHub for latest releases... 📡');
              final updateService = ref.read(updateCheckerServiceProvider);
              final info = await updateService.checkForUpdate(notifyUserIfAvailable: true);
              if (context.mounted) {
                if (info != null && info.isUpdateAvailable) {
                  UpdateCheckerService.showUpdateDialog(context, info);
                } else {
                  GlassSnackBar.show(context, '✨ Pariyojana is up to date! (v${info?.currentVersion ?? "1.1.0"})');
                }
              }
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        // 1st: Version Info
        _buildVersionItem(context, ref),
        const SizedBox(height: 16),
        // 2nd: PARIYOJANA OS Blueprint Header
        const PariyojanaBlueprintHeader(height: 120, authorTag: 'PARIYOJANA OS'),
        const SizedBox(height: 16),
        // 3rd: User Profile & Signature Card (recreated Dev Profile -> User Profile)
        const _UserProfileCard(),
        const SizedBox(height: 16),
        // 4th: Standalone Open-Source Growth Badge
        const Center(
          child: HelpPariyojanaGrowBadge(
            targetUrl: 'https://pariyojana.gt.tc/',
            text: 'Visit Official Pariyojana Website 🌐',
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}

class _EditableUserProfileCard extends ConsumerWidget {
  const _EditableUserProfileCard();

  static const List<List<Color>> _bannerGradients = [
    [Color(0xFFFF6B6B), Color(0xFFFF8E53), Color(0xFFFE8C00)], // Cyber Sunset
    [Color(0xFF232526), Color(0xFF414345), Color(0xFFF59E0B)], // Obsidian Gold
    [Color(0xFF059669), Color(0xFF10B981), Color(0xFF34D399)], // Emerald Tech
    [Color(0xFF4A00E0), Color(0xFF8E2DE2), Color(0xFF00C9FF)], // Aurora Borealis
    [Color(0xFF833AB4), Color(0xFFFD1D1D), Color(0xFFFCB045)], // Cosmic Neon
    [Color(0xFF1E3C72), Color(0xFF2A5298), Color(0xFF7F00FF)], // Royal Velvet
  ];

  void _showEditProfileDialog(BuildContext context, WidgetRef ref, UserProfile profile) {
    final nameCtrl = TextEditingController(text: profile.fullName);
    final titleCtrl = TextEditingController(text: profile.title);
    final portfolioCtrl = TextEditingController(text: profile.portfolioUrl);
    final githubCtrl = TextEditingController(text: profile.githubUrl);
    int selectedBanner = profile.bannerIndex.clamp(0, _bannerGradients.length - 1);
    String selectedAvatar = profile.avatarUrl;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetCtx) => StatefulBuilder(
        builder: (context, setModalState) {
          final isDark = Theme.of(context).brightness == Brightness.dark;
          final bottomInset = MediaQuery.of(sheetCtx).viewInsets.bottom;

          return Padding(
            padding: EdgeInsets.only(bottom: bottomInset),
            child: Container(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.88,
              ),
              decoration: BoxDecoration(
                color: VelvetColors.surface(context),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
                border: Border.all(color: VelvetColors.border(context)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.4 : 0.15),
                    blurRadius: 24,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 12),
                  // Drag handle
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: VelvetColors.border(context),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Header
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(7),
                          decoration: BoxDecoration(
                            color: VelvetColors.coralPeach.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.badge_rounded, color: VelvetColors.coralPeach, size: 20),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Edit Profile & Identity',
                            style: TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 16,
                              color: VelvetColors.textPrimary(context),
                            ),
                          ),
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: VelvetColors.coralPeach,
                            foregroundColor: Colors.white,
                            elevation: 2,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          ),
                          onPressed: () async {
                            await ref.read(userProfileProvider.notifier).updateProfile(
                              fullName: nameCtrl.text.trim(),
                              title: titleCtrl.text.trim(),
                              portfolioUrl: portfolioCtrl.text.trim(),
                              githubUrl: githubCtrl.text.trim(),
                              avatarUrl: selectedAvatar,
                              bannerIndex: selectedBanner,
                            );
                            if (sheetCtx.mounted) Navigator.pop(sheetCtx);
                            if (context.mounted) GlassSnackBar.show(context, 'Profile & Bio updated! 👤✨');
                          },
                          child: const Text('Save', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12.5)),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Divider(height: 1, color: VelvetColors.border(context)),

                  // Scrollable Content with Keyboard Inset Protection
                  Flexible(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                      physics: const BouncingScrollPhysics(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Banner Theme Selector
                          Text(
                            'Banner Color Palette 🎨',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: VelvetColors.textPrimary(context)),
                          ),
                          const SizedBox(height: 8),
                          SizedBox(
                            height: 36,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: _bannerGradients.length,
                              itemBuilder: (context, idx) {
                                final isSel = selectedBanner == idx;
                                return GestureDetector(
                                  onTap: () => setModalState(() => selectedBanner = idx),
                                  child: Container(
                                    width: 48,
                                    margin: const EdgeInsets.only(right: 8),
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(colors: _bannerGradients[idx]),
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                        color: isSel ? Colors.white : Colors.transparent,
                                        width: isSel ? 2 : 1,
                                      ),
                                      boxShadow: isSel
                                          ? [
                                              BoxShadow(
                                                color: _bannerGradients[idx].first.withValues(alpha: 0.6),
                                                blurRadius: 6,
                                              ),
                                            ]
                                          : null,
                                    ),
                                    child: isSel
                                        ? const Icon(Icons.check_rounded, color: Colors.white, size: 16)
                                        : null,
                                  ),
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: 14),

                          // Avatar Persona Selector Header with Google Photo Option
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Avatar Persona 👤',
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: VelvetColors.textPrimary(context)),
                              ),
                              // 1-Tap Google Account Profile Picture Button
                              GestureDetector(
                                onTap: () async {
                                  try {
                                    if (context.mounted) {
                                      GlassSnackBar.show(context, 'Syncing Google Account Photo... 🌐');
                                    }
                                    final photoUrl = await ref.read(userProfileProvider.notifier).syncGooglePhoto();
                                    if (photoUrl != null && photoUrl.isNotEmpty) {
                                      setModalState(() => selectedAvatar = photoUrl);
                                      if (context.mounted) {
                                        GlassSnackBar.show(context, 'Google Photo linked successfully! 📷✨');
                                      }
                                    } else {
                                      // Check if there is already a saved photo or email prefix
                                      final savedAvatar = await ref.read(secureStorageProvider).getAvatarUrl();
                                      if (savedAvatar != null && savedAvatar.startsWith('http')) {
                                        setModalState(() => selectedAvatar = savedAvatar);
                                        if (context.mounted) {
                                          GlassSnackBar.show(context, 'Set Google Account Photo 📷✨');
                                        }
                                      } else if (context.mounted) {
                                        GlassSnackBar.show(context, 'Signed in! (No public profile photo found on this Google account)');
                                      }
                                    }
                                  } catch (e) {
                                    if (context.mounted) {
                                      GlassSnackBar.show(context, 'Google Photo sync: $e');
                                    }
                                  }
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
                                  decoration: BoxDecoration(
                                    color: selectedAvatar.startsWith('http')
                                        ? VelvetColors.coralPeach.withValues(alpha: 0.2)
                                        : VelvetColors.cardSurface(context),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: selectedAvatar.startsWith('http')
                                          ? VelvetColors.coralPeach
                                          : VelvetColors.border(context),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.account_circle_outlined, size: 13, color: VelvetColors.coralPeach),
                                      const SizedBox(width: 4),
                                      Text(
                                        'Use Google Photo 🌐',
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                          color: VelvetColors.textPrimary(context),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),

                          // Avatar Persona Horizontal Carousel
                          SizedBox(
                            height: 38,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: kAvatarPresets.length,
                              itemBuilder: (context, idx) {
                                final preset = kAvatarPresets[idx];
                                final isSel = selectedAvatar == preset.emoji;
                                return GestureDetector(
                                  onTap: () => setModalState(() => selectedAvatar = preset.emoji),
                                  child: Container(
                                    margin: const EdgeInsets.only(right: 8),
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: isSel ? VelvetColors.coralPeach.withValues(alpha: 0.2) : VelvetColors.cardSurface(context),
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                        color: isSel ? VelvetColors.coralPeach : VelvetColors.border(context),
                                        width: isSel ? 1.6 : 1,
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(preset.emoji, style: const TextStyle(fontSize: 15)),
                                        const SizedBox(width: 4),
                                        Text(
                                          preset.label,
                                          style: TextStyle(
                                            fontSize: 10.5,
                                            fontWeight: isSel ? FontWeight.w900 : FontWeight.w600,
                                            color: VelvetColors.textPrimary(context),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: 14),

                          // 1-Tap Quick Bio Suggestions Carousel
                          Text(
                            'Quick Bio Presets ⚡',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: VelvetColors.textPrimary(context)),
                          ),
                          const SizedBox(height: 8),
                          SizedBox(
                            height: 32,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: kBioPresets.length,
                              itemBuilder: (context, idx) {
                                final bio = kBioPresets[idx];
                                return Padding(
                                  padding: const EdgeInsets.only(right: 6),
                                  child: ActionChip(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 0),
                                    label: Text(bio, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: VelvetColors.textPrimary(context))),
                                    backgroundColor: VelvetColors.cardSurface(context),
                                    side: BorderSide(color: VelvetColors.border(context)),
                                    onPressed: () {
                                      titleCtrl.text = bio;
                                      setModalState(() {});
                                    },
                                  ),
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: 14),

                          // Inputs
                          TextField(
                            controller: nameCtrl,
                            style: TextStyle(color: VelvetColors.textPrimary(context), fontSize: 13.5),
                            decoration: InputDecoration(
                              labelText: 'Full Name',
                              labelStyle: TextStyle(color: VelvetColors.textSecondary(context), fontSize: 12),
                              hintText: 'e.g. Alex Mercer',
                              filled: true,
                              fillColor: VelvetColors.cardSurface(context),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: VelvetColors.border(context))),
                              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: VelvetColors.border(context))),
                            ),
                          ),
                          const SizedBox(height: 10),

                          TextField(
                            controller: titleCtrl,
                            style: TextStyle(color: VelvetColors.textPrimary(context), fontSize: 13.5),
                            decoration: InputDecoration(
                              labelText: 'Bio & Engineering Focus',
                              labelStyle: TextStyle(color: VelvetColors.textSecondary(context), fontSize: 12),
                              hintText: 'e.g. Full-Stack Architect',
                              filled: true,
                              fillColor: VelvetColors.cardSurface(context),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: VelvetColors.border(context))),
                              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: VelvetColors.border(context))),
                            ),
                          ),
                          const SizedBox(height: 10),

                          TextField(
                            controller: portfolioCtrl,
                            style: TextStyle(color: VelvetColors.textPrimary(context), fontSize: 13.5),
                            decoration: InputDecoration(
                              labelText: 'Portfolio / Website URL',
                              labelStyle: TextStyle(color: VelvetColors.textSecondary(context), fontSize: 12),
                              hintText: 'https://...',
                              filled: true,
                              fillColor: VelvetColors.cardSurface(context),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: VelvetColors.border(context))),
                              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: VelvetColors.border(context))),
                            ),
                          ),
                          const SizedBox(height: 10),

                          TextField(
                            controller: githubCtrl,
                            style: TextStyle(color: VelvetColors.textPrimary(context), fontSize: 13.5),
                            decoration: InputDecoration(
                              labelText: 'GitHub Profile URL',
                              labelStyle: TextStyle(color: VelvetColors.textSecondary(context), fontSize: 12),
                              hintText: 'https://github.com/...',
                              filled: true,
                              fillColor: VelvetColors.cardSurface(context),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: VelvetColors.border(context))),
                              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: VelvetColors.border(context))),
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(userProfileProvider);
    final cardColor = VelvetColors.cardSurface(context);
    final textColor = VelvetColors.textPrimary(context);

    final bannerColors = _bannerGradients[profile.bannerIndex.clamp(0, _bannerGradients.length - 1)];

    final initials = profile.displayName.isNotEmpty
        ? profile.displayName.split(' ').map((e) => e.isNotEmpty ? e[0] : '').take(2).join().toUpperCase()
        : 'U';

    final isEmojiAvatar = profile.avatarUrl.isNotEmpty && profile.avatarUrl.runes.length <= 4 && !profile.avatarUrl.startsWith('http');
    final isHttpAvatar = profile.avatarUrl.startsWith('http');

    return ClayCard(
      color: cardColor,
      padding: EdgeInsets.zero,
      borderRadius: 24,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Top Curved Glossy Banner with Executive Badge & Edit Button
          Container(
            height: 76,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: bannerColors,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Stack(
              children: [
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.white.withValues(alpha: 0.2),
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.15),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                    ),
                  ),
                ),
                Positioned(
                  top: 10,
                  left: 14,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.35),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.verified_rounded, size: 12, color: Colors.white),
                        SizedBox(width: 4),
                        Text(
                          'COMMAND CENTER ID',
                          style: TextStyle(
                            fontSize: 9.5,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.0,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.35),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.edit_rounded, size: 16, color: Colors.white),
                      onPressed: () => _showEditProfileDialog(context, ref, profile),
                      tooltip: 'Edit Profile & Bio',
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 2. Profile Details & Overlapping Avatar Badge
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Transform.translate(
                  offset: const Offset(0, -26),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      // Avatar Badge with Halo
                      Container(
                        padding: const EdgeInsets.all(3.5),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: VelvetColors.surface(context),
                          boxShadow: [
                            BoxShadow(
                              color: bannerColors.first.withValues(alpha: 0.4),
                              blurRadius: 10,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Container(
                          padding: const EdgeInsets.all(2.5),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(colors: bannerColors),
                          ),
                          child: isHttpAvatar
                              ? CircleAvatar(
                                  radius: 28,
                                  backgroundImage: NetworkImage(profile.avatarUrl),
                                  backgroundColor: VelvetColors.surface(context),
                                )
                              : isEmojiAvatar
                                  ? CircleAvatar(
                                      radius: 28,
                                      backgroundColor: VelvetColors.surface(context),
                                      child: Text(profile.avatarUrl, style: const TextStyle(fontSize: 26)),
                                    )
                                  : CircleAvatar(
                                      radius: 28,
                                      backgroundColor: VelvetColors.surface(context),
                                      child: Text(
                                        initials,
                                        style: TextStyle(
                                          fontWeight: FontWeight.w900,
                                          fontSize: 18,
                                          color: bannerColors.first,
                                        ),
                                      ),
                                    ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 2),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                profile.displayName,
                                style: TextStyle(
                                  fontSize: 16.5,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: -0.3,
                                  color: textColor,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                profile.title.isNotEmpty ? profile.title : 'Tech Innovator & Project Builder',
                                style: const TextStyle(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w700,
                                  color: VelvetColors.coralPeach,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                Transform.translate(
                  offset: const Offset(0, -14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Social & Proof of Work Chips
                      if (profile.githubUrl.isNotEmpty || profile.portfolioUrl.isNotEmpty) ...[
                        Wrap(
                          spacing: 8,
                          runSpacing: 6,
                          children: [
                            if (profile.githubUrl.isNotEmpty)
                              InkWell(
                                onTap: () => launchUrl(Uri.parse(profile.githubUrl), mode: LaunchMode.externalApplication),
                                borderRadius: BorderRadius.circular(10),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4.5),
                                  decoration: BoxDecoration(
                                    color: VelvetColors.coralPeach.withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(color: VelvetColors.coralPeach.withValues(alpha: 0.4)),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.code_rounded, size: 13, color: textColor),
                                      const SizedBox(width: 5),
                                      Text(
                                        profile.githubUsername.isNotEmpty ? 'github.com/${profile.githubUsername}' : 'GitHub',
                                        style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: textColor),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            if (profile.portfolioUrl.isNotEmpty)
                              InkWell(
                                onTap: () => launchUrl(Uri.parse(profile.portfolioUrl), mode: LaunchMode.externalApplication),
                                borderRadius: BorderRadius.circular(10),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4.5),
                                  decoration: BoxDecoration(
                                    color: VelvetColors.mint.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(color: VelvetColors.mint.withValues(alpha: 0.5)),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.language_rounded, size: 13, color: textColor),
                                      const SizedBox(width: 5),
                                      Text(
                                        'Portfolio 🌐',
                                        style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: textColor),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 10),
                      ],

                      // Hardware-Locked Vault Security Tag
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: VelvetColors.surface(context),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: VelvetColors.border(context)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.lock_outline_rounded, size: 12, color: VelvetColors.coralPeach),
                                const SizedBox(width: 6),
                                Text(
                                  'SQLCipher AES-256 Vault Protected',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    color: VelvetColors.textSecondary(context),
                                  ),
                                ),
                              ],
                            ),
                            Text(
                              'HARDWARE ENCLAVE',
                              style: TextStyle(
                                fontFamily: GoogleFonts.jetBrainsMono().fontFamily,
                                fontSize: 8.5,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0.8,
                                color: VelvetColors.coralPeach,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

void _showFontPickerSheet(BuildContext context, WidgetRef ref) {
  showModalBottomSheet(
    context: context,
    useRootNavigator: true,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (sheetCtx) {
      final currentFont = ref.watch(appFontProvider);
      return SafeArea(
        child: Container(
          margin: const EdgeInsets.all(12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: VelvetColors.surface(context),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: VelvetColors.periwinkle.withValues(alpha: 0.4), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.25),
                blurRadius: 20,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.font_download_rounded, color: VelvetColors.periwinkle, size: 22),
                      const SizedBox(width: 8),
                      Text(
                        'Select App Typography 🔤',
                        style: TextStyle(fontFamily: GoogleFonts.outfit().fontFamily, fontWeight: FontWeight.bold, fontSize: 16, color: VelvetColors.textPrimary(context)),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: Icon(Icons.close_rounded, size: 20, color: VelvetColors.iconColor(context)),
                    onPressed: () => Navigator.pop(sheetCtx),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                'Customize the font across the entire application interface.',
                style: TextStyle(fontSize: 11, color: VelvetColors.textSecondary(context)),
              ),
              const SizedBox(height: 14),
              Flexible(
                child: ListView(
                  shrinkWrap: true,
                  physics: const BouncingScrollPhysics(),
                  children: AppFontFamily.values.map((f) {
                    final isSelected = f == currentFont;
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      decoration: BoxDecoration(
                        color: isSelected ? VelvetColors.periwinkle.withValues(alpha: 0.15) : VelvetColors.cardSurface(context),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isSelected ? VelvetColors.periwinkle : VelvetColors.border(context),
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: ListTile(
                        dense: true,
                        leading: Icon(
                          isSelected ? Icons.check_circle_rounded : Icons.text_fields_rounded,
                          color: isSelected ? VelvetColors.periwinkle : VelvetColors.iconColor(context),
                          size: 20,
                        ),
                        title: Text(
                          f.displayName,
                          style: TextStyle(
                            fontFamily: GoogleFonts.getFont(f.googleFontName).fontFamily,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: VelvetColors.textPrimary(context),
                          ),
                        ),
                        subtitle: Text(
                          f.description,
                          style: TextStyle(fontSize: 10.5, color: VelvetColors.textSecondary(context)),
                        ),
                        onTap: () {
                          ref.read(appFontProvider.notifier).setFont(f);
                          Navigator.pop(sheetCtx);
                          GlassSnackBar.show(context, 'Applied typography: ${f.displayName} 🔤✨');
                        },
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}
