# 🚀 Pariyojana Triple-Store Publishing Kit

This guide contains the exact copy-paste templates, file paths, and submission steps to publish **Pariyojana** simultaneously to **F-Droid (IzzyOnDroid)**, **Samsung Galaxy Store**, and **Google Play Store**.

---

## 📦 Store Package Matrix

| Platform | Required File Format | File Location | Account Cost | Review Time |
| :--- | :--- | :--- | :---: | :---: |
| **F-Droid (IzzyOnDroid)** | Direct GitHub Tag / `.apk` | `Pariyojana.apk` on GitHub `v1.0.0` | **$0** (Free) | **24–48 Hours** |
| **Samsung Galaxy Store** | Universal Release `.apk` | `C:\Users\cw\Desktop\Pariyojana.apk` | **$0** (Free) | **24–48 Hours** |
| **Google Play Store** | Signed App Bundle (`.aab`) | `C:\Users\cw\Desktop\Pariyojana-v1.0.0.aab` | **$25** (One-time) | **14–21 Days** (Closed test) |

---

# 1️⃣ TRACK 1: F-Droid / IzzyOnDroid Submission

IzzyOnDroid is the official fast-track repository for F-Droid clients worldwide.

### Submission Steps:
1. Go to: **[https://gitlab.com/IzzyOnDroid/repo/-/issues/new](https://gitlab.com/IzzyOnDroid/repo/-/issues/new)**
2. Set Issue Title: `[App] Pariyojana (com.navii.pariyojana)`
3. Copy and paste the template below into the description:

```markdown
### Application Information
- **Name:** Pariyojana
- **Package Name:** `com.navii.pariyojana`
- **Summary:** Sovereign Offline Research & Project OS
- **License:** MIT (Open Source)
- **Source Repository:** https://github.com/Naveen-21-Cyber/Pariyojana-Mobile-App-
- **Issue Tracker:** https://github.com/Naveen-21-Cyber/Pariyojana-Mobile-App-/issues
- **Release APK Tag:** `v1.0.0`
- **Direct Download Asset:** https://github.com/Naveen-21-Cyber/Pariyojana-Mobile-App-/releases/download/v1.0.0/Pariyojana.apk

### Description
Pariyojana is a 100% offline-first personal operating system and deep research command center built with local SQLCipher 256-bit AES encryption. It includes an Idea Vault, 6-stage Kanban board, ArXiv paper search, salary/job tracker, and BYOK AI assistant.

### Anti-Features / Tracking
- Zero tracking / telemetry selling.
- Uses Firebase Crashlytics for crash diagnosis.
```

---

# 2️⃣ TRACK 2: Samsung Galaxy Store Submission

The Samsung Galaxy Store serves over 1 Billion devices worldwide with no closed testing rules.

### Submission Steps:
1. Sign in to **[Samsung Galaxy Store Developer Portal](https://seller.samsungapps.com/)** (100% Free).
2. Click **Add New Application** ➔ Select **Android**.
3. Fill in the App Information:
   - **Application Title:** `Pariyojana: Offline Project OS`
   - **Default Language:** English (United States)
   - **Category:** Productivity / Tools
   - **Age Rating:** 12+ / 16+
4. **Upload Binary:**
   - Select **Binary ➔ Add Binary**.
   - Upload file: `C:\Users\cw\Desktop\Pariyojana.apk`.
5. **Upload Graphic Assets:**
   - **App Icon:** 512 x 512 PNG (`assets/branding/app_icon.png`).
   - **Screenshots:** Upload images from `GITHUB/1.png` to `GITHUB/6.png`.
6. **Privacy Policy URL:**
   - Paste: `https://naveen-21-cyber.github.io/Pariyojana-Mobile-App-/privacy.html` or `http://pariyojana.gt.tc/privacy.html`.
7. Click **Submit for Review** (Approved in 24–48 hours!).

---

# 3️⃣ TRACK 3: Google Play Store Submission

### Submission Steps:
1. Open **[Google Play Console](https://play.google.com/console/)**.
2. Click **Create App**:
   - **App Name:** `Pariyojana: Offline Project OS`
   - **Default Language:** English (United States)
   - **App or Game:** App
   - **Free or Paid:** Free
3. **Store Listing Copy-Paste Fields:**
   - **Short Description (80 chars):**  
     `Encrypted offline project OS, 6-stage Kanban, idea vault & research tracker.`
   - **Full Description:**  
     *(Copy directly from `fastlane/metadata/android/en-US/full_description.txt`)*
   - **Privacy Policy URL:**  
     `https://github.com/Naveen-21-Cyber/Pariyojana-Mobile-App-/blob/main/PRIVACY_POLICY.md`
4. **Data Safety Questionnaire Answers:**
   - **Does your app collect or share user data?** Yes (Crashlytics).
   - **Data Encrypted in Transit?** Yes (HTTPS).
   - **Can users request data deletion?** Yes (Local factory reset inside app).
   - **Data Types Collected:**
     - *Diagnostics:* Crash logs & Diagnostics (Anonymous performance / crash analysis).
     - *All user content (ideas, notes, resumes):* Stored locally on-device only, zero data shared with developer or third parties.
5. **Upload App Bundle:**
   - Go to **Release ➔ Closed Testing** (or Production if Organization account).
   - Upload: `C:\Users\cw\Desktop\Pariyojana-v1.0.0.aab`.
   - Release Name: `1.0.0 (Initial Release)`
   - Release Notes: `Initial public release of Pariyojana: Offline Project & Deep Research OS.`

---

# 🎨 Ready Assets Cheat Sheet

| Asset | Dimensions / Type | Path in Workspace |
| :--- | :--- | :--- |
| **App Icon** | 512 x 512 PNG | `assets/branding/app_icon.png` |
| **Feature Graphic** | 1024 x 500 JPG/PNG | `GITHUB/SUR.png` |
| **Screenshots 1-6** | High-Res 1080p | `GITHUB/1.png` through `GITHUB/6.png` |
| **Release APK** | Android APK (71.5 MB) | `Pariyojana.apk` |
| **Release Bundle** | Android App Bundle (`.aab`) | `Pariyojana-v1.0.0.aab` |
| **Privacy Policy** | Markdown & HTML | `PRIVACY_POLICY.md` / `website/privacy.html` |
