import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AppLogoStyle {
  pariyojanaDefault, // 'P' — the original app icon (default)
  sunsetOrange,
  softwareDev,
  cyberSecurity,
  devopsCicd,
  cloudInfra,
  crmRelationship,
  techSupport,
  aiMachineLearning,
  dataAnalytics,
  productScrum,
  velvetCocoa,
  cyberObsidian,
  vedicGold,
  pureWhite,
}

const MethodChannel _iconChannel = MethodChannel('com.navii.velvet/icon');

final appLogoProvider = StateNotifierProvider<AppLogoNotifier, AppLogoStyle>((ref) {
  final notifier = AppLogoNotifier();
  notifier.loadFromStorage();
  return notifier;
});

class AppLogoNotifier extends StateNotifier<AppLogoStyle> {
  // Default is the Pariyojana 'P' logo
  AppLogoNotifier() : super(AppLogoStyle.pariyojanaDefault);

  Future<void> loadFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedName = prefs.getString('pariyojana_app_logo_style_v1');
      if (savedName != null && savedName.isNotEmpty) {
        final savedStyle = AppLogoStyle.values.firstWhere(
          (e) => e.name == savedName,
          orElse: () => AppLogoStyle.pariyojanaDefault,
        );
        state = savedStyle;
      }
    } catch (_) {}
  }

  Future<void> setStyle(AppLogoStyle style) async {
    state = style;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('pariyojana_app_logo_style_v1', style.name);
    } catch (_) {}
    try {
      final iconKey = style.name;
      await _iconChannel.invokeMethod('changeIcon', {'iconName': iconKey});
    } catch (_) {}
  }
}

class AppLogoHelper {
  static IconData getLogoIcon(AppLogoStyle style) {
    switch (style) {
      case AppLogoStyle.pariyojanaDefault:
        return Icons.apps_rounded;
      case AppLogoStyle.sunsetOrange:
        return Icons.local_fire_department_rounded;
      case AppLogoStyle.softwareDev:
        return Icons.code_rounded;
      case AppLogoStyle.cyberSecurity:
        return Icons.security_rounded;
      case AppLogoStyle.devopsCicd:
        return Icons.rocket_launch_rounded;
      case AppLogoStyle.cloudInfra:
        return Icons.cloud_done_rounded;
      case AppLogoStyle.crmRelationship:
        return Icons.handshake_rounded;
      case AppLogoStyle.techSupport:
        return Icons.support_agent_rounded;
      case AppLogoStyle.aiMachineLearning:
        return Icons.psychology_rounded;
      case AppLogoStyle.dataAnalytics:
        return Icons.analytics_rounded;
      case AppLogoStyle.productScrum:
        return Icons.assignment_rounded;
      case AppLogoStyle.velvetCocoa:
        return Icons.auto_awesome_mosaic_rounded;
      case AppLogoStyle.cyberObsidian:
        return Icons.bolt_rounded;
      case AppLogoStyle.vedicGold:
        return Icons.shield_rounded;
      case AppLogoStyle.pureWhite:
        return Icons.layers_rounded;
    }
  }

  static String getLogoName(AppLogoStyle style) {
    switch (style) {
      case AppLogoStyle.pariyojanaDefault:
        return 'Sovereign Focus 🛡️';
      case AppLogoStyle.sunsetOrange:
        return 'Sunset Orange 🍊';
      case AppLogoStyle.softwareDev:
        return 'Software Dev 💻';
      case AppLogoStyle.cyberSecurity:
        return 'Cyber Security 🛡️';
      case AppLogoStyle.devopsCicd:
        return 'DevOps & CI/CD 🚀';
      case AppLogoStyle.cloudInfra:
        return 'Cloud Infra ☁️';
      case AppLogoStyle.crmRelationship:
        return 'Customer CRM 🤝';
      case AppLogoStyle.techSupport:
        return 'Tech Support 🎧';
      case AppLogoStyle.aiMachineLearning:
        return 'AI & ML Core 🧠';
      case AppLogoStyle.dataAnalytics:
        return 'Data Analytics 📊';
      case AppLogoStyle.productScrum:
        return 'Product & Agile 📋';
      case AppLogoStyle.velvetCocoa:
        return 'Velvet Cocoa ☕';
      case AppLogoStyle.cyberObsidian:
        return 'Cyber Cyan ⚡';
      case AppLogoStyle.vedicGold:
        return 'Vedic Gold ⚜️';
      case AppLogoStyle.pureWhite:
        return 'Pure White 🏳️';
    }
  }
}
