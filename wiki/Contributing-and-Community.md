# 🤝 Contributing & Community Guidelines

Thank you for your interest in contributing to **Pariyojana**! This project is built for the global open-source community under **Cyber_buddy** to champion digital freedom, offline data sovereignty, and security engineering.

---

## 📜 Architectural Rules (Non-Negotiable)

When writing code for Pariyojana, you MUST adhere to the project architectural rules defined in [`AGENTS.md`](file:///e:/ALL%20HOSTED/PARIYOJANA%20END%20USER/AGENTS.md):

1. **Clean Architecture (Feature-First)**: Every feature must be placed in `lib/features/<feature_name>/` containing `data/`, `domain/`, and `presentation/` subdirectories. No business logic inside UI widgets.
2. **State Management**: `flutter_riverpod` ONLY. Do not use `setState` for global or feature application state. (Local UI state like animation controllers or focus nodes are acceptable).
3. **Navigation**: `go_router` ONLY with strongly-typed route definitions.
4. **Local Database**: Drift + SQLCipher ONLY. All application data at rest MUST be encrypted. Never introduce an unencrypted fallback storage mechanism.
5. **No Hardcoded Secrets**: Secrets, keys, or tokens must never be committed to source code. Use `flutter_dotenv` for development and `flutter_secure_storage` for persisted runtime secrets.
6. **Security Discipline**: RSA-2048 is used ONLY to wrap small symmetric AES session keys during backup exports. Never bulk-encrypt database tables with RSA.
7. **Static Analysis**: Run `flutter analyze` after every code modification. Zero warnings and zero errors are required before marking any task or PR complete.
8. **Logging Hygiene**: Never use `print()` or output unredacted tokens, keys, or PII. Use the `logger` package with appropriate log levels.

---

## 🛠️ Contribution Workflow

### 1. Fork & Clone
```bash
git clone https://github.com/<your-username>/Pariyojana-Mobile-App-.git
cd Pariyojana-Mobile-App-
```

### 2. Create Feature Branch
```bash
git checkout -b feature/your-feature-name
```

### 3. Implement Feature & Add Tests
- Implement feature in `lib/features/<feature_name>/`.
- Write unit tests in `test/features/<feature_name>/`.

### 4. Run Static Analysis & Verification
```bash
flutter analyze
flutter test
```

### 5. Commit & Submit Pull Request
Use clear commit messages following Conventional Commits format:
```bash
git commit -m "feat(job_tracker): add Indian LPA Old Tax Regime deduction rules"
git push origin feature/your-feature-name
```

Open a Pull Request against `main` on GitHub!

---

## 🐛 Reporting Bugs & Requesting Features

- 🐛 **Bug Reports**: Open an issue using the [Bug Report Template](https://github.com/Naveen-21-Cyber/Pariyojana-Mobile-App-/issues). Please include Android version, device model, and reproduction steps.
- 💡 **Feature Requests**: Open an issue using the [Feature Request Template](https://github.com/Naveen-21-Cyber/Pariyojana-Mobile-App-/issues).

---

## 🌐 Community & Contact

- **Organization**: [Cyber_buddy on LinkedIn](https://www.linkedin.com/company/cyber-buddy3/)
- **Lead Developer**: [Naveen Telasang](https://github.com/Naveen-21-Cyber)
- **Official Website**: [http://pariyojana.gt.tc/](http://pariyojana.gt.tc/)

---

*Return to **[Home](Home.md)** or explore **[FAQ & Troubleshooting](FAQ-and-Troubleshooting.md)**.*
