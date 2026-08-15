# 🛠️ Building & Deployment Guide

This guide provides step-by-step instructions for developers and contributors building **Pariyojana** from source, configuring environment variables, running database code generators, and compiling production release APKs (`Pariyojana.apk`).

---

## 📋 Prerequisites

Ensure your build environment meets the following requirements:

- **Flutter SDK**: `>=3.29.0` (Stable channel)
- **Dart SDK**: `>=3.7.0`
- **Java JDK**: `Java 17` (Open JDK 17 or Temurin 17)
- **Android SDK**: `API Level 34` (Android 14 / 15 SDK)
- **Android Build Tools**: `34.0.0`
- **Git**: Installed and configured

---

## 🛠️ Step-by-Step Build Process

### 1. Clone the Repository
```bash
git clone https://github.com/Naveen-21-Cyber/Pariyojana-Mobile-App-.git
cd Pariyojana-Mobile-App-
```

### 2. Fetch Flutter Dependencies
```bash
flutter pub get
```

### 3. Configure Environment Variables (`.env`)
Copy the template environment file `.env.example` to `.env`:
```bash
cp .env.example .env
```

Configure your development flags in `.env`:
```ini
# Environment Configuration
APP_ENV=production
ENABLE_ANALYTICS=false
SECURE_STORAGE_KEY_ALIAS=pariyojana_master_keystore
OPENROUTER_BASE_URL=https://openrouter.ai/api/v1
```

### 4. Run Code Generators (Drift, Freezed, Riverpod)
Pariyojana utilizes source generation for Drift SQLCipher tables, Freezed immutable domain models, and Riverpod providers:
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

---

## 📦 Compiling Production Release APK (`Pariyojana.apk`)

To generate an optimized, shrunk, and ProGuard/R8 obfuscated production APK:

```bash
flutter build apk --release --no-tree-shake-icons
```

The compiled release APK will be generated at:
```
build/app/outputs/flutter-apk/app-release.apk
```

> **Root APK Location**: In the root repository, the release binary is published as [`Pariyojana.apk`](file:///e:/ALL%20HOSTED/PARIYOJANA%20END%20USER/Pariyojana.apk).

---

## 🛡️ ProGuard & R8 Obfuscation Rules

ProGuard rules in `android/app/proguard-rules.pro` preserve SQLCipher native JNI symbols and Flutter plugin bindings:

```proguard
# SQLCipher Native Rules
-keep class net.sqlcipher.** { *; }
-keep class net.sqlcipher.database.** { *; }

# Flutter & Riverpod Rules
-keep class com.dexterous.flutterlocalnotifications.** { *; }
-keep class io.flutter.plugins.** { *; }
```

---

## 🧪 Code Quality & Static Analysis

Before submitting a Pull Request or tagging a release, run static analysis:

```bash
flutter analyze
```

Ensure **Zero Warnings and Zero Errors** are reported.

---

*Return to **[Home](Home.md)** or explore **[Contributing & Community](Contributing-and-Community.md)**.*
