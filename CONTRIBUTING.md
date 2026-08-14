# Contributing to Pariyojana (परियोजना)

Thank you for your interest in contributing to **Pariyojana** — the open-source, sovereign focus and productivity vault for Android!

---

## 📜 Code of Conduct & Architecture Rules

Before submitting pull requests, please review our core architectural rules:

1. **Clean Architecture (Feature-First):** Every feature must be structured under `lib/features/<feature_name>/` with `data/`, `domain/`, and `presentation/` layers. No business logic inside UI widgets.
2. **Riverpod Only:** Use Riverpod for state management. Avoid `setState` for global or cross-widget state.
3. **Zero Unencrypted Local Storage:** All database storage must be encrypted via **Drift + SQLCipher**. Never write sensitive data to unencrypted local storage.
4. **Android KeyStore TEE:** Secrets, API keys, and tokens must be handled via `flutter_secure_storage` or `flutter_dotenv`. Never hardcode keys in source code.
5. **No Telemetry / No Tracking:** Pariyojana is 100% offline-first. Never introduce third-party tracking or analytics SDKs.

---

## 🛠️ How to Set Up & Build Locally

### Prerequisites
- [Flutter SDK](https://docs.flutter.dev/get-started/install) (3.24+ recommended)
- Android Studio / Android SDK (Target API 34, Min API 29)
- Java 17 / Kotlin 1.9+

### Setup Commands
```bash
# 1. Clone the repository
git clone https://github.com/Naveen-21-Cyber/Pariyojana.git
cd Pariyojana

# 2. Get dependencies
flutter pub get

# 3. Generate Drift database & Riverpod code
dart run build_runner build --delete-conflicting-outputs

# 4. Check code analyzer (Must have ZERO errors)
flutter analyze

# 5. Run unit & widget tests
flutter test

# 6. Run on Android device/emulator
flutter run
```

---

## 🌐 Official Links
- **Website:** [http://pariyojana.gt.tc/](http://pariyojana.gt.tc/)
- **Repository:** [https://github.com/Naveen-21-Cyber/Pariyojana](https://github.com/Naveen-21-Cyber/Pariyojana)

