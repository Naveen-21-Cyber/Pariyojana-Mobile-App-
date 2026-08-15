# 🏗️ Architecture & UI Design System

This document describes the architectural pattern, directory structure, state management model, navigation system, and UI design system used in **Pariyojana**.

---

## 🏛️ Clean Architecture (Feature-First)

Pariyojana strictly follows **Clean Architecture** with a feature-first folder organization. Business logic is completely decoupled from UI widgets.

```
lib/
├── main.dart                      # App entry point & initialization
├── app.dart                       # MaterialApp.router configuration & theme binding
├── core/                          # Cross-cutting application infrastructure
│   ├── database/                  # Drift + SQLCipher database definition & migrations
│   ├── network/                   # Dio HTTP client, OpenRouter REST client, interceptors
│   ├── router/                    # GoRouter declarative typed routes & auth guards
│   ├── security/                  # KeyStore, AES-256 cipher, RAM zeroing engine
│   ├── theme/                     # Glass, Clay, Skeuomorphic tokens & typography
│   └── utils/                     # Formatters, loggers, and extension methods
├── features/                      # Feature modules (Feature-First pattern)
│   ├── auth/                      # Biometric, PIN, and Google OAuth authentication
│   │   ├── data/                  # Repositories & secure storage data sources
│   │   ├── domain/                # Use cases & AuthUser models
│   │   └── presentation/          # Screens (PIN, Biometric, Onboarding) & Riverpod providers
│   ├── idea_vault/                # Idea capture, promotion, and search engine
│   ├── project_tracker/           # Visual 6-Stage Scrum Kanban board
│   ├── research_tracker/          # Academic PDF & SSRN revision tracker
│   ├── job_tracker/               # Job funnel & Indian LPA Tax Engine
│   ├── hacker_news/               # Tech news feed integration
│   ├── route_map/                 # OpenRouteService location layer
│   └── settings/                  # App preferences, API KeySafe, & .velvet backup export
└── shared_widgets/                # Reusable UI component library
    ├── clay_card.dart             # Soft dual-shadow matte card
    ├── glass_container.dart       # Glassmorphism backdrop-blur container
    ├── skeuo_folder_tab.dart      # Tactile folder/drive asset navigator
    └── liquid_fab.dart            # Contextual morphing action button
```

---

## 🔄 State Management & Dependency Injection

- **Framework**: `flutter_riverpod` (v2.6.1)
- **Pattern**: Immutable State Objects + `StateNotifier` / `@riverpod` Generators.
- **Rules**:
  1. **No `setState` for App State**: Widgets only manage transient UI state (e.g. text field cursor focus or local animation controllers). All business data flows through Riverpod providers.
  2. **Reactive Data Streams**: Drift SQLite queries return reactive `Stream` objects that automatically update UI screens on data mutations.

```dart
// Example: Riverpod Provider pattern used across feature repositories
final jobTrackerRepositoryProvider = Provider<JobTrackerRepository>((ref) {
  final database = ref.watch(appDatabaseProvider);
  return JobTrackerRepositoryImpl(database);
});

final jobsStreamProvider = StreamProvider.autoDispose<List<JobEntity>>((ref) {
  final repository = ref.watch(jobTrackerRepositoryProvider);
  return repository.watchAllJobs();
});
```

---

## 🚦 Declarative Navigation (GoRouter 17)

All navigation uses `go_router` with strongly-typed route definitions and authentication redirect guards.

```
/ (Splash & Auth Guard Check)
├── /onboarding                   # First-run onboarding wizard
├── /pin-login                    # Biometric / PIN unlock screen
├── /home                         # Primary bottom-navigation shell
│   ├── /home/ideas               # Idea Vault Module
│   ├── /home/projects            # 6-Stage Scrum Kanban Module
│   ├── /home/research            # Academic Research Paper Module
│   ├── /home/jobs                # Job Application Tracker Module
│   └── /home/hacker-news         # Tech News Feed Module
├── /ai-studio                    # BYOK AI Multi-Model Switcher
├── /focus-gita                   # Bhagavad Gita Focus Shield & Vadya Audio
└── /settings                     # KeySafe Credentials & Encrypted Export
```

---

## 🎨 UI Design System & Visual Languages

Pariyojana combines **three distinct visual languages**, each reserved for a specific functional purpose to maintain visual hierarchy and tactile feedback:

```
┌────────────────────────────────────────────────────────────────────────┐
│                        PARIYOJANA DESIGN TOKENS                        │
├───────────────────────┬────────────────────────────────────────────────┤
│ Base Background       │ #FDF6F0 (Warm Cream / Dark Charcoal #07090C)   │
│ Primary Coral Accent  │ #FF522B (CTAs, Active States, Brand Gradient)  │
│ Periwinkle Secondary │ #B8C0FF (Progress Indicators, Subtitle Tags)   │
│ Cocoa Text / Dark     │ #6B4F4F / #F0F0F4 (High Contrast Typography)   │
│ Mint Positive State   │ #10B981 (Success, Shipped, Verification)       │
│ Gold Gita Accent      │ #D4AF37 (Sanskrit Wisdom, Shloka Badges)       │
└───────────────────────┴────────────────────────────────────────────────┘
```

### 1. 🧪 Glassmorphism (Navigation, Header, Modals)
- **Token**: `GlassContainer`
- **Spec**: `BackdropFilter` blur (20px-30px), 1px subtle white-border (`rgba(255,255,255,0.12)`), semi-transparent background fill.
- **Usage**: Top navigation bars, floating dialogs, context menus, and bottom sheets.

### 2. 🧱 Claymorphism (Content Cards)
- **Token**: `ClayCard`
- **Spec**: Matte pastel background fill, 24px-32px border radius, dual soft inner and outer drop shadows.
- **Usage**: Idea notes, Kanban project items, research papers, and job application cards.

### 3. 📁 Skeuomorphism (Folder & Drive Navigator)
- **Token**: `SkeuoFolderTab`
- **Spec**: Tactile inner shadows, top tab bevels, and physical material highlights.
- **Usage**: Workspace folder trees, file path asset registers, and repository path selectors.

---

## 💧 Signature Motion: Liquid Glass FAB

- Powered by **Rive vector animation engine**.
- The main Floating Action Button (FAB) smoothly morphs shape contextually based on the active screen tab (e.g. morphing into an idea spark icon on the Idea Vault screen, a project column icon on the Kanban screen, or an AI prompt bubble on the AI Studio screen).

---

*Return to **[Home](Home.md)** or explore **[Security Architecture](Security-Architecture-and-Threat-Model.md)**.*
