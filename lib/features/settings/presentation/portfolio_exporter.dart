import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import '../../../shared_widgets/glass_snackbar.dart';
import '../../../core/profile/user_profile_provider.dart';

class PortfolioExporter {
  static String generateCvContent({UserProfile? profile}) {
    final name = (profile != null && profile.fullName.isNotEmpty)
        ? profile.fullName.toUpperCase()
        : 'USER PROFILE';
    final role = (profile != null && profile.title.isNotEmpty)
        ? profile.title
        : 'Software Engineer & Command Center User';
    final portfolio = (profile != null && profile.portfolioUrl.isNotEmpty)
        ? profile.portfolioUrl
        : 'https://github.com';
    final github = (profile != null && profile.githubUrl.isNotEmpty)
        ? profile.githubUrl
        : 'https://github.com';

    return '''
================================================================================
$name — $role
Contact: $portfolio | GitHub: $github
================================================================================

🛡️ CORE EXPERTISE
• Security Operations & Offline-First Systems
• Encrypted Local Storage (SQLCipher AES-256) & Zero-Trust Mobile Protocols
• Clean Architecture & Riverpod State Management

🚀 FEATURED ENGINEERING PROJECTS
1. PARIYOJANA OS: Personal Command Center with SQLCipher AES-256 local encryption and glass-clay UI.

Generated via Pariyojana OS v1.2.0 (Community Release)
''';
  }

  static Future<void> exportPortfolioMarkdown(
      BuildContext context, {UserProfile? profile}) async {
    final cv = generateCvContent(profile: profile);
    await Clipboard.setData(ClipboardData(text: cv));
    if (context.mounted) {
      GlassSnackBar.show(
        context,
        'Portfolio & CV copied to clipboard! 📄📋',
        icon: Icons.assignment_turned_in_rounded,
      );
    }
  }

  static String generateRepositoryReadme({
    required String projectName,
    required String description,
    required String techStack,
    required String status,
    UserProfile? profile,
  }) {
    final authorName = (profile != null && profile.fullName.isNotEmpty)
        ? profile.fullName
        : 'Command Center User';
    final ghHandle = (profile != null && profile.githubUsername.isNotEmpty)
        ? profile.githubUsername
        : 'user';
    final cloneUrl = (profile != null && profile.githubUsername.isNotEmpty)
        ? 'https://github.com/${profile.githubUsername}/$projectName.git'
        : 'https://github.com/user/$projectName.git';

    return '''# $projectName

> **Pariyojana Engineering Asset** • Author: **$authorName** (`$ghHandle`)

## 🛡️ Overview
$description

## ⚡ Tech Stack & Architecture
- **Core Framework**: $techStack
- **Security & Crypto**: Zero-Trust SQLCipher AES-256 local encryption, HIBP k-Anonymity breach detection
- **State Management**: Riverpod (Clean Architecture, Feature-First)
- **Current Development Status**: `$status`

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (v3.27+)
- Android SDK (API Level 34+)

### Installation
```bash
git clone $cloneUrl
cd $projectName
flutter pub get
flutter run
```

---

*Generated automatically via Pariyojana OS Remote Repository Creator.*
''';
  }

  static Future<void> sharePortfolioCV(
      BuildContext context, {UserProfile? profile}) async {
    final cv = generateCvContent(profile: profile);
    final name = (profile != null && profile.fullName.isNotEmpty)
        ? profile.fullName
        : 'User';
    await Share.share(
      cv,
      subject: '$name — Portfolio & Resume (Pariyojana OS Export)',
    );
  }
}
