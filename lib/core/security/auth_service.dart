import 'dart:convert';
import 'dart:math';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_auth/local_auth.dart';
import 'package:local_auth_android/local_auth_android.dart';
import 'package:local_auth_darwin/local_auth_darwin.dart';
import 'package:logger/logger.dart';
import 'package:pointycastle/digests/sha256.dart';
import 'secure_storage_service.dart';
import 'totp_service.dart';

final _log = Logger();


enum AuthStatus {
  onboarding,
  locked,
  unlocked,
}

class AuthService extends StateNotifier<AuthStatus> {
  final SecureStorageService _storage;
  final LocalAuthentication _localAuth;
  
  String? _decryptedDbKey;

  AuthService({
    required SecureStorageService storage,
    LocalAuthentication? localAuth,
  })  : _storage = storage,
        _localAuth = localAuth ?? LocalAuthentication(),
        super(AuthStatus.locked) {
    checkPinStatus();
  }

  String? get decryptedDbKey => _decryptedDbKey;

  void lockVault() {
    _decryptedDbKey = null;
    state = AuthStatus.locked;
  }

  Future<void> checkPinStatus() async {
    try {
      final hasPin = await _storage.hasPin();
      if (!hasPin) {
        state = AuthStatus.onboarding;
      } else {
        state = AuthStatus.locked;
      }
    } catch (e) {
      state = AuthStatus.onboarding;
    }
  }

  Future<bool> setupPin(String pin, bool enableBiometrics) async {
    try {
      final salt = _generateSalt();
      final hashedPin = _hashPin(pin, salt);
      await _storage.savePin(hashedPin, salt, pinLength: pin.length);
      await _storage.setBiometricsEnabled(enableBiometrics);
      
      _decryptedDbKey = await _storage.getOrCreateDatabaseKey();
      state = AuthStatus.unlocked;
      return true;
    } catch (e, stack) {
      _log.e('setupPin failed', error: e, stackTrace: stack);
      return false;
    }
  }

  Future<bool> verifyPin(String pin) async {
    try {
      final storedHash = await _storage.getPinHash();
      final salt = await _storage.getPinSalt();
      if (storedHash == null || salt == null) {
        // If no PIN but there is a profile, fall back to checking password instead of PIN
        final hasProfile = await _storage.hasProfile();
        if (hasProfile) {
          final passwordOk = await verifyPassword(pin);
          if (passwordOk) {
            _decryptedDbKey = await _storage.getOrCreateDatabaseKey();
            state = AuthStatus.unlocked;
            return true;
          }
        }
        return false;
      }

      final inputHash = _hashPin(pin, salt);
      if (storedHash == inputHash) {
        _decryptedDbKey = await _storage.getOrCreateDatabaseKey();
        state = AuthStatus.unlocked;
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<bool> registerProfile({
    required String username,
    required String password,
    String? totpSecret,
    required bool enableBiometrics,
  }) async {
    try {
      final salt = _generateSalt();
      final hashedPassword = _hashPin(password, salt);
      await _storage.saveProfile(
        username: username,
        passwordHash: hashedPassword,
        passwordSalt: salt,
        totpSecret: totpSecret,
        mfaEnabled: totpSecret != null,
      );
      await _storage.savePin(hashedPassword, salt);
      await _storage.setBiometricsEnabled(enableBiometrics);
      
      _decryptedDbKey = await _storage.getOrCreateDatabaseKey();
      state = AuthStatus.unlocked;
      return true;
    } catch (e, stack) {
      _log.e('registerProfile failed', error: e, stackTrace: stack);
      return false;
    }
  }

  Future<bool> verifyPassword(String password) async {
    try {
      final storedHash = await _storage.getPasswordHash();
      final salt = await _storage.getPasswordSalt();
      if (storedHash == null || salt == null) return false;

      final inputHash = _hashPin(password, salt);
      return storedHash == inputHash;
    } catch (e) {
      return false;
    }
  }

  Future<bool> verifyTotp(String code) async {
    try {
      final isMfa = await _storage.isMfaEnabled();
      if (!isMfa) return true;
      
      final secret = await _storage.getTotpSecret();
      if (secret == null) return false;

      return TotpService.verifyOtp(secret, code);
    } catch (e) {
      return false;
    }
  }

  Future<bool> loginWithPasswordAndMfa(String password, String totpCode) async {
    final passwordOk = await verifyPassword(password);
    if (!passwordOk) return false;

    final totpOk = await verifyTotp(totpCode);
    if (!totpOk) return false;

    _decryptedDbKey = await _storage.getOrCreateDatabaseKey();
    state = AuthStatus.unlocked;
    return true;
  }

  Future<bool> authenticateBiometrics({bool forcePrompt = false}) async {
    try {
      // OWASP Top 10 A01 (Broken Access Control): Biometrics MUST NEVER unlock
      // if no PIN / account has been provisioned on this device.
      final hasPin = await _storage.hasPin();
      final hasProfile = await _storage.hasProfile();
      if (!hasPin && !hasProfile) {
        _log.w('Biometric unlock rejected: No account/PIN provisioned on this device');
        return false;
      }

      if (!forcePrompt) {
        final isEnabled = await _storage.isBiometricsEnabled();
        if (!isEnabled) return false;
      }

      final canCheck = await _localAuth.canCheckBiometrics;
      final isSupported = await _localAuth.isDeviceSupported();
      if (!canCheck || !isSupported) return false;

      final didAuthenticate = await _localAuth.authenticate(
        localizedReason: 'Unlock Pariyojana Workspace using Fingerprint',
        authMessages: const <AuthMessages>[
          AndroidAuthMessages(
            signInTitle: 'Pariyojana Secured Unlock',
            biometricHint: 'Authenticate using Fingerprint',
            cancelButton: 'Cancel',
          ),
          IOSAuthMessages(
            cancelButton: 'Cancel',
            goToSettingsButton: 'Settings',
            goToSettingsDescription: 'Please enable Biometrics in your device settings.',
            lockOut: 'Biometrics locked out. Please re-enable.',
          ),
        ],
        options: const AuthenticationOptions(
          biometricOnly: false,
          stickyAuth: true,
          useErrorDialogs: true,
        ),
      );

      if (didAuthenticate) {
        _decryptedDbKey = await _storage.getOrCreateDatabaseKey();
        state = AuthStatus.unlocked;
        return true;
      }
      return false;
    } on PlatformException {
      return false;
    } catch (e) {
      return false;
    }
  }


  void lock() {
    _decryptedDbKey = null;
    state = AuthStatus.locked;
  }

  /// Full logout: wipes all local credentials (PIN, profile, DB key) and resets
  /// the app to the onboarding state. Use for "Sign Out" / "Reset Account".
  Future<void> logout() async {
    _decryptedDbKey = null;
    try {
      await _storage.clearAll();
    } catch (_) {}
    state = AuthStatus.onboarding;
  }

  String _generateSalt() {
    // Always use cryptographically secure random. Random.secure() is guaranteed
    // available on all Android/iOS devices. If it ever fails, we must NOT silently
    // fall back to an insecure source — throw so the caller can surface the error.
    final random = Random.secure();
    final bytes = Uint8List.fromList(List<int>.generate(16, (_) => random.nextInt(256)));
    return bytes.map((byte) => byte.toRadixString(16).padLeft(2, '0')).join();
  }

  String _hashPin(String pin, String salt) {
    final digest = SHA256Digest();
    final combined = Uint8List.fromList(utf8.encode(pin + salt));
    final hashed = digest.process(combined);
    return hashed.map((byte) => byte.toRadixString(16).padLeft(2, '0')).join();
  }
}

final secureStorageProvider = Provider<SecureStorageService>((ref) {
  return SecureStorageService();
});

final authServiceProvider = StateNotifierProvider<AuthService, AuthStatus>((ref) {
  final storage = ref.watch(secureStorageProvider);
  return AuthService(storage: storage);
});

final decryptedDbKeyProvider = Provider<String?>((ref) {
  final authService = ref.watch(authServiceProvider.notifier);
  ref.watch(authServiceProvider);
  return authService.decryptedDbKey;
});
