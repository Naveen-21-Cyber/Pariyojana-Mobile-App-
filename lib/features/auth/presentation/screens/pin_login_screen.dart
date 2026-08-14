import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/velvet_colors.dart';
import '../../../../core/security/auth_service.dart';
import '../../../../shared_widgets/clay_card.dart';
import '../../../../shared_widgets/pariyojana_logo.dart';
import '../../../../core/profile/user_profile_provider.dart';
import 'package:google_fonts/google_fonts.dart';

class PinLoginScreen extends ConsumerStatefulWidget {
  const PinLoginScreen({super.key});

  @override
  ConsumerState<PinLoginScreen> createState() => _PinLoginScreenState();
}

class _PinLoginScreenState extends ConsumerState<PinLoginScreen> {
  String _pinText = '';
  String _errorMessage = '';
  bool _isChecking = false;
  bool _hasAccountOnDevice = true;
  int _pinLength = 6; // loaded from storage

  // Brute-force lockout state
  int _failedAttempts = 0;
  static const int _maxAttempts = 5;
  static const Duration _lockoutDuration = Duration(seconds: 30);
  DateTime? _lockoutUntil;

  bool get _isLockedOut {
    if (_lockoutUntil == null) return false;
    return DateTime.now().isBefore(_lockoutUntil!);
  }

  String get _lockoutRemainingText {
    if (!_isLockedOut) return '';
    final remaining = _lockoutUntil!.difference(DateTime.now()).inSeconds + 1;
    return '🔒 Too many attempts. Try again in ${remaining}s';
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final storage = ref.read(secureStorageProvider);
      final hasPin = await storage.hasPin();
      if (!hasPin) {
        if (mounted) {
          setState(() {
            _hasAccountOnDevice = false;
            _errorMessage = 'ℹ️ No vault account found on this device. Please create your Master PIN first.';
          });
        }
        return;
      }
      // Load the PIN length so dots and auto-check are accurate
      final savedLength = await storage.getPinLength();
      if (mounted) setState(() => _pinLength = savedLength);
      await _triggerBiometrics(silentFail: true);
    });
  }


  Future<void> _triggerBiometrics({bool silentFail = false}) async {
    if (!_hasAccountOnDevice) return;
    final router = GoRouter.of(context);
    try {
      final success = await ref.read(authServiceProvider.notifier).authenticateBiometrics(forcePrompt: true);
      if (success && mounted) {
        await ref.read(userProfileProvider.notifier).loadFromStorage();
        await HapticFeedback.mediumImpact();
        router.go('/ideas');
        return;
      }
    } catch (_) {}

    if (!silentFail && mounted) {
      setState(() {
        _errorMessage = '⚠️ Biometrics unavailable or canceled. Use PIN below.';
      });
      await HapticFeedback.vibrate();
    }
  }

  Future<void> _onKeypadTap(String val) async {
    if (_isChecking) return;


    // Block input during lockout — refresh the countdown display
    if (_isLockedOut) {
      setState(() {
        _errorMessage = _lockoutRemainingText;
      });
      return;
    }

    if (val == 'back') {
      if (_pinText.isNotEmpty) {
        setState(() {
          _pinText = _pinText.substring(0, _pinText.length - 1);
          _errorMessage = '';
        });
        await HapticFeedback.selectionClick();
      }
    } else {
      if (_pinText.length < _pinLength) {
        final newPin = _pinText + val;
        setState(() {
          _pinText = newPin;
          _errorMessage = '';
        });
        await HapticFeedback.selectionClick();

        // Auto-check only when exactly the expected PIN length is entered
        if (newPin.length == _pinLength) {
          unawaited(_verifyPinSubmission(newPin));
        }
      }
    }
  }

  Future<void> _verifyPinSubmission(String pin) async {
    setState(() {
      _isChecking = true;
    });

    final router = GoRouter.of(context);
    final auth = ref.read(authServiceProvider.notifier);
    final success = await auth.verifyPin(pin);

    if (success && mounted) {
      _failedAttempts = 0;
      _lockoutUntil = null;
      await ref.read(userProfileProvider.notifier).loadFromStorage();
      await HapticFeedback.mediumImpact();
      router.go('/ideas');
    } else if (mounted) {
      await HapticFeedback.heavyImpact();
      _failedAttempts++;

      String errorMsg;
      if (_failedAttempts >= _maxAttempts) {
        _lockoutUntil = DateTime.now().add(_lockoutDuration);
        _failedAttempts = 0; // reset counter after lockout starts
        errorMsg = _lockoutRemainingText;
        // Refresh the countdown every second during lockout
        unawaited(Future.doWhile(() async {
          await Future.delayed(const Duration(seconds: 1));
          if (!mounted) return false;
          if (!_isLockedOut) {
            if (mounted) setState(() { _errorMessage = ''; });
            return false;
          }
          if (mounted) setState(() { _errorMessage = _lockoutRemainingText; });
          return true;
        }));
      } else {
        final remaining = _maxAttempts - _failedAttempts;
        errorMsg = '❌ Incorrect PIN. $remaining attempt${remaining == 1 ? '' : 's'} left.';
      }

      setState(() {
        _isChecking = false;
        _errorMessage = errorMsg;
        _pinText = '';
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: VelvetColors.background(context),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [
                    VelvetColors.background(context),
                    const Color(0xFF160E0E),
                    const Color(0xFF1E1313),
                  ]
                : [
                    VelvetColors.cream,
                    const Color(0xFFF6ECE1),
                    const Color(0xFFFFF2EE),
                  ],
          ),
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: IntrinsicHeight(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 20),
                        const PariyojanaLogo(size: 68),
                        const SizedBox(height: 16),
                        Text(
                          'PARIYOJANA',
                          style: GoogleFonts.outfit(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: VelvetColors.textPrimary(context),
                            letterSpacing: 4.0,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Enter PIN to unlock your vault',
                          style: GoogleFonts.outfit(
                            fontSize: 13,
                            color: VelvetColors.textSecondary(context),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 28),

                        // Animated PIN Dot Row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(
                            _pinLength,
                            (index) => AnimatedPinDot(isFilled: index < _pinText.length),
                          ),
                        ),
                        const SizedBox(height: 18),

                        // Error or Feedback Message
                        if (_errorMessage.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            child: Text(
                              _errorMessage,
                              style: const TextStyle(
                                color: Colors.redAccent,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        const SizedBox(height: 24),

                        // PIN Keypad grid with animated keys
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 44.0),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  AnimatedKeypadButton(label: '1', onTap: () => _onKeypadTap('1')),
                                  AnimatedKeypadButton(label: '2', onTap: () => _onKeypadTap('2')),
                                  AnimatedKeypadButton(label: '3', onTap: () => _onKeypadTap('3')),
                                ],
                              ),
                              const SizedBox(height: 14),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  AnimatedKeypadButton(label: '4', onTap: () => _onKeypadTap('4')),
                                  AnimatedKeypadButton(label: '5', onTap: () => _onKeypadTap('5')),
                                  AnimatedKeypadButton(label: '6', onTap: () => _onKeypadTap('6')),
                                ],
                              ),
                              const SizedBox(height: 14),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  AnimatedKeypadButton(label: '7', onTap: () => _onKeypadTap('7')),
                                  AnimatedKeypadButton(label: '8', onTap: () => _onKeypadTap('8')),
                                  AnimatedKeypadButton(label: '9', onTap: () => _onKeypadTap('9')),
                                ],
                              ),
                              const SizedBox(height: 14),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  // Fingerprint scanner button
                                  FingerprintScannerWidget(onTap: () => _triggerBiometrics(silentFail: false)),
                                  AnimatedKeypadButton(label: '0', onTap: () => _onKeypadTap('0')),
                                  AnimatedKeypadButton(
                                    label: 'back',
                                    onTap: () => _onKeypadTap('back'),
                                    icon: Icon(
                                      Icons.backspace_outlined,
                                      color: VelvetColors.iconColor(context),
                                      size: 22,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextButton(
                          onPressed: () => context.go('/pin_setup'),
                          child: Text(
                            _hasAccountOnDevice
                                ? 'Change Vault Account / Reset PIN ➔'
                                : 'Create Master PIN & Setup Vault ➔',
                            style: GoogleFonts.outfit(
                              fontWeight: FontWeight.w600,
                              color: VelvetColors.coralPeach,
                              fontSize: 12.5,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class AnimatedPinDot extends StatelessWidget {
  final bool isFilled;
  const AnimatedPinDot({super.key, required this.isFilled});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOutBack,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      width: isFilled ? 18 : 14,
      height: isFilled ? 18 : 14,
      decoration: BoxDecoration(
        color: isFilled ? VelvetColors.coralPeach : Colors.transparent,
        shape: BoxShape.circle,
        border: Border.all(
          color: isFilled ? VelvetColors.coralPeach : VelvetColors.border(context),
          width: 2,
        ),
        boxShadow: isFilled
            ? [
                BoxShadow(
                  color: VelvetColors.coralPeach.withValues(alpha: 0.4),
                  blurRadius: 6,
                  spreadRadius: 1,
                )
              ]
            : [],
      ),
    );
  }
}

class AnimatedKeypadButton extends StatefulWidget {
  final String label;
  final VoidCallback onTap;
  final Widget? icon;

  const AnimatedKeypadButton({
    super.key,
    required this.label,
    required this.onTap,
    this.icon,
  });

  @override
  State<AnimatedKeypadButton> createState() => _AnimatedKeypadButtonState();
}

class _AnimatedKeypadButtonState extends State<AnimatedKeypadButton> {
  double _scale = 1.0;
  double _depth = 5.0;

  void _handleTap() {
    setState(() {
      _scale = 0.88;
      _depth = 1.5;
    });
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
        setState(() {
          _scale = 1.0;
          _depth = 5.0;
        });
      }
    });
    widget.onTap();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: _scale,
      duration: const Duration(milliseconds: 100),
      curve: Curves.easeOut,
      child: ClayCard(
        color: VelvetColors.cardSurface(context),
        borderRadius: 36,
        depth: _depth,
        padding: EdgeInsets.zero,
        onTap: _handleTap,
        child: SizedBox(
          width: 68,
          height: 68,
          child: Center(
            child: widget.icon ??
                Text(
                  widget.label,
                  style: TextStyle(
                    fontFamily: GoogleFonts.outfit().fontFamily,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: VelvetColors.textPrimary(context),
                  ),
                ),
          ),
        ),
      ),
    );
  }
}

class FingerprintScannerWidget extends StatefulWidget {
  final VoidCallback onTap;
  const FingerprintScannerWidget({super.key, required this.onTap});

  @override
  State<FingerprintScannerWidget> createState() => _FingerprintScannerWidgetState();
}

class _FingerprintScannerWidgetState extends State<FingerprintScannerWidget> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final scanValue = _controller.value;
        return ClayCard(
          color: VelvetColors.cardSurface(context),
          borderRadius: 36,
          depth: 5.0,
          padding: EdgeInsets.zero,
          onTap: widget.onTap,
          child: SizedBox(
            width: 68,
            height: 68,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(36),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: VelvetColors.coralPeach.withValues(alpha: 0.1 + 0.15 * scanValue),
                    ),
                  ),
                  const Icon(
                    Icons.fingerprint_rounded,
                    color: VelvetColors.coralPeach,
                    size: 30,
                  ),
                  Positioned(
                    top: 16 + (32 * scanValue),
                    left: 16,
                    right: 16,
                    child: Container(
                      height: 2.0,
                      decoration: BoxDecoration(
                        color: VelvetColors.coralPeach,
                        boxShadow: [
                          BoxShadow(
                            color: VelvetColors.coralPeach.withValues(alpha: 0.8),
                            blurRadius: 4,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
