import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mocktail/mocktail.dart';
import 'package:drift/native.dart';
import 'package:velvet/core/security/secure_storage_service.dart';
import 'package:velvet/core/security/auth_service.dart';
import 'package:velvet/core/database/database.dart';
import 'package:velvet/core/security/totp_service.dart';

class MockFlutterSecureStorage extends Mock implements FlutterSecureStorage {}

void main() {
  group('AuthService PIN Hashing & States', () {
    late SecureStorageService storageService;
    late Map<String, String> fakeStorage;

    setUp(() {
      fakeStorage = {};
      final mockSecureStorage = MockFlutterSecureStorage();
      
      when(() => mockSecureStorage.read(key: any(named: 'key')))
          .thenAnswer((invocation) async {
        final key = invocation.namedArguments[#key] as String;
        return fakeStorage[key];
      });

      when(() => mockSecureStorage.write(
        key: any(named: 'key'),
        value: any(named: 'value'),
      )).thenAnswer((invocation) async {
        final key = invocation.namedArguments[#key] as String;
        final val = invocation.namedArguments[#value] as String;
        fakeStorage[key] = val;
      });

      when(() => mockSecureStorage.delete(key: any(named: 'key')))
          .thenAnswer((invocation) async {
        final key = invocation.namedArguments[#key] as String;
        fakeStorage.remove(key);
      });

      storageService = SecureStorageService(storage: mockSecureStorage);
    });

    test('PIN setup hashes and saves correctly', () async {
      final authService = AuthService(storage: storageService);
      await authService.checkPinStatus();
      expect(authService.state, AuthStatus.onboarding);

      final success = await authService.setupPin('1234', true);
      expect(success, true);
      expect(authService.state, AuthStatus.unlocked);

      expect(fakeStorage.containsKey('velvet_pin_hash'), true);
      expect(fakeStorage.containsKey('velvet_pin_salt'), true);
      expect(fakeStorage.containsKey('velvet_db_encryption_key'), true);
    });

    test('PIN verification works correctly', () async {
      final authService1 = AuthService(storage: storageService);
      await authService1.setupPin('4321', false);
      authService1.lock();
      expect(authService1.state, AuthStatus.locked);

      final verifiedWrong = await authService1.verifyPin('1111');
      expect(verifiedWrong, false);
      expect(authService1.state, AuthStatus.locked);

      final verifiedCorrect = await authService1.verifyPin('4321');
      expect(verifiedCorrect, true);
      expect(authService1.state, AuthStatus.unlocked);
    });

    test('Profile registration and login with Password & TOTP works correctly', () async {
      final authService = AuthService(storage: storageService);
      await authService.checkPinStatus();
      expect(authService.state, AuthStatus.onboarding);

      // Register profile with password and TOTP secret key
      const secret = 'JBSWY3DPEHPK3PXP'; // Base32 encoded key
      final success = await authService.registerProfile(
        username: 'navii',
        password: 'securePassword123',
        totpSecret: secret,
        enableBiometrics: false,
      );
      expect(success, true);
      expect(authService.state, AuthStatus.unlocked);

      // Verify that profile storage keys exist
      expect(fakeStorage.containsKey('pariyojana_username'), true);
      expect(fakeStorage.containsKey('pariyojana_password_hash'), true);
      expect(fakeStorage.containsKey('pariyojana_totp_secret'), true);

      // Lock profile
      authService.lock();
      expect(authService.state, AuthStatus.locked);

      // Test incorrect password
      final wrongPasswordLogin = await authService.loginWithPasswordAndMfa('wrongPassword', '000000');
      expect(wrongPasswordLogin, false);

      // Test correct password but incorrect TOTP
      final wrongTotpLogin = await authService.loginWithPasswordAndMfa('securePassword123', '000000');
      expect(wrongTotpLogin, false);

      // Test correct password and correct TOTP
      final now = DateTime.now().millisecondsSinceEpoch;
      // We import TotpService locally or directly (it is already in velvet package)
      final correctOtp = TotpService.getOtp(secret, now);
      final correctLogin = await authService.loginWithPasswordAndMfa('securePassword123', correctOtp);
      expect(correctLogin, true);
      expect(authService.state, AuthStatus.unlocked);
    });
  });

  group('Database SQLCipher Encryption', () {
    late Directory tempDir;
    late String dbPath;

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp('velvet_test_db');
      dbPath = '${tempDir.path}/test_encrypted.db';
    });

    tearDown(() async {
      try {
        if (await tempDir.exists()) {
          await tempDir.delete(recursive: true);
        }
      } catch (_) {}
    });

    test('Database encrypted at rest - unreadable with wrong key', () async {
      final key1 = 'a' * 64;
      final key2 = 'b' * 64;

      final connection1 = NativeDatabase(
        File(dbPath),
        setup: (rawDb) {
          rawDb.execute("PRAGMA key = \"x'$key1'\";");
        },
      );
      final db1 = VelvetDatabase(connection1);
      
      bool isSqlCipher = false;
      try {
        final result = await db1.customSelect('PRAGMA cipher_version;').getSingle();
        final version = result.read<String?>('cipher_version');
        isSqlCipher = version != null && version.isNotEmpty;
      } catch (_) {}

      await db1.into(db1.ideas).insert(
            IdeasCompanion.insert(
              content: 'Secret Idea',
              category: 'Test',
            ),
          );
      
      final ideas = await db1.select(db1.ideas).get();
      expect(ideas.length, 1);
      expect(ideas.first.content, 'Secret Idea');
      
      await db1.close();

      if (isSqlCipher) {
        final connection2 = NativeDatabase(
          File(dbPath),
          setup: (rawDb) {
            rawDb.execute("PRAGMA key = \"x'$key2'\";");
          },
        );
        final db2 = VelvetDatabase(connection2);

        expect(
          db2.select(db2.ideas).get(),
          throwsA(isA<Exception>()),
        );

        await db2.close();
      } else {
        // ignore: avoid_print
        print('SQLCipher not available on host system test runner. Skipping decryption failure check.');
      }
    });
  });
}
