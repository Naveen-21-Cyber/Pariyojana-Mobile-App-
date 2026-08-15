# ❓ FAQ & Troubleshooting Guide

This page provides solutions to frequently asked questions, backup management instructions, and troubleshooting steps for **Pariyojana**.

---

## ❓ Frequently Asked Questions (FAQ)

### Q1: Is Pariyojana really 100% free with no hidden subscriptions?
**Yes!** Pariyojana is 100% Free ($0 Lifetime) licensed under the permissive MIT open-source license. There are no monthly paywalls, locked feature modules, or hidden fees.

### Q2: Can I use Pariyojana without an active internet connection?
**Yes!** Pariyojana is designed as a **100% offline-first application**. All your ideas, 6-stage Kanban projects, research papers, and job application dossiers live directly on your physical Android phone inside a 256-bit SQLCipher-encrypted database. Internet is only required when you query online AI reasoning models using your BYOK keys.

### Q3: How are my BYOK AI keys and personal data protected?
Your API keys are encrypted at rest using your phone's **Android KeyStore TEE Hardware Enclave**. Decrypted key strings exist in RAM only during active operational API requests and are immediately overwritten with zeroes (`0x00`) when the app is locked or backgrounded.

### Q4: Does Pariyojana collect user telemetry or usage metrics?
**No.** Pariyojana includes zero telemetry SDKs, zero third-party analytics trackers, and zero corporate advertising plugins.

### Q5: How do I export or restore backups?
Go to **Settings → Export Backup** to generate an AES-256 encrypted `.velvet` backup archive. You can store this archive on an external SD card, USB drive, or private storage and restore it on any Android phone running Pariyojana via **Settings → Restore Backup**.

---

## 🔧 Troubleshooting Guide

### Issue 1: Database Lock or Migration Errors
- **Symptom**: App displays database lock or schema error on startup after manual modification.
- **Solution**:
  1. Force close Pariyojana.
  2. Ensure device has free internal storage space (>50 MB).
  3. Re-launch Pariyojana. SQLCipher will automatically verify SQLite database checksum integrity on startup.

### Issue 2: AI Provider Returns 401 Unauthorized Error
- **Symptom**: BYOK AI Studio displays `401 Unauthorized` or `Invalid API Key`.
- **Solution**:
  1. Open **Settings → AI Engine & KeySafe**.
  2. Verify your API key has no trailing spaces.
  3. If using OpenRouter, verify your OpenRouter account has active credits or select a `:free` model tier (such as `deepseek/deepseek-r1:free` or `google/gemini-2.0-flash-exp:free`).

### Issue 3: Screen Appears Black in Android Recents Screen
- **Symptom**: Android task switcher displays a black thumbnail or screenshot is disabled.
- **Explanation**: This is expected security behavior enforced by Android DRM `FLAG_SECURE` to prevent screen recording spyware or background screenshot harvesting of your sensitive notes and API keys.

---

*Return to **[Home](Home.md)** or explore **[Roadmap & Status](Roadmap-and-Status.md)**.*
