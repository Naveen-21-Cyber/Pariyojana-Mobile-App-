# ─────────────────────────────────────────────────────────────────────────────
# PROGUARD / R8 OPTIMIZATION RULES — PARIYOJANA PRODUCTION RELEASE
# ─────────────────────────────────────────────────────────────────────────────

# Preserve generic type signatures for Gson & TypeToken in R8 shrinker
-keepattributes Signature
-keepattributes *Annotation*
-keepattributes InnerClasses
-keepattributes EnclosingMethod
-dontwarn javax.annotation.**
-dontwarn com.google.android.play.core.**

# Keep Gson TypeToken & generic models
-keep class com.google.gson.reflect.TypeToken { *; }
-keep class * extends com.google.gson.reflect.TypeToken
-keepclassmembers class * {
    @com.google.gson.annotations.SerializedName <fields>;
}

# Flutter Native Engine & Plugins
-keep class io.flutter.** { *; }
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.plugins.** { *; }

# Keep Firebase & Google Sign-In classes
-keep class com.google.firebase.** { *; }
-keep class io.flutter.plugins.firebase.** { *; }
-keep class com.google.android.gms.** { *; }
-keep class com.google.android.gms.auth.api.signin.** { *; }

# Keep SQLCipher & Drift Native Database Libraries (Prevents unsaved encrypted DB crash)
-keep class net.sqlcipher.** { *; }
-keep class net.sqlcipher.database.** { *; }
-keep class io.simonbinder.sqlite3.** { *; }

# Local Notifications, Biometrics, Secure Storage, Rive & Audio
-keep class com.dexterous.flutterlocalnotifications.** { *; }
-keep class io.flutter.plugins.localauth.** { *; }
-keep class io.flutter.plugins.flutter_secure_storage.** { *; }
-keep class app.rive.** { *; }
-keep class xyz.luan.audioplayers.** { *; }

# ─────────────────────────────────────────────────────────────────────────────
# ANTI-FORENSICS & LOG STRIPPING (Eliminates CWE-532 / MSTG-STORAGE-3)
# ─────────────────────────────────────────────────────────────────────────────
-assumenosideeffects class android.util.Log {
    public static boolean isLoggable(java.lang.String, int);
    public static int v(...);
    public static int d(...);
    public static int i(...);
    public static int w(...);
    public static int e(...);
    public static int println(...);
}

# Repackage & Obfuscate internal helper classes
-repackageclasses ''
-allowaccessmodification
-renamesourcefileattribute SourceFile


