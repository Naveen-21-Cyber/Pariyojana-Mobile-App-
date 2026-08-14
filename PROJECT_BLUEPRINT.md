# PROJECT VELVET — Personal Command Center

**Target:** Flutter, Android-only, single-user local-first app
**Owner:** Navii — security researcher / project + research + job tracker in one app

---

## 0. What this app actually is

One app, four trackers, one brain:

1. **Idea Vault** — capture every idea the second it hits you, before it's lost
2. **Project Tracker** — real engineering-style tracking (paths, drives, OS, folder structure — like a company asset register)
3. **Research Tracker** — papers, SSRN abstract IDs, submission status, citations, revisions
4. **Job Tracker** — applications, outreach messages, interview stages, follow-ups
5. **AI Agent Layer** — your own API key powers agents that summarize, tag, remind, and surface what's stale
6. Wrapped in a soft, tactile, animated UI: glassmorphism + claymorphism + skeuomorphic touches + "liquid glass" motion, biometric-gated.

---

## 1. Tech stack

```yaml
dependencies:
  flutter:
    sdk: flutter

  # State management & architecture
  flutter_riverpod: ^2.6.1
  riverpod_annotation: ^2.6.1
  go_router: ^17.0.0
  freezed_annotation: ^2.4.4
  json_annotation: ^4.9.0

  # Local storage (encrypted, offline-first)
  drift: ^2.22.1
  sqlcipher_flutter_libs: ^0.6.4
  path_provider: ^2.1.5
  flutter_secure_storage: ^9.2.2

  # Auth
  local_auth: ^2.3.0
  google_sign_in: ^6.2.2
  firebase_auth: ^5.3.4
  firebase_core: ^3.9.0

  # Crypto
  pointycastle: ^3.9.1
  cryptography: ^2.7.0
  encrypt: ^5.0.3

  # Networking
  dio: ^5.7.0
  retrofit: ^4.4.2
  connectivity_plus: ^6.1.1

  # UI / motion / glass-clay-skeuomorphic system
  flutter_animate: ^4.5.2
  rive: ^0.13.20
  glassmorphism: ^3.0.0
  google_fonts: ^6.2.1
  lottie: ^3.3.1
  flutter_svg: ^2.0.16
  shimmer: ^3.0.0
  fl_chart: ^0.70.0
  percent_indicator: ^4.2.4

  # Notifications & background work
  flutter_local_notifications: ^18.0.1
  workmanager: ^0.5.2
  firebase_messaging: ^15.1.5

  # Utilities
  intl: ^0.19.0
  uuid: ^4.5.1
  logger: ^2.5.0
  device_info_plus: ^11.2.0

dev_dependencies:
  build_runner: ^2.4.13
  drift_dev: ^2.22.1
  freezed: ^2.5.7
  json_serializable: ^6.9.0
  riverpod_generator: ^2.6.3
  flutter_lints: ^5.0.0
  mocktail: ^1.0.4
  integration_test:
    sdk: flutter
```

**Architecture pattern:** Clean Architecture, 3 layers per feature (`data / domain / presentation`), Riverpod for DI + state, `go_router` for nav with typed routes.

---

## 2. Design system tokens

**Palette**:
- `#FDF6F0` — base cream (backgrounds)
- `#FFB4A2` — coral-peach (primary accent, CTAs)
- `#B8C0FF` — periwinkle (secondary accent, links/progress)
- `#6B4F4F` — cocoa (text, high contrast)
- `#E8D5C4` — clay tan (skeuomorphic card base)
- `#7FE7C4` — mint (success/positive states)

**Themes**:
- **Glassmorphism**: BackdropFilter blur 20-30px, 1px white-8% border. Used for navigation bars, modals, floating action panels.
- **Claymorphism**: soft dual-shadow, rounded 24-32px, matte pastel fill. Used for cards for projects/papers/jobs.
- **Skeuomorphism**: subtle inner shadow + highlight. Used for folder/drive navigator.
- **"Liquid glass" motion**: Rive for blob/liquid morph on tab-switch and FAB expand.

**Typography**:
- Display: `Fraunces` or `Cabinet Grotesk`
- Body/UI: `Inter` or `Plus Jakarta Sans`
- Data/mono: `JetBrains Mono`

**Signature element**: a single "liquid orb" FAB that morphs shape depending on context.

---

## 3. Feature modules
- 3.1 Auth & Onboarding
- 3.2 Idea Vault
- 3.3 Project Tracker
- 3.4 Research Paper Tracker
- 3.5 Job Tracker
- 3.6 Hacker News integration
- 3.7 Route/Map layer (OpenRouteService)
- 3.8 Custom AI Agents
- 3.9 Notifications
- 3.10 Settings

---

## 4. Security architecture
- **At rest:** SQLCipher (AES-256) for DB.
- **Key management:** Android Keystore via `flutter_secure_storage`.
- **API keys:** encrypted individually with AES-256-GCM.
- **RSA-2048:** for backup/export file wrapping.
- **Transport:** TLS + cert pinning.
- **Secrets:** `.env` via `flutter_dotenv`.
- **Dependency hygiene:** pin versions, run `flutter pub outdated`.

---

## 5. Reliability / "no data loss" architecture
1. Local-first.
2. Transactions for multi-table writes.
3. Append-only activity log.
4. Encrypted local snapshot daily.
5. Google Drive backup (RSA-wrapped export).
6. Checksum verification on resume.

---

## 6. App folder structure
```
lib/
├── main.dart
├── app.dart
├── core/
│   ├── theme/
│   ├── router/
│   ├── security/
│   ├── database/
│   ├── network/
│   └── utils/
├── features/
│   ├── auth/
│   ├── idea_vault/
│   ├── project_tracker/
│   ├── research_tracker/
│   ├── job_tracker/
│   ├── hacker_news/
│   ├── route_map/
│   └── settings/
└── shared_widgets/
    ├── glass_container.dart
    ├── clay_card.dart
    ├── skeuo_folder_tab.dart
    └── liquid_fab.dart
```

