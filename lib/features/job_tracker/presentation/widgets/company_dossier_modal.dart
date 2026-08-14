import 'dart:convert';
import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:velvet/core/theme/velvet_colors.dart';
import 'package:velvet/core/haptics/haptic_service.dart';
import 'package:velvet/shared_widgets/glass_snackbar.dart';
import 'package:velvet/shared_widgets/microchip_circuit_loader.dart';
import '../../../../shared_widgets/sparkle_generate_button.dart';
import '../../../../shared_widgets/ai_sparkle_guide_modal.dart';
import '../../data/company_dossier_service.dart';


class CompanyDossierModal extends ConsumerStatefulWidget {
  final String? initialCompanyName;
  final String? initialCompanyUrl;

  const CompanyDossierModal({
    super.key,
    this.initialCompanyName,
    this.initialCompanyUrl,
  });

  static Future<void> show(BuildContext context, {String? companyName, String? companyUrl}) async {
    await showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CompanyDossierModal(
        initialCompanyName: companyName,
        initialCompanyUrl: companyUrl,
      ),
    );
  }

  @override
  ConsumerState<CompanyDossierModal> createState() => _CompanyDossierModalState();
}

class _CompanyDossierModalState extends ConsumerState<CompanyDossierModal> with SingleTickerProviderStateMixin {
  late final TextEditingController _companyUrlController;
  late final TextEditingController _jobUrlController;

  bool _isLoading = false;
  CompanyDossier? _dossier;
  String? _errorMessage;
  int _activeTab = 0; // 0: Overview & Match, 1: Shift & Culture, 2: Partners & Tech, 3: Interview Prep, 4: Negotiation & Practice

  String? _uploadedFileName;
  String? _uploadedFileText;

  @override
  void initState() {
    super.initState();
    _companyUrlController = TextEditingController(text: widget.initialCompanyUrl ?? '');
    _jobUrlController = TextEditingController();
  }

  @override
  void dispose() {
    _companyUrlController.dispose();
    _jobUrlController.dispose();
    super.dispose();
  }

  String _extractTextFromPickedFile(PlatformFile file, String prefix) {
    if (file.bytes == null || file.bytes!.isEmpty) return '';
    try {
      final raw = utf8.decode(file.bytes!, allowMalformed: true);
      final textMatches = <String>[];

      // 1. Extract text from PDF Tj / TJ stream blocks
      final tjRegex = RegExp(r'\(([^)]+)\)\s*T[jJ]');
      for (final m in tjRegex.allMatches(raw)) {
        final str = m.group(1)?.trim();
        if (str != null && str.length > 1 && !str.startsWith('/') && !str.contains('obj') && !str.contains('endobj')) {
          textMatches.add(str);
        }
      }

      String extractedText = '';
      if (textMatches.length > 5) {
        extractedText = textMatches.join(' ');
      } else {
        // 2. Fallback: Extract clean printable tokens > 2 chars
        final cleanTokens = raw
            .replaceAll(RegExp(r'%PDF-\d\.\d[\s\S]*?obj'), ' ')
            .replaceAll(RegExp(r'endobj|stream|endstream|/Type|/Font|/Subtype|/Filter|/Length'), ' ')
            .replaceAll(RegExp(r'[^\x20-\x7E]'), ' ')
            .split(RegExp(r'\s+'))
            .where((t) => t.length >= 2 && !t.startsWith('/') && !t.startsWith('\\') && !t.contains('000'))
            .toList();
        extractedText = cleanTokens.join(' ');
      }

      if (extractedText.trim().length > 20) {
        return '$prefix (${file.name}):\n${extractedText.trim()}';
      }
    } catch (_) {}
    return '$prefix (${file.name}): Candidate Technical Profile Skills Experience';
  }

  Future<void> _pickJdFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'txt', 'png', 'jpg', 'jpeg', 'doc', 'docx'],
        withData: true,
      );

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        final contentText = _extractTextFromPickedFile(file, 'JOB DESCRIPTION DOCUMENT');
        setState(() {
          _uploadedFileName = file.name;
          _uploadedFileText = contentText;
          _errorMessage = null;
        });
        unawaited(ref.read(hapticServiceProvider).lightTap());
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Could not pick JD file: $e';
      });
    }
  }


  Future<void> _extractDossier() async {
    final haptic = ref.read(hapticServiceProvider);
    await haptic.mediumImpact();

    final companyUrl = _companyUrlController.text.trim();
    final jobUrl = _jobUrlController.text.trim();

    if (companyUrl.isEmpty && jobUrl.isEmpty && (_uploadedFileText == null || _uploadedFileText!.isEmpty)) {
      setState(() {
        _errorMessage = 'Please enter a Company Website, Job Link, or upload a JD File.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      String? combinedInputText;
      if (_uploadedFileText != null && _uploadedFileText!.isNotEmpty) {
        combinedInputText = _uploadedFileText;
      }

      final service = ref.read(companyDossierServiceProvider);
      final dossier = await service.extractDossier(
        companyUrl: companyUrl.isNotEmpty ? companyUrl : null,
        jobPostingUrl: jobUrl.isNotEmpty ? jobUrl : null,
        customJdText: combinedInputText,
      );

      if (mounted) {
        setState(() {
          _dossier = dossier;
          _isLoading = false;
        });
        await haptic.heavyImpact();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString().replaceAll('RateLimitException: ', '').replaceAll('Exception: ', '');
          _isLoading = false;
        });
        await haptic.heavyImpact();
      }
    }
  }

  Future<void> _downloadMarkdownFile() async {
    if (_dossier == null) return;
    try {
      final mdContent = _dossier!.toFormattedMarkdownNote();
      final sanitizedName = _dossier!.companyName.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '_');
      final filename = '${sanitizedName}_intelligence_dossier.md';

      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/$filename');
      await file.writeAsString(mdContent);

      unawaited(ref.read(hapticServiceProvider).mediumImpact());
      if (mounted) {
        GlassSnackBar.show(context, '📥 Downloaded .md report to Documents/$filename');
      }
    } catch (e) {
      unawaited(Clipboard.setData(ClipboardData(text: _dossier!.toFormattedMarkdownNote())));
      if (mounted) {
        GlassSnackBar.show(context, '📋 Report copied to clipboard as Markdown (.md)!');
      }
    }
  }

  void _resetForm() {
    setState(() {
      _companyUrlController.clear();
      _jobUrlController.clear();
      _uploadedFileName = null;
      _uploadedFileText = null;
      _dossier = null;
      _errorMessage = null;
    });
    CompanyDossierService.resetRateLimit();
    ref.read(hapticServiceProvider).lightTap();
    GlassSnackBar.show(context, '🔄 Form & API limits reset cleanly!');
  }

  void _copyToClipboard() {
    if (_dossier == null) return;
    Clipboard.setData(ClipboardData(text: _dossier!.toFormattedMarkdownNote()));
    ref.read(hapticServiceProvider).lightTap();
    GlassSnackBar.show(context, '📋 Full Dossier copied to clipboard!');
  }

  @override
  Widget build(BuildContext context) {
    final remainingRequests = CompanyDossierService.getRemainingRequestsThisMinute();

    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.90,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: VelvetColors.surface(context),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Top Grab Bar Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 16, 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Text('🕵️‍♂️', style: TextStyle(fontSize: 20)),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'AI Company & JD Intel',
                            style: TextStyle(
                              fontFamily: GoogleFonts.outfit().fontFamily,
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              color: VelvetColors.textPrimary(context),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.help_outline_rounded, size: 18, color: VelvetColors.coralPeach),
                    tooltip: 'AI Sparkle Guide ✨',
                    onPressed: () {
                      AiSparkleGuideModal.show(
                        context,
                        featureName: 'Company & JD Intelligence Dossier',
                        description: 'Autonomous multi-dimensional intelligence synthesizer that analyzes company web domains, tech stacks, engineering cultures, and job descriptions into actionable interview blueprints.',
                        capabilities: const [
                          {
                            'icon': '🏢',
                            'title': '360° Company Analysis',
                            'detail': 'Extracts product ecosystems, tech architectures, funding rounds, and executive leadership.',
                          },
                          {
                            'icon': '🎯',
                            'title': 'Job Fit & Skill Matching',
                            'detail': 'Computes exact match score percentages between your profile and job requirements.',
                          },
                          {
                            'icon': '💼',
                            'title': 'Salary & Negotiation Strategy',
                            'detail': 'Provides market benchmark compensation ranges and tactical counter-offer arguments.',
                          },
                          {
                            'icon': '⚡',
                            'title': '70%+ Token Efficiency',
                            'detail': 'All web scraping and dossier synthesis runs with prompt compression and local caching.',
                          },
                        ],
                      );
                    },
                  ),
                  const SizedBox(width: 4),
                  Material(

                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(20),
                      onTap: () => Navigator.of(context).pop(),
                      child: Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          color: VelvetColors.cardSurface(context),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Icon(Icons.close_rounded, size: 17, color: VelvetColors.iconColor(context)),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: VelvetColors.clayTan),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Rate Limit Meter Pill
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            'WEB SCRAPER & INTEL',
                            style: TextStyle(
                              fontFamily: GoogleFonts.outfit().fontFamily,
                              fontSize: 10.5,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.2,
                              color: VelvetColors.textSecondary(context),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Row(
                          children: [
                            GestureDetector(
                              onTap: _resetForm,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                margin: const EdgeInsets.only(right: 6),
                                decoration: BoxDecoration(
                                  color: VelvetColors.cardSurface(context),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: VelvetColors.border(context)),
                                ),
                                child: Row(
                                  children: [
                                    Icon(Icons.refresh_rounded, size: 12, color: VelvetColors.iconColor(context)),
                                    const SizedBox(width: 3),
                                    Text('Reset', style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: VelvetColors.textPrimary(context))),
                                  ],
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: remainingRequests > 0
                                    ? VelvetColors.coralPeach.withValues(alpha: 0.15)
                                    : Colors.red.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: remainingRequests > 0 ? VelvetColors.coralPeach : Colors.red,
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.bolt_rounded,
                                    size: 13,
                                    color: remainingRequests > 0 ? VelvetColors.coralPeach : Colors.red,
                                  ),
                                  const SizedBox(width: 3),
                                  Text(
                                    '$remainingRequests/5 reqs/min',
                                    style: TextStyle(
                                      fontSize: 10.5,
                                      fontWeight: FontWeight.bold,
                                      color: remainingRequests > 0 ? VelvetColors.coralPeach : Colors.red,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // Input Form Card
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: VelvetColors.cardSurface(context),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: VelvetColors.border(context), width: 1.5),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.15),
                            blurRadius: 12,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '1️⃣ Company Website URL (Primary)',
                            style: TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w700,
                              color: VelvetColors.textPrimary(context),
                            ),
                          ),
                          const SizedBox(height: 6),
                          TextField(
                            controller: _companyUrlController,
                            keyboardType: TextInputType.url,
                            style: TextStyle(fontSize: 13, color: VelvetColors.textPrimary(context)),
                            decoration: InputDecoration(
                              hintText: 'e.g. https://stripe.com or google.com',
                              hintStyle: TextStyle(color: VelvetColors.textSecondary(context), fontSize: 13),
                              prefixIcon: const Icon(Icons.language_rounded, color: VelvetColors.coralPeach, size: 20),
                              filled: true,
                              fillColor: VelvetColors.inputFill(context),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: BorderSide(color: VelvetColors.border(context)),
                              ),
                            ),
                          ),
                          const SizedBox(height: 14),

                          Text(
                            '2️⃣ LinkedIn / Naukri / Indeed Job URL (Secondary)',
                            style: TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w700,
                              color: VelvetColors.textPrimary(context),
                            ),
                          ),
                          const SizedBox(height: 6),
                          TextField(
                            controller: _jobUrlController,
                            keyboardType: TextInputType.url,
                            style: TextStyle(fontSize: 13, color: VelvetColors.textPrimary(context)),
                            decoration: InputDecoration(
                              hintText: 'e.g. https://linkedin.com/jobs/view/123456',
                              hintStyle: TextStyle(color: VelvetColors.textSecondary(context), fontSize: 13),
                              prefixIcon: const Icon(Icons.work_outline_rounded, color: VelvetColors.coralPeach, size: 20),
                              filled: true,
                              fillColor: VelvetColors.inputFill(context),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: BorderSide(color: VelvetColors.border(context)),
                              ),
                            ),
                          ),
                          const SizedBox(height: 14),

                          Text(
                            '3️⃣ Upload Job Description (PDF / Screenshot Image / Text)',
                            style: TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w700,
                              color: VelvetColors.textPrimary(context),
                            ),
                          ),
                          const SizedBox(height: 6),
                          GestureDetector(
                            onTap: _pickJdFile,
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                              decoration: BoxDecoration(
                                color: VelvetColors.inputFill(context),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: _uploadedFileName != null ? VelvetColors.coralPeach : VelvetColors.border(context),
                                  width: 1.2,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    _uploadedFileName != null ? Icons.check_circle_rounded : Icons.upload_file_rounded,
                                    color: _uploadedFileName != null ? VelvetColors.coralPeach : VelvetColors.iconColor(context),
                                    size: 20,
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      _uploadedFileName != null ? 'Uploaded JD: $_uploadedFileName' : 'Tap to attach JD PDF or text',
                                      style: TextStyle(
                                        fontSize: 12.5,
                                        fontWeight: _uploadedFileName != null ? FontWeight.bold : FontWeight.normal,
                                        color: _uploadedFileName != null ? VelvetColors.textPrimary(context) : VelvetColors.textSecondary(context),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 14),

                          Center(
                            child: SparkleGenerateButton(
                              label: 'Generate Intelligence Dossier',
                              isLoading: _isLoading,
                              width: double.infinity,
                              height: 52,
                              onPressed: _isLoading ? null : _extractDossier,
                            ),
                          ),
                        ],
                      ),
                    ),

                    if (_isLoading) ...[
                      const SizedBox(height: 20),
                      const Center(
                        child: MicrochipCircuitLoader(
                          width: 330,
                          height: 210,
                          label: 'Scraping Web Intel & Computing Match...',
                        ),
                      ),
                    ],

                    if (_errorMessage != null) ...[
                      const SizedBox(height: 14),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.red.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
                        ),
                        child: Text(
                          _errorMessage!,
                          style: const TextStyle(color: Colors.red, fontSize: 12.5, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],

                    if (_dossier != null) ...[
                      const SizedBox(height: 20),
                      // Dossier Result Header Card
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF8F0),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: const Color(0xFFE5A852), width: 1.6),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: const BoxDecoration(
                                color: Color(0xFFFEF3C7),
                                shape: BoxShape.circle,
                              ),
                              child: const Text('🏢', style: TextStyle(fontSize: 24)),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _dossier!.companyName,
                                    style: TextStyle(
                                      fontFamily: GoogleFonts.outfit().fontFamily,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: const Color(0xFF1E1005),
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    _dossier!.foundingYear,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF7C4A03),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.file_download_rounded, color: Color(0xFFB45309)),
                              onPressed: _downloadMarkdownFile,
                              tooltip: 'Download .md Report File',
                            ),
                            IconButton(
                              icon: const Icon(Icons.copy_rounded, color: Color(0xFFB45309)),
                              onPressed: _copyToClipboard,
                              tooltip: 'Copy Markdown Dossier',
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),

                      // Tab selector bar
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            _buildTabPill(0, '🏢 Overview & Match'),
                            _buildTabPill(1, '⏰ Shift & Culture'),
                            _buildTabPill(2, '🤝 Partners & Tech'),
                            _buildTabPill(3, '🎯 Interview Prep'),
                            _buildTabPill(4, '🗣️ Counter-Offer & Practice'),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),

                      // Tab Content Card
                      _buildTabContent(),
                      const SizedBox(height: 14),

                      // Formal Legal & Public Data Disclaimer
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF9FAFB),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: const Color(0xFFE5E7EB)),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.gavel_rounded, size: 16, color: Color(0xFF6B7280)),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'LEGAL & DATA DISCLAIMER: Information in this dossier is automatically synthesized from publicly accessible web sources for interview preparation & research purposes only. Pariyojana does not verify entity authenticity and assumes no liability for recruitment scams, false postings, or third-party offer activities. Always verify employer credentials independently through official corporate channels.',
                                style: TextStyle(
                                  fontSize: 10.5,
                                  color: Colors.grey.shade700,
                                  height: 1.35,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    ),
    );
  }

  Widget _buildTabPill(int index, String label) {
    final isSelected = _activeTab == index;
    return GestureDetector(
      onTap: () {
        ref.read(hapticServiceProvider).lightTap();
        setState(() => _activeTab = index);
      },
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? VelvetColors.coralPeach : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? VelvetColors.coralPeach : VelvetColors.clayTan,
            width: 1.5,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: isSelected ? Colors.white : VelvetColors.textPrimary(context),
          ),
        ),
      ),
    );
  }

  Widget _buildTabContent() {
    if (_dossier == null) return const SizedBox.shrink();

    switch (_activeTab) {
      case 0: // Overview & Match
        final isHighRisk = _dossier!.layoffRiskStatus.toLowerCase().contains('high');
        final isMedRisk = _dossier!.layoffRiskStatus.toLowerCase().contains('medium');
        final riskColor = isHighRisk ? Colors.red : (isMedRisk ? Colors.orange : Colors.green);
        final riskBg = isHighRisk ? const Color(0xFFFEF2F2) : (isMedRisk ? const Color(0xFFFFFBEB) : const Color(0xFFF0FDF4));

        final verdict = _dossier!.applyVerdict;
        final isStrong = verdict.toLowerCase().contains('strong');
        final isCaution = verdict.toLowerCase().contains('caution');
        final verdictColor = isStrong ? const Color(0xFF059669) : (isCaution ? const Color(0xFFD97706) : const Color(0xFFDC2626));
        final verdictBg = isStrong ? const Color(0xFFECFDF5) : (isCaution ? const Color(0xFFFFFBEB) : const Color(0xFFFEF2F2));

        // Dynamic ESOP calculation numbers
        final isPublicCompany = _dossier!.companyStage.toLowerCase().contains('public') ||
            _dossier!.companyStage.toLowerCase().contains('faang') ||
            _dossier!.fundingStatus.toLowerCase().contains('public');

        return _buildClaySection(
          title: '🏢 COMPANY SNAPSHOT & CANDIDATE MATCH',
          children: [
            // Feature 1: Should I Apply? AI Verdict Scorecard
            Container(
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: verdictBg,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: verdictColor.withValues(alpha: 0.4), width: 1.2),
              ),
              child: Row(
                children: [
                  Icon(
                    isStrong ? Icons.thumb_up_alt_rounded : (isCaution ? Icons.privacy_tip_rounded : Icons.gpp_maybe_rounded),
                    color: verdictColor,
                    size: 22,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'AI Fit Verdict: ${_dossier!.applyVerdict}',
                          style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: verdictColor),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _dossier!.applyVerdictReason,
                          style: TextStyle(fontSize: 11.5, color: verdictColor.withValues(alpha: 0.9), height: 1.3),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Resume Match — link to dedicated AI Resume Matcher
            Container(
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFF6366F1).withValues(alpha: 0.35)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.analytics_outlined, size: 20, color: Color(0xFF4338CA)),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      '📊 Resume Skill Match — Use the AI Resume Match Matrix (🎯 icon on Job Card) to upload your PDF resume and evaluate your exact skill match & gaps with AI.',
                      style: TextStyle(fontSize: 11.5, color: Color(0xFF334155), fontWeight: FontWeight.w500, height: 1.35),
                    ),
                  ),
                ],
              ),
            ),

            // Layoff & Stability Risk Meter Badge
            Container(
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: riskBg,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: riskColor.withValues(alpha: 0.4), width: 1.2),
              ),
              child: Row(
                children: [
                  Icon(
                    isHighRisk ? Icons.warning_rounded : (isMedRisk ? Icons.info_outline_rounded : Icons.verified_user_rounded),
                    color: riskColor,
                    size: 22,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Stability Signal: ${_dossier!.layoffRiskStatus}',
                          style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: riskColor),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _dossier!.layoffRiskReason,
                          style: TextStyle(fontSize: 11.5, color: riskColor.withValues(alpha: 0.85), height: 1.3),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Feature 2: Indian Startup ESOP & Equity Calculator Card
            Container(
              padding: const EdgeInsets.all(14),
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFF0FDF4),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFF86EFAC), width: 1.2),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.monetization_on_rounded, size: 20, color: Color(0xFF16A34A)),
                      const SizedBox(width: 8),
                      Text(
                        isPublicCompany ? '📈 Public Listed Equity & RSU Structure:' : '📈 Startup ESOP & Equity Calculator:',
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF15803D)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _dossier!.esopVestingProjection.isNotEmpty
                        ? _dossier!.esopVestingProjection
                        : (isPublicCompany
                            ? 'RSU Equity Grant: 4-Year Vesting with 25% annual vesting (quarterly disbursements post 12 months).'
                            : 'ESOP Structure: 4-Year Vesting with 1-Year 25% Cliff (Month 12), followed by 2.08% monthly vesting.'),
                    style: const TextStyle(fontSize: 11.5, color: Color(0xFF166534), height: 1.35),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.8),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFBBF7D0)),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                isPublicCompany ? 'Year 1 RSU Vesting (Month 12):' : 'Year 1 ESOP Cliff (Month 12):',
                                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF166534)),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Text('25% Vesting', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF15803D))),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                isPublicCompany ? 'Years 2 - 4 (Quarterly):' : 'Years 2 - 4 (Monthly):',
                                style: const TextStyle(fontSize: 11, color: Color(0xFF166534)),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              isPublicCompany ? '6.25%/Quarter (75% total)' : '2.08%/Month (75% total)',
                              style: const TextStyle(fontSize: 11, color: Color(0xFF166534)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                isPublicCompany ? 'Market Ticker Performance:' : 'Startup Valuation Growth (2.5x):',
                                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF047857)),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              isPublicCompany ? 'Public Market Stock' : 'Est. 2.5x Valuation Target',
                              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF047857)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            _buildDetailTile(Icons.location_on_rounded, 'Headquarters', _dossier!.headquartersLocation),
            _buildDetailTile(Icons.public_rounded, 'Global Presence', _dossier!.internationalPresence),
            _buildDetailTile(Icons.people_rounded, 'Company Size', _dossier!.companySize),
            _buildDetailTile(Icons.account_balance_rounded, 'Funding / Status', _dossier!.fundingStatus),
            _buildDetailTile(Icons.rocket_launch_rounded, 'Company Stage', _dossier!.companyStage),
            _buildDetailTile(Icons.home_work_rounded, 'Work Mode', _dossier!.workMode),
            _buildDetailTile(Icons.currency_rupee_rounded, 'Salary Benchmark', _dossier!.salaryBenchmark),
            if (_dossier!.founderBackground != 'Not publicly disclosed' && _dossier!.founderBackground.isNotEmpty) ...[ 
              _buildDetailTile(Icons.person_rounded, 'Founder Background', _dossier!.founderBackground),
            ],
            if (_dossier!.investorsOrBoard.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text('💰 Key Investors:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: VelvetColors.textPrimary(context))),
              const SizedBox(height: 6),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: _dossier!.investorsOrBoard
                    .map((i) => _buildChip(i, const Color(0xFFFFF7ED), const Color(0xFF92400E)))
                    .toList(),
              ),
            ],
            if (_dossier!.recentHighlights.isNotEmpty) ...[
              const SizedBox(height: 10),
              Text('📰 Recent Highlights:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: VelvetColors.textPrimary(context))),
              const SizedBox(height: 6),
              ..._dossier!.recentHighlights.map((h) => Padding(
                padding: const EdgeInsets.only(bottom: 5),
                child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Text('• ', style: TextStyle(fontWeight: FontWeight.bold, color: VelvetColors.coralPeach)),
                  Expanded(child: Text(h, style: TextStyle(fontSize: 12, color: VelvetColors.textPrimary(context), height: 1.35))),
                ]),
              )),
            ],
            if (_dossier!.coreServicesAndProducts.isNotEmpty) ...[
              const SizedBox(height: 10),
              Text('🛠️ Core Products & Services:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: VelvetColors.textPrimary(context))),
              const SizedBox(height: 6),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: _dossier!.coreServicesAndProducts
                    .map((s) => _buildChip(s, VelvetColors.coralPeach.withValues(alpha: 0.15), VelvetColors.textPrimary(context)))
                    .toList(),
              ),
            ],
          ],
        );

      case 1: // Shift & Culture
        return _buildClaySection(
          title: '⏰ WORK SCHEDULE & TEAM CULTURE',
          children: [
            _buildDetailTile(Icons.access_time_filled_rounded, 'Shift Schedule', _dossier!.shiftTypeAndHours),
            _buildDetailTile(Icons.groups_rounded, 'Engineering Culture', _dossier!.careerAndTeamCulture),
          ],
        );

      case 2: // Partners & Tech
        final hasTechData = _dossier!.partnershipsAndClients.isNotEmpty || _dossier!.techStack.isNotEmpty || _dossier!.openSourceProjects.isNotEmpty;

        return _buildClaySection(
          title: '🤝 PARTNERS, CLIENTS & GITHUB TECH STACK',
          children: [
            if (_dossier!.partnershipsAndClients.isNotEmpty) ...[
              Text('Key Partners & Clients:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: VelvetColors.textPrimary(context))),
              const SizedBox(height: 6),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: _dossier!.partnershipsAndClients
                    .map((p) => _buildChip(p, const Color(0xFFECFDF5), const Color(0xFF064E3B)))
                    .toList(),
              ),
            ],
            if (_dossier!.techStack.isNotEmpty) ...[
              const SizedBox(height: 14),
              Text('⚙️ Core Tech Stack:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: VelvetColors.textPrimary(context))),
              const SizedBox(height: 6),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: _dossier!.techStack
                    .map((t) => _buildChip(t, const Color(0xFFEFF6FF), const Color(0xFF1E3A5F)))
                    .toList(),
              ),
            ],
            if (_dossier!.openSourceProjects.isNotEmpty) ...[
              const SizedBox(height: 14),
              Text('🐙 GitHub Open Source Repos:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: VelvetColors.textPrimary(context))),
              const SizedBox(height: 6),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: _dossier!.openSourceProjects
                    .map((repo) => _buildChip('📦 $repo', const Color(0xFFF3F4F6), const Color(0xFF1F2937)))
                    .toList(),
              ),
            ],
            if (!hasTechData) ...[
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 12.0),
                child: Text(
                  'No public open-source repos or client disclosures extracted for this target entity.',
                  style: TextStyle(fontSize: 12, color: Colors.grey, fontStyle: FontStyle.italic),
                ),
              ),
            ],
          ],
        );

      case 3: // Interview Prep
        final prep = _dossier!.interviewPrep;
        final hasPrep = prep.whyUsScript.isNotEmpty || prep.keyJdBuzzwords.isNotEmpty || prep.questionsToAskInterviewer.isNotEmpty || prep.topLeetCodeTopics.isNotEmpty || prep.atsKeywordsToInject.isNotEmpty;

        return _buildClaySection(
          title: '🎯 INTERVIEW CHEAT SHEET & ATS OPTIMIZER',
          children: [
            // Feature 4: ATS Resume Keywords Card
            if (prep.atsKeywordsToInject.isNotEmpty) ...[
              const Text(
                '📝 High-Frequency ATS Keywords (Paste in Resume):',
                style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: Color(0xFF4F46E5)),
              ),
              const SizedBox(height: 6),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: prep.atsKeywordsToInject
                    .map((k) => _buildChip('📌 $k', const Color(0xFFEEF2FF), const Color(0xFF3730A3)))
                    .toList(),
              ),
              const SizedBox(height: 4),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: prep.atsKeywordsToInject.join(', ')));
                    showGlassSnackBar(context, message: 'ATS keywords copied to clipboard!');
                  },
                  icon: const Icon(Icons.copy_rounded, size: 13, color: Color(0xFF4F46E5)),
                  label: const Text('Copy All Keywords', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF4F46E5))),
                ),
              ),
              const SizedBox(height: 12),
            ],

            if (prep.whyUsScript.isNotEmpty) ...[
              const Text(
                '💡 Custom "Why Us?" Script:',
                style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: Color(0xFFB45309)),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF3C7),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '"${prep.whyUsScript}"',
                  style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic, color: Color(0xFF7C4A03), height: 1.4),
                ),
              ),
              const SizedBox(height: 12),
            ],

            if (prep.topLeetCodeTopics.isNotEmpty) ...[
              Text(
                '💻 Top LeetCode & Technical Topics Asked:',
                style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: VelvetColors.textPrimary(context)),
              ),
              const SizedBox(height: 6),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: prep.topLeetCodeTopics
                    .map((t) => _buildChip('⚡ $t', const Color(0xFFEEF2FF), const Color(0xFF3730A3)))
                    .toList(),
              ),
              const SizedBox(height: 12),
            ],

            if (prep.keyJdBuzzwords.isNotEmpty) ...[
              Text(
                '🔑 Key JD Buzzwords to Drop:',
                style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: VelvetColors.textPrimary(context)),
              ),
              const SizedBox(height: 6),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: prep.keyJdBuzzwords
                    .map((w) => _buildChip('`$w`', VelvetColors.coralPeach.withValues(alpha: 0.15), VelvetColors.textPrimary(context)))
                    .toList(),
              ),
              const SizedBox(height: 12),
            ],

            if (prep.typicalInterviewRounds.isNotEmpty) ...[
              Text('🔄 Typical Interview Rounds:', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: VelvetColors.textPrimary(context))),
              const SizedBox(height: 6),
              ...prep.typicalInterviewRounds.asMap().entries.map((e) => Padding(
                padding: const EdgeInsets.only(bottom: 5),
                child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Container(
                    width: 18, height: 18, margin: const EdgeInsets.only(right: 8),
                    decoration: const BoxDecoration(color: VelvetColors.coralPeach, shape: BoxShape.circle),
                    child: Center(child: Text('${e.key + 1}', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white))),
                  ),
                  Expanded(child: Text(e.value, style: TextStyle(fontSize: 12, color: VelvetColors.textPrimary(context), height: 1.35))),
                ]),
              )),
              const SizedBox(height: 12),
            ],

            if (prep.questionsToAskInterviewer.isNotEmpty) ...[
              Text(
                '❓ Smart Questions to Ask Interviewer:',
                style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: VelvetColors.textPrimary(context)),
              ),
              const SizedBox(height: 6),
              ...prep.questionsToAskInterviewer.map(
                (q) => Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('• ', style: TextStyle(fontWeight: FontWeight.bold, color: VelvetColors.coralPeach)),
                      Expanded(
                        child: Text(q, style: TextStyle(fontSize: 12, color: VelvetColors.textPrimary(context), height: 1.35)),
                      ),
                    ],
                  ),
                ),
              ),
            ],

            if (prep.potentialRedFlags.isNotEmpty) ...[
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.amber.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.amber, width: 1),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.warning_amber_rounded, size: 16, color: Colors.amber),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        prep.potentialRedFlags,
                        style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: Color(0xFF78350F)),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            if (!hasPrep) ...[
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 12.0),
                child: Text(
                  'Upload a Job Description to generate tailored interview questions and keywords.',
                  style: TextStyle(fontSize: 12, color: Colors.grey, fontStyle: FontStyle.italic),
                ),
              ),
            ],

            // Company-Specific Practice Questions
            if (_dossier!.mockInterviewQuestions.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                '🎯 Company-Specific Practice Questions:',
                style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: VelvetColors.textPrimary(context)),
              ),
              const SizedBox(height: 6),
              ..._dossier!.mockInterviewQuestions.asMap().entries.map(
                (entry) => Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: VelvetColors.cardSurface(context),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: VelvetColors.border(context)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: const BoxDecoration(
                          color: VelvetColors.coralPeach,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          'Q${entry.key + 1}',
                          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          entry.value,
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: VelvetColors.textPrimary(context), height: 1.35),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        );

      case 4: // Negotiation & Practice Emails
      default:
        return _buildClaySection(
          title: '🗣️ COUNTER-OFFER, FOLLOW-UP EMAILS & AI MOCK INTERVIEW',
          children: [
            // Feature 5: Follow-Up & Negotiation Email Templates
            if (_dossier!.salaryNegotiationScript.isNotEmpty) ...[
              _buildEmailCard('💰 Salary Negotiation Counter-Offer Email:', _dossier!.salaryNegotiationScript, const Color(0xFF047857), const Color(0xFFECFDF5), const Color(0xFFA7F3D0)),
              const SizedBox(height: 12),
            ],
            if (_dossier!.followUpThankYouEmail.isNotEmpty) ...[
              _buildEmailCard('💌 Post-Interview Thank You Note:', _dossier!.followUpThankYouEmail, const Color(0xFF4338CA), const Color(0xFFEEF2FF), const Color(0xFFC7D2FE)),
              const SizedBox(height: 12),
            ],
            if (_dossier!.followUpStatusCheckEmail.isNotEmpty) ...[
              _buildEmailCard('⏳ 5-Day Application Status Check-in Email:', _dossier!.followUpStatusCheckEmail, const Color(0xFFB45309), const Color(0xFFFEF3C7), const Color(0xFFFDE68A)),
              const SizedBox(height: 12),
            ],
            if (_dossier!.followUpCompetingOfferEmail.isNotEmpty) ...[
              _buildEmailCard('⚡ Competing Offer Leverage Email:', _dossier!.followUpCompetingOfferEmail, const Color(0xFFBE185D), const Color(0xFFFCE7F3), const Color(0xFFFBCFE8)),
              const SizedBox(height: 16),
            ],
          ],
        );
    }
  }

  Widget _buildEmailCard(String title, String content, Color titleColor, Color bg, Color border) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: titleColor)),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SelectableText(
                content,
                style: TextStyle(fontSize: 11.5, color: titleColor.withValues(alpha: 0.9), height: 1.4),
              ),
              const SizedBox(height: 6),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: content));
                    showGlassSnackBar(context, message: 'Email template copied to clipboard!');
                  },
                  icon: Icon(Icons.copy_rounded, size: 13, color: titleColor),
                  label: Text('Copy Email', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: titleColor)),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildClaySection({required String title, required List<Widget> children}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: VelvetColors.cardSurface(context),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: VelvetColors.border(context), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontFamily: GoogleFonts.outfit().fontFamily,
              fontSize: 10.5,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.5,
              color: VelvetColors.textSecondary(context),
            ),
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  Widget _buildDetailTile(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: VelvetColors.coralPeach),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: VelvetColors.textSecondary(context))),
                const SizedBox(height: 2),
                Text(value, style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: VelvetColors.textPrimary(context), height: 1.35)),
              ],
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildChip(String text, Color bg, Color textClr) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: textClr),
      ),
    );
  }
}
