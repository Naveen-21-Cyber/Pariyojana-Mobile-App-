# 📖 Pariyojana (परियोजना) Wiki

Welcome to the official **Pariyojana Wiki**! This documentation hub provides a complete breakdown of the project architecture, security specification, feature modules, BYOK AI integration, developer build steps, and product roadmap.

> **योगः कर्मसु कौशलम्**  
> *"Excellence in Action is True Yoga"* — Bhagavad Gita 2.50  
> 
> *Pariyojana is a 100% Free, Offline-First, Encrypted Personal Focus, Research & Productivity Vault for Android, built in India for sovereign developers worldwide.*

---

## 🧭 Navigation Index

- 🗺️ **[Roadmap & Status](Roadmap-and-Status.md)** — Project roadmap (v1.0.0, v1.1.0, v2.0.0), module completion metrics, and live status.
- 🏗️ **[Architecture & Design](Architecture-and-Design.md)** — Clean Architecture, Riverpod state management, GoRouter, and UI Design Tokens (Glass, Clay, Skeuomorphic, Liquid FAB).
- 🛡️ **[Security Architecture & Threat Model](Security-Architecture-and-Threat-Model.md)** — 256-bit SQLCipher database, Android KeyStore TEE, Anti-Forensic RAM zeroing, and DRM screenshot protection.
- ✨ **[Feature Modules Guide](Feature-Modules-Guide.md)** — Deep dive into all 8 native modules (Idea Vault, 6-Stage Kanban, Research Tracker, BYOK AI, Job Tracker, KeySafe, Gita Shield, Velvet Engine).
- 🤖 **[BYOK AI Integration Guide](BYOK-AI-Integration-Guide.md)** — Bring-Your-Own-Key model switcher (OpenRouter, DeepSeek R1, Llama 3.3, Gemini 2.0 Flash, Claude 3.5, GPT-4o).
- 🛠️ **[Building & Deployment Guide](Building-and-Deployment-Guide.md)** — Prerequisites, step-by-step compilation, APK generation (`Pariyojana.apk`), and ProGuard/R8 configuration.
- 🤝 **[Contributing & Community](Contributing-and-Community.md)** — Clean code guidelines, testing standards (`flutter analyze`), and open-source contribution workflows.
- ❓ **[FAQ & Troubleshooting](FAQ-and-Troubleshooting.md)** — Frequently asked questions, backup export/import (.velvet format), and troubleshooting tips.

---

## ⚡ Quick Overview

| Metric / Aspect | Value / Specification |
|---|---|
| **Target Platform** | Android 10+ (Android Native via Flutter 3.29+) |
| **Pricing** | **100% Free ($0 Lifetime)** · Zero Subscriptions · Zero Ads |
| **Storage Architecture** | **100% Local Device Only** (Offline-First) |
| **Database Encryption** | **SQLCipher 256-bit AES-CBC** (64,000 PBKDF2 iterations) |
| **Hardware KeySafe** | Android KeyStore TEE Hardware Security Enclave |
| **AI Integration** | BYOK (Bring Your Own Key) via OpenRouter & Direct Providers |
| **License** | **MIT License** (Open Source Community Software) |
| **Official Website** | [http://pariyojana.gt.tc/](http://pariyojana.gt.tc/) |
| **Source Repository** | [GitHub Repository](https://github.com/Naveen-21-Cyber/Pariyojana-Mobile-App-) |

---

## 🚩 Why Pariyojana Was Built

Modern cloud productivity platforms charge steep monthly subscriptions ($10-$25/mo), harvest user notes and career data on corporate surveillance servers, and fail completely when offline.

**Pariyojana** reverses this paradigm:
1. **Zero Cloud Lock-in**: Your data never touches third-party servers. All notes, Kanban boards, research papers, and job dossiers live inside an encrypted SQLite database on your physical device.
2. **Bring Your Own Keys (BYOK)**: Connect to world-class AI reasoning models (DeepSeek R1, Claude 3.5, Gemini 2.0, GPT-4o) using your own free or API keys without paying markup fees.
3. **Anti-Surveillance Security**: Sealed with SQLCipher 256-bit AES encryption, Android KeyStore TEE keys, and Anti-Forensic RAM Zeroing (`0x00`) upon lock.

---

## 📸 Core System Architecture Preview

```
┌────────────────────────────────────────────────────────────────────────┐
│                        PARIYOJANA MOBILE APP                           │
├────────────────────────────────────────────────────────────────────────┤
│  [Presentation Layer] Flutter 3.29 · Riverpod 2.6 · GoRouter 17        │
│  ├── Glassmorphic Nav Bars & Modals                                     │
│  ├── Claymorphic Project & Research Cards                              │
│  ├── Skeuomorphic Folder Asset Navigator                               │
│  └── Liquid Glass Rive Motion FAB                                      │
├────────────────────────────────────────────────────────────────────────┤
│  [Domain Layer] Clean Architecture Use Cases & Repositories            │
├────────────────────────────────────────────────────────────────────────┤
│  [Data Layer] Encrypted Drift ORM + SQLCipher 256-bit AES               │
├────────────────────────────────────────────────────────────────────────┤
│  [Security Core] Android KeyStore TEE + Anti-Forensic RAM Zeroing      │
└────────────────────────────────────────────────────────────────────────┘
```

---

*For detailed instructions on setting up or contributing to Pariyojana, explore the pages in the sidebar!*
