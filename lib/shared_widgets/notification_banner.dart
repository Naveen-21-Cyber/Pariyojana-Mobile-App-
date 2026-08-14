import 'package:flutter/material.dart';
import '../core/theme/velvet_colors.dart';

OverlayEntry? _activeBannerEntry;

class VelvetNotificationBanner {
  VelvetNotificationBanner._();

  static void show(
    BuildContext context, {
    required String title,
    required String body,
    IconData icon = Icons.notifications_active_rounded,
    Color accentColor = VelvetColors.coralPeach,
    VoidCallback? onTap,
    Duration duration = const Duration(seconds: 4),
  }) {
    final overlay = Overlay.maybeOf(context, rootOverlay: true);
    if (overlay == null) return;

    // Safely remove existing banner
    try {
      if (_activeBannerEntry != null) {
        _activeBannerEntry!.remove();
        _activeBannerEntry = null;
      }
    } catch (_) {
      _activeBannerEntry = null;
    }

    late OverlayEntry entry;
    entry = OverlayEntry(
      builder: (ctx) => _FloatingBannerWidget(
        title: title,
        body: body,
        icon: icon,
        accentColor: accentColor,
        onTap: () {
          try {
            entry.remove();
            _activeBannerEntry = null;
          } catch (_) {}
          if (onTap != null) onTap();
        },
        onDismiss: () {
          try {
            if (_activeBannerEntry == entry) {
              entry.remove();
              _activeBannerEntry = null;
            }
          } catch (_) {}
        },
      ),
    );

    _activeBannerEntry = entry;
    overlay.insert(entry);

    Future.delayed(duration, () {
      try {
        if (_activeBannerEntry == entry) {
          entry.remove();
          _activeBannerEntry = null;
        }
      } catch (_) {
        _activeBannerEntry = null;
      }
    });
  }
}

class _FloatingBannerWidget extends StatefulWidget {
  final String title;
  final String body;
  final IconData icon;
  final Color accentColor;
  final VoidCallback onTap;
  final VoidCallback onDismiss;

  const _FloatingBannerWidget({
    required this.title,
    required this.body,
    required this.icon,
    required this.accentColor,
    required this.onTap,
    required this.onDismiss,
  });

  @override
  State<_FloatingBannerWidget> createState() => _FloatingBannerWidgetState();
}

class _FloatingBannerWidgetState extends State<_FloatingBannerWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _offsetAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _offsetAnimation = Tween<Offset>(
      begin: const Offset(0.0, -1.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Positioned(
      top: MediaQuery.of(context).padding.top + 8,
      left: 12,
      right: 12,
      child: SlideTransition(
        position: _offsetAnimation,
        child: Material(
          color: Colors.transparent,
          child: GestureDetector(
            onTap: widget.onTap,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E1B18) : Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: widget.accentColor.withValues(alpha: 0.5),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: widget.accentColor.withValues(alpha: 0.25),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: widget.accentColor.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: widget.accentColor.withValues(alpha: 0.4),
                      ),
                    ),
                    child: Icon(
                      widget.icon,
                      color: widget.accentColor,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.title,
                          style: TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w900,
                            color: isDark ? Colors.white : const Color(0xFF1E1B18),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          widget.body,
                          style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w500,
                            color: isDark ? Colors.white70 : Colors.black87,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, size: 18),
                    color: isDark ? Colors.white54 : Colors.black45,
                    onPressed: widget.onDismiss,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
