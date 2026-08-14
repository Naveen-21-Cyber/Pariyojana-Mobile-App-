import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/theme/app_logo_provider.dart';

class PariyojanaLogo extends ConsumerWidget {
  final double size;

  const PariyojanaLogo({
    super.key,
    this.size = 100,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final style = ref.watch(appLogoProvider);
    final spec = _logoSpec(style);

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: spec.gradientColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(size * 0.28),
        boxShadow: [
          BoxShadow(
            color: spec.gradientColors.first.withValues(alpha: 0.45),
            blurRadius: size * 0.4,
            spreadRadius: 0,
            offset: Offset(0, size * 0.12),
          ),
        ],
      ),
      child: Center(child: _buildLogoContent(spec)),
    );
  }

  Widget _buildLogoContent(_LogoSpec spec) {
    if (spec.assetPath != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(size * 0.28),
        child: Image.asset(
          spec.assetPath!,
          width: size,
          height: size,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _letterWidget(spec.letter),
        ),
      );
    }
    if (spec.icon != null) {
      return Icon(spec.icon, color: Colors.white, size: size * 0.56);
    }
    return _letterWidget(spec.letter);
  }

  Widget _letterWidget(String letter) => Text(
        letter,
        style: TextStyle(
          fontFamily: 'Outfit',
          fontSize: size * 0.58,
          fontWeight: FontWeight.w900,
          color: Colors.white,
          height: 1,
        ),
      );

  static _LogoSpec _logoSpec(AppLogoStyle style) {
    switch (style) {
      case AppLogoStyle.pariyojanaDefault:
        return const _LogoSpec(
          gradientColors: [Color(0xFFFF6B4A), Color(0xFFFF3D1A)],
          letter: 'P',
          assetPath: 'assets/branding/app_icon.png',
        );
      case AppLogoStyle.sunsetOrange:
        return const _LogoSpec(
          gradientColors: [Color(0xFFFF8C42), Color(0xFFFF4500)],
          icon: Icons.local_fire_department_rounded,
          letter: '🔥',
        );
      case AppLogoStyle.softwareDev:
        return const _LogoSpec(
          gradientColors: [Color(0xFF4A90D9), Color(0xFF1A5FA8)],
          icon: Icons.code_rounded,
          letter: '</>',
        );
      case AppLogoStyle.cyberSecurity:
        return const _LogoSpec(
          gradientColors: [Color(0xFF2DBD8A), Color(0xFF0D7A57)],
          icon: Icons.security_rounded,
          letter: '🛡',
        );
      case AppLogoStyle.devopsCicd:
        return const _LogoSpec(
          gradientColors: [Color(0xFF9B59B6), Color(0xFF6C3483)],
          icon: Icons.rocket_launch_rounded,
          letter: '🚀',
        );
      case AppLogoStyle.cloudInfra:
        return const _LogoSpec(
          gradientColors: [Color(0xFF5DADE2), Color(0xFF2471A3)],
          icon: Icons.cloud_done_rounded,
          letter: '☁',
        );
      case AppLogoStyle.crmRelationship:
        return const _LogoSpec(
          gradientColors: [Color(0xFFF39C12), Color(0xFFD68910)],
          icon: Icons.handshake_rounded,
          letter: '🤝',
        );
      case AppLogoStyle.techSupport:
        return const _LogoSpec(
          gradientColors: [Color(0xFF48C9B0), Color(0xFF17A589)],
          icon: Icons.support_agent_rounded,
          letter: '🎧',
        );
      case AppLogoStyle.aiMachineLearning:
        return const _LogoSpec(
          gradientColors: [Color(0xFFAB47BC), Color(0xFF7B1FA2)],
          icon: Icons.psychology_rounded,
          letter: '🧠',
        );
      case AppLogoStyle.dataAnalytics:
        return const _LogoSpec(
          gradientColors: [Color(0xFF26A69A), Color(0xFF00695C)],
          icon: Icons.analytics_rounded,
          letter: '📊',
        );
      case AppLogoStyle.productScrum:
        return const _LogoSpec(
          gradientColors: [Color(0xFF42A5F5), Color(0xFF1565C0)],
          icon: Icons.assignment_rounded,
          letter: '📋',
        );
      case AppLogoStyle.velvetCocoa:
        return const _LogoSpec(
          gradientColors: [Color(0xFF8D6E63), Color(0xFF4E342E)],
          icon: Icons.auto_awesome_mosaic_rounded,
          letter: 'V',
        );
      case AppLogoStyle.cyberObsidian:
        return const _LogoSpec(
          gradientColors: [Color(0xFF00E5FF), Color(0xFF0077B6)],
          icon: Icons.bolt_rounded,
          letter: '⚡',
        );
      case AppLogoStyle.vedicGold:
        return const _LogoSpec(
          gradientColors: [Color(0xFFFFD700), Color(0xFFB8860B)],
          icon: Icons.shield_rounded,
          letter: '⚜',
        );
      case AppLogoStyle.pureWhite:
        return const _LogoSpec(
          gradientColors: [Color(0xFFECEFF1), Color(0xFFB0BEC5)],
          icon: Icons.layers_rounded,
          letter: 'P',
        );
    }
  }

}

class _LogoSpec {
  final List<Color> gradientColors;
  final String letter;
  final IconData? icon;
  final String? assetPath;

  const _LogoSpec({
    required this.gradientColors,
    required this.letter,
    this.icon,
    this.assetPath,
  });
}
