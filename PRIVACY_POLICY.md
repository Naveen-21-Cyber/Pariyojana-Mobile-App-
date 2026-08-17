# 🛡️ Privacy Policy for Pariyojana

**Last Updated:** August 17, 2026  
**Effective Date:** August 15, 2026  
**Developer / Organization:** Cyber_buddy ([LinkedIn](https://www.linkedin.com/company/cyber-buddy3/))  
**Application:** Pariyojana (Package: `com.navii.pariyojana`)  
**Source Code:** [GitHub Repository](https://github.com/Naveen-21-Cyber/Pariyojana-Mobile-App-)  

---

## 1. 🌐 Executive Privacy Commitment
**Pariyojana** was built with a fundamental architectural principle: **Your data belongs exclusively to you.**  
Pariyojana is a **100% offline-first, locally encrypted personal operating system** for ideas, 6-stage Kanban projects, research papers, and job applications.

We do **not** sell, monetize, harvest, or transmit your personal data, project notes, research documents, or resumes to any private or third-party servers.

---

## 2. 🔒 Local On-Device Encryption & Data Storage
- **SQLCipher 256-bit AES Encryption:** All user content created in Pariyojana (ideas, tasks, research papers, salary logs, notes) is stored strictly on your local device storage inside a hardware-accelerated, SQLCipher-encrypted SQLite database.
- **Hardware KeyStore Protection (TEE):** Database passphrases and encryption master keys are securely derived and stored inside your Android device's hardware **Trusted Execution Environment (TEE)** via `flutter_secure_storage`.
- **Zero-Knowledge Architecture:** The developer has zero access to your database file, encryption passphrases, or local backups.

---

## 3. 🤖 BYOK (Bring-Your-Own-Key) AI Reasoning Privacy
- Pariyojana allows optional integration with AI reasoning providers (OpenAI, Anthropic Claude, Google Gemini, Groq, DeepSeek, Ollama, Perplexity, OpenRouter) via BYOK.
- Your API keys are encrypted at rest on your physical device.
- API requests are sent **directly and securely over HTTPS** from your device to your chosen AI provider's official endpoint. Decrypted keys exist in RAM only for the duration of the operational request and are overwritten with zeroes (`0x00`) upon completion.

---

## 4. 📊 Crash Reporting & Anonymous Performance Metrics
To maintain application stability, performance, and diagnose crashes:
- Pariyojana uses **Firebase Crashlytics** and **Firebase Analytics** to receive anonymized crash stack traces and basic app health metrics (e.g., app version, device model, operating system version).
- **No Personally Identifiable Information (PII)**, user project names, notes, resumes, or database contents are ever included in telemetry or crash reports.

---

## 5. 📱 Device Permissions & Usage Rationale

| Permission | Technical Requirement | Rationale |
| :--- | :--- | :--- |
| **Biometric / Fingerprint** | `USE_BIOMETRIC` | To locally unlock your encrypted vault using your device's biometric sensor. |
| **Notifications** | `POST_NOTIFICATIONS` | To send local study timer alerts, task deadlines, and OTA update notifications. |
| **Storage / Media** | `READ_EXTERNAL_STORAGE` / Photo Picker | To allow you to attach local documents or research papers to your dossiers. |
| **Internet** | `INTERNET` | To fetch open research metadata (ArXiv, Hacker News) and communicate with your configured BYOK AI endpoints. |
| **Ignore Battery Optimizations** | Optional / User-Triggered | To ensure the Gita Focus Shield / Pomodoro timer is not killed by aggressive OEM power managers. |

---

## 6. 👶 Children's Privacy
Pariyojana does not knowingly collect or solicit any personal information from children under the age of 13. The application is rated for general productivity, research, and educational utility.

---

## 7. ⚖️ User Rights & Data Deletion
Since all your data resides 100% on your physical device:
- **Instant Full Deletion:** You can delete all your data at any time by selecting **"Factory Reset Vault"** inside Settings or by clearing application data in Android System Settings.
- **Export Sovereignty:** You can export unencrypted or AES-encrypted backups (`.pariyojana.bak`) at any time via the Backup & Export module.

---

## 8. 📬 Contact & Open Source Verification
Pariyojana is 100% open-source under the **MIT License**. You can independently audit the entire source code on GitHub.

For questions, security disclosures, or support:
- **GitHub Issues:** [https://github.com/Naveen-21-Cyber/Pariyojana-Mobile-App-/issues](https://github.com/Naveen-21-Cyber/Pariyojana-Mobile-App-/issues)
- **Organization:** Cyber_buddy ([LinkedIn](https://www.linkedin.com/company/cyber-buddy3/))
- **Email:** `cyberbuddy.official@gmail.com`
