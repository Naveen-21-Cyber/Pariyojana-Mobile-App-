# 🛡️ Security Architecture & Threat Model

This document outlines the security specifications, cryptographic protocols, key management, anti-forensic safeguards, and threat mitigations implemented in **Pariyojana**.

---

## 🔒 Threat Model & Core Assumptions

Pariyojana assumes an **untrusted device environment** where:
1. Physical device loss or theft may occur.
2. Malicious third-party apps may attempt background memory scraping or clipboard sniffing.
3. Network surveillance (MITM) may be present on untrusted public Wi-Fi networks.
4. Remote cloud servers are considered un-trusted (hence 100% offline local storage).

```
┌────────────────────────────────────────────────────────────────────────┐
│                     PARIYOJANA SECURITY ENCLAVE                        │
├────────────────────────────────────────────────────────────────────────┤
│  1. SQLCipher 256-bit AES-CBC (PBKDF2 64,000 Key Derivation)           │
│  2. Android KeyStore TEE Hardware Enclave (`flutter_secure_storage`)   │
│  3. Master KeySafe for Developer BYOK API Keys                         │
│  4. Anti-Forensic RAM Zeroing (`0x00`) on Memory Release               │
│  5. Android DRM `FLAG_SECURE` Screenshot & OS Recents Shield           │
│  6. Biometric Unlock (Android BiometricPrompt API)                     │
└────────────────────────────────────────────────────────────────────────┘
```

---

## 🔑 Key Management & Cryptography

### 1. Database Encryption (SQLCipher 256-bit AES)
- **Engine**: SQLite + SQLCipher (`sqlcipher_flutter_libs` v0.6.8 / `drift` v2.28.2).
- **Cipher**: 256-bit AES in CBC mode with HMAC SHA-512 authentication.
- **Key Derivation**: PBKDF2 with 64,000 iterations.
- **Key Generation**: High-entropy 256-bit cryptographically secure random key (`Random.secure()`).
- **Storage**: Master database key is encrypted by the Android OS and stored inside the **Android KeyStore TEE (Trusted Execution Environment)**.

### 2. BYOK Master KeySafe
- User API keys (OpenRouter, GitHub PAT, Gemini, OpenAI) are encrypted at rest using AES-256-GCM.
- Secrets are stored via `flutter_secure_storage` with Android KeyStore hardware backing (`encryptedSharedPreferences: true`).
- API keys are **never written to log output (`print()`)**, shared with telemetry, or sent to any intermediary server.

### 3. Anti-Forensic RAM Zeroing (`0x00`)
- Decrypted API keys and sensitive notes exist in RAM *only* during active operational calls.
- When the app is backgrounded, locked, or closed, the security core executes byte clearing by overwriting decrypted memory buffers with zeroes (`0x00`).

```dart
// Example: Anti-Forensic RAM clearing implementation
void wipeSensitiveBuffer(Uint8List secretBuffer) {
  for (int i = 0; i < secretBuffer.length; i++) {
    secretBuffer[i] = 0x00;
  }
}
```

---

## 🛡️ Physical & OS-Level Protections

### 1. Android DRM `FLAG_SECURE` Screenshot Protection
- Prevents screenshot captures, screen recording tools, and Android OS Recents App Switcher thumbnail caching.
- Enforced at the native `MainActivity` window level:

```kotlin
// Android Native Window Protection
window.setFlags(
    WindowManager.LayoutParams.FLAG_SECURE,
    WindowManager.LayoutParams.FLAG_SECURE
)
```

### 2. Biometric Authentication (`local_auth`)
- Integrates Android `BiometricPrompt` API supporting Fingerprint & Face Unlock with hardware TEE verification.
- Fallback to device PIN/Pattern provided through secure OS system dialog.

### 3. Encrypted Backup Archives (`.velvet`)
- User data export creates a standalone, portable `.velvet` archive.
- The payload is encrypted with AES-256-GCM using a user-specified backup password or wrapped with an RSA-2048 keypair.

---

## 🚫 Security Rules & Guidelines (Enforced)

1. **Zero Hardcoded Secrets**: Secrets, keys, and tokens must never be hardcoded into `.dart` source code. Development variables are loaded via `.env` (`flutter_dotenv`).
2. **RSA Scope Limitation**: RSA-2048 is used exclusively to wrap small symmetric AES session keys during backup exports — never to bulk-encrypt database tables directly.
3. **No Unencrypted Storage**: No unencrypted fallback storage (e.g. standard `SharedPreferences` or raw SQLite) is permitted for app data.
4. **Dependency Auditing**: Every crypto or storage dependency is audited and version-pinned in `pubspec.yaml`.

---

*Return to **[Home](Home.md)** or explore **[Feature Modules Guide](Feature-Modules-Guide.md)**.*
