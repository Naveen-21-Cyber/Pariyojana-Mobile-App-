# 🤖 BYOK (Bring Your Own Key) AI Integration Guide

This guide explains how **Pariyojana's BYOK AI Studio** operates, how to configure API keys securely, supported provider endpoints, and on-device cost optimization mechanisms.

---

## 🔑 Concept: Bring Your Own Key (BYOK)

Unlike commercial AI wrappers that charge $10–$25/month for restricted query limits, **Pariyojana is 100% free software ($0)**.

You bring your own API keys (from free providers like OpenRouter or Google AI Studio, or your own developer API accounts). The app connects your phone directly to the provider endpoint.

```
┌────────────────────────────────────────────────────────────────────────┐
│                   PARIYOJANA DIRECT AI PIPELINE                        │
├────────────────────────────────────────────────────────────────────────┤
│  User Input ──> Encrypted KeySafe (Android TEE)                        │
│             ──> On-Device HTTPS Request (TLS 1.3)                      │
│             ──> Provider Endpoint (OpenRouter / DeepSeek / Gemini)      │
│             ──> Direct Response Stream to Android Device               │
└────────────────────────────────────────────────────────────────────────┘
```

> **Zero Middleman Servers**: Pariyojana has no intermediate cloud servers. Your prompts and API keys never pass through any third-party infrastructure.

---

## 🌐 Supported AI Providers & Models

### 1. OpenRouter (Recommended for Free Models)
- **Free Models**: `deepseek/deepseek-r1:free`, `meta-llama/llama-3.3-70b-instruct:free`, `google/gemini-2.0-flash-exp:free`.
- **Paid Reasoning Models**: Claude 3.5 Sonnet, OpenAI GPT-4o, Mistral Large.
- **Obtaining Key**: Sign up at [OpenRouter.ai](https://openrouter.ai/), create a free API key, and paste it into Pariyojana Settings.

### 2. Google Gemini API
- **Models**: `gemini-2.0-flash`, `gemini-1.5-pro`.
- **Obtaining Key**: Generate a free API key at [Google AI Studio](https://aistudio.google.com/).

### 3. OpenAI API
- **Models**: `gpt-4o`, `gpt-4o-mini`, `o3-mini`.

### 4. DeepSeek API
- **Models**: `deepseek-chat` (V3), `deepseek-reasoner` (R1).

---

## 🛡️ KeySafe Hardware Security

1. **Storage**: API keys are encrypted at rest using AES-256-GCM via `flutter_secure_storage` backed by the **Android KeyStore TEE Hardware Enclave**.
2. **Memory Protection**: Decrypted keys exist in RAM *only* during active API request execution.
3. **Anti-Forensic Clearing**: When Pariyojana is backgrounded or locked, memory buffers containing key strings are overwritten with zeroes (`0x00`).

---

## ⚡ On-Device Token Cost Saver (1024-Slot LRU Cache)

To minimize API expenses when using paid models, Pariyojana includes an **on-device prompt compression and caching engine**:

- **1024-Slot LRU Cache**: Stores hash signatures of previous prompt context and LLM responses.
- **Cost Reduction**: Re-asking similar queries or summarizing updated notes leverages cached tokens, cutting API costs by **40%–60%**.
- **Privacy Sealed**: The cache is saved inside the local SQLCipher 256-bit encrypted database.

---

## 🛠️ Configuring BYOK Keys in Pariyojana

1. Open Pariyojana on your Android phone.
2. Navigate to **Settings → AI Engine & KeySafe**.
3. Select your provider (e.g. **OpenRouter**).
4. Paste your API Key (`sk-or-v1-...`).
5. Select your default model (e.g. **DeepSeek R1 Free**).
6. Tap **Test & Save Credentials**.

---

*Return to **[Home](Home.md)** or explore **[Building & Deployment Guide](Building-and-Deployment-Guide.md)**.*
