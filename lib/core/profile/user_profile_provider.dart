import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:velvet/core/security/secure_storage_service.dart';
import 'package:velvet/core/security/auth_service.dart';

class UserProfile {
  final String fullName;
  final String title;
  final String portfolioUrl;
  final String githubUrl;
  final String avatarUrl;
  final int bannerIndex;

  const UserProfile({
    required this.fullName,
    required this.title,
    required this.portfolioUrl,
    required this.githubUrl,
    this.avatarUrl = '',
    this.bannerIndex = 0,
  });

  /// Friendly display name — falls back to 'User' if not configured yet.
  String get displayName => fullName.trim().isEmpty ? 'User' : fullName.trim();

  /// True when the user has filled in at least their name.
  bool get isConfigured => fullName.trim().isNotEmpty;

  /// GitHub username parsed from the URL (e.g. 'alice' from 'https://github.com/alice').
  String get githubUsername {
    final uri = Uri.tryParse(githubUrl.trim());
    if (uri == null) return '';
    final segments = uri.pathSegments;
    return segments.isNotEmpty ? segments.first : '';
  }

  UserProfile copyWith({
    String? fullName,
    String? title,
    String? portfolioUrl,
    String? githubUrl,
    String? avatarUrl,
    int? bannerIndex,
  }) {
    return UserProfile(
      fullName: fullName ?? this.fullName,
      title: title ?? this.title,
      portfolioUrl: portfolioUrl ?? this.portfolioUrl,
      githubUrl: githubUrl ?? this.githubUrl,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      bannerIndex: bannerIndex ?? this.bannerIndex,
    );
  }
}

class UserProfileNotifier extends StateNotifier<UserProfile> {
  final SecureStorageService _secureStorage;

  UserProfileNotifier(this._secureStorage)
      : super(const UserProfile(
          fullName: '',
          title: '',
          portfolioUrl: '',
          githubUrl: '',
          avatarUrl: '',
        ));

  /// Load profile from encrypted storage on startup.
  Future<void> loadFromStorage() async {
    final data = await _secureStorage.getUserProfile();
    var fullName = data['fullName'] ?? '';
    final title = data['title'] ?? '';
    final portfolioUrl = data['portfolioUrl'] ?? '';
    final githubUrl = data['githubUrl'] ?? '';
    var avatarUrl = data['avatarUrl'] ?? '';

    // Auto-fallback 1: Username from local registerProfile / PIN setup
    if (fullName.isEmpty) {
      final username = await _secureStorage.getUsername();
      if (username != null && username.trim().isNotEmpty) {
        fullName = username.trim();
      }
    }

    // Auto-fallback 2: Email prefix from Google Sign-In
    if (fullName.isEmpty) {
      final googleEmail = await _secureStorage.getGoogleUserEmailPersisted();
      if (googleEmail != null && googleEmail.trim().isNotEmpty) {
        final emailPrefix = googleEmail.trim().split('@').first;
        fullName = emailPrefix.replaceAll(RegExp(r'[._]'), ' ').trim();
      }
    }

    if (avatarUrl.isEmpty) {
      final savedAvatar = await _secureStorage.getAvatarUrl();
      if (savedAvatar != null && savedAvatar.isNotEmpty) {
        avatarUrl = savedAvatar;
      } else {
        // Try silent sign-in asynchronously — update state once resolved
        // so avatar appears on FIRST launch without needing a restart.
        unawaited(_tryFetchGoogleAvatar(fullName));
      }
    }

    var resolvedTitle = title;
    if (resolvedTitle.isEmpty) {
      resolvedTitle = 'Tech Innovator & Project Builder';
    }

    final bannerIndex = int.tryParse(data['bannerIndex'] ?? '0') ?? 0;

    state = UserProfile(
      fullName: fullName,
      title: resolvedTitle,
      portfolioUrl: portfolioUrl,
      githubUrl: githubUrl,
      avatarUrl: avatarUrl,
      bannerIndex: bannerIndex,
    );
  }

  /// Persist updated profile to encrypted storage.
  Future<void> updateProfile({
    String? fullName,
    String? title,
    String? portfolioUrl,
    String? githubUrl,
    String? avatarUrl,
    int? bannerIndex,
  }) async {
    state = state.copyWith(
      fullName: fullName,
      title: title,
      portfolioUrl: portfolioUrl,
      githubUrl: githubUrl,
      avatarUrl: avatarUrl,
      bannerIndex: bannerIndex,
    );
    await _secureStorage.saveUserProfile(
      fullName: state.fullName,
      title: state.title,
      portfolioUrl: state.portfolioUrl,
      githubUrl: state.githubUrl,
      avatarUrl: state.avatarUrl,
      bannerIndex: state.bannerIndex,
    );
    if (fullName != null && fullName.isNotEmpty) {
      await _secureStorage.saveUsername(fullName);
    }
  }

  /// 1-Tap Google Account Photo Sync
  /// Prompts or uses existing Google Sign-In session, extracts the high-res photo URL,
  /// saves it to secure storage, and immediately updates the live profile state.
  Future<String?> syncGooglePhoto() async {
    try {
      final googleSignIn = GoogleSignIn(
        serverClientId:
            '962236967041-i761g5d908cideg170daha86o7g9r0f5.apps.googleusercontent.com',
        scopes: [
          'https://www.googleapis.com/auth/drive.appdata',
          'email',
        ],
      );

      GoogleSignInAccount? account = googleSignIn.currentUser;
      account ??= await googleSignIn.signInSilently();
      account ??= await googleSignIn.signIn();

      if (account != null) {
        String? photo = account.photoUrl;
        final name = account.displayName;

        if (photo != null && photo.isNotEmpty) {
          // Request higher resolution photo if available from Google
          if (photo.contains('=s96-c')) {
            photo = photo.replaceAll('=s96-c', '=s400-c');
          }
          await _secureStorage.saveAvatarUrl(photo);
        }

        await _secureStorage.setGoogleSignedIn(true);
        await _secureStorage.setGoogleSimulated(false);
        await _secureStorage.setGoogleUserEmail(account.email);

        final updatedName = (state.fullName.isEmpty && name != null && name.isNotEmpty)
            ? name
            : state.fullName;

        state = state.copyWith(
          avatarUrl: photo ?? state.avatarUrl,
          fullName: updatedName.isNotEmpty ? updatedName : state.fullName,
        );

        await _secureStorage.saveUserProfile(
          fullName: state.fullName,
          title: state.title,
          portfolioUrl: state.portfolioUrl,
          githubUrl: state.githubUrl,
          avatarUrl: state.avatarUrl,
        );

        return photo;
      }
    } catch (e) {
      // Non-fatal, handled gracefully by caller
    }
    return null;
  }

  /// Async helper — runs Google silent sign-in in the background and patches
  /// state with the avatar URL once resolved.
  Future<void> _tryFetchGoogleAvatar(String currentFullName) async {
    try {
      final googleSignIn = GoogleSignIn();
      var googleUser = googleSignIn.currentUser;
      googleUser ??= await googleSignIn.signInSilently();
      if (googleUser == null) return;

      String? newAvatar;
      if (googleUser.photoUrl != null && googleUser.photoUrl!.isNotEmpty) {
        newAvatar = googleUser.photoUrl;
        if (newAvatar!.contains('=s96-c')) {
          newAvatar = newAvatar.replaceAll('=s96-c', '=s400-c');
        }
        await _secureStorage.saveAvatarUrl(newAvatar);
      }

      final newName = (currentFullName.isEmpty &&
              googleUser.displayName != null &&
              googleUser.displayName!.isNotEmpty)
          ? googleUser.displayName!
          : null;

      if (newAvatar != null || newName != null) {
        state = state.copyWith(
          avatarUrl: newAvatar ?? state.avatarUrl,
          fullName: newName ?? state.fullName,
        );
      }
    } catch (_) {}
  }

  /// Clear profile from both state and encrypted storage.
  Future<void> clearProfile() async {
    state = const UserProfile(
      fullName: '',
      title: '',
      portfolioUrl: '',
      githubUrl: '',
      avatarUrl: '',
      bannerIndex: 0,
    );
    await _secureStorage.clearUserProfile();
  }
}

class AvatarPreset {
  final String id;
  final String label;
  final String emoji;
  const AvatarPreset({required this.id, required this.label, required this.emoji});
}

class BannerPreset {
  final String name;
  final List<dynamic> colorHexes;
  const BannerPreset({required this.name, required this.colorHexes});
}

const List<AvatarPreset> kAvatarPresets = [
  AvatarPreset(id: 'dev', label: 'Full-Stack Dev', emoji: '👨‍💻'),
  AvatarPreset(id: 'ai_hacker', label: 'AI Hacker', emoji: '🤖'),
  AvatarPreset(id: 'cyber_ninja', label: 'Cyber Defender', emoji: '🥷'),
  AvatarPreset(id: 'architect', label: 'System Architect', emoji: '⚡'),
  AvatarPreset(id: 'polyglot', label: 'Polyglot Coder', emoji: '🚀'),
  AvatarPreset(id: 'scholar', label: 'Deep Scholar', emoji: '🧠'),
  AvatarPreset(id: 'artisan', label: 'UI/UX Artisan', emoji: '🎨'),
  AvatarPreset(id: 'mobile', label: 'Mobile Crafter', emoji: '📱'),
  AvatarPreset(id: 'data_wizard', label: 'Data Wizard', emoji: '📊'),
  AvatarPreset(id: 'cloud', label: 'Cloud Architect', emoji: '🌐'),
  AvatarPreset(id: 'robotics', label: 'Robotics Eng', emoji: '🦾'),
  AvatarPreset(id: 'lead', label: 'Tech Lead', emoji: '🎯'),
  AvatarPreset(id: 'quantum', label: 'Quantum Dev', emoji: '🔮'),
  AvatarPreset(id: 'neko', label: 'Cyber Neko', emoji: '🐱'),
  AvatarPreset(id: 'fox', label: 'Code Fox', emoji: '🦊'),
  AvatarPreset(id: 'pioneer', label: 'Pioneer', emoji: '🦁'),
];

const List<String> kBioPresets = [
  'Full-Stack Developer 💻',
  'AI & ML Researcher 🤖',
  'Cybersecurity Analyst 🛡️',
  'Product & Systems Architect ⚡',
  'Mobile Software Engineer 📱',
  'Open Source Innovator 🌐',
  'Competitive Programmer 🏆',
  'Cloud & DevOps Engineer ☁️',
];

final userProfileProvider =
    StateNotifierProvider<UserProfileNotifier, UserProfile>((ref) {
  final secureStorage = ref.read(secureStorageProvider);
  final notifier = UserProfileNotifier(secureStorage);
  notifier.loadFromStorage();
  return notifier;
});
