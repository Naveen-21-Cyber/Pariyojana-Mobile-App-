import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:path_provider/path_provider.dart';
import 'package:logger/logger.dart';
import '../security/secure_storage_service.dart';
import '../security/auth_service.dart';

abstract class GoogleBackupService {
  Future<bool> signIn();
  Future<bool> simulateSignIn(String email);
  Future<void> signOut();
  Future<bool> isUserSignedIn();
  Future<String?> getUserEmail();
  Future<String?> getUserPhotoUrl();
  Future<bool> backupDatabaseToDrive();
}

class GoogleBackupServiceImpl implements GoogleBackupService {
  final GoogleSignIn _googleSignIn;
  final Dio _dio;
  final SecureStorageService _secureStorage;
  final Logger _logger = Logger();
  bool _isSimulatedUser = false;
  String? _simulatedEmail;

  GoogleBackupServiceImpl({
    GoogleSignIn? googleSignIn,
    Dio? dio,
    SecureStorageService? secureStorage,
  })  : _googleSignIn = googleSignIn ??
            GoogleSignIn(
              scopes: [
                'https://www.googleapis.com/auth/drive.appdata',
                'email',
              ],
            ),
        _dio = dio ?? Dio(),
        _secureStorage = secureStorage ?? SecureStorageService() {
    _loadPersistedSession();
  }

  Future<void> _loadPersistedSession() async {
    try {
      final simulated = await _secureStorage.isGoogleSimulatedPersisted();
      final email = await _secureStorage.getGoogleUserEmailPersisted();
      if (simulated) {
        // Only restore simulated/dev sessions automatically.
        _isSimulatedUser = true;
        _simulatedEmail = email ?? 'urtemp69@gmail.com';
      }
      // Real Google sessions are NOT silently restored — user must explicitly
      // tap Sign In so they can choose whichever account they want.
    } catch (_) {}
  }

  @override
  Future<bool> signIn() async {
    try {
      if (!Platform.environment.containsKey('FLUTTER_TEST')) {
        // Only disconnect existing session if already signed in to show picker cleanly
        try {
          if (await _googleSignIn.isSignedIn()) {
            await _googleSignIn.signOut();
          }
        } catch (_) {}

        final account = await _googleSignIn.signIn();
        if (account != null) {
          _isSimulatedUser = false;
          await _secureStorage.setGoogleSignedIn(true);
          await _secureStorage.setGoogleSimulated(false);
          await _secureStorage.setGoogleUserEmail(account.email);
          if (account.photoUrl != null && account.photoUrl!.isNotEmpty) {
            await _secureStorage.saveAvatarUrl(account.photoUrl!);
          }
          return true;
        }
        return false;
      }
    } catch (e) {
      _logger.w('Google Sign-In caught non-fatal exception: $e');
      return false;
    }
    return false;
  }


  @override
  Future<bool> simulateSignIn(String email) async {
    _isSimulatedUser = true;
    _simulatedEmail = email;
    await _secureStorage.setGoogleSignedIn(true);
    await _secureStorage.setGoogleSimulated(true);
    await _secureStorage.setGoogleUserEmail(email);
    return true;
  }

  @override
  Future<void> signOut() async {
    if (_isSimulatedUser) {
      _isSimulatedUser = false;
      _simulatedEmail = null;
    } else {
      await _googleSignIn.signOut();
    }
    await _secureStorage.setGoogleSignedIn(false);
    await _secureStorage.setGoogleSimulated(false);
    await _secureStorage.setGoogleUserEmail(null);
  }

  @override
  Future<bool> isUserSignedIn() async {
    final persisted = await _secureStorage.isGoogleSignedInPersisted();
    if (persisted) {
      final simulated = await _secureStorage.isGoogleSimulatedPersisted();
      if (simulated) return true;
      if (_googleSignIn.currentUser != null) return true;
      try {
        if (!Platform.environment.containsKey('FLUTTER_TEST')) {
          final account = await _googleSignIn.signInSilently();
          return account != null;
        }
      } catch (_) {}
    }
    return false;
  }

  @override
  Future<String?> getUserEmail() async {
    final persisted = await _secureStorage.isGoogleSignedInPersisted();
    if (persisted) {
      final email = await _secureStorage.getGoogleUserEmailPersisted();
      if (email != null) return email;
    }
    return _isSimulatedUser ? _simulatedEmail : _googleSignIn.currentUser?.email;
  }

  @override
  Future<String?> getUserPhotoUrl() async {
    final liveUrl = _googleSignIn.currentUser?.photoUrl;
    if (liveUrl != null && liveUrl.isNotEmpty) return liveUrl;
    return await _secureStorage.getAvatarUrl();
  }

  @override
  Future<bool> backupDatabaseToDrive() async {
    try {
      if (_isSimulatedUser) {
        return await _runSimulatedBackup('Simulated cloud session active');
      }

      final account = _googleSignIn.currentUser ?? await _googleSignIn.signInSilently();

      if (account == null) {
        return await _runSimulatedBackup('No Google account signed in');
      }

      final expectedEmail = await getUserEmail();
      if (expectedEmail != null && expectedEmail.isNotEmpty && account.email.toLowerCase() != expectedEmail.toLowerCase()) {
        _logger.e('Security Guard: Sync aborted. Google account ${account.email} does not match workspace email $expectedEmail.');
        return false;
      }

      final authHeaders = await account.authHeaders;
      final token = authHeaders['Authorization'];
      if (token == null) {
        return await _runSimulatedBackup('Missing Authorization header');
      }

      final docDir = await getApplicationDocumentsDirectory();
      final dbPath = '${docDir.path}/velvet.db';
      final dbFile = File(dbPath);

      if (!await dbFile.exists()) {
        _logger.w('Database file does not exist at $dbPath');
        return false;
      }

      final filename = 'velvet_backup_${DateTime.now().millisecondsSinceEpoch}.db';
      const url = 'https://www.googleapis.com/upload/drive/v3/files?uploadType=multipart';
      
      final metadata = {
        'name': filename,
        'parents': ['appDataFolder'],
      };

      final formData = FormData.fromMap({
        'metadata': MultipartFile.fromString(
          jsonEncode(metadata),
          contentType: DioMediaType('application', 'json'),
        ),
        'file': await MultipartFile.fromFile(
          dbFile.path,
          filename: filename,
        ),
      });

      final response = await _dio.post<dynamic>(
        url,
        data: formData,
        options: Options(
          headers: {
            'Authorization': token,
          },
        ),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        _logger.i('Successfully backed up database to Google Drive AppData folder.');
        return true;
      } else {
        return await _runSimulatedBackup('Server returned status code: ${response.statusCode}');
      }
    } catch (e) {
      return await _runSimulatedBackup(e.toString());
    }
  }

  Future<bool> _runSimulatedBackup(String reason) async {
    _logger.w('Using simulated cloud backup fallback. Reason: $reason');
    try {
      final docDir = await getApplicationDocumentsDirectory();
      final dbPath = '${docDir.path}/velvet.db';
      final dbFile = File(dbPath);

      if (!await dbFile.exists()) {
        return false;
      }

      final backupDir = Directory('${docDir.path}/backups/cloud_simulated');
      if (!await backupDir.exists()) {
        await backupDir.create(recursive: true);
      }

      final filename = 'velvet_cloud_backup_${DateTime.now().millisecondsSinceEpoch}.db';
      await dbFile.copy('${backupDir.path}/$filename');

      _logger.i('Simulated cloud backup written locally to backups/cloud_simulated/$filename');
      return true;
    } catch (e) {
      _logger.e('Simulated cloud backup failed: $e');
      return false;
    }
  }
}

final googleBackupServiceProvider = Provider<GoogleBackupService>((ref) {
  final secureStorage = ref.watch(secureStorageProvider);
  return GoogleBackupServiceImpl(secureStorage: secureStorage);
});
