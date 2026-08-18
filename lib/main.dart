import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqlite3/open.dart';
import 'package:sqlcipher_flutter_libs/sqlcipher_flutter_libs.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'app.dart';
import 'core/providers/feature_toggles_provider.dart';
import 'core/notifications/notification_service.dart';
import 'core/background/background_service.dart';
import 'core/haptics/haptic_service.dart';
import 'package:velvet/core/sounds/sound_service.dart';
import 'core/analytics/analytics_service.dart';
import 'core/profile/user_profile_provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'core/home_widget/home_widget_service.dart';
import 'core/notifications/notification_scheduler.dart';
import 'core/theme/velvet_colors.dart';
import 'core/theme/font_provider.dart';

void main() {
  GoogleFonts.config.allowRuntimeFetching = false; // L1: use bundled fonts, not Google CDN
  unawaited(
    runZonedGuarded(
      () async {
        WidgetsFlutterBinding.ensureInitialized();

      // Load environment variables
      try {
        await dotenv.load(fileName: '.env');
      } catch (e) {
        debugPrint('Failed to load dotenv: $e');
      }

      // Override SQLite loading to use SQLCipher on Android
      try {
        open.overrideFor(OperatingSystem.android, openCipherOnAndroid);
      } catch (e) {
        debugPrint('Failed to override SQLite for SQLCipher: $e');
      }

      // Constrain orientation to portrait only for consistent premium UI feel
      try {
        await SystemChrome.setPreferredOrientations([
          DeviceOrientation.portraitUp,
          DeviceOrientation.portraitDown,
        ]);
      } catch (e) {
        debugPrint('Failed to set preferred orientations: $e');
      }

      // Initialize Notifications
      try {
        final notificationService = NotificationService();
        await notificationService.initialize();
        await notificationService.requestPermissions();
      } catch (e) {
        debugPrint('Failed to initialize notifications: $e');
      }

      // Initialize Haptic Feedback Service (native Vibration API)
      try {
        final hapticService = HapticService();
        await hapticService.initialize();
      } catch (e) {
        debugPrint('Failed to initialize haptic service: $e');
      }

      // Initialize Sound Effects Service
      try {
        final soundService = SoundService();
        await soundService.initialize();
      } catch (e) {
        debugPrint('Failed to initialize sound service: $e');
      }

      // Initialize Background Tasks
      try {
        await BackgroundService.initialize();
        await BackgroundService.registerDailyMaintenance();
      } catch (e) {
        debugPrint('Failed to initialize background service: $e');
      }

      // Initialize Home Screen Widget
      try {
        await HomeWidgetService.init();
      } catch (e) {
        debugPrint('Failed to initialize home widget: $e');
      }

      // Initialize Push Notification Scheduler (daily reminders)
      try {
        await NotificationScheduler.init();
      } catch (e) {
        debugPrint('Failed to initialize notification scheduler: $e');
      }

      // Initialize Firebase + Analytics + Crashlytics
      try {
        await Firebase.initializeApp();

        // Pass all Flutter framework errors to Crashlytics (silent — no dev notification)
        FlutterError.onError = (details) {
          FirebaseCrashlytics.instance.recordFlutterFatalError(details);
        };

        // Pass all uncaught async/platform errors to Crashlytics (silent)
        PlatformDispatcher.instance.onError = (error, stack) {
          FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
          return true;
        };

        final analytics = AnalyticsService();
        await analytics.logAppOpen();
      } catch (e) {
        debugPrint('Firebase init error: $e');
      }

      // Initialize SharedPreferences for instant settings persistence
      final sharedPreferences = await SharedPreferences.getInstance();

      // Build the provider container so we can eagerly load the user profile,
      // theme accent, font, and theme mode before the first frame — 0ms flicker.
      final container = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(sharedPreferences),
        ],
      );
      await Future.wait([
        container.read(userProfileProvider.notifier).loadFromStorage(),
        container.read(themeAccentProvider.notifier).load(),
        container.read(appFontProvider.notifier).loadFont(),
        container.read(appThemeModeProvider.notifier).load(),
      ]);

      runApp(
        UncontrolledProviderScope(
          container: container,
          child: const VelvetApp(),
        ),
      );
    },
    (error, stack) {
      try {
        FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      } catch (_) {}
    },
  ));
}
