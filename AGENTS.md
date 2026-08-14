# AGENTS.md — Rules for Antigravity 2.0 on this project

## Project
Flutter, Android-only. Personal project/research/job tracker with idea capture,
AI agents, and heavy local encryption. Full spec: `PROJECT_BLUEPRINT.md`.

## Architecture rules (non-negotiable)
- Clean Architecture, feature-first: every feature gets `data/`, `domain/`,
  `presentation/`. No business logic inside widgets.
- State management: Riverpod only. No `setState`-driven app state, local UI
  state (animation controllers, text field focus) is fine.
- Navigation: `go_router` only, typed routes.
- Local DB: Drift + SQLCipher. The database file must be encrypted at rest.
  Never introduce a second unencrypted storage mechanism for app data.
- Never hardcode API keys, secrets, or tokens in source. Use `flutter_dotenv`
  for dev and `flutter_secure_storage` for anything persisted on-device at
  runtime. If you generate a key or secret, stop and ask where it should live.

## Security rules
- Any new dependency touching crypto, auth, or storage requires you to state
  in your plan why it's needed and what it replaces.
- RSA is used only to wrap AES session keys for backup export — never to bulk-
  encrypt data directly. If a task seems to require RSA-encrypting more than a
  small key blob, flag it instead of implementing it.
- Run `flutter analyze` after every change. Zero warnings before marking a
  task complete.
- No `print()`/verbose logging of tokens, keys, or PII. Use the `logger`
  package with levels, and redact secrets in any log line that could touch them.

## Design system rules
- Use the design tokens in `PROJECT_BLUEPRINT.md` §2 exactly — do not
  substitute default Material 3 purple/indigo defaults.
- Three visual languages, used for their specified purpose only:
  glass (nav/modals), clay (content cards), skeuomorphic (folder/file tree
  only). Don't mix all three on one component.
- One signature motion element (liquid FAB via Rive). Do not scatter
  animation across every widget — restraint is part of the brief.

## Process rules
- Work one phase at a time per `PROJECT_BLUEPRINT.md` §8. Do not start the
  next phase until the current phase's exit criteria are met and reported.
- Write a widget or unit test for any new repository, use case, or custom
  widget before considering the task done.
- If a request is ambiguous, state your assumption and proceed — don't block
  on it — but log the assumption in your plan output so it can be corrected.

