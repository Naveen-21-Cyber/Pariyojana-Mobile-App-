# ✨ Feature Modules Guide

This guide provides an in-depth operational and technical reference for all **8 core feature modules** in **Pariyojana**.

---

## 1. 💡 Sovereign Idea Vault & Cherishing System

The **Idea Vault** allows instant capture of raw creative sparks, startup concepts, and research notes before they fade away.

### Key Capabilities
- **Instant Capture**: Zero-latency card creation with title, detail, tags, and priority matrix (`Low`, `Medium`, `High`, `Critical`).
- **1-Tap Promotion Pipeline**: Instantly convert any idea into an active **Scrum Kanban Project**, **Academic Research Paper**, or **Job Application**.
- **Search & Tag Filtering**: Instant search across 256-bit encrypted text with custom category tags.

```
Idea Vault Note ──[1-Tap Promote]──> 🛠️ Scrum Project Board
                                 ──> 📚 Research Paper Tracker
                                 ──> 💼 Job Application Dossier
```

---

## 2. 📋 6-Stage Scrum & Agile Kanban Stage

An engineering-style project management module designed for tracking software builds, open-source repositories, and technical deliverables.

### Visual 6-Stage Pipeline
1. **Backlog**: Unscheduled backlog tasks and feature ideas.
2. **Sprint**: Selected items queued for active work sprint.
3. **In Progress**: Active execution stage.
4. **QA**: Quality assurance and unit test verification.
5. **Security Audit**: Code security inspection & static analysis check (`flutter analyze`).
6. **Shipped**: Verified production features.

### Features
- **Asset Indexing**: Attach local folder paths, GitHub repository URLs, and operating system targets.
- **30-Day Activity Heatmap**: Visual calendar grid displaying daily work consistency streaks (Green for active, Red for missed).

---

## 3. 📚 Academic Research Paper Tracker & World of Science

Designed specifically for academic researchers, scholars, and PhD authors tracking SSRN papers, journal submissions, and peer-review revisions.

### Key Features
- **PDF Vault**: Index local research paper PDFs fully offline.
- **SSRN Stall Detector**: Highlights papers stuck in submission or review queues beyond target thresholds.
- **World of Science Action Items**: Itemized checklist for reviewer comments and revision deadlines.
- **AI Rebuttal Generator**: Draft formal, academically rigorous rebuttal letters addressing reviewer critiques using BYOK OpenRouter models.

---

## 4. 🤖 BYOK (Bring Your Own Key) Multi-Model AI Studio

Empowers users to leverage modern Large Language Models without cloud surveillance or subscription fees.

### Supported Providers & Models
- **OpenRouter**: DeepSeek R1, Llama 3.3 70B, Gemini 2.0 Flash Free, Claude 3.5 Sonnet, GPT-4o.
- **Direct API Keys**: OpenAI API, Google Gemini API, Anthropic API, DeepSeek API.

### Cost & Privacy Architecture
- **On-Device HTTPS**: API requests originate directly from the user's Android phone to the provider API. Zero middleman servers.
- **1024-Slot LRU Prompt Cache**: On-device prompt compression engine that slashes repetitive token expenditure by up to 60%.

---

## 5. 💼 Job Application Tracker & Indian LPA Tax Engine

A career management suite for tracking job applications, outreach messages, interview stages, and salary offer breakdowns.

### Application Funnel Stages
`Applied` → `Screening` → `Technical Interview` → `HR Round` → `Offer Received` → `Accepted / Rejected`

### Indian LPA Tax & In-Hand Salary Calculator
- Calculates exact monthly in-hand take-home salary projections from total LPA packages.
- Supports **New Tax Regime (FY 2024-25 / 2025-26)** and **Old Tax Regime** with Section 80C, 80D, HRA, and Standard Deduction rules.

---

## 6. 🛡️ Biometric KeySafe & Anti-Forensic RAM Engine

The security vault managing developer credentials and master hardware lock.

### Capabilities
- Hardware-backed biometric unlock via Android KeyStore TEE.
- **Master API KeySafe**: Hardware-sealed key storage for GitHub PATs, AI keys, and custom tokens.
- **Anti-Forensic Clearing**: Zeroes out decrypted key buffers in memory (`0x00`) immediately upon app backgrounding.

---

## 7. 🕉️ Focus Shield & Sacred Bhagavad Gita Wisdom

A deep work environment designed to foster mental clarity, stoic focus, and equanimity during work sessions.

### Features
- **Custom Pomodoro Timer**: Flexible sprint durations (15m, 25m, 45m, 60m).
- **15 Curated Sanskrit Bhagavad Gita Verses**: Displaying original Devanagari text, transliteration, and English reflections on detachment from outcome (*Karma Yoga*).
- **Vadya Ambient Soundscapes**: Offline micro-audio themes for deep focus (*Daily Digest*, *Milestone Fanfare*, *Sacred Gita Om*).

---

## 8. ⚡ 120 FPS High-Refresh Velvet Engine

The performance layer ensuring fluid responsiveness across all screens.

### Technical Highlights
- Hardware-accelerated Flutter 3.29 rendering pipeline.
- `RepaintBoundary` isolation preventing unnecessary widget redraws.
- 120Hz display refresh rate optimization with battery-friendly dark mode.

---

*Return to **[Home](Home.md)** or explore **[BYOK AI Guide](BYOK-AI-Integration-Guide.md)**.*
