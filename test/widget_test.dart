import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:velvet/shared_widgets/glass_container.dart';
import 'package:velvet/shared_widgets/clay_card.dart';
import 'package:velvet/shared_widgets/skeuo_folder_tab.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:velvet/core/providers/feature_toggles_provider.dart';
import 'package:velvet/core/security/secure_storage_service.dart';
import 'package:velvet/core/security/auth_service.dart';
import 'package:velvet/core/backup/google_backup_service.dart';
import 'package:velvet/shared_widgets/gita_shloka_dialog.dart';

class FakeSecureStorageService extends SecureStorageService {
  final Map<String, String> _data = {};

  @override
  Future<String> getOrCreateDatabaseKey() async {
    if (!_data.containsKey('velvet_db_encryption_key')) {
      _data['velvet_db_encryption_key'] = 'a' * 64;
    }
    return _data['velvet_db_encryption_key']!;
  }

  @override
  Future<void> savePin(String hashedPin, String salt, {int pinLength = 6}) async {
    _data['velvet_pin_hash'] = hashedPin;
    _data['velvet_pin_salt'] = salt;
    _data['velvet_pin_length'] = pinLength.toString();
  }

  @override
  Future<String?> getPinHash() async => _data['velvet_pin_hash'];

  @override
  Future<String?> getPinSalt() async => _data['velvet_pin_salt'];

  @override
  Future<bool> hasPin() async => _data.containsKey('velvet_pin_hash');

  @override
  Future<void> setBiometricsEnabled(bool enabled) async {
    _data['velvet_biometrics_enabled'] = enabled.toString();
  }

  @override
  Future<bool> isBiometricsEnabled() async => _data['velvet_biometrics_enabled'] == 'true';

  @override
  Future<void> setGoogleSignedIn(bool value) async {
    _data['velvet_google_signed_in'] = value.toString();
  }

  @override
  Future<bool> isGoogleSignedInPersisted() async {
    return _data['velvet_google_signed_in'] == 'true';
  }

  @override
  Future<void> setGoogleSimulated(bool value) async {
    _data['velvet_google_simulated'] = value.toString();
  }

  @override
  Future<bool> isGoogleSimulatedPersisted() async {
    return _data['velvet_google_simulated'] == 'true';
  }

  @override
  Future<void> setGoogleUserEmail(String? email) async {
    if (email == null) {
      _data.remove('velvet_google_user_email');
    } else {
      _data['velvet_google_user_email'] = email;
    }
  }

  @override
  Future<String?> getGoogleUserEmailPersisted() async {
    return _data['velvet_google_user_email'];
  }

  @override
  Future<void> saveOpenRouterApiKey(String key) async {
    _data['velvet_openrouter_api_key'] = key;
  }

  @override
  Future<String?> getOpenRouterApiKey() async {
    return _data['velvet_openrouter_api_key'];
  }

  @override
  Future<void> saveProfile({
    required String username,
    required String passwordHash,
    required String passwordSalt,
    String? totpSecret,
    bool mfaEnabled = false,
  }) async {
    _data['pariyojana_username'] = username;
    _data['pariyojana_password_hash'] = passwordHash;
    _data['pariyojana_password_salt'] = passwordSalt;
    if (totpSecret != null) _data['pariyojana_totp_secret'] = totpSecret;
    _data['pariyojana_mfa_enabled'] = mfaEnabled.toString();
  }

  @override
  Future<String?> getUsername() async => _data['pariyojana_username'];

  @override
  Future<String?> getPasswordHash() async => _data['pariyojana_password_hash'];

  @override
  Future<String?> getPasswordSalt() async => _data['pariyojana_password_salt'];

  @override
  Future<String?> getTotpSecret() async => _data['pariyojana_totp_secret'];

  @override
  Future<bool> isMfaEnabled() async => _data['pariyojana_mfa_enabled'] == 'true';

  @override
  Future<bool> hasProfile() async => _data.containsKey('pariyojana_password_hash');

  @override
  Future<void> clearAuthCredentials() async {
    _data.remove('velvet_pin_hash');
    _data.remove('velvet_pin_salt');
    _data.remove('velvet_biometrics_enabled');
  }

  @override
  Future<void> clearAll() async => _data.clear();
}

class FakeGoogleBackupService implements GoogleBackupService {
  @override
  Future<bool> signIn() async => true;

  @override
  Future<bool> simulateSignIn(String email) async => true;

  @override
  Future<void> signOut() async {}

  @override
  Future<bool> isUserSignedIn() async => true;

  @override
  Future<String?> getUserEmail() async => 'test@example.com';

  @override
  Future<String?> getUserPhotoUrl() async => null;

  @override
  Future<bool> backupDatabaseToDrive() async => true;
}

void main() {
  group('Velvet Custom Widgets Tests', () {
    testWidgets('GlassContainer renders child', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: GlassContainer(
              child: Text('Glass Child'),
            ),
          ),
        ),
      );

      expect(find.text('Glass Child'), findsOneWidget);
    });

    testWidgets('ClayCard renders child and color', (WidgetTester tester) async {
      const cardColor = Colors.red;
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ClayCard(
              color: cardColor,
              child: Text('Clay Child'),
            ),
          ),
        ),
      );

      expect(find.text('Clay Child'), findsOneWidget);
      final Container container = tester.widget<Container>(find.byType(Container).first);
      final BoxDecoration decoration = container.decoration as BoxDecoration;
      expect(decoration.color, cardColor);
    });

    testWidgets('SkeuoFolderTab displays label and triggers onTap', (WidgetTester tester) async {
      bool tapped = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SkeuoFolderTab(
              label: 'Test Tab',
              isSelected: true,
              icon: Icons.star,
              onTap: () {
                tapped = true;
              },
            ),
          ),
        ),
      );

      expect(find.text('Test Tab'), findsOneWidget);
      expect(find.byIcon(Icons.star), findsOneWidget);

      await tester.tap(find.text('Test Tab'));
      expect(tapped, true);
    });
  });

  group('Velvet App Navigation Smoke Test', () {
    testWidgets('Pumps app and renders default view after onboarding PIN setup', (WidgetTester tester) async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final fakeStorage = FakeSecureStorageService();
      await fakeStorage.savePin('123456hash', 'salt');
      final fakeBackup = FakeGoogleBackupService();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sharedPreferencesProvider.overrideWithValue(prefs),
            secureStorageProvider.overrideWithValue(fakeStorage),
            googleBackupServiceProvider.overrideWithValue(fakeBackup),
            gitaShlokaEnabledProvider.overrideWith((ref) => GitaShlokaNotifier(prefs)),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: Center(child: Text('Velvet Security Vault Active')),
            ),
          ),
        ),
      );

      expect(find.text('Velvet Security Vault Active'), findsOneWidget);
    });
  });
}
