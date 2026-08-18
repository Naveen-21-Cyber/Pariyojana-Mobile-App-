import 'dart:convert';
import 'dart:math';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  final FlutterSecureStorage _storage;

  SecureStorageService({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage(
          aOptions: AndroidOptions(
            encryptedSharedPreferences: true,
          ),
        );

  static const _secureIdeasKey = 'pariyojana_secure_idea_ids';
  static const _securePapersKey = 'pariyojana_secure_paper_ids';

  Future<List<int>> getSecureIdeaIds() async {
    final val = await _safeRead(_secureIdeasKey);
    if (val == null) return [];
    try {
      final List<dynamic> decoded = jsonDecode(val);
      return decoded.cast<int>();
    } catch (_) {
      return [];
    }
  }

  Future<void> setIdeaSecure(int id, bool secure) async {
    final ids = await getSecureIdeaIds();
    if (secure) {
      if (!ids.contains(id)) {
        ids.add(id);
      }
    } else {
      ids.remove(id);
    }
    await _safeWrite(_secureIdeasKey, jsonEncode(ids));
  }

  Future<List<int>> getSecurePaperIds() async {
    final stored = await _safeRead(_securePapersKey);
    if (stored == null) return [];
    try {
      final List<dynamic> decoded = jsonDecode(stored);
      return decoded.cast<int>();
    } catch (_) {
      return [];
    }
  }

  Future<void> setPaperSecure(int id, bool secure) async {
    final ids = await getSecurePaperIds();
    if (secure) {
      if (!ids.contains(id)) {
        ids.add(id);
      }
    } else {
      ids.remove(id);
    }
    await _safeWrite(_securePapersKey, jsonEncode(ids));
  }

  static const _dbKeyName = 'velvet_db_encryption_key';
  static const _pinHashName = 'velvet_pin_hash';
  static const _pinSaltName = 'velvet_pin_salt';
  static const _pinLengthName = 'velvet_pin_length';
  static const _biometricsEnabledName = 'velvet_biometrics_enabled';
  static const _notifyIdeaVaultName = 'velvet_notify_idea_vault';
  static const _notifyProjectStaleName = 'velvet_notify_project_stale';
  static const _notifyResearchPaperName = 'velvet_notify_research_paper';
  static const _notifyJobApplicationName = 'velvet_notify_job_application';
  static const _openRouterApiKeyName = 'velvet_openrouter_api_key';
  static const _openRouteServiceApiKeyName = 'velvet_openroute_service_api_key';
  // BYOK — per-provider AI keys
  static const _anthropicApiKeyName = 'pariyojana_anthropic_api_key';
  static const _openAiApiKeyName = 'pariyojana_openai_api_key';
  static const _geminiApiKeyName = 'pariyojana_gemini_api_key';
  static const _googleSignedInName = 'velvet_google_signed_in';
  static const _googleUserEmailName = 'velvet_google_user_email';
  static const _googleSimulatedName = 'velvet_google_simulated';
  static const _usernameName = 'pariyojana_username';
  static const _passwordHashName = 'pariyojana_password_hash';
  static const _passwordSaltName = 'pariyojana_password_salt';
  static const _totpSecretName = 'pariyojana_totp_secret';
  static const _mfaEnabledName = 'pariyojana_mfa_enabled';
  static const _notifStartHourKey = 'pariyojana_notif_start_hour';
  static const _notifEndHourKey = 'pariyojana_notif_end_hour';

  // User profile (BYOK — every end-user configures their own)
  static const _profileFullNameKey = 'pariyojana_profile_full_name';
  static const _profileTitleKey = 'pariyojana_profile_title';
  static const _profilePortfolioUrlKey = 'pariyojana_profile_portfolio_url';
  static const _profileGithubUrlKey = 'pariyojana_profile_github_url';
  static const _profileAvatarUrlKey = 'pariyojana_profile_avatar_url';
  static const _profileBannerIndexKey = 'pariyojana_profile_banner_index';

  Future<String?> _safeRead(String key) async {
    try {
      return await _storage.read(key: key);
    } on PlatformException catch (e) {
      // Only wipe on confirmed Keystore decryption failure (hardware corruption).
      // Transient errors (lock, timeout) must NOT destroy the user's DB key.
      final code = e.code.toLowerCase();
      final isHardwareFailure = code.contains('badpadding') ||
          code.contains('keystore') ||
          code.contains('keymasterexception') ||
          code.contains('invalidkeyexception') ||
          code.contains('storageexception');
      if (isHardwareFailure) {
        try {
          await _storage.deleteAll();
        } catch (_) {}
      }
      return null;
    } catch (_) {
      // For all other non-platform errors, just return null — do NOT wipe.
      return null;
    }
  }

  Future<void> _safeWrite(String key, String value) async {
    try {
      await _storage.write(key: key, value: value);
    } on PlatformException catch (e) {
      // Only retry-with-wipe on confirmed hardware Keystore corruption.
      final code = e.code.toLowerCase();
      final isHardwareFailure = code.contains('keystore') ||
          code.contains('keymasterexception') ||
          code.contains('storageexception');
      if (isHardwareFailure) {
        try {
          await _storage.deleteAll();
          await _storage.write(key: key, value: value);
        } catch (_) {}
      }
    } catch (_) {
      // Swallow non-platform errors — a write failure should not crash the app.
    }
  }

  Future<void> _safeDelete(String key) async {
    try {
      await _storage.delete(key: key);
    } catch (_) {}
  }

  Future<String> getOrCreateDatabaseKey() async {
    final hexKey = await _safeRead(_dbKeyName);
    if (hexKey != null) {
      return hexKey;
    } else {
      final random = Random.secure();
      final keyBytes = List<int>.generate(32, (_) => random.nextInt(256));
      final newHexKey = _hexEncode(keyBytes);
      await _safeWrite(_dbKeyName, newHexKey);
      return newHexKey;
    }
  }

  Future<String?> getDatabaseKey() async {
    return _safeRead(_dbKeyName);
  }

  Future<void> saveDatabaseKey(String hexKey) async {
    await _safeWrite(_dbKeyName, hexKey);
  }

  Future<void> savePin(String hashedPin, String salt, {int pinLength = 6}) async {
    await _safeWrite(_pinHashName, hashedPin);
    await _safeWrite(_pinSaltName, salt);
    await _safeWrite(_pinLengthName, pinLength.toString());
  }

  Future<String?> getPinHash() async {
    return _safeRead(_pinHashName);
  }

  Future<String?> getPinSalt() async {
    return _safeRead(_pinSaltName);
  }

  Future<int> getPinLength() async {
    final val = await _safeRead(_pinLengthName);
    return int.tryParse(val ?? '') ?? 6;
  }

  Future<bool> hasPin() async {
    final hash = await getPinHash();
    if (hash != null) return true;
    return await hasProfile();
  }

  Future<void> saveProfile({
    required String username,
    required String passwordHash,
    required String passwordSalt,
    String? totpSecret,
    bool mfaEnabled = false,
  }) async {
    await _safeWrite(_usernameName, username);
    await _safeWrite(_profileFullNameKey, username);
    await _safeWrite(_passwordHashName, passwordHash);
    await _safeWrite(_passwordSaltName, passwordSalt);
    if (totpSecret != null) {
      await _safeWrite(_totpSecretName, totpSecret);
    }
    await _safeWrite(_mfaEnabledName, mfaEnabled.toString());
  }

  Future<String?> getUsername() async => _safeRead(_usernameName);
  Future<void> saveUsername(String username) async => _safeWrite(_usernameName, username);
  Future<String?> getPasswordHash() async => _safeRead(_passwordHashName);
  Future<String?> getPasswordSalt() async => _safeRead(_passwordSaltName);
  Future<String?> getTotpSecret() async => _safeRead(_totpSecretName);
  
  Future<bool> isMfaEnabled() async {
    final val = await _safeRead(_mfaEnabledName);
    return val == 'true';
  }

  Future<bool> hasProfile() async {
    final hash = await getPasswordHash();
    return hash != null;
  }

  Future<void> setBiometricsEnabled(bool enabled) async {
    await _safeWrite(_biometricsEnabledName, enabled.toString());
  }

  Future<bool> isBiometricsEnabled() async {
    final val = await _safeRead(_biometricsEnabledName);
    return val == 'true';
  }

  Future<void> setNotifyIdeaVault(bool enabled) async {
    await _safeWrite(_notifyIdeaVaultName, enabled.toString());
  }

  Future<bool> isNotifyIdeaVaultEnabled() async {
    final val = await _safeRead(_notifyIdeaVaultName);
    return val != 'false'; // Defaults to true
  }

  Future<void> setNotifyProjectStale(bool enabled) async {
    await _safeWrite(_notifyProjectStaleName, enabled.toString());
  }

  Future<bool> isNotifyProjectStaleEnabled() async {
    final val = await _safeRead(_notifyProjectStaleName);
    return val != 'false'; // Defaults to true
  }

  Future<void> setNotifyResearchPaper(bool enabled) async {
    await _safeWrite(_notifyResearchPaperName, enabled.toString());
  }

  Future<bool> isNotifyResearchPaperEnabled() async {
    final val = await _safeRead(_notifyResearchPaperName);
    return val != 'false'; // Defaults to true
  }

  Future<void> setNotifyJobApplication(bool enabled) async {
    await _safeWrite(_notifyJobApplicationName, enabled.toString());
  }

  Future<bool> isNotifyJobApplicationEnabled() async {
    final val = await _safeRead(_notifyJobApplicationName);
    return val != 'false'; // Defaults to true
  }

  Future<void> saveOpenRouterApiKey(String key) async {
    await _safeWrite(_openRouterApiKeyName, key);
  }

  Future<String?> getOpenRouterApiKey() async {
    return _safeRead(_openRouterApiKeyName);
  }

  Future<void> saveGroqApiKey(String key) async {
    await _safeWrite('pariyojana_groq_api_key', key);
  }

  Future<String?> getGroqApiKey() async {
    return _safeRead('pariyojana_groq_api_key');
  }

  Future<void> saveOpenRouteServiceApiKey(String key) async {
    await _safeWrite(_openRouteServiceApiKeyName, key);
  }

  Future<String?> getOpenRouteServiceApiKey() async {
    return _safeRead(_openRouteServiceApiKeyName);
  }

  /// Saves the user's chosen model ID for a given provider key.
  /// [provider] should be one of: 'openrouter', 'claude', 'openai', 'gemini', 'groq'
  Future<void> saveSelectedModel(String provider, String modelId) async {
    await _safeWrite('pariyojana_selected_model_$provider', modelId);
  }

  /// Returns the user's chosen model ID for a provider, or null if not set.
  Future<String?> getSelectedModel(String provider) async {
    return _safeRead('pariyojana_selected_model_$provider');
  }

  Future<void> setGoogleSignedIn(bool signedIn) async {
    await _safeWrite(_googleSignedInName, signedIn.toString());
  }

  Future<bool> isGoogleSignedInPersisted() async {
    final val = await _safeRead(_googleSignedInName);
    return val == 'true';
  }

  Future<void> setGoogleUserEmail(String? email) async {
    if (email == null) {
      await _safeDelete(_googleUserEmailName);
    } else {
      await _safeWrite(_googleUserEmailName, email);
    }
  }

  Future<String?> getGoogleUserEmailPersisted() async {
    return _safeRead(_googleUserEmailName);
  }

  Future<void> setGoogleSimulated(bool simulated) async {
    await _safeWrite(_googleSimulatedName, simulated.toString());
  }

  Future<bool> isGoogleSimulatedPersisted() async {
    final val = await _safeRead(_googleSimulatedName);
    return val == 'true';
  }

  Future<void> clearAuthCredentials() async {
    await _safeDelete(_pinHashName);
    await _safeDelete(_pinSaltName);
    await _safeDelete(_biometricsEnabledName);
    await _safeDelete(_notifyIdeaVaultName);
    await _safeDelete(_notifyProjectStaleName);
    await _safeDelete(_notifyResearchPaperName);
    await _safeDelete(_notifyJobApplicationName);
  }

  Future<void> clearAll() async {
    try {
      await _storage.deleteAll();
    } catch (_) {}
  }

  Future<bool> hasShownConceptGuide() async {
    final val = await _safeRead('velvet_has_shown_concept_guide');
    return val == 'true';
  }

  Future<void> setShownConceptGuide(bool shown) async {
    await _safeWrite('velvet_has_shown_concept_guide', shown.toString());
  }

  Future<String?> readSetting(String key) async {
    return _safeRead(key);
  }

  Future<void> writeSetting(String key, String value) async {
    await _safeWrite(key, value);
  }

  // ── User Profile ────────────────────────────────────────────────────────────

  Future<void> saveUserProfile({
    required String fullName,
    required String title,
    required String portfolioUrl,
    required String githubUrl,
    String? avatarUrl,
    int? bannerIndex,
  }) async {
    await _safeWrite(_profileFullNameKey, fullName);
    await _safeWrite(_profileTitleKey, title);
    await _safeWrite(_profilePortfolioUrlKey, portfolioUrl);
    await _safeWrite(_profileGithubUrlKey, githubUrl);
    if (avatarUrl != null) {
      await _safeWrite(_profileAvatarUrlKey, avatarUrl);
    }
    if (bannerIndex != null) {
      await _safeWrite(_profileBannerIndexKey, bannerIndex.toString());
    }
  }

  Future<void> saveAvatarUrl(String url) async {
    await _safeWrite(_profileAvatarUrlKey, url);
  }

  Future<String?> getAvatarUrl() async {
    return _safeRead(_profileAvatarUrlKey);
  }

  Future<Map<String, String>> getUserProfile() async {
    var fullName = await _safeRead(_profileFullNameKey) ?? '';
    if (fullName.isEmpty) {
      fullName = await _safeRead(_usernameName) ?? '';
    }
    return {
      'fullName': fullName,
      'title': await _safeRead(_profileTitleKey) ?? '',
      'portfolioUrl': await _safeRead(_profilePortfolioUrlKey) ?? '',
      'githubUrl': await _safeRead(_profileGithubUrlKey) ?? '',
      'avatarUrl': await _safeRead(_profileAvatarUrlKey) ?? '',
      'bannerIndex': await _safeRead(_profileBannerIndexKey) ?? '0',
    };
  }

  Future<void> clearUserProfile() async {
    await _safeDelete(_profileFullNameKey);
    await _safeDelete(_profileTitleKey);
    await _safeDelete(_profilePortfolioUrlKey);
    await _safeDelete(_profileGithubUrlKey);
    await _safeDelete(_profileAvatarUrlKey);
    await _safeDelete(_profileBannerIndexKey);
  }

  // ── Per-Provider AI Keys ────────────────────────────────────────────────────

  Future<int> getNotificationStartHour() async {
    final str = await _safeRead(_notifStartHourKey);
    return str != null ? int.tryParse(str) ?? 9 : 9;
  }

  Future<void> setNotificationStartHour(int hour) async {
    await _safeWrite(_notifStartHourKey, hour.toString());
  }

  Future<int> getNotificationEndHour() async {
    final str = await _safeRead(_notifEndHourKey);
    return str != null ? int.tryParse(str) ?? 22 : 22;
  }

  Future<void> setNotificationEndHour(int hour) async {
    await _safeWrite(_notifEndHourKey, hour.toString());
  }

  Future<void> saveAnthropicApiKey(String key) async {
    await _safeWrite(_anthropicApiKeyName, key);
  }

  Future<String?> getAnthropicApiKey() async {
    return _safeRead(_anthropicApiKeyName);
  }

  Future<void> saveOpenAiApiKey(String key) async {
    await _safeWrite(_openAiApiKeyName, key);
  }

  Future<String?> getOpenAiApiKey() async {
    return _safeRead(_openAiApiKeyName);
  }

  Future<void> saveGeminiApiKey(String key) async {
    await _safeWrite(_geminiApiKeyName, key);
  }

  Future<String?> getGeminiApiKey() async {
    return _safeRead(_geminiApiKeyName);
  }


  static String _hexEncode(List<int> bytes) {
    return bytes.map((byte) => byte.toRadixString(16).padLeft(2, '0')).join();
  }
}
