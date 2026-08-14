import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/theme/velvet_colors.dart';
import '../core/haptics/haptic_service.dart';
import 'clay_card.dart';
import 'pariyojana_logo.dart';

class AppIntroductionSheet extends ConsumerStatefulWidget {
  final VoidCallback? onCompleted;
  final bool showCompleteButton;

  const AppIntroductionSheet({
    super.key,
    this.onCompleted,
    this.showCompleteButton = false,
  });

  @override
  ConsumerState<AppIntroductionSheet> createState() => _AppIntroductionSheetState();
}

class _AppIntroductionSheetState extends ConsumerState<AppIntroductionSheet> with SingleTickerProviderStateMixin {
  final PageController _pageController = PageController();
  late final AnimationController _sanskritScrollController;
  int _currentPage = 0;
  final int _totalPages = 5;

  @override
  void initState() {
    super.initState();
    _sanskritScrollController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _sanskritScrollController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final haptic = ref.read(hapticServiceProvider);

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(36)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 28, sigmaY: 28),
        child: Container(
          height: MediaQuery.of(context).size.height * 0.88,
          decoration: BoxDecoration(
            color: VelvetColors.surface(context),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(36)),
            border: Border.all(
              color: VelvetColors.coralPeach.withValues(alpha: 0.5),
              width: 1.8,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.35),
                blurRadius: 40,
                spreadRadius: 6,
              ),
            ],
          ),
          child: Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 14),
                  // Grab handle & Header controls
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: VelvetColors.coralPeach.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: VelvetColors.coralPeach.withValues(alpha: 0.4)),
                          ),
                          child: Text(
                            'GUIDE ${_currentPage + 1}/$_totalPages',
                            style: TextStyle(
                              fontFamily: GoogleFonts.outfit().fontFamily,
                              fontSize: 11,
                              fontWeight: FontWeight.w900,
                              color: VelvetColors.coralPeach,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ),
                        Container(
                          width: 44,
                          height: 5,
                          decoration: BoxDecoration(
                            color: VelvetColors.border(context),
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        IconButton(
                          icon: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: VelvetColors.cardSurface(context),
                              border: Border.all(color: VelvetColors.border(context)),
                            ),
                            child: Icon(
                              Icons.close_rounded,
                              size: 18,
                              color: VelvetColors.iconColor(context),
                            ),
                          ),
                          onPressed: () async {
                            await haptic.lightTap();
                            if (context.mounted) {
                              if (widget.onCompleted != null) {
                                widget.onCompleted!();
                              } else {
                                Navigator.of(context).pop();
                              }
                            }
                          },
                        ),
                      ],
                    ),
                  ),

                  // Page View content
                  Expanded(
                    child: PageView(
                      controller: _pageController,
                      onPageChanged: (page) {
                        setState(() {
                          _currentPage = page;
                        });
                        haptic.lightTap();
                      },
                      children: [
                        // Slide 1: Welcome & Mission
                        _buildSlide(
                          badge: 'OVERVIEW',
                          title: 'Welcome to Pariyojana',
                          subtitle: 'Your Encrypted Personal Command Center',
                          child: SingleChildScrollView(
                            physics: const BouncingScrollPhysics(),
                            child: Column(
                              children: [
                                const PariyojanaLogo(size: 76),
                                const SizedBox(height: 12),
                                // Theme-Aware Sacred Subhashita Card
                                Builder(
                                  builder: (context) {
                                    final isDark = Theme.of(context).brightness == Brightness.dark;
                                    return Container(
                                      margin: const EdgeInsets.symmetric(vertical: 8),
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        color: isDark ? const Color(0xFF1E293B) : const Color(0xFFFFF8F0),
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(
                                          color: isDark ? const Color(0xFFF59E0B).withValues(alpha: 0.5) : const Color(0xFFE5A852),
                                          width: 1.6,
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: isDark ? Colors.black.withValues(alpha: 0.4) : const Color(0xFF2C1E1E).withValues(alpha: 0.08),
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
                                              const Text('🕉️', style: TextStyle(fontSize: 15)),
                                              const SizedBox(width: 6),
                                              Text(
                                                'SACRED WISDOM & GUIDANCE',
                                                style: TextStyle(
                                                  fontFamily: GoogleFonts.outfit().fontFamily,
                                                  fontSize: 10.5,
                                                  fontWeight: FontWeight.w900,
                                                  letterSpacing: 1.6,
                                                  color: isDark ? const Color(0xFFFBBF24) : const Color(0xFFB45309),
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 10),
                                          Container(
                                            width: double.infinity,
                                            padding: const EdgeInsets.all(12),
                                            decoration: BoxDecoration(
                                              color: isDark ? const Color(0xFF0F172A) : const Color(0xFFFEF3C7),
                                              borderRadius: BorderRadius.circular(12),
                                              border: Border.all(
                                                color: isDark ? const Color(0xFFF59E0B).withValues(alpha: 0.3) : const Color(0xFFF59E0B).withValues(alpha: 0.4),
                                              ),
                                            ),
                                            child: Column(
                                              children: [
                                                Text(
                                                  'ಪ್ರಯತ್ನಂ ಸರ್ವ ಸಿದ್ಧಿ ಸಾಧನಂ',
                                                  style: TextStyle(
                                                    fontSize: 15,
                                                    fontWeight: FontWeight.w900,
                                                    color: isDark ? const Color(0xFFFEF3C7) : const Color(0xFF1E1005),
                                                    letterSpacing: 0.3,
                                                  ),
                                                  textAlign: TextAlign.center,
                                                ),
                                                const SizedBox(height: 4),
                                                Text(
                                                  '"Effort is the ultimate key to achieve all success in life."',
                                                  style: TextStyle(
                                                    fontFamily: GoogleFonts.outfit().fontFamily,
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
                                          const SizedBox(height: 10),
                                          Container(
                                            width: double.infinity,
                                            padding: const EdgeInsets.all(12),
                                            decoration: BoxDecoration(
                                              color: isDark ? const Color(0xFF064E3B).withValues(alpha: 0.35) : const Color(0xFFECFDF5),
                                              borderRadius: BorderRadius.circular(12),
                                              border: Border.all(
                                                color: const Color(0xFF10B981).withValues(alpha: 0.4),
                                              ),
                                            ),
                                            child: Column(
                                              children: [
                                                Text(
                                                  'शीघ्रतायां सत्यां केचित् दह्यन्ते, परन्तु समयेन सह अपरे श्रेष्ठाः भवन्ति।',
                                                  style: TextStyle(
                                                    fontSize: 13,
                                                    fontWeight: FontWeight.bold,
                                                    color: isDark ? const Color(0xFFA7F3D0) : const Color(0xFF064E3B),
                                                    height: 1.35,
                                                  ),
                                                  textAlign: TextAlign.center,
                                                ),
                                                const SizedBox(height: 4),
                                                Text(
                                                  'When there is rush, some things burn; but with time, others become excellent.',
                                                  style: TextStyle(
                                                    fontFamily: GoogleFonts.outfit().fontFamily,
                                                    fontSize: 10.5,
                                                    fontStyle: FontStyle.italic,
                                                    color: isDark ? const Color(0xFF6EE7B7) : const Color(0xFF047857),
                                                    height: 1.3,
                                                  ),
                                                  textAlign: TextAlign.center,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                                const SizedBox(height: 12),
                                Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: VelvetColors.cardSurface(context),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(color: VelvetColors.coralPeach.withValues(alpha: 0.25)),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(alpha: 0.08),
                                        blurRadius: 16,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    children: [
                                      Text(
                                        '🌟 What is Pariyojana & How it Empowers You',
                                        style: TextStyle(
                                          fontFamily: GoogleFonts.outfit().fontFamily,
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold,
                                          color: VelvetColors.textPrimary(context),
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'Pariyojana is your sovereign personal command center designed to capture ideas, track career goals, manage research papers, and execute projects seamlessly without digital distraction.',
                                        style: TextStyle(
                                          fontFamily: GoogleFonts.outfit().fontFamily,
                                          fontSize: 13,
                                          color: VelvetColors.textSecondary(context),
                                          height: 1.45,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 14),
                                Container(
                                  padding: const EdgeInsets.all(14),
                                  decoration: BoxDecoration(
                                    color: VelvetColors.periwinkle.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(color: VelvetColors.periwinkle.withValues(alpha: 0.3)),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.shield_outlined, color: VelvetColors.periwinkle, size: 22),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          'Offline-first and completely private with SQLCipher AES-256 local database encryption.',
                                          style: TextStyle(
                                            fontFamily: GoogleFonts.outfit().fontFamily,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                            color: VelvetColors.textPrimary(context),
                                            height: 1.35,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        // Slide 2: Core Workspace Pillars
                        _buildSlide(
                          badge: 'WORKSPACES',
                          title: 'Core System Pillars',
                          subtitle: '4 Streamlined modules built for execution',
                          child: SingleChildScrollView(
                            physics: const BouncingScrollPhysics(),
                            child: Column(
                              children: [
                                _buildPillarCard(
                                  icon: Icons.lightbulb_rounded,
                                  iconColor: Colors.amber.shade700,
                                  title: '1. Idea Vault (AI Triage & Voice Capture)',
                                  desc: 'Fast typing bar, instant AI categorization, speech-to-text audio recorder, and biometric zero-knowledge vault lock.',
                                ),
                                const SizedBox(height: 10),
                                _buildPillarCard(
                                  icon: Icons.account_tree_rounded,
                                  iconColor: VelvetColors.coralPeach,
                                  title: '2. Projects Pipeline (6-Stage Agile Scrum)',
                                  desc: '💡 Backlog → 📋 Sprint Planning → 🏃 In Progress → 🧪 Review & QA → 🛡️ Security Audit → ✅ Done & Deployed. Modular tech stack matrix & GitHub sync.',
                                ),
                                const SizedBox(height: 10),
                                _buildPillarCard(
                                  icon: Icons.auto_stories_rounded,
                                  iconColor: VelvetColors.periwinkle,
                                  title: '3. Research Tracker (Deep Dives & ArXiv)',
                                  desc: 'Full-featured Markdown/LaTeX editor, cross-document full-text indexing, and automatic BibTeX/IEEE citation generator.',
                                ),
                                const SizedBox(height: 10),
                                _buildPillarCard(
                                  icon: Icons.work_rounded,
                                  iconColor: VelvetColors.mint,
                                  title: '4. Job Tracker (5-Stage Pipeline & ATS Matcher)',
                                  desc: '📌 Saved → 📤 Applied → 🎯 Shortlisted → 💬 Interview → 🏆 Offer. Built-in ATS Resume keyword matcher, LPA tax calculator & AI interview prep.',
                                ),
                              ],
                            ),
                          ),
                        ),

                        // Slide 3: Security & Sync
                        _buildSlide(
                          badge: 'SECURITY',
                          title: 'Zero-Knowledge Backups',
                          subtitle: 'Encrypted Google Drive cloud sync & BYOK AI',
                          child: SingleChildScrollView(
                            physics: const BouncingScrollPhysics(),
                            child: Column(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(18),
                                  decoration: BoxDecoration(
                                    color: VelvetColors.coralPeach.withValues(alpha: 0.12),
                                    shape: BoxShape.circle,
                                    border: Border.all(color: VelvetColors.coralPeach, width: 2),
                                  ),
                                  child: const Icon(Icons.cloud_sync_rounded, size: 52, color: VelvetColors.coralPeach),
                                ),
                                const SizedBox(height: 18),
                                Text(
                                  'Your Data Remains Yours Alone',
                                  style: TextStyle(
                                    fontFamily: GoogleFonts.outfit().fontFamily,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: VelvetColors.textPrimary(context),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Pariyojana operates without central servers. Backups are stored in your own Google Drive isolated AppData folder, encrypted with your personal AES session keys wrapped via RSA-2048 before ever leaving your phone.',
                                  style: TextStyle(
                                    fontFamily: GoogleFonts.outfit().fontFamily,
                                    fontSize: 13,
                                    color: VelvetColors.textSecondary(context),
                                    height: 1.45,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 14),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                  decoration: BoxDecoration(
                                    color: VelvetColors.surface(context),
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(color: VelvetColors.border(context)),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(Icons.verified_user_rounded, size: 16, color: VelvetColors.coralPeach),
                                      const SizedBox(width: 8),
                                      Text(
                                        'RSA-2048 Session Key Wrapping Enabled',
                                        style: TextStyle(
                                          fontFamily: GoogleFonts.outfit().fontFamily,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: VelvetColors.textPrimary(context),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        // Slide 4: Sacred Gita Guidance
                        _buildSlide(
                          badge: 'PHILOSOPHY',
                          title: 'Bhagavad Gita Wisdom 🕉️',
                          subtitle: 'Eternal guiding principles for duty & focus',
                          child: SingleChildScrollView(
                            physics: const BouncingScrollPhysics(),
                            child: Column(
                              children: [
                                Builder(
                                  builder: (context) {
                                    final isDark = Theme.of(context).brightness == Brightness.dark;
                                    return Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.all(14),
                                      decoration: BoxDecoration(
                                        color: isDark ? const Color(0xFF1E293B) : const Color(0xFFFFF7ED),
                                        borderRadius: BorderRadius.circular(16),
                                        border: Border.all(
                                          color: isDark ? VelvetColors.coralPeach.withValues(alpha: 0.5) : VelvetColors.coralPeach,
                                          width: 1.5,
                                        ),
                                      ),
                                      child: Column(
                                        children: [
                                          Text(
                                            'कर्मण्येवाधिकारस्ते मा फलेषु कदाचन।\nमा कर्मफलहेतुर्भूर्मा ते सङ्गोऽस्त्वकर्मणि॥',
                                            style: TextStyle(
                                              fontFamily: GoogleFonts.outfit().fontFamily,
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                              color: isDark ? const Color(0xFFF8FAFC) : VelvetColors.cocoa,
                                              height: 1.4,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            '“You have a right to perform your prescribed duties, but you are not entitled to the results of your actions. Never consider yourself the cause of results, nor be attached to inaction.” — Srimad Bhagavad Gita (2.47)',
                                            style: TextStyle(
                                              fontFamily: GoogleFonts.outfit().fontFamily,
                                              fontSize: 11.5,
                                              fontStyle: FontStyle.italic,
                                              color: isDark ? const Color(0xFFFDE68A) : const Color(0xFF7C4A03),
                                              height: 1.35,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                                const SizedBox(height: 10),
                                Builder(
                                  builder: (context) {
                                    final isDark = Theme.of(context).brightness == Brightness.dark;
                                    return Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.all(14),
                                      decoration: BoxDecoration(
                                        color: isDark ? const Color(0xFF064E3B).withValues(alpha: 0.35) : const Color(0xFFECFDF5),
                                        borderRadius: BorderRadius.circular(16),
                                        border: Border.all(
                                          color: const Color(0xFF10B981),
                                          width: 1.5,
                                        ),
                                      ),
                                      child: Column(
                                        children: [
                                          Text(
                                            'योगः कर्मसु कौशलम्॥',
                                            style: TextStyle(
                                              fontFamily: GoogleFonts.outfit().fontFamily,
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: isDark ? const Color(0xFFA7F3D0) : VelvetColors.cocoa,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            '“Yogaḥ karmasu kauśalam — Excellence in action is true Yoga (BG 2.50). Work with total dedication without anxiety for outcomes.”',
                                            style: TextStyle(
                                              fontFamily: GoogleFonts.outfit().fontFamily,
                                              fontSize: 11.5,
                                              fontStyle: FontStyle.italic,
                                              color: isDark ? const Color(0xFF6EE7B7) : const Color(0xFF065F46),
                                              fontWeight: FontWeight.w600,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),

                        // Slide 5: Power Controls & Shortcuts
                        _buildSlide(
                          badge: 'POWER CONTROLS',
                          title: 'Launcher & Sound Engine',
                          subtitle: 'Quick navigation & Vadya music player',
                          child: SingleChildScrollView(
                            child: Column(
                              children: [
                                _buildShortcutCard(
                                  icon: Icons.bolt_rounded,
                                  color: VelvetColors.coralPeach,
                                  title: 'Cyber Command Launcher ⚡',
                                  desc: 'Tap the top search bar or quick action pill anywhere in the app to jump to projects, search ideas, or launch tools.',
                                ),
                                const SizedBox(height: 10),
                                _buildShortcutCard(
                                  icon: Icons.music_note_rounded,
                                  color: VelvetColors.periwinkle,
                                  title: 'Vadya Audio Player 🎵',
                                  desc: 'Ambient focus music player in Settings to power your deep work sessions.',
                                ),
                                const SizedBox(height: 10),
                                _buildShortcutCard(
                                  icon: Icons.touch_app_rounded,
                                  color: VelvetColors.mint,
                                  title: 'Dynamic Floating Island 🏝️',
                                  desc: 'Floating bottom navigation island with haptic feedback & quick capture triggers.',
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Bottom Action Bar
                  SafeArea(
                    top: false,
                    child: Padding(
                      padding: EdgeInsets.only(left: 20.0, right: 20.0, bottom: MediaQuery.of(context).padding.bottom + 24.0, top: 10.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Page Dots
                          Row(
                            children: List.generate(_totalPages, (index) {
                              final isActive = index == _currentPage;
                              return AnimatedContainer(
                                duration: const Duration(milliseconds: 250),
                                margin: const EdgeInsets.symmetric(horizontal: 3),
                                width: isActive ? 22 : 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(4),
                                  color: isActive ? VelvetColors.coralPeach : VelvetColors.cocoa.withValues(alpha: 0.2),
                                ),
                              );
                            }),
                          ),

                          // Next / Complete Button
                          Row(
                            children: [
                              if (_currentPage < _totalPages - 1) ...[
                                TextButton(
                                  onPressed: () async {
                                    await haptic.lightTap();
                                    if (context.mounted) {
                                      if (widget.onCompleted != null) {
                                        widget.onCompleted!();
                                      } else {
                                        Navigator.of(context).pop();
                                      }
                                    }
                                  },
                                  child: Text(
                                    'Skip',
                                    style: TextStyle(
                                      fontFamily: GoogleFonts.outfit().fontFamily,
                                      fontWeight: FontWeight.bold,
                                      color: VelvetColors.cocoa.withValues(alpha: 0.5),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                              ],
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: VelvetColors.coralPeach,
                                  foregroundColor: Colors.white,
                                  elevation: 3,
                                  shadowColor: VelvetColors.coralPeach.withValues(alpha: 0.4),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                  padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 13),
                                ),
                                onPressed: () async {
                                  if (_currentPage < _totalPages - 1) {
                                    await haptic.mediumImpact();
                                    await _pageController.nextPage(
                                      duration: const Duration(milliseconds: 350),
                                      curve: Curves.easeInOutCubic,
                                    );
                                  } else {
                                    await haptic.successPattern();
                                    if (context.mounted) {
                                      if (widget.onCompleted != null) {
                                        widget.onCompleted!();
                                      } else {
                                        Navigator.of(context).pop();
                                      }
                                    }
                                  }
                                },
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      _currentPage < _totalPages - 1
                                          ? 'Next'
                                          : (widget.showCompleteButton ? 'Continue' : 'Get Started 🚀'),
                                      style: TextStyle(
                                        fontFamily: GoogleFonts.outfit().fontFamily,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Icon(
                                      _currentPage < _totalPages - 1
                                          ? Icons.arrow_forward_rounded
                                          : Icons.check_circle_rounded,
                                      size: 16,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSlide({
    required String badge,
    required String title,
    required String subtitle,
    required Widget child,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 6.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
              decoration: BoxDecoration(
                color: VelvetColors.coralPeach.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: VelvetColors.coralPeach.withValues(alpha: 0.4)),
              ),
              child: Text(
                badge,
                style: TextStyle(
                  fontFamily: GoogleFonts.outfit().fontFamily,
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2.0,
                  color: VelvetColors.coralPeach,
                ),
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            title,
            style: TextStyle(
              fontFamily: GoogleFonts.outfit().fontFamily,
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: VelvetColors.textPrimary(context),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(
              fontFamily: GoogleFonts.outfit().fontFamily,
              fontSize: 12.5,
              color: VelvetColors.textSecondary(context),
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 18),
          Expanded(child: child),
        ],
      ),
    );
  }

  Widget _buildPillarCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String desc,
  }) {
    return ClayCard(
      color: VelvetColors.cardSurface(context),
      borderRadius: 20,
      depth: 4.0,
      padding: const EdgeInsets.all(14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: iconColor, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontFamily: GoogleFonts.outfit().fontFamily,
                    fontSize: 13.5,
                    fontWeight: FontWeight.bold,
                    color: VelvetColors.textPrimary(context),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  desc,
                  style: TextStyle(
                    fontFamily: GoogleFonts.outfit().fontFamily,
                    fontSize: 11.5,
                    color: VelvetColors.textSecondary(context),
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShortcutCard({
    required IconData icon,
    required Color color,
    required String title,
    required String desc,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontFamily: GoogleFonts.outfit().fontFamily,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: VelvetColors.textPrimary(context),
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  desc,
                  style: TextStyle(
                    fontFamily: GoogleFonts.outfit().fontFamily,
                    fontSize: 11,
                    color: VelvetColors.textSecondary(context),
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
