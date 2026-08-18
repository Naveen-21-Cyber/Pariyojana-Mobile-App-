import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../../../core/backup/google_backup_service.dart';
import '../../../../core/security/auth_service.dart';
import '../../../../core/security/totp_service.dart';
import '../../../../core/theme/velvet_colors.dart';
import '../../../../shared_widgets/clay_card.dart';
import '../../../../shared_widgets/pariyojana_logo.dart';
import '../../../../core/profile/user_profile_provider.dart';

class PinSetupScreen extends ConsumerStatefulWidget {
  const PinSetupScreen({super.key});

  @override
  ConsumerState<PinSetupScreen> createState() => _PinSetupScreenState();
}

class _PinSetupScreenState extends ConsumerState<PinSetupScreen> {
  int _step = 0; // 0: Welcome, 1: Profile & Master PIN Setup

  final _usernameController = TextEditingController(text: 'Pariyojana User');
  final _bioController = TextEditingController(text: 'Full-Stack Developer & Security Researcher');
  final _pinController = TextEditingController();
  final _confirmPinController = TextEditingController();
  final _totpVerifyController = TextEditingController();

  int _selectedPinLength = 6;
  bool _enableBiometrics = true;
  bool _isGoogleSigningIn = false;
  bool _isGoogleAuthenticated = false;
  String? _googleEmail;
  String? _googlePhotoUrl;
  String _errorMessage = '';

  // Google Authenticator / Authy / Microsoft Authenticator 2FA
  bool _enableAuthenticator = false;
  String? _totpSecret;
  bool _isTotpVerified = false;
  bool _isTotpSecretVisible = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _bioController.dispose();
    _pinController.dispose();
    _confirmPinController.dispose();
    _totpVerifyController.dispose();
    super.dispose();
  }

  void _generateNewTotpSecret() {
    final secret = TotpService.generateSecret();
    setState(() {
      _totpSecret = secret;
      _isTotpVerified = false;
      _totpVerifyController.clear();
    });
  }

  bool _verifyEnteredTotp() {
    if (_totpSecret == null) return false;
    final code = _totpVerifyController.text.trim();
    final isValid = TotpService.verifyOtp(_totpSecret!, code);
    setState(() {
      _isTotpVerified = isValid;
    });
    return isValid;
  }



  Future<void> _handleGoogleSignIn() async {
    setState(() {
      _isGoogleSigningIn = true;
      _errorMessage = '';
    });

    try {
      await HapticFeedback.mediumImpact();
      final googleService = ref.read(googleBackupServiceProvider);
      final success = await googleService.signIn();

      if (success) {
        final email = await googleService.getUserEmail();
        final photoUrl = await googleService.getUserPhotoUrl();
        if (email != null && email.isNotEmpty && mounted) {
          final displayName = email.split('@').first;
          setState(() {
            _googleEmail = email;
            _googlePhotoUrl = photoUrl;
            _isGoogleAuthenticated = true;
            _usernameController.text = displayName;
            _step = 1;
          });
          await ref.read(userProfileProvider.notifier).updateProfile(
            fullName: displayName,
            avatarUrl: photoUrl ?? '',
          );
        }
      } else {
        if (mounted) {
          _showFallbackEmailDialog(context, error: 'Google Play Services unavailable on this device.');
        }
      }
    } catch (e) {
      if (mounted) {
        _showFallbackEmailDialog(context, error: e.toString());
      }
    } finally {
      if (mounted) {
        setState(() {
          _isGoogleSigningIn = false;
        });
      }
    }
  }

  void _showFallbackEmailDialog(BuildContext context, {required String error}) {
    final emailController = TextEditingController();
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: VelvetColors.surface(context),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Account Setup & Email Link ☁️', style: TextStyle(fontWeight: FontWeight.bold, color: VelvetColors.textPrimary(context))),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Enter your email to link your account and initialize your sovereign profile:',
              style: TextStyle(fontSize: 12, color: VelvetColors.textSecondary(context)),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              autofocus: true,
              style: TextStyle(fontSize: 13, color: VelvetColors.textPrimary(context)),
              decoration: InputDecoration(
                hintText: 'user@gmail.com',
                labelText: 'Google Email',
                prefixIcon: const Icon(Icons.email_outlined, size: 18, color: VelvetColors.coralPeach),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              emailController.dispose();
              Navigator.pop(dialogCtx);
            },
            child: Text('Cancel', style: TextStyle(color: VelvetColors.textSecondary(context))),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: VelvetColors.coralPeach,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () async {
              final email = emailController.text.trim();
              if (email.isNotEmpty && email.contains('@')) {
                final googleService = ref.read(googleBackupServiceProvider);
                await googleService.simulateSignIn(email);
                final displayName = email.split('@').first;
                if (mounted) {
                  setState(() {
                    _googleEmail = email;
                    _isGoogleAuthenticated = true;
                    _usernameController.text = displayName;
                    _step = 1;
                  });
                }
                emailController.dispose();
                if (dialogCtx.mounted) Navigator.pop(dialogCtx);
              }
            },
            child: const Text('Sign In With Email'),
          ),
        ],
      ),
    );
  }


  Future<void> _onRegisterSubmit() async {
    setState(() {
      _errorMessage = '';
    });

    final username = _usernameController.text.trim();
    final pin = _pinController.text.trim();
    final confirm = _confirmPinController.text.trim();

    if (username.isEmpty || pin.isEmpty) {
      setState(() {
        _errorMessage = 'Username and Master PIN cannot be empty.';
      });
      return;
    }

    if (username.length > 24) {
      setState(() {
        _errorMessage = 'Username cannot exceed 24 characters.';
      });
      return;
    }

    if (pin.length != _selectedPinLength) {
      setState(() {
        _errorMessage = 'PIN must be exactly $_selectedPinLength numeric digits.';
      });
      return;
    }

    if (pin != confirm) {
      setState(() {
        _errorMessage = 'PIN and Confirmation PIN do not match.';
      });
      return;
    }

    // Validate TOTP if Authenticator is enabled
    if (_enableAuthenticator) {
      if (!_isTotpVerified) {
        final isValid = _verifyEnteredTotp();
        if (!isValid) {
          setState(() {
            _errorMessage = 'Invalid 6-digit Authenticator Code. Scan QR & enter current OTP.';
          });
          return;
        }
      }
    }

    final router = GoRouter.of(context);
    final auth = ref.read(authServiceProvider.notifier);
    final userProfileNotifier = ref.read(userProfileProvider.notifier);
    final bio = _bioController.text.trim().isEmpty ? 'Tech Innovator & Project Builder' : _bioController.text.trim();

    // Register user profile & setup encrypted Master PIN + optional TOTP 2FA
    final success = await auth.registerProfile(
      username: username,
      password: pin,
      totpSecret: _enableAuthenticator ? _totpSecret : null,
      enableBiometrics: _enableBiometrics,
    );

    if (success) {
      final pinSuccess = await auth.setupPin(pin, _enableBiometrics);
      if (pinSuccess) {
        await userProfileNotifier.updateProfile(
          fullName: username,
          title: bio,
          avatarUrl: _googlePhotoUrl,
        );
        if (mounted) {
          router.go('/ideas');
        }
        return;
      }
    }

    if (mounted) {
      setState(() {
        _errorMessage = 'Failed to register vault profile. Please try again.';
      });
    }
  }

  Widget _buildGoogleButtonWidget() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: _isGoogleSigningIn ? null : _handleGoogleSignIn,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: double.infinity,
        constraints: const BoxConstraints(maxWidth: 320),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF241B1B) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isDark ? VelvetColors.border(context) : Colors.black.withValues(alpha: 0.2)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.08),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: _isGoogleSigningIn
            ? const Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Color(0xFF4285F4),
                  ),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CustomPaint(
                    size: const Size(20, 20),
                    painter: _GoogleSvgLogoPainter(),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'CONTINUE WITH GOOGLE',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : const Color(0xFF413F3F),
                      letterSpacing: 0.6,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildWelcomeSlide() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 24),
          const PariyojanaLogo(size: 76),
          const SizedBox(height: 24),
          Text(
            'PARIYOJANA',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: VelvetColors.textPrimary(context),
              letterSpacing: 4.0,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          Text(
            'Secured Personal Command Center',
            style: TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w600,
              color: VelvetColors.textSecondary(context),
              letterSpacing: 0.8,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 18),
          Text(
            'Pariyojana is your unified human-centered career & intelligence workspace. Effortlessly organize ideas, track projects, and analyze job opportunities.',
            style: TextStyle(
              fontSize: 13,
              color: VelvetColors.textSecondary(context),
              height: 1.45,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 22),

          // EXACT CUSTOM CSS/SVG SIGN IN WITH GOOGLE BUTTON
          _buildGoogleButtonWidget(),
          const SizedBox(height: 18),

          Row(
            children: [
              Expanded(
                child: Divider(
                  color: VelvetColors.border(context),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  'OR SET UP PIN VAULT',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                    color: VelvetColors.textSecondary(context),
                  ),
                ),
              ),
              Expanded(
                child: Divider(
                  color: VelvetColors.border(context),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),

          // Sacred Guidance Card
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 4),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF281C10) : const Color(0xFFFFF8F0),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isDark ? const Color(0xFFB45309) : const Color(0xFFE5A852),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.15),
                  blurRadius: 14,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('📜', style: TextStyle(fontSize: 15)),
                    const SizedBox(width: 6),
                    Text(
                      'SACRED GUIDANCE',
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.8,
                        color: isDark ? const Color(0xFFFBBF24) : const Color(0xFFB45309),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  'ಪ್ರಯತ್ನಂ ಸರ್ವ ಸಿದ್ಧಿ ಸಾಧನಂ',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                    color: isDark ? const Color(0xFFFEF3C7) : const Color(0xFF1E1005),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 3),
                Text(
                  '"Effort is the ultimate key to achieve all success in life."',
                  style: TextStyle(
                    fontSize: 11,
                    fontStyle: FontStyle.italic,
                    fontWeight: FontWeight.w600,
                    color: isDark ? const Color(0xFFFDE68A) : const Color(0xFF7C4A03),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: VelvetColors.coralPeach,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 52),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 4,
            ),
            onPressed: () => setState(() => _step = 1),
            child: const Text(
              'PROCEED TO MASTER PIN SETUP ➔',
              style: TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 13.5,
                letterSpacing: 0.8,
              ),
            ),
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: () => context.go('/pin_login'),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Already have an account? ',
                  style: TextStyle(
                    fontSize: 13,
                    color: VelvetColors.textSecondary(context),
                  ),
                ),
                const Text(
                  'Sign In 🔑',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: VelvetColors.coralPeach,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileSlide() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 12),
        Text(
          _isGoogleAuthenticated
              ? 'Google Identity & Master PIN Setup'
              : 'Vault Security Provisioning',
          style: TextStyle(
            fontSize: 21,
            fontWeight: FontWeight.bold,
            color: VelvetColors.textPrimary(context),
            letterSpacing: 1.0,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        Text(
          _isGoogleAuthenticated
              ? 'Signed in as $_googleEmail • Set up your local Master PIN'
              : 'Provision local encrypted vault with biometric armor',
          style: TextStyle(
            fontSize: 11.5,
            color: _isGoogleAuthenticated
                ? (isDark ? const Color(0xFF4ADE80) : Colors.green.shade800)
                : VelvetColors.textSecondary(context),
            fontWeight: _isGoogleAuthenticated
                ? FontWeight.bold
                : FontWeight.normal,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 14),

        if (!_isGoogleAuthenticated) ...[
          _buildGoogleButtonWidget(),
          const SizedBox(height: 14),
        ],

        // 🛡️ HARDWARE SAFETY KEY EXPLANATION CARD
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF0F1E36) : const Color(0xFFEFF6FF),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark ? const Color(0xFF2563EB) : const Color(0xFF3B82F6).withValues(alpha: 0.4),
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF3B82F6).withValues(alpha: 0.08),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.shield_outlined, size: 16, color: Color(0xFF3B82F6)),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'WHY MASTER PIN IS REQUIRED',
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.0,
                        color: isDark ? const Color(0xFF93C5FD) : const Color(0xFF1E40AF),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                'Your Master PIN derives the hardware encryption key inside Android KeyStore TEE — keeping local database tables 100% encrypted at rest.',
                style: TextStyle(
                  fontSize: 11,
                  color: isDark ? const Color(0xFFBFDBFE) : const Color(0xFF1E3A8A),
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        if (_errorMessage.isNotEmpty) ...[
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.redAccent.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.redAccent.withValues(alpha: 0.4)),
            ),
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
          if (_errorMessage.contains('SHA-1'))
            TextButton.icon(
              onPressed: () => _showFallbackEmailDialog(context, error: _errorMessage),
              icon: const Icon(Icons.email_outlined, size: 16, color: VelvetColors.coralPeach),
              label: const Text('Sign in with email instead', style: TextStyle(fontSize: 12, color: VelvetColors.coralPeach)),
            ),
          const SizedBox(height: 10),
        ],

        ClayCard(
          color: VelvetColors.cardSurface(context),
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Username (Max 24 chars)',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: VelvetColors.textPrimary(context),
                      fontSize: 13,
                    ),
                  ),
                  Text(
                    '${_usernameController.text.length}/24',
                    style: TextStyle(
                      fontSize: 11,
                      color: VelvetColors.textSecondary(context),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _usernameController,
                maxLength: 24,
                inputFormatters: [
                  LengthLimitingTextInputFormatter(24),
                ],
                onChanged: (_) => setState(() {}),
                style: TextStyle(color: VelvetColors.textPrimary(context)),
                decoration: InputDecoration(
                  counterText: '',
                  hintText: 'Pariyojana User',
                  hintStyle: TextStyle(
                    color: VelvetColors.textSecondary(context).withValues(alpha: 0.5),
                  ),
                  filled: true,
                  fillColor: VelvetColors.surface(context),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: VelvetColors.border(context)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: VelvetColors.border(context)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: VelvetColors.coralPeach, width: 1.5),
                  ),
                ),
              ),
              const SizedBox(height: 14),

              Text(
                'Professional Bio / Title',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: VelvetColors.textPrimary(context),
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _bioController,
                maxLength: 64,
                inputFormatters: [
                  LengthLimitingTextInputFormatter(64),
                ],
                style: TextStyle(color: VelvetColors.textPrimary(context)),
                decoration: InputDecoration(
                  counterText: '',
                  hintText: 'e.g. Full-Stack Developer & Security Researcher',
                  hintStyle: TextStyle(
                    color: VelvetColors.textSecondary(context).withValues(alpha: 0.5),
                  ),
                  filled: true,
                  fillColor: VelvetColors.surface(context),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: VelvetColors.border(context)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: VelvetColors.border(context)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: VelvetColors.coralPeach, width: 1.5),
                  ),
                ),
              ),
              const SizedBox(height: 14),

              Row(
                children: [
                  const Icon(Icons.pin_rounded, size: 18, color: VelvetColors.coralPeach),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Master PIN Tier',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: VelvetColors.textPrimary(context),
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),
              Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 8.0,
                runSpacing: 6.0,
                children: [
                  ...[
                    {'len': 6, 'label': '6 Digits (Standard)'},
                    {'len': 8, 'label': '8 Digits'},
                    {'len': 12, 'label': '12 Digits (High Security)'},
                  ].map((item) {
                    final len = item['len'] as int;
                    final label = item['label'] as String;
                    final isSel = _selectedPinLength == len;
                    return ChoiceChip(
                      label: Text(
                        label,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: isSel ? Colors.white : VelvetColors.textPrimary(context),
                        ),
                      ),
                      selected: isSel,
                      selectedColor: VelvetColors.coralPeach,
                      backgroundColor: VelvetColors.surface(context),
                      onSelected: (val) {
                        if (val) setState(() => _selectedPinLength = len);
                      },
                    );
                  }),
                ],
              ),
              const SizedBox(height: 14),

              Text(
                'Enter $_selectedPinLength-Digit Master PIN',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: VelvetColors.textPrimary(context),
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _pinController,
                obscureText: true,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(_selectedPinLength),
                ],
                style: TextStyle(
                  color: VelvetColors.textPrimary(context),
                  fontWeight: FontWeight.bold,
                  letterSpacing: 3.0,
                ),
                decoration: InputDecoration(
                  hintText: '•' * _selectedPinLength,
                  hintStyle: TextStyle(
                    color: VelvetColors.textSecondary(context).withValues(alpha: 0.5),
                    letterSpacing: 3.0,
                  ),
                  filled: true,
                  fillColor: VelvetColors.surface(context),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: VelvetColors.border(context)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: VelvetColors.border(context)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: VelvetColors.coralPeach, width: 1.5),
                  ),
                ),
              ),
              const SizedBox(height: 14),

              Text(
                'Confirm $_selectedPinLength-Digit Master PIN',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: VelvetColors.textPrimary(context),
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _confirmPinController,
                obscureText: true,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(_selectedPinLength),
                ],
                style: TextStyle(
                  color: VelvetColors.textPrimary(context),
                  fontWeight: FontWeight.bold,
                  letterSpacing: 3.0,
                ),
                decoration: InputDecoration(
                  hintText: '•' * _selectedPinLength,
                  hintStyle: TextStyle(
                    color: VelvetColors.textSecondary(context).withValues(alpha: 0.5),
                    letterSpacing: 3.0,
                  ),
                  filled: true,
                  fillColor: VelvetColors.surface(context),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: VelvetColors.border(context)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: VelvetColors.border(context)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: VelvetColors.coralPeach, width: 1.5),
                  ),
                ),
              ),
              const SizedBox(height: 14),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        const Icon(Icons.fingerprint_rounded, size: 18, color: VelvetColors.coralPeach),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            'Enable Biometrics (Finger / Face ID)',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: VelvetColors.textPrimary(context),
                              fontSize: 12.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Switch.adaptive(
                    value: _enableBiometrics,
                    activeThumbColor: VelvetColors.coralPeach,
                    onChanged: (val) {
                      setState(() => _enableBiometrics = val);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // 2FA GOOGLE AUTHENTICATOR TOGGLE
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        const Icon(Icons.security_rounded, size: 18, color: Color(0xFF9333EA)),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            'Google Authenticator / Authy (2FA)',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: VelvetColors.textPrimary(context),
                              fontSize: 12.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Switch.adaptive(
                    value: _enableAuthenticator,
                    activeThumbColor: const Color(0xFF9333EA),
                    onChanged: (val) {
                      setState(() {
                        _enableAuthenticator = val;
                        if (val && _totpSecret == null) {
                          _generateNewTotpSecret();
                        }
                      });
                    },
                  ),
                ],
              ),

              // REAL SCANNABLE QR CODE & REAL 6-DIGIT VERIFICATION SETUP
              if (_enableAuthenticator && _totpSecret != null) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF201330) : const Color(0xFFF3E8FF),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: const Color(0xFF9333EA).withValues(alpha: 0.4),
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'Scan QR in Google Authenticator or Authy',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: isDark ? const Color(0xFFD8B4FE) : const Color(0xFF581C87),
                        ),
                      ),
                      const SizedBox(height: 8),

                      // 🛡️ PRIVACY SHIELD NOTICE
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF2D1B44) : const Color(0xFFFAF5FF),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: const Color(0xFFC084FC).withValues(alpha: 0.4),
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.shield_rounded, size: 14, color: Color(0xFFC084FC)),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                'Screenshots are disabled app-wide for security. Scan this QR code with a secondary device or copy the secret key below to paste directly into your Authenticator app.',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: isDark ? const Color(0xFFE9D5FF) : const Color(0xFF6B21A8),
                                  height: 1.3,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: const [
                            BoxShadow(color: Colors.black12, blurRadius: 6),
                          ],
                        ),
                        child: QrImageView(
                          data: 'otpauth://totp/Pariyojana:${_usernameController.text.trim().isEmpty ? 'User' : _usernameController.text.trim()}?secret=$_totpSecret&issuer=Pariyojana',
                          version: QrVersions.auto,
                          size: 150,
                          eyeStyle: const QrEyeStyle(
                            eyeShape: QrEyeShape.square,
                            color: Color(0xFF581C87),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF2D1B44) : Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: const Color(0xFF9333EA).withValues(alpha: 0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                _isTotpSecretVisible
                                    ? 'Secret: $_totpSecret'
                                    : 'Secret: ••••••••••••••••',
                                style: TextStyle(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'monospace',
                                  color: isDark ? const Color(0xFFE9D5FF) : const Color(0xFF6B21A8),
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            IconButton(
                              icon: Icon(
                                _isTotpSecretVisible
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                                size: 16,
                                color: isDark ? const Color(0xFFD8B4FE) : const Color(0xFF6B21A8),
                              ),
                              onPressed: () {
                                setState(() {
                                  _isTotpSecretVisible = !_isTotpSecretVisible;
                                });
                              },
                              tooltip: 'Toggle Privacy Mask',
                            ),
                            IconButton(
                              icon: Icon(
                                Icons.copy_rounded,
                                size: 16,
                                color: isDark ? const Color(0xFFD8B4FE) : const Color(0xFF6B21A8),
                              ),
                              onPressed: () {
                                Clipboard.setData(ClipboardData(text: _totpSecret!));
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Secret copied! Auto-clearing clipboard in 30s for anti-forensic security 🛡️'),
                                    duration: Duration(seconds: 3),
                                  ),
                                );

                                // 30-Second Anti-Forensic Clipboard Auto-Clear
                                Future.delayed(const Duration(seconds: 30), () {
                                  Clipboard.setData(const ClipboardData(text: ''));
                                });
                              },
                              tooltip: 'Copy Base32 Secret',
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _totpVerifyController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(6),
                        ],
                        onChanged: (_) => _verifyEnteredTotp(),
                        style: TextStyle(
                          color: isDark ? const Color(0xFFF3E8FF) : const Color(0xFF581C87),
                          fontWeight: FontWeight.bold,
                          letterSpacing: 3.0,
                        ),
                        textAlign: TextAlign.center,
                        decoration: InputDecoration(
                          hintText: 'Enter 6-Digit Code',
                          hintStyle: TextStyle(
                            color: (isDark ? const Color(0xFFC084FC) : const Color(0xFF581C87)).withValues(alpha: 0.5),
                            letterSpacing: 1.0,
                          ),
                          filled: true,
                          fillColor: isDark ? const Color(0xFF2D1B44) : Colors.white,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Color(0xFF9333EA)),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Color(0xFF9333EA)),
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            _isTotpVerified
                                ? Icons.check_circle_rounded
                                : Icons.pending_outlined,
                            size: 14,
                            color: _isTotpVerified ? Colors.green : Colors.orange,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _isTotpVerified
                                ? 'Authenticator 2FA Verified!'
                                : 'Enter current 6-digit OTP to verify',
                            style: TextStyle(
                              fontSize: 10.5,
                              fontWeight: FontWeight.bold,
                              color: _isTotpVerified ? Colors.green : Colors.orange,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),

        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            OutlinedButton(
              style: OutlinedButton.styleFrom(
                foregroundColor: VelvetColors.textPrimary(context),
                side: BorderSide(color: VelvetColors.border(context)),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              ),
              onPressed: () => setState(() => _step = 0),
              child: const Text('Back'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: VelvetColors.coralPeach,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
              ),
              onPressed: _onRegisterSubmit,
              child: Text(
                _isGoogleAuthenticated
                    ? 'Lock Workspace & Initialize 🛡️'
                    : 'Initialize Vault 🚀',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ],
    );
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
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (_step == 0) _buildWelcomeSlide(),
                if (_step == 1) _buildProfileSlide(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Official 4-Color Google Vector Logo Custom Painter
class _GoogleSvgLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final scaleX = size.width / 256.0;
    final scaleY = size.height / 262.0;
    canvas.scale(scaleX, scaleY);

    // Blue Path (#4285F4)
    final bluePaint = Paint()..color = const Color(0xFF4285F4);
    final bluePath = Path()
      ..moveTo(255.878, 133.451)
      ..cubicTo(255.878, 122.717, 255.007, 114.884, 253.122, 106.761)
      ..lineTo(130.55, 106.761)
      ..lineTo(130.55, 155.209)
      ..lineTo(202.497, 155.209)
      ..cubicTo(201.047, 167.249, 193.214, 185.381, 175.807, 197.565)
      ..lineTo(175.563, 199.187)
      ..lineTo(214.318, 229.21)
      ..lineTo(217.003, 229.478)
      ..cubicTo(241.662, 206.704, 255.878, 173.196, 255.878, 133.451)
      ..close();
    canvas.drawPath(bluePath, bluePaint);

    // Green Path (#34A853)
    final greenPaint = Paint()..color = const Color(0xFF34A853);
    final greenPath = Path()
      ..moveTo(130.55, 261.1)
      ..cubicTo(165.798, 261.1, 195.389, 249.495, 217.003, 229.478)
      ..lineTo(175.807, 197.565)
      ..cubicTo(164.783, 205.253, 149.987, 210.62, 130.55, 210.62)
      ..cubicTo(96.027, 210.62, 66.726, 187.847, 56.281, 156.37)
      ..lineTo(54.75, 156.5)
      ..lineTo(14.452, 187.687)
      ..lineTo(13.925, 189.152)
      ..cubicTo(35.393, 231.798, 79.49, 261.1, 130.55, 261.1)
      ..close();
    canvas.drawPath(greenPath, greenPaint);

    // Yellow Path (#FBBC05)
    final yellowPaint = Paint()..color = const Color(0xFFFBBC05);
    final yellowPath = Path()
      ..moveTo(56.281, 156.37)
      ..cubicTo(53.525, 148.247, 51.93, 139.543, 51.93, 130.55)
      ..cubicTo(51.93, 121.556, 53.525, 112.853, 56.136, 104.73)
      ..lineTo(56.063, 103.0)
      ..lineTo(15.26, 71.312)
      ..lineTo(13.925, 71.947)
      ..cubicTo(5.077, 89.644, 0.0, 109.517, 0.0, 130.55)
      ..cubicTo(0.0, 151.583, 5.077, 171.456, 13.925, 189.152)
      ..lineTo(56.281, 156.37)
      ..close();
    canvas.drawPath(yellowPath, yellowPaint);

    // Red Path (#EB4335)
    final redPaint = Paint()..color = const Color(0xFFEB4335);
    final redPath = Path()
      ..moveTo(130.55, 50.479)
      ..cubicTo(155.064, 50.479, 171.6, 61.068, 181.029, 69.917)
      ..lineTo(217.873, 33.943)
      ..cubicTo(195.245, 12.91, 165.798, 0.0, 130.55, 0.0)
      ..cubicTo(79.49, 0.0, 35.393, 29.301, 13.925, 71.947)
      ..lineTo(56.136, 104.73)
      ..cubicTo(66.726, 73.253, 96.027, 50.479, 130.55, 50.479)
      ..close();
    canvas.drawPath(redPath, redPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
