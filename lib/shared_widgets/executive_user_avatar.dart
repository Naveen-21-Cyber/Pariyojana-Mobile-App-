import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/profile/user_profile_provider.dart';
import '../core/theme/velvet_colors.dart';

/// Ultra-Luxurious Executive User Avatar
/// Supports Google Network photos, emoji personas, custom metallic initials,
/// dual-ring halo, shimmering loading skeleton, and live status indicator.
class ExecutiveUserAvatar extends ConsumerWidget {
  final double size;
  final VoidCallback? onTap;
  final bool showHalo;
  final bool showBadge;
  final double borderWidth;

  const ExecutiveUserAvatar({
    super.key,
    this.size = 32,
    this.onTap,
    this.showHalo = true,
    this.showBadge = true,
    this.borderWidth = 1.5,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(userProfileProvider);
    final avatar = profile.avatarUrl.trim();
    final isHttp = avatar.startsWith('http');
    final isEmoji = avatar.isNotEmpty && !isHttp && avatar.runes.length <= 4;
    final initials = profile.displayName.isNotEmpty
        ? profile.displayName
            .split(' ')
            .where((w) => w.isNotEmpty)
            .map((w) => w[0])
            .take(2)
            .join()
            .toUpperCase()
        : 'U';

    final isDark = Theme.of(context).brightness == Brightness.dark;

    Widget avatarContent;

    if (isHttp) {
      avatarContent = Image.network(
        avatar,
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _buildInitials(context, initials, isDark),
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            width: size,
            height: size,
            color: VelvetColors.cardSurface(context),
            child: const Center(
              child: SizedBox(
                width: 10,
                height: 10,
                child: CircularProgressIndicator(
                  strokeWidth: 1.5,
                  valueColor: AlwaysStoppedAnimation<Color>(VelvetColors.coralPeach),
                ),
              ),
            ),
          );
        },
      );
    } else if (isEmoji) {
      avatarContent = Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: isDark
                ? const [
                    Color(0xFF332626),
                    Color(0xFF1C1414),
                  ]
                : const [
                    Color(0xFFFFF2EC),
                    Color(0xFFFFDDD0),
                  ],
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          avatar,
          style: TextStyle(
            fontSize: size * 0.52,
            height: 1.1,
          ),
        ),
      );
    } else {
      avatarContent = _buildInitials(context, initials, isDark);
    }

    Widget coreAvatar = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: VelvetColors.coralPeach.withValues(alpha: 0.95),
          width: borderWidth,
        ),
        boxShadow: showHalo
            ? [
                BoxShadow(
                  color: VelvetColors.coralPeach.withValues(alpha: isDark ? 0.45 : 0.28),
                  blurRadius: size * 0.4,
                  spreadRadius: 1.2,
                ),
              ]
            : null,
      ),
      child: ClipOval(child: avatarContent),
    );

    if (showBadge) {
      coreAvatar = Stack(
        clipBehavior: Clip.none,
        children: [
          coreAvatar,
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              width: size * 0.32,
              height: size * 0.32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: VelvetColors.mint,
                border: Border.all(
                  color: isDark ? const Color(0xFF141210) : Colors.white,
                  width: 1.4,
                ),
                boxShadow: [
                  BoxShadow(
                    color: VelvetColors.mint.withValues(alpha: 0.6),
                    blurRadius: 4,
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    }

    if (onTap != null) {
      return GestureDetector(
        onTap: () {
          HapticFeedback.lightImpact();
          onTap!();
        },
        child: coreAvatar,
      );
    }

    return coreAvatar;
  }

  Widget _buildInitials(BuildContext context, String initials, bool isDark) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            VelvetColors.coralPeach,
            Color(0xFFFF7A59),
          ],
        ),
      ),
      alignment: Alignment.center,
      child: Text(
        initials,
        style: TextStyle(
          fontSize: size * 0.42,
          fontWeight: FontWeight.w900,
          color: Colors.white,
          letterSpacing: -0.5,
        ),
      ),
    );
  }
}
