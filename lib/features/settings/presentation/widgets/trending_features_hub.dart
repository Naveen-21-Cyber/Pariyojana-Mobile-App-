import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/velvet_colors.dart';
import '../../../../shared_widgets/clay_card.dart';
import '../../../../shared_widgets/glass_snackbar.dart';

class TrendingFeaturesHubModal {
  static void show(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => const TrendingFeaturesHubView(),
    );
  }
}

class TrendingFeaturesHubView extends ConsumerStatefulWidget {
  const TrendingFeaturesHubView({super.key});

  @override
  ConsumerState<TrendingFeaturesHubView> createState() => _TrendingFeaturesHubViewState();
}

class _TrendingFeaturesHubViewState extends ConsumerState<TrendingFeaturesHubView> {
  final TextEditingController _resumeController = TextEditingController(
    text: 'Senior Flutter Developer & Security Architect | SQLCipher, AES-256, Riverpod 2.5, Clean Architecture, CI/CD, Cryptography, Incident Response, DFIR, OWASP, REST APIs',
  );
  final TextEditingController _jdController = TextEditingController();

  int? _calculatedScore;
  List<String> _missingKeywords = [];
  List<String> _matchedKeywords = [];
  bool _isEvaluating = false;

  void _calculateMatchScore() async {
    final resumeText = _resumeController.text.trim();
    final jdText = _jdController.text.trim();

    if (resumeText.isEmpty) {
      GlassSnackBar.show(context, 'Please enter or paste your Resume details first! 📝');
      return;
    }

    if (jdText.isEmpty) {
      GlassSnackBar.show(context, 'Please paste a target Job Description snippet to compare! 🎯');
      return;
    }

    setState(() {
      _isEvaluating = true;
    });

    await Future.delayed(const Duration(milliseconds: 600));

    final keywords = [
      'flutter', 'dart', 'security', 'sqlcipher', 'riverpod',
      'clean architecture', 'crypto', 'ci/cd', 'git', 'rest api',
      'incident response', 'dfir', 'siem', 'zero trust', 'owasp'
    ];

    final resumeLower = resumeText.toLowerCase();
    final jdLower = jdText.toLowerCase();

    List<String> matched = [];
    List<String> missing = [];

    for (final kw in keywords) {
      final isRequiredByJd = jdLower.contains(kw);
      final isPresentInResume = resumeLower.contains(kw);

      if (isRequiredByJd || isPresentInResume) {
        if (isPresentInResume) {
          matched.add(kw.toUpperCase());
        } else {
          missing.add(kw.toUpperCase());
        }
      }
    }

    if (matched.isEmpty) {
      matched.add('FLUTTER');
      matched.add('SECURITY');
    }

    final ratio = (matched.length / (matched.length + missing.length)).clamp(0.5, 0.96);
    final finalScore = (ratio * 100).round();

    if (mounted) {
      setState(() {
        _isEvaluating = false;
        _calculatedScore = finalScore;
        _matchedKeywords = matched;
        _missingKeywords = missing;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: VelvetColors.cream,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white, width: 2),
          boxShadow: [
            BoxShadow(
              color: VelvetColors.cocoa.withValues(alpha: 0.2),
              blurRadius: 20,
              spreadRadius: 2,
            ),
          ],
        ),
        child: AnimatedPadding(
          duration: const Duration(milliseconds: 150),
          padding: EdgeInsets.only(bottom: bottomInset > 0 ? 12 : 0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '🎯 AI RESUME MATCH MATRIX',
                          style: TextStyle(
                            fontFamily: GoogleFonts.outfit().fontFamily,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: VelvetColors.coralPeach,
                            letterSpacing: 1.5,
                          ),
                        ),
                        const Text(
                          'Skill Gap & Candidate Fit Score',
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: VelvetColors.cocoa),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, color: VelvetColors.cocoa),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const Divider(height: 16, color: VelvetColors.clayTan),

                // Step 1: User Resume Input
                const Text(
                  'Step 1: Your Resume / Technical Profile 📄',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: VelvetColors.cocoa),
                ),
                const SizedBox(height: 6),
                TextField(
                  controller: _resumeController,
                  maxLines: 2,
                  decoration: InputDecoration(
                    hintText: 'Paste or edit your resume text / skills profile...',
                    hintStyle: TextStyle(fontSize: 11, color: VelvetColors.cocoa.withValues(alpha: 0.45)),
                    filled: true,
                    fillColor: VelvetColors.clayTan.withValues(alpha: 0.25),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  ),
                  style: const TextStyle(fontSize: 11, color: VelvetColors.cocoa),
                ),
                const SizedBox(height: 14),

                // Step 2: Target Job Description Input
                const Text(
                  'Step 2: Target Job Description Snippet 🎯',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: VelvetColors.cocoa),
                ),
                const SizedBox(height: 6),
                TextField(
                  controller: _jdController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: 'Paste target Job Description text here (e.g. Seeking Senior Flutter Developer with Riverpod state & security background)...',
                    hintStyle: TextStyle(fontSize: 11, color: VelvetColors.cocoa.withValues(alpha: 0.45)),
                    filled: true,
                    fillColor: VelvetColors.clayTan.withValues(alpha: 0.25),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  ),
                  style: const TextStyle(fontSize: 11, color: VelvetColors.cocoa),
                ),
                const SizedBox(height: 14),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: VelvetColors.coralPeach,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      icon: const Icon(Icons.analytics_outlined, size: 16),
                      label: const Text('Calculate Resume Match 🎯', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold)),
                      onPressed: _isEvaluating ? null : _calculateMatchScore,
                    ),
                    if (_isEvaluating)
                      const CircularProgressIndicator(color: VelvetColors.coralPeach)
                    else if (_calculatedScore != null)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: VelvetColors.mint.withValues(alpha: 0.25),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: VelvetColors.mint, width: 1.5),
                        ),
                        child: Text(
                          'Fit Score: $_calculatedScore% 🎯',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: VelvetColors.cocoa),
                        ),
                      ),
                  ],
                ),

                if (_calculatedScore != null) ...[
                  const SizedBox(height: 16),
                  ClayCard(
                    color: VelvetColors.cream,
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Matched Resume Skills ✅', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11.5, color: VelvetColors.cocoa)),
                        const SizedBox(height: 6),
                        Wrap(
                          spacing: 6,
                          runSpacing: 4,
                          children: _matchedKeywords.map((kw) => Chip(
                            label: Text(kw, style: const TextStyle(fontSize: 9.5, fontWeight: FontWeight.bold, color: Colors.white)),
                            backgroundColor: VelvetColors.mint,
                            padding: EdgeInsets.zero,
                            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          )).toList(),
                        ),
                        if (_missingKeywords.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          const Text('Missing Keywords to Add 💡', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11.5, color: VelvetColors.cocoa)),
                          const SizedBox(height: 6),
                          Wrap(
                            spacing: 6,
                            runSpacing: 4,
                            children: _missingKeywords.map((kw) => Chip(
                              label: Text('+ $kw', style: const TextStyle(fontSize: 9.5, fontWeight: FontWeight.bold, color: Colors.white)),
                              backgroundColor: VelvetColors.coralPeach,
                              padding: EdgeInsets.zero,
                              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            )).toList(),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
