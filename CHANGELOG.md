# Changelog

All notable changes to Pariyojana are documented here.
Format based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).

---

## [1.0.0] — 2026-08-09

### Added
- Initial public release
- Encrypted vault (AES-256 SQLCipher + PIN/Biometric/Password/TOTP auth)
- Idea Vault with voice, camera, and text capture
- Project Tracker with deadlines and milestones
- Research Tracker with AI summarization
- Job Tracker with AI resume-to-JD ATS match scorer and company dossier
- AI Agents with BYOK (OpenRouter, Claude, OpenAI, Gemini, Groq)
- Per-provider model selector with 40+ model options (20+ free on OpenRouter)
- Analytics Dashboard with FL Chart visualizations
- Achievement Badges system
- Bhagavad Gita Focus Timer with Vadya soundscapes (Rive animation)
- GitHub PAT integration
- Interview Route Map (OpenRouteService)
- Android Home Screen Widget (2x2: idea count + active projects)
- Push notification reminders for stale projects
- Dark/Light theme with glassmorphism + clay card design system
- Onboarding flow (5 slides) with clean Skip navigation
- Bidirectional auth nav: Sign In <-> Set Up Vault & PIN
- Open Source (MIT License) with SECURITY.md vulnerability disclosure policy

### Security
- AES-256 SQLCipher encrypted DB at rest
- Android TEE KeyStore for BYOK API keys
- RSA key wrapping for backup export only
- ProGuard/R8 rules for SQLCipher, Drift, and Google Auth native symbols
- Zero hardcoded secrets

---

*Made in India — Open Source*
